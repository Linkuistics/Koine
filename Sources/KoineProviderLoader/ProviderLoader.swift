import Foundation
import KoineProviderAPI

public enum ProviderLoadError: Error, Equatable {
    case unreadableManifest(String)
    case loadFailed(bundle: String, reason: String)
    case noPrincipalClass(bundle: String, name: String)
    case descriptorDisagrees(bundle: String)
}

/// A bundle's declarative manifest, `manifest.json`. Later stages add the
/// version, architecture and compatibility declarations the contract lists.
struct ProviderManifest: Decodable {
    let providerId: String
    let graphQLPrefix: String
    /// The Objective-C-visible name of the bundle's `ProviderFactory` class.
    let principalClass: String
    /// The dylib's file name within the bundle.
    let library: String
}

public struct LoadedProvider: Sendable {
    public let descriptor: ProviderDescriptor
    public let provider: any Provider
}

/// The native loader. It loads every `*.koineprovider` bundle directly inside a
/// root the host was configured with; it searches nowhere else. Verification
/// before `dlopen`, trust and status reporting are not here yet.
public enum ProviderLoader {
    public static let bundleExtension = "koineprovider"

    public static func loadProviders(in root: URL) throws -> [LoadedProvider] {
        let entries = try FileManager.default.contentsOfDirectory(
            at: root, includingPropertiesForKeys: nil
        )
        return try entries
            .filter { $0.pathExtension == bundleExtension }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
            .map(load)
    }

    private static func load(bundle: URL) throws -> LoadedProvider {
        let name = bundle.lastPathComponent
        let manifest: ProviderManifest
        do {
            manifest = try JSONDecoder().decode(
                ProviderManifest.self,
                from: Data(contentsOf: bundle.appendingPathComponent("manifest.json"))
            )
        } catch {
            throw ProviderLoadError.unreadableManifest(name)
        }
        // An absolute path: dlopen never searches for a provider. The image is
        // never closed; loaded providers stay mapped until process exit.
        let library = bundle.appendingPathComponent(manifest.library).path
        guard dlopen(library, RTLD_NOW | RTLD_LOCAL) != nil else {
            throw ProviderLoadError.loadFailed(
                bundle: name, reason: dlerror().map { String(cString: $0) } ?? "unknown"
            )
        }
        // https://developer.apple.com/documentation/foundation/nsclassfromstring(_:)
        guard let factoryType = NSClassFromString(manifest.principalClass) as? any ProviderFactory.Type
        else {
            throw ProviderLoadError.noPrincipalClass(bundle: name, name: manifest.principalClass)
        }
        let factory = factoryType.init()
        let descriptor = factory.descriptor
        guard descriptor.providerId == manifest.providerId,
            descriptor.graphQLPrefix == manifest.graphQLPrefix
        else {
            throw ProviderLoadError.descriptorDisagrees(bundle: name)
        }
        return LoadedProvider(descriptor: descriptor, provider: factory.makeProvider())
    }
}
