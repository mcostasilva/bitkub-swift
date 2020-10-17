import XCTest
import Combine
@testable import Bitkub

final class BitkubTests: XCTestCase {
	var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()

	func testLoadCoins() {
		let expectation = XCTestExpectation(description: "Coin values recovered from Bitkub")
		let controller = BitkubController()
		controller.loadCoins()
		controller.$coins.drop(while: { $0.count == 0 }).sink { (coins) in
			expectation.fulfill()
		}
		.store(in: &cancellables)
		wait(for: [expectation], timeout: 5)
	}

	func testLoadBalance() {
		let key = ProcessInfo.processInfo.environment["KEY"]
		let secret = ProcessInfo.processInfo.environment["SECRET"]
		XCTAssertNotNil(key)
		XCTAssertNotNil(secret)
		let controller = BitkubController()
		let expectation = XCTestExpectation(description: "Balance retrieved from Bitkub")
		controller.loadBalance(key: key!, secret: secret!)
		controller.$balances.drop(while: {$0.count == 0}).sink { (balances) in
			expectation.fulfill()
		}
		.store(in: &cancellables)
		wait(for: [expectation], timeout: 5)
	}

    static var allTests = [
        ("testLoadCoins", testLoadCoins),
    ]
}
