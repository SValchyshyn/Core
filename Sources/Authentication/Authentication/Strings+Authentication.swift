// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum AuthenticationStrings {
  /// Go To Settings
  public static let authScannerCameraPermissionGoToSettings = AuthenticationStrings.tr("Authentication", "auth_scanner_camera_permission_go_to_settings")
  /// The camera is used to scan your loyalty card information
  public static let authScannerCameraPermissionText = AuthenticationStrings.tr("Authentication", "auth_scanner_camera_permission_text")
  /// Scan your loyalty card
  public static let authScannerScanDescription = AuthenticationStrings.tr("Authentication", "auth_scanner_scan_description")
  /// Sign Up
  public static let authScannerScreenTitle = AuthenticationStrings.tr("Authentication", "auth_scanner_screen_title")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension AuthenticationStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
	let format = Bundle.module.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
