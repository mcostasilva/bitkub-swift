//
//  Coin.swift
//  
//
//  Created by Marcio on 10/17/20.
//

import Foundation

struct Coin: Decodable, Identifiable {
	var name: String {
		self.symbol?.name ?? CoinSymbol.UNKNOWN.rawValue
	}
	let id: Int
	let symbol: CoinSymbol?
	let last: Double
	let percentChange: Double
	var favorite: Bool = false
	var lowestAsk: Double = 0
	var highestBid: Double = 0
	var high24hr: Double = 0
	var low24hr: Double = 0

	var imageName: String {
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

	init(from decoder: Decoder) throws {
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


	init(id: Int, symbol: CoinSymbol, last: Double, percentChange: Double = 0, favorite: Bool = false) {
		self.id = id
		self.symbol = symbol
		self.last = last
		self.percentChange = percentChange
		self.favorite = favorite
	}

	mutating func refreshFavorite() {
//		favorite = PreferencesManager.favorites().contains(id)
	}
}
