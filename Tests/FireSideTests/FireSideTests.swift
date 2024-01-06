import XCTest
import OSLog
import Foundation
@testable import FireSide

let logger: Logger = Logger(subsystem: "FireSide", category: "Tests")

@available(macOS 13, *)
final class FireSideTests: XCTestCase {
    func testFireSide() throws {
        logger.log("running testFireSide")
        XCTAssertEqual(1 + 2, 3, "basic test")
        
        // load the TestData.json file from the Resources folder and decode it into a struct
        let resourceURL: URL = try XCTUnwrap(Bundle.module.url(forResource: "TestData", withExtension: "json"))
        let testData = try JSONDecoder().decode(TestData.self, from: Data(contentsOf: resourceURL))
        XCTAssertEqual("FireSide", testData.testModuleName)
    }
}

struct TestData : Codable, Hashable {
    var testModuleName: String
}