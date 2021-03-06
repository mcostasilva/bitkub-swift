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
	@Published public private(set) var balances: [Balance] = []
	@Published public private(set) var normalizedBalance: Double?
	@Published public private(set) var normalizedBalanceString: String?
	@Published public var apiKey: String?
	@Published public var secret: String?
	@Published public private(set) var loading: Bool = false
	@Published public private(set) var refreshDate: Date?
	@Published public private(set) var validCredentials: Bool = true
	private let cacheController: CacheController = CacheController()

	private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()

	public init() { }

	/// Initialize controller with a secret and password
	/// - Parameters:
	///   - apiKey: User's API KEY
	///   - secret: User's secret
	/// - Note:
	/// `apiKey` and `secret` are only used on API calls that require them.
	public init(apiKey: String, secret: String) {
		self.secret = secret
		self.apiKey = apiKey
	}

	/// Set controller with a secret and password
	/// - Parameters:
	///   - apiKey: User's API KEY
	///   - secret: User's secret
	/// - Note:
	/// `apiKey` and `secret` are only used on API calls that require them.
	public func set(apiKey: String, secret: String) {
		self.secret = secret
		self.apiKey = apiKey
	}

	/// Pull latest exchange rates from Bitkub and stores them into `self.coins`
	public func loadCoins() {
		self.loading = true
		self.coins = cacheController.recover()
		let url = URL(string: "https://api.bitkub.com/api/market/ticker")!
		let request = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData)
		URLSession.shared
		.dataTaskPublisher(for: request)
		.map { $0.data }
		.decode(type: ResultDictionary<Coin>.self, decoder: JSONDecoder())
		.receive(on: DispatchQueue.main)
		.sink(receiveCompletion: { (completion) in
			self.loading = false
			switch completion {
			case .failure(let error):
				print(error.localizedDescription)
			case .finished:
				print("Download finished")
			}
		}, receiveValue: { (coins) in
			self.coins = coins.array.sorted(by: {$0.id < $1.id })
			self.cacheController.save(self.coins)
			self.refreshDate = Date()
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

	/// Load balances from Bitkub and stores it into `self.balances`
	/// - Parameters:
	///   - callback: Optional closure called with a normalized string representing the current balance total amount in THB
	///	- Throws: `BitkubError.missingCredentials` if `apikey` or `secret` are empty

	public func loadBalance(callback: ((String) -> Void)? = nil) throws {
		guard let key = apiKey, key != "", let secret = secret, secret != "" else {
			throw BitkubError.missingCredentials
		}

		var request = URLRequest(url: URL(string: "https://api.bitkub.com/api/market/balances")!)
		request.allHTTPHeaderFields = ["Content-Type": "application/json", "Accept": "application/json", "X-BTK-APIKEY": key]
		request.httpMethod = "POST"
		let now = Int(Date().timeIntervalSince1970)
		let preQuery = ["ts": now]
		let signature = sign(preQuery)
		let query: [String: Any] = ["ts": now, "sig": signature]
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
					// Bitkub returns a 200 even when credentials are invalid.
					// If there was an error decoding the json
					// we assume it's because of wrong credentials
					self.validCredentials = false
				case .finished:
					print("Balance recovered")
				}
			} receiveValue: { (balances) in
				self.balances = balances.result.array.filter({ $0.available + $0.reserved > 0})
				self.normalizedBalance = self.balances.reduce(0) { (acc, bal) -> Double in
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

	private func sign<T: Codable>(_ query: [String: T]) -> String {
		let preQueryData = try! JSONEncoder().encode(query)
		let signatureData = HMAC<SHA256>.authenticationCode(for: preQueryData, using: SymmetricKey(data: secret!.data(using: .utf8)!))
		let signature = String(describing: signatureData).replacingOccurrences(of: "HMAC with SHA256: ", with: "")
		return signature
	}

	func value(for symbol: CoinSymbol) -> Double {
		coins.first(where: { $0.symbol == symbol})?.last ?? 1
	}
}

enum BitkubError: Error {
	case missingCredentials
	case invalidCredentials
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
