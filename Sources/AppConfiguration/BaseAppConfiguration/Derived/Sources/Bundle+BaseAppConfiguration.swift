// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
import Foundation

// MARK: - Swift Bundle Accessor

private class BundleFinder {}

extension Foundation.Bundle {
    /// Since BaseAppConfiguration is a framework, the bundle containing the resources is copied into the final product.
    static var BaseAppConfiguration: Bundle = {
        return Bundle(for: BundleFinder.self)
    }()
}

// MARK: - Objective-C Bundle Accessor

//@objc
//public class BaseAppConfigurationResources: NSObject {
//   @objc public class var bundle: Bundle {
//         return .module
//   }
//}
// swiftlint:enable all
// swiftformat:enable all
