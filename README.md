<img src="https://img.shields.io/badge/SwiftNIO-Swift-FA7343.svg?logo=swift&style=plastic">

# Swift INDIClient
This is a client implementation of the [INDI Library](https://indilib.org/), an open-source software for controlling astronomical instruments,
written in Swift. Because it uses the Swift standard library and the SwiftNIO framework for network communication,
it may be possible to use it on Linux or Windows, but I have not confirmed this.

## Getting Started
Swift INDIClient primarily uses SwiftPM as its build tool, so we recommend using that as well. If you want to depend on Swift INDIClient in you own project,
it's as simple as adding a dependencies clause to your Package.swift:
```
dependencies: [
  .package(url: "https://github.com/ykimura1970/swift-indiclient.git", from: "2.0.0")
]
```
and then adding the appropriate Swift INDIClient module to your target dependencies. The syntax for adding target dependencies differs slightly between Swift versions.
For example, specify the following dependencies:
```
dependencies: [
  .product(name: "INDIClient", package: "swift-indiclient")
]
```

## Using Xcode Package support
If your project is set up as an Xcode project and you're using Xcode 16+, you can add Swift INDIClient as a dependency to your Xcode project by clicking File -> Swift Packages
 -> Add Package Dependency. In the upcoming dialog, please enter `https://github.com/ykimura1970/swift-indiclient.git` and click Next twice. finally select the targets
you are planning to use and clock finish. Now will be able to import INDIClient in your project.
