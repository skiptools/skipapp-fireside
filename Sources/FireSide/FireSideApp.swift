import FireSideModel
import Foundation
import OSLog
import SwiftUI
#if SKIP
import SkipFirebaseMessaging
#else
import FirebaseMessaging
#endif

let logger: Logger = Logger(subsystem: "skip.fireside.App", category: "FireSide")

/// The Android SDK number we are running against, or `nil` if not running on Android
let androidSDK = ProcessInfo.processInfo.environment["android.os.Build.VERSION.SDK_INT"].flatMap({ Int($0) })

/// The shared top-level view for the app, loaded from the platform-specific App delegates below.
///
/// The default implementation merely loads the `ContentView` for the app and logs a message.
public struct RootView : View {
    public init() {
    }

    public var body: some View {
        ContentView()
            .task {
                logger.log("Welcome to Skip on \(androidSDK != nil ? "Android" : "Darwin")!")
                logger.warning("Skip app logs are viewable in the Xcode console for iOS; Android logs can be viewed in Studio or using adb logcat")
            }
    }
}

/// Shared delegate for responding to notifications.
///
/// See FireSideAppMain for iOS setup, Main.kt for Android setup.
public class NotificationDelegate : NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    public func requestPermission() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        Task { @MainActor in
            do {
                if try await UNUserNotificationCenter.current().requestAuthorization(options: authOptions) {
                    logger.info("notification permission granted")
                } else {
                    logger.info("notification permission denied")
                }
            } catch {
                logger.error("notification permission error: \(error)")
            }
        }
    }

    @MainActor
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let content = notification.request.content
        logger.info("willPresentNotification: \(content.title): \(content.body) \(content.userInfo)")
        return [.banner, .sound]
    }

    @MainActor
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let content = response.notification.request.content
        logger.info("didReceiveNotification: \(content.title): \(content.body) \(content.userInfo)")

        // Example of using a deep_link key passed in the notification to route to the app's `onOpenURL` handler
        if let deepLink = response.notification.request.content.userInfo["deep_link"] as? String, let url = URL(string: deepLink) {
            await UIApplication.shared.open(url)
        }
    }

    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken token: String?) {
        logger.info("didReceiveRegistrationToken: \(token ?? "nil")")
    }
}

#if !SKIP
public protocol FireSideApp : App {
}

/// The entry point to the FireSide app.
/// The concrete implementation is in the FireSideApp module.
public extension FireSideApp {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
#endif
