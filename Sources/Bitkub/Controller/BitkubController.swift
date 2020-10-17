//
//  BitkubController.swift
//  
//
//  Created by Marcio on 10/17/20.
//

import Foundation
import Combine
import CryptoKit

public class BitkubController: ObservableObject {

	@Published public private(set) var coins: [Coin] = []
	@Published public private(set) var balance: [Balance] = []
	@Published public private(set) var normalizedBalance: Double?
	@Published public private(set) var normalizedBalanceString: String?

	private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()

	public func loadCoins() {
		URLSession.shared
		.dataTaskPublisher(for: URL(string: "https://api.bitkub.com/api/market/ticker")!)
		.map { $0.data }
		.decode(type: ResultDictionary<Coin>.self, decoder: JSONDecoder())
		.receive(on: DispatchQueue.main)
		.sink(receiveCompletion: { (completion) in
			switch completion {
			case .failure(let error):
				print(error.localizedDescription)
			case .finished:
				print("Download finished")
			}
		}, receiveValue: { (coins) in
			self.coins = coins.array.sorted(by: {$0.id < $1.id })
		})
		.store(in: &cancellables)

		NotificationCenter.default
			.publisher(for: notif)
			.sink { (notification) in
				guard let id = notification.object as? Int, let index = self.coins.firstIndex(where: { $0.id == id}) else {
					return
				}
				self.coins[index].refreshFavorite()
			}
			.store(in: &cancellables)
	}

	public func loadBalance(key: String, secret: String, callback: ((String) -> Void)? = nil) {
		guard key != "", secret != "" else { return }

		var request = URLRequest(url: URL(string: "https://api.bitkub.com/api/market/balances")!)
		request.allHTTPHeaderFields = ["Content-Type": "application/json", "Accept": "application/json", "X-BTK-APIKEY": key]
		request.httpMethod = "POST"
		let now = Int(Date().timeIntervalSince1970)
		let preQuery = ["ts": now]
		let preQueryData = try! JSONEncoder().encode(preQuery)
		let signatureData = HMAC<SHA256>.authenticationCode(for: preQueryData, using: SymmetricKey(data: secret.data(using: .utf8)!))
		let signature = String(describing: signatureData).replacingOccurrences(of: "HMAC with SHA256: ", with: "")
		let query: [String: Any] = ["ts": now, "sig": signature]
		print(query)
		let data = try! JSONSerialization.data(withJSONObject: query, options: .fragmentsAllowed)
		request.httpBody = data
		URLSession.shared
			.dataTaskPublisher(for: request)
			.map { $0.data }
			.decode(type: Result<ResultDictionary<Balance>>.self, decoder: JSONDecoder())
			.receive(on: DispatchQueue.main)
			.sink { (completion) in
				switch completion {
				case .failure(let error):
					print(error.localizedDescription)
				case .finished:
					print("Balance recovered")
				}
			} receiveValue: { (balances) in
				self.balance = balances.result.array.filter({ $0.available + $0.reserved > 0})
				self.normalizedBalance = self.balance.reduce(0) { (acc, bal) -> Double in
					acc + self.value(for: bal.currency) * (bal.available + bal.reserved)
				}
				let currencyFormatter = NumberFormatter()
				currencyFormatter.numberStyle = .currency
				let normalizedString = currencyFormatter.string(for: self.normalizedBalance ?? 0) ?? "0"
				self.normalizedBalanceString = normalizedString
				callback?(normalizedString)
			}
			.store(in: &cancellables)
	}

	func value(for symbol: CoinSymbol) -> Double {
		coins.first(where: { $0.symbol == symbol})?.last ?? 1
	}
}

let notif = Notification.Name(rawValue: "FavoritesUpdated")


extension Data {
	struct HexEncodingOptions: OptionSet {
		let rawValue: Int
		static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
	}

	func hexEncodedString(options: HexEncodingOptions = []) -> String {
		let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
		return map { String(format: format, $0) }.joined()
	}
}
