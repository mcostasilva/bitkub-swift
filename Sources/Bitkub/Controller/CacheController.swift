//
//  CacheController.swift
//  
//
//  Created by Marcio on 1/8/21.
//

import Foundation
import CoreData

fileprivate let key = "CacheKey"

class CacheController {
	fileprivate let cache = NSCache<NSString, EncapsulatedCoins>()

	func recover() -> [Coin] {
		guard let cachedCoins = cache.object(forKey: key as NSString) else {
			return []
		}
		return cachedCoins.coins
	}

	func save(_ coins: [Coin]) {
		let encapsulated = EncapsulatedCoins(coins)
		cache.setObject(encapsulated, forKey: key as NSString)
	}
}

fileprivate class EncapsulatedCoins: NSObject {
	let coins: [Coin]
	init(_ coins: [Coin]) {
		self.coins = coins
	}
}
