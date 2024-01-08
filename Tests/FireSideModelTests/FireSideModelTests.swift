import XCTest
import OSLog
import Foundation
@testable import FireSideModel

let logger: Logger = Logger(subsystem: "FireSideModel", category: "Tests")

// SKIP INSERT: @org.junit.runner.RunWith(androidx.test.ext.junit.runners.AndroidJUnit4::class)
@available(macOS 13, *)
final class FireSideModelTests: XCTestCase {
    // values from Darwin/GoogleService-Info.plist
    static let store: Result<FireSideStore, Error> = Result {
        try FireSideStore(options: [
            "API_KEY": "AIzaSyCjhtnQ4GE010ED8hRMaGZjpdApSk43z1I",
            "GCM_SENDER_ID": "1058155430593",
            //"BUNDLE_ID": "skip.fireside.App",
            "PROJECT_ID": "skip-fireside",
            "STORAGE_BUCKET": "skip-fireside.appspot.com",
            "GOOGLE_APP_ID": "1:1058155430593:ios:d3a7a76d92b20132370a40",
        ])
    }

    func testFireSideStore() throws {
        let _ = Self.store
    }

    func testFireSideModel() async throws {
        let chatKey = try await Self.store.get().startNewChat()

    }
}
