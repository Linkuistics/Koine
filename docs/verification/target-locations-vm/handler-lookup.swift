import AppKit

// Disposable (target-locations-vm, k180). What the platform's own default-handler lookup answers for
// links of a chain, asked exactly as Koine's native adapter asks it for the caller's literal path:
// NSWorkspace.urlForApplication(toOpen:). It is compiled and run in the guest by
// scripts/vm-verify-target-locations.sh (section `platform`); nothing here is Koine.
//
//   handler-lookup <directory holding w32-1.txt ... w32-32.txt>
//
// w32-N.txt is the Nth link of a chain of 32 links to w32-target.txt, so it is a chain of N links.
let directory = CommandLine.arguments[1]
for links in [1, 5, 9, 10, 11, 12, 16, 20, 31, 32] {
    let path = "\(directory)/w32-\(links).txt"
    let handler = NSWorkspace.shared.urlForApplication(toOpen: URL(fileURLWithPath: path))
    print(links, handler?.lastPathComponent ?? "nil")
}
