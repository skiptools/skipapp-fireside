import XCTest
import OSLog
import Foundation
#if !SKIP
import FirebaseCore
#else
import SkipFirebaseCore
#endif
@testable import FireSideModel

let logger: Logger = Logger(subsystem: "FireSideModel", category: "Tests")

@available(macOS 13, *)
final class FireSideModelTests: XCTestCase {
    // values from Darwin/GoogleService-Info.plist
    static let model: Result<FireSideModel, Error> = Result {
        let opts = FirebaseOptions(googleAppID: "1:1058155430593:ios:d3a7a76d92b20132370a40", gcmSenderID: "1058155430593")
        opts.apiKey = "AIzaSyCjhtnQ4GE010ED8hRMaGZjpdApSk43z1I"
        opts.projectID = "skip-fireside"
        opts.storageBucket = "skip-fireside.appspot.com"
        FirebaseApp.configure(options: opts)
        return FireSideModel.shared
    }

    func testFireSideModel() throws {
        // disabled because this crashed for an app with notifications enabled:
        /*
         Test Case '-[FireSideModelTests.FireSideModelTests testFireSideModel]' started.2024-09-07 13:50:23.210 xctest[24766:83757] *** Assertion failure in +[UNUserNotificationCenter currentNotificationCenter], UNUserNotificationCenter.m:63/Users/runner/work/skipapp-fireside/skipapp-fireside/.build/checkouts/firebase-ios-sdk/FirebaseMessaging/Sources/FIRMessagingRemoteNotificationsProxy.m:378: error: -[FireSideModelTests.FireSideModelTests testFireSideModel] : bundleProxyForCurrentProcess is nil: mainBundle.bundleURL file:///Applications/Xcode_15.3.app/Contents/Developer/usr/bin/ (NSInternalInconsistencyException)*** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'bundleProxyForCurrentProcess is nil: mainBundle.bundleURL file:///Applications/Xcode_15.3.app/Contents/Developer/usr/bin/'
         *** First throw call stack:
         (
             0   CoreFoundation                      0x000000019275e2ec __exceptionPreprocess + 176
             1   libobjc.A.dylib                     0x0000000192242158 objc_exception_throw + 60
             2   Foundation                          0x00000001938d120c -[NSCalendarDate initWithCoder:] + 0
             3   UserNotifications                   0x000000019f08a4a8 __53+[UNUserNotificationCenter currentNotificationCenter]_block_invoke + 680
             4   libdispatch.dylib                   0x00000001924593e8 _dispatch_client_callout + 20
             5   libdispatch.dylib                   0x000000019245ac68 _dispatch_once_callout + 32
             6   UserNotifications                   0x000000019f08a1fc +[UNUserNotificationCenter currentNotificationCenter] + 156
             7   skipapp-firesidePackageTests        0x000000010603ca38 FIRMessagingPropertyNameFromObject + 172
             8   skipapp-firesidePackageTests        0x000000010603c924 -[FIRMessagingRemoteNotificationsProxy swizzleMethodsIfPossible] + 176
             9   skipapp-firesidePackageTests        0x000000010602ede4 -[FIRMessaging configureNotificationSwizzlingIfEnabled] + 184
             10  skipapp-firesidePackageTests        0x000000010602e648 __36+[FIRMessaging componentsToRegister]_block_invoke + 508
             11  skipapp-firesidePackageTests        0x0000000105fdccc8 -[FIRComponentContainer instantiateInstanceForProtocol:withBlock:] + 120
             12  skipapp-firesidePackageTests        0x0000000105fdcf94 -[FIRComponentContainer instanceForProtocol:] + 296
             13  skipapp-firesidePackageTests        0x0000000105fdcb38 -[FIRComponentContainer instantiateEagerComponents] + 288
             14  skipapp-firesidePackageTests        0x0000000105fd7cd8 +[FIRApp configureWithName:options:] + 1264
             15  skipapp-firesidePackageTests        0x0000000105fd76cc +[FIRApp configureWithOptions:] + 132
             16  skipapp-firesidePackageTests        0x0000000105ebe748 $s18FireSideModelTestsAAC5models6ResultOy0abC0AFCs5Error_pGvpZfiAGyXEfU_ + 420
             17  skipapp-firesidePackageTests        0x0000000105ebe534 $s18FireSideModelTestsAAC5model_WZ + 36
         */
        // let _ = Self.model
    }
}
