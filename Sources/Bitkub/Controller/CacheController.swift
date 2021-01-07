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
			return self.load()
		}
		return cachedCoins.coins
	}

	private func load() -> [Coin] {
		let fileManager = FileManager.default
		let folderURLs = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
		let fileURL = folderURLs[0].appendingPathComponent("coins.cache")
		guard let data = try? Data(contentsOf: fileURL) else {
			return []
		}
		guard let coins = try? JSONDecoder().decode([Coin].self, from: data) else {
			try! fileManager.removeItem(at: fileURL)
			return []
		}
		cache.setObject(EncapsulatedCoins(coins), forKey: key as NSString)
		return coins
	}

	func save(_ coins: [Coin]) {
		let encapsulated = EncapsulatedCoins(coins)
		let fileManager = FileManager.default
		let folderURLs = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
		let fileURL = folderURLs[0].appendingPathComponent("coins.cache")
		let data = try! JSONEncoder().encode(coins)
		try! data.write(to: fileURL)
		cache.setObject(EncapsulatedCoins(coins), forKey: key as NSString)
	}
}

fileprivate class EncapsulatedCoins: NSObject {
	let coins: [Coin]
	init(_ coins: [Coin]) {
		self.coins = coins
	}
}
