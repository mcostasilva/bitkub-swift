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
		let controller = BitkubController(apiKey: key!, secret: secret!)
		let expectation = XCTestExpectation(description: "Balance retrieved from Bitkub")
		try! controller.loadBalance()
		controller.$balances.drop(while: {$0.count == 0}).sink { (balances) in
			expectation.fulfill()
		}
		.store(in: &cancellables)
		wait(for: [expectation], timeout: 5)
	}

	func testWrongCredentials() {
		let key = "abcd"
		let secret = "efgh"
		let controller = BitkubController(apiKey: key, secret: secret)
		let expectation = XCTestExpectation(description: "Credentials are marked as invalid")
		try! controller.loadBalance()
		controller.$validCredentials.drop(while: { $0 }).sink { (validCredentials) in
			if validCredentials == false {
				expectation.fulfill()
			}
		}.store(in: &cancellables)
		wait(for: [expectation], timeout: 5)
	}

	func testLoadBalanceThrowsWithoutCredentials() {
		let controller = BitkubController()
		XCTAssertThrowsError(try controller.loadBalance()) { error in
			XCTAssertEqual(error as! BitkubError, BitkubError.missingCredentials)
		}
	}

    static var allTests = [
        ("testLoadCoins", testLoadCoins),
    ]
}
