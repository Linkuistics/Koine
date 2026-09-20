/// The introspection request the conformance check makes.
///
/// It is the standard graphql-js introspection query, with one omission: the spec's
/// "Public GraphQL contract" promises that standard GraphQL code generation
/// consumes Koine's introspection, so the check asks the same question a code
/// generator asks rather than one shaped to Koine. It lives here so that the
/// guest-side capture and the in-package test send the same text — the script
/// writes it out with `KoineConformance --print-query`.
///
/// The omission is `isDeprecated` and `deprecationReason` on `__InputValue`,
/// which graphql-js adds only under its `inputValueDeprecation` option.
/// GraphQLSwift/GraphQL 4.2.0 declares `__InputValue.isDeprecated` non-null and
/// gives it no resolver, so asking for it answers "Cannot return null for
/// non-nullable field __InputValue.isDeprecated" and nulls the whole
/// `fields`/`inputFields` list. Asking would make every run fail for a reason
/// that is not Koine's schema. `SchemaConformanceTests` pins that behaviour, so
/// a library upgrade that fixes it is noticed here rather than forgotten.
///
/// Within the transport's limits (`RequestPolicy`): it nests 13 selections deep
/// against a bound of 16, and expands to about 185 field selections against a
/// bound of 1000.
public enum IntrospectionQuery {
    public static let text = """
        query IntrospectionQuery {
          __schema {
            description
            queryType { name }
            mutationType { name }
            subscriptionType { name }
            types { ...FullType }
            directives {
              name
              description
              isRepeatable
              locations
              args(includeDeprecated: true) { ...InputValue }
            }
          }
        }

        fragment FullType on __Type {
          kind
          name
          description
          specifiedByURL
          isOneOf
          fields(includeDeprecated: true) {
            name
            description
            args(includeDeprecated: true) { ...InputValue }
            type { ...TypeRef }
            isDeprecated
            deprecationReason
          }
          inputFields(includeDeprecated: true) { ...InputValue }
          interfaces { ...TypeRef }
          enumValues(includeDeprecated: true) {
            name
            description
            isDeprecated
            deprecationReason
          }
          possibleTypes { ...TypeRef }
        }

        fragment InputValue on __InputValue {
          name
          description
          type { ...TypeRef }
          defaultValue
        }

        fragment TypeRef on __Type {
          kind
          name
          ofType {
            kind
            name
            ofType {
              kind
              name
              ofType {
                kind
                name
                ofType {
                  kind
                  name
                  ofType {
                    kind
                    name
                    ofType {
                      kind
                      name
                    }
                  }
                }
              }
            }
          }
        }
        """
}
