// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum CoreStrings {
  public enum Core {
    /// Add
    public static let buttonAdd = CoreStrings.tr("Core", "button_add")
    /// Accept
    public static let buttonAgree = CoreStrings.tr("Core", "button_agree")
    /// Cancel
    public static let buttonCancel = CoreStrings.tr("Core", "button_cancel")
    /// Cancel
    public static let buttonCancelAnnuller = CoreStrings.tr("Core", "button_cancel_annuller")
    /// Close
    public static let buttonClose = CoreStrings.tr("Core", "button_close")
    /// Continue
    public static let buttonContinue = CoreStrings.tr("Core", "button_continue")
    /// Reject
    public static let buttonDeny = CoreStrings.tr("Core", "button_deny")
    /// No
    public static let buttonNo = CoreStrings.tr("Core", "button_no")
    /// OK
    public static let buttonOk = CoreStrings.tr("Core", "button_ok")
    /// OK that sounds good
    public static let buttonOkSoundsGood = CoreStrings.tr("Core", "button_ok_sounds_good")
    /// Go to settings
    public static let buttonOpenSettings = CoreStrings.tr("Core", "button_open_settings")
    /// Try again
    public static let buttonRetry = CoreStrings.tr("Core", "button_retry")
    /// See more details
    public static let buttonSeeMore = CoreStrings.tr("Core", "button_see_more")
    /// Yes
    public static let buttonYes = CoreStrings.tr("Core", "button_yes")
    /// Yes please
    public static let buttonYesThanks = CoreStrings.tr("Core", "button_yes_thanks")
    /// EEE' the 'd'.'MMM' at 'HH.mm'
    public static let dtPastDate = CoreStrings.tr("Core", "dt_past_date")
    /// d.''MMM' 'yyyy' at 'HH:mm' o'clock
    public static let dtTimestampDate = CoreStrings.tr("Core", "dt_timestamp_date")
    /// Because you entered an incorrect PIN too many times, you must change it for security reasons to continue. You change your PIN code under  'Your  means of payment ' in the app 's main menu.
    public static let errorBlockedPinBody = CoreStrings.tr("Core", "error_blocked_pin_body")
    /// PIN has been entered incorrectly too many times
    public static let errorBlockedPinTitle = CoreStrings.tr("Core", "error_blocked_pin_title")
    /// Could not update pin, please try again later
    public static let errorChangePinCodeUpdateFailedBody = CoreStrings.tr("Core", "error_change_pin_code_update_failed_body")
    /// Error
    public static let errorChangePinCodeUpdateFailedTitle = CoreStrings.tr("Core", "error_change_pin_code_update_failed_title")
    /// Payment is not possible with the associated debit card. \nReplace the debit card or pay otherwise.
    public static let errorCppApi1000Body = CoreStrings.tr("Core", "error_cpp_api_1000_body")
    /// Payment not possible
    public static let errorCppApi1000Title = CoreStrings.tr("Core", "error_cpp_api_1000_title")
    /// There are too many payment cards registered.
    public static let errorCppApi100Body = CoreStrings.tr("Core", "error_cpp_api_100_body")
    /// Error
    public static let errorCppApi100Title = CoreStrings.tr("Core", "error_cpp_api_100_title")
    /// The payment card is already in use and therefore cannot be used.
    public static let errorCppApi101Body = CoreStrings.tr("Core", "error_cpp_api_101_body")
    /// Error
    public static let errorCppApi101Title = CoreStrings.tr("Core", "error_cpp_api_101_title")
    /// Your transaction has already been completed. Ask the cashier for help if you want to cancel anyway.
    public static let errorCppApi10Body = CoreStrings.tr("Core", "error_cpp_api_10_body")
    /// Error
    public static let errorCppApi10Title = CoreStrings.tr("Core", "error_cpp_api_10_title")
    /// You cannot remove your debit card because you have an active credit in your Prime account. You can freely replace your associated debit card. \n\nIf you wish to remove your debit card, you must repay your credit. You do this under the menu item ‘Get credit on PrimeKonto’ in the menu on Prime account.
    public static let errorCppApi117Body = CoreStrings.tr("Core", "error_cpp_api_117_body")
    /// You can not remove your debit card
    public static let errorCppApi117Title = CoreStrings.tr("Core", "error_cpp_api_117_title")
    /// You cannot remove your debit card because you have an automatic transfer to your Prime account. You can freely replace your associated debit card. \n\nIf you wish to remove your debit card, you must stop your automatic transfer to Prime account. You do this under ‘Change monthly amount & benefits ’in Prime account.
    public static let errorCppApi118Body = CoreStrings.tr("Core", "error_cpp_api_118_body")
    /// You can not remove your debit card
    public static let errorCppApi118Title = CoreStrings.tr("Core", "error_cpp_api_118_title")
    /// Wrong amount.
    public static let errorCppApi152Body = CoreStrings.tr("Core", "error_cpp_api_152_body")
    /// Error
    public static let errorCppApi152Title = CoreStrings.tr("Core", "error_cpp_api_152_title")
    /// Hey, another membership number is already registered at checkout. Tell the cashier if it is a mistake.
    public static let errorCppApi15Body = CoreStrings.tr("Core", "error_cpp_api_15_body")
    /// Error
    public static let errorCppApi15Title = CoreStrings.tr("Core", "error_cpp_api_15_title")
    /// Oops, a mistake was made. Sorry for the inconvenience.
    public static let errorCppApi17Body = CoreStrings.tr("Core", "error_cpp_api_17_body")
    /// Error
    public static let errorCppApi17Title = CoreStrings.tr("Core", "error_cpp_api_17_title")
    /// Payment has already been completed.
    public static let errorCppApi19Body = CoreStrings.tr("Core", "error_cpp_api_19_body")
    /// Error
    public static let errorCppApi19Title = CoreStrings.tr("Core", "error_cpp_api_19_title")
    /// PIN code must be entered
    public static let errorCppApi20Body = CoreStrings.tr("Core", "error_cpp_api_20_body")
    /// Error
    public static let errorCppApi20Title = CoreStrings.tr("Core", "error_cpp_api_20_title")
    /// Hey, you can not pay with bonus right now. Pay instead with a debit card or cash.
    public static let errorCppApi21Body = CoreStrings.tr("Core", "error_cpp_api_21_body")
    /// Error
    public static let errorCppApi21Title = CoreStrings.tr("Core", "error_cpp_api_21_title")
    /// You have a temporary membership and therefore cannot pay with a bonus
    public static let errorCppApi22Body = CoreStrings.tr("Core", "error_cpp_api_22_body")
    /// Error
    public static let errorCppApi22Title = CoreStrings.tr("Core", "error_cpp_api_22_title")
    /// There is currently no collective bargaining campaign.
    public static let errorCppApi23Body = CoreStrings.tr("Core", "error_cpp_api_23_body")
    /// Error
    public static let errorCppApi23Title = CoreStrings.tr("Core", "error_cpp_api_23_title")
    /// Collectibles cannot be used at this time.
    public static let errorCppApi24Body = CoreStrings.tr("Core", "error_cpp_api_24_body")
    /// Error
    public static let errorCppApi24Title = CoreStrings.tr("Core", "error_cpp_api_24_title")
    /// User not found
    public static let errorCppApi49Body = CoreStrings.tr("Core", "error_cpp_api_49_body")
    /// Error
    public static let errorCppApi49Title = CoreStrings.tr("Core", "error_cpp_api_49_title")
    /// Oops, a mistake was made. Sorry for the inconvenience.
    public static let errorCppApi500Body = CoreStrings.tr("Core", "error_cpp_api_500_body")
    /// Error
    public static let errorCppApi500Title = CoreStrings.tr("Core", "error_cpp_api_500_title")
    /// It took too long. Please try again later.
    public static let errorCppApi504Body = CoreStrings.tr("Core", "error_cpp_api_504_body")
    /// Error
    public static let errorCppApi504Title = CoreStrings.tr("Core", "error_cpp_api_504_title")
    /// Oops, the box and your mobile can not get in touch with each other. Use your physical membership card instead.
    public static let errorCppApi50Body = CoreStrings.tr("Core", "error_cpp_api_50_body")
    /// Error
    public static let errorCppApi50Title = CoreStrings.tr("Core", "error_cpp_api_50_title")
    /// Please try again, and if it still does not work, you can give the cashier your phone or membership number. Then your membership benefits are taken into account.
    public static let errorCppApi58Body = CoreStrings.tr("Core", "error_cpp_api_58_body")
    /// Hey, there's something wrong with the QR code
    public static let errorCppApi58Title = CoreStrings.tr("Core", "error_cpp_api_58_title")
    /// Have you completed the Mobilepay transaction correctly?
    public static let errorCppApi801Body = CoreStrings.tr("Core", "error_cpp_api_801_body")
    /// Error
    public static let errorCppApi801Title = CoreStrings.tr("Core", "error_cpp_api_801_title")
    /// Oops, a mistake was made. Please try again later.
    public static let errorCppApi900Body = CoreStrings.tr("Core", "error_cpp_api_900_body")
    /// Error
    public static let errorCppApi900Title = CoreStrings.tr("Core", "error_cpp_api_900_title")
    /// Access not allowed
    public static let errorCppApi93Body = CoreStrings.tr("Core", "error_cpp_api_93_body")
    /// Error
    public static let errorCppApi93Title = CoreStrings.tr("Core", "error_cpp_api_93_title")
    /// Transaction not found
    public static let errorCppApi9Body = CoreStrings.tr("Core", "error_cpp_api_9_body")
    /// Error
    public static let errorCppApi9Title = CoreStrings.tr("Core", "error_cpp_api_9_title")
    /// You have attempted to transfer an amount too quickly after your most recent transfer. Please try again later.
    public static let errorCppApiDuplicateTransactionBody = CoreStrings.tr("Core", "error_cpp_api_duplicate_transaction_body")
    /// You're too fast
    public static let errorCppApiDuplicateTransactionTitle = CoreStrings.tr("Core", "error_cpp_api_duplicate_transaction_title")
    /// Contact Member Service on 43 86 20 20.
    public static let errorCreditCardAddBody = CoreStrings.tr("Core", "error_credit_card_add_body")
    /// Unable to add card
    public static let errorCreditCardAddTitle = CoreStrings.tr("Core", "error_credit_card_add_title")
    /// Unfortunately, we cannot offer you a credit on Prime accunt, as you do not meet our credit requirements. Contact Member Services on tel.  43 86 20 20 if you have any questions.
    public static let errorEnrollmentBlacklistedBody = CoreStrings.tr("Core", "error_enrollment_blacklisted_body")
    /// You can not get credit
    public static let errorEnrollmentBlacklistedTitle = CoreStrings.tr("Core", "error_enrollment_blacklisted_title")
    /// Unfortunately, we cannot offer you a Prime account or a credit on Prime account, as you have registered a credit alert on your CPR number. Read more about how the credit alert can be removed on borger.dk. Once the warning is removed, you can return and complete the creation of Prime account.
    public static let errorEnrollmentCreditWarningBody = CoreStrings.tr("Core", "error_enrollment_credit_warning_body")
    /// You have a credit alert
    public static let errorEnrollmentCreditWarningTitle = CoreStrings.tr("Core", "error_enrollment_credit_warning_title")
    /// Unfortunately, we cannot offer you Prime account or a credit on Prime account, as your CPR number cannot be validated. Contact Member Services on tel.  43 86 20 20 for more information.
    public static let errorEnrollmentDeceasedBody = CoreStrings.tr("Core", "error_enrollment_deceased_body")
    /// CPR number cannot be validated
    public static let errorEnrollmentDeceasedTitle = CoreStrings.tr("Core", "error_enrollment_deceased_title")
    /// Unfortunately, we cannot offer you a credit on Prime account, as you do not meet our credit requirements. You are welcome to apply again at a later date.
    public static let errorEnrollmentHighRiskBody = CoreStrings.tr("Core", "error_enrollment_high_risk_body")
    /// You can not get a credit
    public static let errorEnrollmentHighRiskTitle = CoreStrings.tr("Core", "error_enrollment_high_risk_title")
    /// Unfortunately, we cannot offer you Prime account or a credit on Prime account, as your CPR number cannot be validated. Contact Member Services on tel.  43 86 20 20 for more information.
    public static let errorEnrollmentLegalIncapacityBody = CoreStrings.tr("Core", "error_enrollment_legal_incapacity_body")
    /// CPR number cannot be validated
    public static let errorEnrollmentLegalIncapacityTitle = CoreStrings.tr("Core", "error_enrollment_legal_incapacity_title")
    /// Unfortunately, we cannot offer you Prime account or a credit on Prime account, as your CPR number cannot be validated. Contact Member Services on tel.  43 86 20 20 for more information.
    public static let errorEnrollmentMissingPersonBody = CoreStrings.tr("Core", "error_enrollment_missing_person_body")
    /// CPR number cannot be validated
    public static let errorEnrollmentMissingPersonTitle = CoreStrings.tr("Core", "error_enrollment_missing_person_title")
    /// Unfortunately, we can not offer you Prime account or a credit on Prime account, as it is a requirement that you have permanent residence in Denmark and are listed in the CPR register.
    public static let errorEnrollmentNoAddressBody = CoreStrings.tr("Core", "error_enrollment_no_address_body")
    /// You have no permanent residence registered
    public static let errorEnrollmentNoAddressTitle = CoreStrings.tr("Core", "error_enrollment_no_address_title")
    /// Unfortunately, we can not offer you Prime account or a credit on Prime account, as it is a requirement that you reside in Denmark and are listed in the CPR register.
    public static let errorEnrollmentNotResidentBody = CoreStrings.tr("Core", "error_enrollment_not_resident_body")
    /// You do not reside in Denmark
    public static let errorEnrollmentNotResidentTitle = CoreStrings.tr("Core", "error_enrollment_not_resident_title")
    /// Unfortunately, we cannot offer you Prime account or a credit on Prime account, as your CPR number cannot be validated. Contact Member Services on tel.  43 86 20 20 for more information.
    public static let errorEnrollmentNotVerifiedBody = CoreStrings.tr("Core", "error_enrollment_not_verified_body")
    /// CPR number cannot be validated
    public static let errorEnrollmentNotVerifiedTitle = CoreStrings.tr("Core", "error_enrollment_not_verified_title")
    /// We can see that you have name and address protection. We therefore need you to register and submit identification via this form to get Prime account.
    public static let errorEnrollmentProtectedAddressBody = CoreStrings.tr("Core", "error_enrollment_protected_address_body")
    /// Submit identification
    public static let errorEnrollmentProtectedAddressConfirmAction = CoreStrings.tr("Core", "error_enrollment_protected_address_confirm_action")
    /// Protected name and address
    public static let errorEnrollmentProtectedAddressTitle = CoreStrings.tr("Core", "error_enrollment_protected_address_title")
    /// Unfortunately, we cannot offer you a credit on Prime account, as you are registered in RKI.
    public static let errorEnrollmentRkiBody = CoreStrings.tr("Core", "error_enrollment_rki_body")
    /// You can not get a credit
    public static let errorEnrollmentRkiTitle = CoreStrings.tr("Core", "error_enrollment_rki_title")
    /// We are very sorry. Please try again. If you still experience errors, contact Member Service on tel.  43 86 20 20.
    public static let errorEnrollmentUndefinedBody = CoreStrings.tr("Core", "error_enrollment_undefined_body")
    /// An error occurred
    public static let errorEnrollmentUndefinedTitle = CoreStrings.tr("Core", "error_enrollment_undefined_title")
    /// Unfortunately, we cannot offer you Prime account or a credit on Prime account, as you must be 18 years of age to access these products..
    public static let errorEnrollmentUnderAgedBody = CoreStrings.tr("Core", "error_enrollment_under_aged_body")
    /// You are under 18 years old
    public static let errorEnrollmentUnderAgedTitle = CoreStrings.tr("Core", "error_enrollment_under_aged_title")
    /// You have reached the limit of how much you can deposit into your Prime Account. \n\nThe money you have left in your Prime Account can still be used to trade.
    public static let errorFraud12MonthLimitBody = CoreStrings.tr("Core", "error_fraud_12_month_limit_body")
    /// Deposit limit reached
    public static let errorFraud12MonthLimitTitle = CoreStrings.tr("Core", "error_fraud_12_month_limit_title")
    /// We have locked your account to protect you against abuse and fraud. Please contact customer service
    public static let errorFraudAttemptBody = CoreStrings.tr("Core", "error_fraud_attempt_body")
    /// The account is locked for payment and credit
    public static let errorFraudAttemptTitle = CoreStrings.tr("Core", "error_fraud_attempt_title")
    /// You have reached the daily limit for how much you can deposit into your Prime account. Tomorrow you can deposit money into your Prime Account again. \n\nThe money you have left in your Prime Account can still be used to trade.
    public static let errorFraudDailyLimitBody = CoreStrings.tr("Core", "error_fraud_daily_limit_body")
    /// Daily deposit limit reached
    public static let errorFraudDailyLimitTitle = CoreStrings.tr("Core", "error_fraud_daily_limit_title")
    /// You have reached the limit of how much money you can have left in your Prime Account. When the balance is lower, you can put money back into the account. \n\nThe money you have left in your Prime Account can still be used to trade.
    public static let errorFraudMaxBalanceLimitBody = CoreStrings.tr("Core", "error_fraud_max_balance_limit_body")
    /// Maximum balance on Prime account reached
    public static let errorFraudMaxBalanceLimitTitle = CoreStrings.tr("Core", "error_fraud_max_balance_limit_title")
    /// You have reached the daily limit for how much money you can trade for with the app. Tomorrow you can again use your app to trade with. If you shop at Coop MAD in the app, you can go to Coop MAD's website and complete your order.
    public static let errorFraudMaxDailySpendingBody = CoreStrings.tr("Core", "error_fraud_max_daily_spending_body")
    /// Your amount limit has been reached
    public static let errorFraudMaxDailySpendingTitle = CoreStrings.tr("Core", "error_fraud_max_daily_spending_title")
    /// Please try to restart the app or come back later
    public static let errorGenericActionBody = CoreStrings.tr("Core", "error_generic_action_body")
    /// An error occurred
    public static let errorGenericActionTitle = CoreStrings.tr("Core", "error_generic_action_title")
    /// We were unable to receive the needed information. Please try and restart your app
    public static let errorGenericDataLoadBody = CoreStrings.tr("Core", "error_generic_data_load_body")
    /// Information missing
    public static let errorGenericDataLoadTitle = CoreStrings.tr("Core", "error_generic_data_load_title")
    /// Server error
    public static let errorGenericServerFailTitle = CoreStrings.tr("Core", "error_generic_server_fail_title")
    /// Error
    public static let errorGenericTitle = CoreStrings.tr("Core", "error_generic_title")
    /// It requires internet to be able to log in.
    public static let errorInternetConnectionMissingLoginBody = CoreStrings.tr("Core", "error_internet_connection_missing_login_body")
    /// It requires internet to scan your membership card.
    public static let errorInternetConnectionMissingPaymentStartBody = CoreStrings.tr("Core", "error_internet_connection_missing_payment_start_body")
    /// No internet
    public static let errorInternetConnectionMissingTitle = CoreStrings.tr("Core", "error_internet_connection_missing_title")
    /// Enter the correct PIN code. If you have forgotten it, you can change it under 'Your Payment Means' in the app's main menu.
    public static let errorInvalidPinBody = CoreStrings.tr("Core", "error_invalid_pin_body")
    /// The PIN code is incorrect
    public static let errorInvalidPinTitle = CoreStrings.tr("Core", "error_invalid_pin_title")
    /// You need to be connected to the internet in order to use the functionalities in the app
    public static let errorNetworkUnavailableBody = CoreStrings.tr("Core", "error_network_unavailable_body")
    /// The app has no connection to the internet
    public static let errorNetworkUnavailableTitle = CoreStrings.tr("Core", "error_network_unavailable_title")
    /// Unfortunately, your purchase was canceled before you had time to approve it on your mobile. Start over with your payment to pay with the app.
    public static let errorPaymentAlreadyCanceledBody = CoreStrings.tr("Core", "error_payment_already_canceled_body")
    /// Your purchase has not been completed
    public static let errorPaymentAlreadyCanceledTitle = CoreStrings.tr("Core", "error_payment_already_canceled_title")
    /// We could not process your payment due to expired card, you can add a new card under payments in the menu
    public static let errorPaymentCardExpiredBody = CoreStrings.tr("Core", "error_payment_card_expired_body")
    /// Payment Card expired
    public static let errorPaymentCardExpiredTitle = CoreStrings.tr("Core", "error_payment_card_expired_title")
    /// We were unable to withdraw money from your card, please add another card under payments in the menu
    public static let errorPaymentCardNotFoundBody = CoreStrings.tr("Core", "error_payment_card_not_found_body")
    /// Payment card not found
    public static let errorPaymentCardNotFoundTitle = CoreStrings.tr("Core", "error_payment_card_not_found_title")
    /// Unfortunately, it seems that there is something wrong with your payment card, or that you do not have enough money available through the various payment options in the app. Therefore, you can not pay with the app right now. Deposit more money or choose another means of payment.
    public static let errorPaymentFailedBody = CoreStrings.tr("Core", "error_payment_failed_body")
    /// Sadly you cannot pay with the app right now
    public static let errorPaymentFailedTitle = CoreStrings.tr("Core", "error_payment_failed_title")
    /// An error occurred.  nTry again or contact Member Service on 43 86 20 20 if the error persists.
    public static let errorPaymentTimeoutBody = CoreStrings.tr("Core", "error_payment_timeout_body")
    /// Go to settings
    public static let errorPermissionCameraAction = CoreStrings.tr("Core", "error_permission_camera_action")
    /// The app lacks permission to use the camera
    public static let errorPermissionCameraDeniedTitle = CoreStrings.tr("Core", "error_permission_camera_denied_title")
    /// There was an error. Please try again otherwise come back later.
    public static let errorServerUnavailableBody = CoreStrings.tr("Core", "error_server_unavailable_body")
    /// Server error
    public static let errorServerUnavailableTitle = CoreStrings.tr("Core", "error_server_unavailable_title")
    /// You can not top up your account right now because we're still completing your most recent replenishment. It goes a little slower than usual. We apologize for the inconvenience. \n\nIf your most recent refill does not go through or the waiting time becomes too long, please contact Member Services on tel.  43 86 20 20
    public static let errorTopupPendingBody = CoreStrings.tr("Core", "error_topup_pending_body")
    /// Your account is already replenished
    public static let errorTopupPendingTitle = CoreStrings.tr("Core", "error_topup_pending_title")
    /// %@ stk.
    public static func formatAmount(_ p1: Any) -> String {
      return CoreStrings.tr("Core", "format_amount", String(describing: p1))
    }
    /// %.0f
    public static func formatPriceSplash(_ p1: Float) -> String {
      return CoreStrings.tr("Core", "format_price_splash", p1)
    }
    /// New article
    public static let genNewDataAvailable = CoreStrings.tr("Core", "gen_new_data_available")
    /// The app shows cached data. Return to the frontpage and try again
    public static let genOldDataAlertMessage = CoreStrings.tr("Core", "gen_old_data_alert_message")
    /// Show saved data
    public static let genOldDataAlertTitle = CoreStrings.tr("Core", "gen_old_data_alert_title")
    /// (See error...)
    public static let genSeeMorePrompt = CoreStrings.tr("Core", "gen_see_more_prompt")
    /// Or
    public static let or = CoreStrings.tr("Core", "or")
  }
  public enum CoreArch {
    /// See fewer
    public static let listItemSeemoreClose = CoreStrings.tr("CoreArch", "list_item_seemore_close")
    /// See more
    public static let listItemSeemoreOpen = CoreStrings.tr("CoreArch", "list_item_seemore_open")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension CoreStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
	  let format = Bundle.Core.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
