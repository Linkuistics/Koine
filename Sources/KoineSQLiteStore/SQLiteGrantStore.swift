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
        try migrator.migrate(queue)
    }

    public func insert(_ grant: GrantRecord) throws {
        let capabilities = String(
            decoding: try JSONEncoder().encode(grant.capabilities), as: UTF8.self
        )
        do {
            try queue.write { db in
                try db.execute(
                    sql: "INSERT INTO grants VALUES (?, ?, ?, ?, ?)",
                    arguments: [
                        grant.id, grant.clientLabel, capabilities,
                        grant.credentialDigest, grant.state.rawValue,
                    ]
                )
            }
        } catch let error as DatabaseError
            where error.extendedResultCode == .SQLITE_CONSTRAINT_UNIQUE
        {
            throw GrantStoreError.duplicateDigest
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

    private struct CorruptRecord: Error {}

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
