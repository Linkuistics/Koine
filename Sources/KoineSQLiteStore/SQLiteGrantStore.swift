import Foundation
import GRDB
import KoineCore

/// The durable grant database, one SQLite file. Writes are single transactions
/// committed with full synchronisation; any read or decode failure throws, so
/// an unreadable or corrupt store refuses rather than yielding authority.
public final class SQLiteGrantStore: GrantStore {
    private let queue: DatabaseQueue

    /// Opens or creates the store. The file is user-only (0600).
    public init(path: String) throws {
        if !FileManager.default.fileExists(atPath: path) {
            guard FileManager.default.createFile(
                atPath: path, contents: nil, attributes: [.posixPermissions: 0o600]
            ) else { throw CocoaError(.fileWriteUnknown) }
        }
        var configuration = Configuration()
        configuration.prepareDatabase { db in
            // A commit returns only once it is on stable storage. macOS needs
            // fullfsync for that: https://www.sqlite.org/pragma.html#pragma_fullfsync
            try db.execute(sql: "PRAGMA synchronous = FULL")
            try db.execute(sql: "PRAGMA fullfsync = ON")
        }
        queue = try DatabaseQueue(path: path, configuration: configuration)

        var migrator = DatabaseMigrator()
        migrator.registerMigration("grants-1") { db in
            try db.execute(sql: """
                CREATE TABLE grants (
                    id TEXT PRIMARY KEY NOT NULL,
                    client_label TEXT NOT NULL,
                    capabilities TEXT NOT NULL,
                    credential_digest TEXT NOT NULL UNIQUE,
                    state TEXT NOT NULL
                ) STRICT
                """)
        }
        migrator.registerMigration("grant-requests-1") { db in
            try db.execute(sql: """
                CREATE TABLE grant_requests (
                    id TEXT PRIMARY KEY NOT NULL,
                    client_label TEXT NOT NULL,
                    capabilities TEXT NOT NULL,
                    credential_digest TEXT NOT NULL UNIQUE,
                    comparison_code TEXT NOT NULL,
                    state TEXT NOT NULL,
                    grant_id TEXT REFERENCES grants(id)
                ) STRICT
                """)
        }
        try migrator.migrate(queue)
    }

    public func insert(_ grant: GrantRecord) throws {
        try uniquely {
            try queue.write { db in
                try Self.requireUnused(grant.credentialDigest, in: "grant_requests", db)
                try Self.insert(grant, into: db)
            }
        }
    }

    /// Each table's own digests are unique by constraint. Uniqueness across the
    /// two is checked here, inside the inserting transaction. Approval alone
    /// skips it: its grant takes the digest of the request it comes from.
    private static func requireUnused(_ digest: String, in table: String, _ db: Database) throws {
        let taken = try Bool.fetchOne(
            db, sql: "SELECT EXISTS (SELECT 1 FROM \(table) WHERE credential_digest = ?)",
            arguments: [digest]
        )
        if taken != false { throw GrantStoreError.duplicateDigest }
    }

    private static func insert(_ grant: GrantRecord, into db: Database) throws {
        try db.execute(
            sql: "INSERT INTO grants VALUES (?, ?, ?, ?, ?)",
            arguments: [
                grant.id, grant.clientLabel, try json(grant.capabilities),
                grant.credentialDigest, grant.state.rawValue,
            ]
        )
    }

    private static func json(_ capabilities: [String]) throws -> String {
        String(decoding: try JSONEncoder().encode(capabilities), as: UTF8.self)
    }

    private func uniquely<T>(_ write: () throws -> T) throws -> T {
        do { return try write() } catch let error as DatabaseError
            where error.extendedResultCode == .SQLITE_CONSTRAINT_UNIQUE
        {
            throw GrantStoreError.duplicateDigest
        }
    }

    public func insertRequest(_ request: GrantRequestRecord) throws {
        try uniquely {
            try queue.write { db in
                try Self.requireUnused(request.credentialDigest, in: "grants", db)
                try db.execute(
                    sql: "INSERT INTO grant_requests VALUES (?, ?, ?, ?, ?, ?, ?)",
                    arguments: [
                        request.id, request.clientLabel, try Self.json(request.requestedCapabilities),
                        request.credentialDigest, request.comparisonCode, request.state.rawValue,
                        request.grantId,
                    ]
                )
            }
        }
    }

    public func requests() throws -> [GrantRequestRecord] {
        try queue.read { db in
            try Row.fetchAll(db, sql: "SELECT * FROM grant_requests ORDER BY rowid")
                .map(Self.request)
        }
    }

    public func request(id: String) throws -> GrantRequestRecord? {
        try queue.read { db in
            try Row.fetchOne(db, sql: "SELECT * FROM grant_requests WHERE id = ?", arguments: [id])
                .map(Self.request)
        }
    }

    public func approve(requestId: String, as grant: GrantRecord) throws -> Bool {
        // One transaction: a throw, such as the grants table refusing a digest
        // it already holds, rolls the request's state back with it.
        try uniquely {
            try queue.write { db in
                try db.execute(
                    sql: "UPDATE grant_requests SET state = ? WHERE id = ? AND state = ?",
                    arguments: [
                        GrantRequestState.approved.rawValue, requestId,
                        GrantRequestState.pending.rawValue,
                    ]
                )
                guard db.changesCount == 1 else { return false }
                try Self.insert(grant, into: db)
                try db.execute(
                    sql: "UPDATE grant_requests SET grant_id = ? WHERE id = ?",
                    arguments: [grant.id, requestId]
                )
                return true
            }
        }
    }

    public func deny(requestId: String) throws -> Bool {
        try queue.write { db in
            try db.execute(
                sql: "UPDATE grant_requests SET state = ? WHERE id = ? AND state = ?",
                arguments: [
                    GrantRequestState.denied.rawValue, requestId,
                    GrantRequestState.pending.rawValue,
                ]
            )
            return db.changesCount == 1
        }
    }

    public func grants() throws -> [GrantRecord] {
        try queue.read { db in
            try Row.fetchAll(db, sql: "SELECT * FROM grants ORDER BY rowid").map(Self.record)
        }
    }

    public func grant(id: String) throws -> GrantRecord? {
        try queue.read { db in
            try Row.fetchOne(db, sql: "SELECT * FROM grants WHERE id = ?", arguments: [id])
                .map(Self.record)
        }
    }

    public func revoke(id: String) throws -> GrantRecord? {
        // One transaction: the state written is the state returned.
        try queue.write { db in
            try db.execute(
                sql: "UPDATE grants SET state = ? WHERE id = ?",
                arguments: [GrantState.revoked.rawValue, id]
            )
            return try Row.fetchOne(db, sql: "SELECT * FROM grants WHERE id = ?", arguments: [id])
                .map(Self.record)
        }
    }

    private struct CorruptRecord: Error {}

    private static func request(_ row: Row) throws -> GrantRequestRecord {
        let capabilities: String = row["capabilities"]
        guard let state = GrantRequestState(rawValue: row["state"]) else { throw CorruptRecord() }
        return GrantRequestRecord(
            id: row["id"],
            clientLabel: row["client_label"],
            requestedCapabilities: try JSONDecoder().decode(
                [String].self, from: Data(capabilities.utf8)
            ),
            credentialDigest: row["credential_digest"],
            comparisonCode: row["comparison_code"],
            state: state,
            grantId: row["grant_id"]
        )
    }

    private static func record(_ row: Row) throws -> GrantRecord {
        let capabilities: String = row["capabilities"]
        guard let state = GrantState(rawValue: row["state"]) else { throw CorruptRecord() }
        return GrantRecord(
            id: row["id"],
            clientLabel: row["client_label"],
            capabilities: try JSONDecoder().decode([String].self, from: Data(capabilities.utf8)),
            credentialDigest: row["credential_digest"],
            state: state
        )
    }
}
