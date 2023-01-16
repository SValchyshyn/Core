// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
import Foundation

// MARK: - Swift Bundle Accessor

private class BundleFinder {}

// MARK: - Objective-C Bundle Accessor

@objc
public class CoreTestsResources: NSObject {
   @objc public class var bundle: Bundle {
         return .Core
   }
}
// swiftlint:enable all
// swiftformat:enable all
