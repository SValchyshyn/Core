// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum CoopCoreStrings {
  /// Approve
  public static let biometricAuthPromptTitle = CoopCoreStrings.tr("Biometric", "biometric_auth_prompt_title")
  /// Use PIN code
  public static let biometricAuthUsePin = CoopCoreStrings.tr("Biometric", "biometric_auth_use_pin")
  /// Do you want to use Face ID from now on?
  public static let pevcFaceIdAlertMessage = CoopCoreStrings.tr("Biometric", "pevc_face_id_alert_message")
  /// Face ID
  public static let pevcFaceIdAlertTitle = CoopCoreStrings.tr("Biometric", "pevc_face_id_alert_title")
  /// Confirm payment with Face ID
  public static let pevcFaceReasonConfirm = CoopCoreStrings.tr("Biometric", "pevc_face_reason_confirm")
  /// Confirm using Face ID for payment
  public static let pevcFaceReasonUse = CoopCoreStrings.tr("Biometric", "pevc_face_reason_use")
  /// Do you want to use Touch ID from now on?
  public static let pevcTouchIdAlertMessage = CoopCoreStrings.tr("Biometric", "pevc_touch_id_alert_message")
  /// Touch id
  public static let pevcTouchIdAlertTitle = CoopCoreStrings.tr("Biometric", "pevc_touch_id_alert_title")
  /// Accept payment using touch id
  public static let pevcTouchReasonConfirm = CoopCoreStrings.tr("Biometric", "pevc_touch_reason_confirm")
  /// Confirm the usage of touch id for payments
  public static let pevcTouchReasonUse = CoopCoreStrings.tr("Biometric", "pevc_touch_reason_use")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension CoopCoreStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = Bundle.CoopCoreModule.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
