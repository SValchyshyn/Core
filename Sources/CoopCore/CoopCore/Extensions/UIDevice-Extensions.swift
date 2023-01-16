import UIKit
import LocalAuthentication
import AudioToolbox
import CoreHaptics

public extension UIDevice {
	enum BiometryType {
		case faceID, touchID, none
	}

	var supportedBiometryType: BiometryType {
		let context = LAContext()

		if context.canEvaluatePolicy( .deviceOwnerAuthenticationWithBiometrics, error: nil ) {
			switch context.biometryType {
			case .faceID:
				return .faceID

			case .touchID:
				return .touchID

			case .none:
				// The none case is the default value of the `biometryType` - when we call `canEvaluatePolicy` and it returns true, this can not be `none` anymore, however, we handle the case anyway.
				return .none

			@unknown default:
				return .none
			}
		} else {
			return .none
		}
	}

	var supportsHapticFeedback: Bool {
		return CHHapticEngine.capabilitiesForHardware().supportsHaptics
	}

	var supports3DTouch: Bool {
		return UIApplication.currentKeyWindow?.rootViewController?.view.traitCollection.forceTouchCapability == .available
	}

	// swiftlint:disable type_name 
	private struct iPhoneModels {
		static let iPhone6 = "iPhone8,1"
		static let iPhone6Plus = "iPhone8,2"
	}

	enum FeedbackType: Int {
		case success, warning, error

		@available(iOS 10.0, *)
		var feedbackType: UINotificationFeedbackGenerator.FeedbackType {
			switch self {
			case .success:
				return .success

			case .warning:
				return .warning

			case .error:
				return .error
			}
		}
	}

	/**
	Plays the corresponding `UINotificationFeedbackType` immediately. If the current device's  haptic feedback engine is unavailable and the `defaultToVibrate` flag is passed as true, this method will use the deafult vibration in the phone.

	- parameters:
	- type: The type of feedback to play. Each type corresponds to one of the `UINotificationFeedbackType` cases
	- defaultToVibrate: Pass `true` in order to make the phone vibrate normally, if the haptic feedback engine is unavailable. Default is true.
	*/
	func playFeedback( type: FeedbackType, defaultToVibrate: Bool = true ) {
		// Check if the device supports haptic feedback
		if supportsHapticFeedback {
			// Use the taptic engine on supported iOS 10 devices
			let successFeedbackGenerator = UINotificationFeedbackGenerator()
			successFeedbackGenerator.notificationOccurred( type.feedbackType )
		} else if defaultToVibrate {
			// Otherwise just use the vibration
			vibrate()
		}
	}
	
	/// Invoke a brief vibration immediately.
	func vibrate() {
		AudioServicesPlaySystemSound( kSystemSoundID_Vibrate )
	}

	/**
	Return a descriptive name for a iPhone model based on the device modelName

	- parameter identifier:		The device modelName which we want translated to descriptive text
	*/
	// swiftlint:disable:next cyclomatic_complexity
	func modelDescription( identifier: String ) -> String {
		#if os(iOS)
		switch identifier {
		case "iPod5,1":                                  return "iPod Touch 5"
		case "iPod7,1":                                  return "iPod Touch 6"
		case "iPhone3,1", "iPhone3,2", "iPhone3,3":      return "iPhone 4"
		case "iPhone4,1":                                return "iPhone 4s"
		case "iPhone5,1", "iPhone5,2":                   return "iPhone 5"
		case "iPhone5,3", "iPhone5,4":                   return "iPhone 5c"
		case "iPhone6,1", "iPhone6,2":                   return "iPhone 5s"
		case "iPhone7,2":                                return "iPhone 6"
		case "iPhone7,1":                                return "iPhone 6 Plus"
		case "iPhone8,1":                                return "iPhone 6s"
		case "iPhone8,2":                                return "iPhone 6s Plus"
		case "iPhone9,1", "iPhone9,3":                   return "iPhone 7"
		case "iPhone9,2", "iPhone9,4":                   return "iPhone 7 Plus"
		case "iPhone8,4":                                return "iPhone SE"
		case "iPhone10,1", "iPhone10,4":                 return "iPhone 8"
		case "iPhone10,2", "iPhone10,5":                 return "iPhone 8 Plus"
		case "iPhone10,3", "iPhone10,6":                 return "iPhone X"
		case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return "iPad 2"
		case "iPad3,1", "iPad3,2", "iPad3,3":            return "iPad 3"
		case "iPad3,4", "iPad3,5", "iPad3,6":            return "iPad 4"
		case "iPad4,1", "iPad4,2", "iPad4,3":            return "iPad Air"
		case "iPad5,3", "iPad5,4":                       return "iPad Air 2"
		case "iPad6,11", "iPad6,12":                     return "iPad 5"
		case "iPad7,5", "iPad7,6":                       return "iPad 6"
		case "iPad2,5", "iPad2,6", "iPad2,7":            return "iPad Mini"
		case "iPad4,4", "iPad4,5", "iPad4,6":            return "iPad Mini 2"
		case "iPad4,7", "iPad4,8", "iPad4,9":            return "iPad Mini 3"
		case "iPad5,1", "iPad5,2":                       return "iPad Mini 4"
		case "iPad6,3", "iPad6,4":                       return "iPad Pro 9.7 Inch"
		case "iPad6,7", "iPad6,8":                       return "iPad Pro 12.9 Inch"
		case "iPad7,1", "iPad7,2":                       return "iPad Pro 12.9 Inch 2. Generation"
		case "iPad7,3", "iPad7,4":                       return "iPad Pro 10.5 Inch"
		case "AppleTV5,3":                               return "Apple TV"
		case "AppleTV6,2":                               return "Apple TV 4K"
		case "AudioAccessory1,1":                        return "HomePod"
		case "i386", "x86_64":                           return "Simulator \(modelDescription( identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
		default:                                         return identifier
		}
		#elseif os(tvOS)
		switch identifier {
		case "AppleTV5,3": return "Apple TV 4"
		case "AppleTV6,2": return "Apple TV 4K"
		case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment[ "SIMULATOR_MODEL_IDENTIFIER" ] ?? "tvOS"))"
		default: return identifier
		}
		#endif
	}
}
