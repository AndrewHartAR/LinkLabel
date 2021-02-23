// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Kingfisher",
    platforms: [.iOS(.v10)],
    products: [
        .library(name: "LinkLabel", targets: ["LinkLabel"])
    ],
    targets: [
        .target(
            name: "LinkLabel",
            path: "Source"
        )
    ]
)
