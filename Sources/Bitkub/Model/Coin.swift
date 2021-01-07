//
//  Coin.swift
//  
//
//  Created by Marcio on 10/17/20.
//

import Foundation

public struct Coin: Codable, Identifiable {

	/// Coin name in English
	public var name: String {
		self.symbol?.name ?? CoinSymbol.UNKNOWN.rawValue
	}

	/// Integer ID for this Coin on Bitkub
	public let id: Int

	/// CoinSymbol representing a coin
	public let symbol: CoinSymbol?

	/// Last traiding value
	public let last: Double

	public let percentChange: Double
	public var favorite: Bool = false
	public var lowestAsk: Double = 0
	public var highestBid: Double = 0

	/// Highest value in the last 24h
	public var high24hr: Double = 0

	/// Lowest value in the last 24h
	public var low24hr: Double = 0

	public var imageName: String {
		guard let symbol = self.symbol?.rawValue else {
			return ""
		}
		return symbol.replacingOccurrences(of: "THB_", with: "")
	}

	enum CodingKeys: String, CodingKey {
		case id
		case symbol
		case last
		case percentChange
		case lowestAsk
		case highestBid
		case high24hr
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		id = try container.decode(Int.self, forKey: CodingKeys.id)
		last = try container.decode(Double.self, forKey: CodingKeys.last)
		percentChange = try container.decode(Double.self, forKey: CodingKeys.percentChange)
		symbol = CoinSymbol(rawValue: container.codingPath.first!.stringValue)
		lowestAsk = try container.decode(Double.self, forKey: CodingKeys.lowestAsk)
		highestBid = try container.decode(Double.self, forKey: CodingKeys.highestBid)
//		favorite = PreferencesManager.favorites().contains(id)
		high24hr = try container.decode(Double.self, forKey: CodingKeys.high24hr)
	}


	public init(id: Int, symbol: CoinSymbol, last: Double, percentChange: Double = 0, favorite: Bool = false) {
		self.id = id
		self.symbol = symbol
		self.last = last
		self.percentChange = percentChange
		self.favorite = favorite
	}

	public mutating func refreshFavorite() {
//		favorite = PreferencesManager.favorites().contains(id)
	}
}
