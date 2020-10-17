import XCTest
import Combine
@testable import Bitkub

final class BitkubTests: XCTestCase {
	var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()

	func testLoadCoins() {
		let expectation = XCTestExpectation(description: "Coin values recovered from Bitkub")
		let controller = BitkubController()
		controller.loadCoins()
		controller.$coins.sink { (coins) in
			if coins.count > 0 {
				expectation.fulfill()
			}
		}
		.store(in: &cancellables)
		wait(for: [expectation], timeout: 5)
		XCTAssertNotEqual(controller.coins.count, 0)
	}

    static var allTests = [
        ("testLoadCoins", testLoadCoins),
    ]
}
