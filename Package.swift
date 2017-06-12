// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "Solam",
    targets: [
        Target(
            name: "Solam",
            dependencies: ["ifaddrs"]),
        Target(
            name: "ifaddrs",
            dependencies: []),
    ],
    dependencies: [])


#if os(macOS)
package.dependencies = [
    .Package(url: "https://github.com/Anviking/Decodable.git", Version(0,5,1)),
    .Package(url: "https://github.com/JohnSundell/Files", Version(1,9,0))
]
#elseif os (Linux)
package.dependencies = [
    .Package(url: "https://github.com/JohnSundell/Files", Version(1,9,0))
]
#endif
