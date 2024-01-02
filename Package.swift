// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftUIRingSlider",
  platforms: [
    .iOS(.v17),
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "SwiftUIRingSlider",
      targets: ["SwiftUIRingSlider"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/siteline/swiftui-introspect", from: "1.1.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "SwiftUIRingSlider",
      dependencies: [
        .product(name: "SwiftUIIntrospect", package: "swiftui-introspect"),]
    ),
    .testTarget(
      name: "SwiftUIRingSliderTests",
      dependencies: ["SwiftUIRingSlider"]
    ),
  ]
)
