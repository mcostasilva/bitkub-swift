//
//  Result.swift
//  
//
//  Created by Marcio on 10/17/20.
//

import Foundation

struct Result<T: Decodable>: Decodable {
	var result: T
}


struct ResultDictionary<T: Decodable>: Decodable {
	var array: [T]

	private struct DynamicCodingKeys: CodingKey {
		var stringValue: String

		init?(stringValue: String) {
			self.stringValue = stringValue
		}

		var intValue: Int?
		init?(intValue: Int) {
			return nil
		}
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

		self.array = try container.allKeys.map({ (key) -> T in
			return try container.decode(T.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
		})
	}
}
