import Foundation
import KoineServer

/// A running server over a throwaway data directory, plus the client's view of
/// it: everything a client knows comes from the published descriptor.
final class Harness {
    let directory: URL
    private(set) var server: KoineServer

    init() async throws {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("koine-tests-\(UUID().uuidString)", isDirectory: true)
        server = try KoineServer(dataDirectory: directory)
        try await server.start()
    }

    deinit { try? FileManager.default.removeItem(at: directory) }

    func restart() async throws {
        await server.stop()
        server = try KoineServer(dataDirectory: directory)
        try await server.start()
    }

    func stop() async { await server.stop() }

    var descriptorURL: URL { directory.appendingPathComponent("endpoint.json") }

    func descriptor() throws -> [String: Any] {
        try JSONSerialization.jsonObject(with: Data(contentsOf: descriptorURL)) as! [String: Any]
    }

    /// Bootstraps a grant through the in-process console and returns its credential.
    func consoleGrant(label: String, capabilities: [String]) async throws -> String {
        let body = try Self.requestBody(
            Self.createGrant, variables: ["label": label, "capabilities": capabilities]
        )
        let response = try JSONSerialization.jsonObject(
            with: try await server.console.execute(jsonBody: body)
        ) as! [String: Any]
        let created = (response["data"] as! [String: Any])["koineCreateGrant"] as! [String: Any]
        return created["credential"] as! String
    }

    struct Reply {
        let status: Int
        let headers: [AnyHashable: Any]
        let json: [String: Any]

        var data: [String: Any]? { json["data"] as? [String: Any] }
        var errors: [[String: Any]] { json["errors"] as? [[String: Any]] ?? [] }
    }

    /// POSTs to the endpoint the descriptor names, as a client would.
    func post(
        _ query: String, variables: [String: Any] = [:], authorization: String?,
        host: String = "127.0.0.1"
    ) async throws -> Reply {
        let descriptor = try descriptor()
        let url = URL(string: "http://\(host):\(descriptor["port"]!)\(descriptor["path"]!)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try Self.requestBody(query, variables: variables)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/graphql-response+json", forHTTPHeaderField: "Accept")
        if let authorization {
            request.setValue(authorization, forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await URLSession(configuration: .ephemeral).data(for: request)
        let http = response as! HTTPURLResponse
        let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
        return Reply(status: http.statusCode, headers: http.allHeaderFields, json: json)
    }

    static func requestBody(_ query: String, variables: [String: Any]) throws -> Data {
        try JSONSerialization.data(withJSONObject: ["query": query, "variables": variables])
    }

    static let createGrant = """
        mutation Create($label: String!, $capabilities: [String!]!) {
          koineCreateGrant(input: { clientLabel: $label, capabilities: $capabilities }) {
            credential
            grant { grantId clientLabel capabilities state }
          }
        }
        """

    static let koine = """
        { koine { contractVersion instanceId schemaDigest availableCapabilities
                  ownGrant { grantId clientLabel capabilities state } } }
        """

    /// graphql-js `getIntrospectionQuery()` with descriptions, the query
    /// standard code generators send.
    static let introspection = """
        query IntrospectionQuery {
          __schema {
            description
            queryType { name } mutationType { name } subscriptionType { name }
            types { ...FullType }
            directives { name description locations args { ...InputValue } }
          }
        }
        fragment FullType on __Type {
          kind name description
          fields(includeDeprecated: true) {
            name description args { ...InputValue } type { ...TypeRef }
            isDeprecated deprecationReason
          }
          inputFields { ...InputValue }
          interfaces { ...TypeRef }
          enumValues(includeDeprecated: true) { name description isDeprecated deprecationReason }
          possibleTypes { ...TypeRef }
        }
        fragment InputValue on __InputValue {
          name description type { ...TypeRef } defaultValue
        }
        fragment TypeRef on __Type {
          kind name ofType { kind name ofType { kind name ofType { kind name ofType {
            kind name ofType { kind name ofType { kind name ofType { kind name } } } } } } }
        }
        """
}
