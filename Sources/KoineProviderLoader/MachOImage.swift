import Foundation

/// What the loader reads from a provider binary without loading it: dylib
/// initializers run inside `dlopen`, so every check that can refuse a bundle
/// reads the file's bytes. Layouts are those of `<mach-o/loader.h>`,
/// `<mach-o/fat.h>` and `<mach-o/nlist.h>`.
struct MachOImage {
    struct Malformed: Error {
        let reason: String
    }

    struct Version: Comparable, CustomStringConvertible {
        let components: [Int]

        /// Dotted decimal, one to three components.
        init?(_ text: String) {
            let parts = text.split(separator: ".", omittingEmptySubsequences: false)
            guard (1...3).contains(parts.count) else { return nil }
            var components: [Int] = []
            for part in parts {
                guard !part.isEmpty, part.allSatisfy(\.isASCII), part.allSatisfy(\.isNumber),
                    let number = Int(part)
                else { return nil }
                components.append(number)
            }
            self.components = components
        }

        init(_ components: [Int]) { self.components = components }

        static func < (left: Version, right: Version) -> Bool {
            left.padded.lexicographicallyPrecedes(right.padded)
        }

        static func == (left: Version, right: Version) -> Bool { left.padded == right.padded }

        private var padded: [Int] { components + Array(repeating: 0, count: 3 - components.count) }

        var description: String { components.map(String.init).joined(separator: ".") }
    }

    struct Slice {
        let architecture: String
        /// Every dylib the image names, whatever the kind of load command.
        let dependencies: [String]
        let runPaths: [String]
        let minimumOS: Version?
        let definedExternalSymbols: Set<String>
    }

    let slices: [Slice]

    init(contentsOf url: URL) throws {
        let data: Data
        do { data = try Data(contentsOf: url, options: .mappedIfSafe) } catch {
            throw Malformed(reason: "it cannot be read")
        }
        let reader = Reader(data: data)
        switch try reader.uint32(at: 0, bigEndian: true) {
        case 0xcafe_babe:
            slices = try (0..<Int(try reader.uint32(at: 4, bigEndian: true))).map { index in
                let entry = 8 + index * 20
                return try Slice(
                    reader,
                    offset: Int(try reader.uint32(at: entry + 8, bigEndian: true)),
                    size: Int(try reader.uint32(at: entry + 12, bigEndian: true))
                )
            }
        case 0xcafe_babf:
            slices = try (0..<Int(try reader.uint32(at: 4, bigEndian: true))).map { index in
                let entry = 8 + index * 32
                return try Slice(
                    reader,
                    offset: Int(clamping: try reader.uint64(at: entry + 8, bigEndian: true)),
                    size: Int(clamping: try reader.uint64(at: entry + 16, bigEndian: true))
                )
            }
        default:
            slices = [try Slice(reader, offset: 0, size: data.count)]
        }
        guard !slices.isEmpty else { throw Malformed(reason: "it holds no architecture") }
    }
}

extension MachOImage.Slice {
    private static let requiredByDyld: UInt32 = 0x8000_0000
    private static let dylibCommands: Set<UInt32> = [
        0xc,  // LC_LOAD_DYLIB
        0x18 | requiredByDyld,  // LC_LOAD_WEAK_DYLIB
        0x1f | requiredByDyld,  // LC_REEXPORT_DYLIB
        0x20,  // LC_LAZY_LOAD_DYLIB
        0x23 | requiredByDyld,  // LC_LOAD_UPWARD_DYLIB
    ]

    fileprivate init(_ file: Reader, offset: Int, size: Int) throws {
        let reader = try file.slice(offset: offset, size: size)
        // 64-bit little-endian is every architecture Koine runs on.
        guard try reader.uint32(at: 0) == 0xfeed_facf else {
            throw MachOImage.Malformed(reason: "it is not a 64-bit Mach-O image")
        }
        switch try reader.uint32(at: 4) {
        // CPU_SUBTYPE_ARM64E is its own architecture: dyld chooses between the
        // two slices, so the one validated must be the one named.
        case 0x0100_000c:
            architecture = try reader.uint32(at: 8) & 0x00ff_ffff == 2 ? "arm64e" : "arm64"
        case 0x0100_0007: architecture = "x86_64"
        case let other: architecture = "cpu-\(other)"
        }
        // MH_DYLIB or MH_BUNDLE: the two kinds dlopen loads.
        guard [6, 8].contains(try reader.uint32(at: 12)) else {
            throw MachOImage.Malformed(reason: "it is not a loadable library")
        }

        var dependencies: [String] = []
        var runPaths: [String] = []
        var minimumOS: MachOImage.Version?
        var symbols: Set<String> = []
        var command = 32
        for _ in 0..<(try reader.uint32(at: 16)) {
            let kind = try reader.uint32(at: command)
            let length = Int(try reader.uint32(at: command + 4))
            guard length >= 8 else {
                throw MachOImage.Malformed(reason: "a load command is truncated")
            }
            if Self.dylibCommands.contains(kind) {
                dependencies.append(try reader.string(inCommandAt: command, length: length))
            } else if kind == 0x1c | Self.requiredByDyld {  // LC_RPATH
                runPaths.append(try reader.string(inCommandAt: command, length: length))
            } else if kind == 0x32 {  // LC_BUILD_VERSION: minos is xxxx.yy.zz
                minimumOS = Self.version(try reader.uint32(at: command + 12))
            } else if kind == 0x24 {  // LC_VERSION_MIN_MACOSX
                minimumOS = Self.version(try reader.uint32(at: command + 8))
            } else if kind == 0x2 {  // LC_SYMTAB
                symbols = try reader.definedExternalSymbols(
                    tableAt: Int(try reader.uint32(at: command + 8)),
                    count: Int(try reader.uint32(at: command + 12)),
                    stringsAt: Int(try reader.uint32(at: command + 16)),
                    stringsSize: Int(try reader.uint32(at: command + 20))
                )
            }
            command += length
        }
        self.dependencies = dependencies
        self.runPaths = runPaths
        self.minimumOS = minimumOS
        definedExternalSymbols = symbols
    }

    private static func version(_ packed: UInt32) -> MachOImage.Version {
        MachOImage.Version([Int(packed >> 16), Int((packed >> 8) & 0xff), Int(packed & 0xff)])
    }
}

/// Bounds-checked reads: the file is untrusted until it has passed.
private struct Reader {
    let data: Data

    func slice(offset: Int, size: Int) throws -> Reader {
        guard offset >= 0, size >= 0, offset <= data.count, size <= data.count - offset else {
            throw MachOImage.Malformed(reason: "an architecture lies outside the file")
        }
        let start = data.startIndex + offset
        return Reader(data: data[start..<(start + size)])
    }

    private func bytes(at offset: Int, count: Int) throws -> Data {
        guard offset >= 0, count >= 0, offset <= data.count, count <= data.count - offset else {
            throw MachOImage.Malformed(reason: "it is truncated")
        }
        let start = data.startIndex + offset
        return data[start..<(start + count)]
    }

    func uint32(at offset: Int, bigEndian: Bool = false) throws -> UInt32 {
        let value = try bytes(at: offset, count: 4).reduce(UInt32(0)) { $0 << 8 | UInt32($1) }
        return bigEndian ? value : value.byteSwapped
    }

    func uint64(at offset: Int, bigEndian: Bool = false) throws -> UInt64 {
        let value = try bytes(at: offset, count: 8).reduce(UInt64(0)) { $0 << 8 | UInt64($1) }
        return bigEndian ? value : value.byteSwapped
    }

    /// The string a dylib or rpath command carries: its offset is the
    /// command's third word, and it ends at a NUL or the command's end.
    func string(inCommandAt command: Int, length: Int) throws -> String {
        let offset = Int(try uint32(at: command + 8))
        guard offset >= 12, offset < length else {
            throw MachOImage.Malformed(reason: "a load command's name lies outside it")
        }
        let raw = try bytes(at: command + offset, count: length - offset)
        return String(decoding: raw.prefix { $0 != 0 }, as: UTF8.self)
    }

    func definedExternalSymbols(
        tableAt table: Int, count: Int, stringsAt strings: Int, stringsSize: Int
    ) throws -> Set<String> {
        let names = try bytes(at: strings, count: stringsSize)
        var symbols: Set<String> = []
        for index in 0..<count {
            let entry = try bytes(at: table + index * 16, count: 16)
            let type = entry[entry.startIndex + 4]
            // Not a debugging entry, external, and defined in a section.
            guard type & 0xe0 == 0, type & 0x01 != 0, type & 0x0e == 0x0e else { continue }
            let nameOffset = Int(try uint32(at: table + index * 16))
            guard nameOffset < names.count else {
                throw MachOImage.Malformed(reason: "a symbol's name lies outside the string table")
            }
            let name = names[(names.startIndex + nameOffset)...].prefix { $0 != 0 }
            symbols.insert(String(decoding: name, as: UTF8.self))
        }
        return symbols
    }
}
