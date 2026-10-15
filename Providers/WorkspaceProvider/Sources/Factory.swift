import Foundation
import KoineProviderAPI

// build.sh generates `workspaceSchemaSDL` from schema.graphql.

@objc(KoineWorkspaceProviderFactory)
final class WorkspaceProviderFactory: NSObject, ProviderFactory {
    override required init() { super.init() }

    var descriptor: ProviderDescriptor { workspaceDescriptor(schemaSDL: workspaceSchemaSDL) }

    func makeProvider() -> any Provider { WorkspaceProvider(native: NativeWorkspace()) }
}
