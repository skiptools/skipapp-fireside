import SwiftUI
import FirebaseCore
import FirebaseMessaging
import FireSide

/// The entry point to the app simply loads the App implementation from SPM module.
@main struct AppMain: App, FireSideApp {
    @UIApplicationDelegateAdaptor(FireSideAppDelegate.self) var appDelegate
}

/// iOS uses the app delegate to integrate push notifications.
///
/// See Main.kt for the equivalent Android functionality.
public class FireSideAppDelegate : NSObject, UIApplicationDelegate {
    let notificationsDelegate = NotificationDelegate() // Defined in FireSideApp.swift

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        UNUserNotificationCenter.current().delegate = notificationsDelegate
        Messaging.messaging().delegate = notificationsDelegate

        // Ask for permissions at a time appropriate for your app
        notificationsDelegate.requestPermission()

        application.registerForRemoteNotifications()
        return true
    }
}
