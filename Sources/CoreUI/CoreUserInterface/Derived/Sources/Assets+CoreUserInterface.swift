// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum CoreUserInterfaceAsset {
  public static let btnPlay = CoreUserInterfaceImages(name: "btn_play")
  public static let checkmark = CoreUserInterfaceImages(name: "checkmark")
  public static let divider = CoreUserInterfaceImages(name: "divider")
  public static let gfxCloseDark = CoreUserInterfaceImages(name: "gfx-close-dark")
  public static let gfxClose = CoreUserInterfaceImages(name: "gfx-close")
  public static let gfxBack = CoreUserInterfaceImages(name: "gfx_back")
  public static let gfxBackDark = CoreUserInterfaceImages(name: "gfx_back_dark")
  public static let gfxOval = CoreUserInterfaceImages(name: "gfx_oval")
  public static let gfxPaymentDot = CoreUserInterfaceImages(name: "gfx_payment_dot")
  public static let notificationsPrepermissionAlertImg = CoreUserInterfaceImages(name: "notifications_prepermission_alert_img")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public struct CoreUserInterfaceImages {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  public var image: Image {
	  let bundle = Bundle.CoreUIModule
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
}

public extension CoreUserInterfaceImages.Image {
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the CoreUserInterfaceImages.image property")
  convenience init?(asset: CoreUserInterfaceImages) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle.CoreUIModule
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

// swiftlint:enable all
// swiftformat:enable all
