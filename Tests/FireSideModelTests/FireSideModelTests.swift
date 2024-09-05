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

// SKIP INSERT: @org.junit.runner.RunWith(androidx.test.ext.junit.runners.AndroidJUnit4::class)
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
        let _ = Self.model
    }
}
