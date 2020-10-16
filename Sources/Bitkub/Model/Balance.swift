//
//  Balance.swift
//  
//
//  Created by Marcio on 10/17/20.
//

import Foundation

public struct Balance: Codable, Hashable {
	public var currency: CoinSymbol
	public var available: Double
	public var reserved: Double

	enum CodingKeys: String, CodingKey {
		case currency
		case available
		case reserved
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		currency = CoinSymbol(rawValue: "THB_\(container.codingPath[1].stringValue)") ?? .UNKNOWN
		available = try container.decode(Double.self, forKey: CodingKeys.available)
		reserved = try container.decode(Double.self, forKey: CodingKeys.reserved)
	}
}
