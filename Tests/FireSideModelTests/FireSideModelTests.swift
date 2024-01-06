import XCTest
import OSLog
import Foundation
@testable import FireSideModel

let logger: Logger = Logger(subsystem: "FireSideModel", category: "Tests")

@available(macOS 13, *)
final class FireSideModelTests: XCTestCase {
    func testFireSideModel() throws {
        logger.log("running testFireSideModel")
        XCTAssertEqual(1 + 2, 3, "basic test")
        
        // load the TestData.json file from the Resources folder and decode it into a struct
        let resourceURL: URL = try XCTUnwrap(Bundle.module.url(forResource: "TestData", withExtension: "json"))
        let testData = try JSONDecoder().decode(TestData.self, from: Data(contentsOf: resourceURL))
        XCTAssertEqual("FireSideModel", testData.testModuleName)
    }
}

struct TestData : Codable, Hashable {
    var testModuleName: String
}