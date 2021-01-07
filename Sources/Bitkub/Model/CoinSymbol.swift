//
//  CoinSymbol.swift
//  
//
//  Created by Marcio on 10/17/20.
//

import Foundation

public enum CoinSymbol: String, Codable {
	case THB_BTC, THB_ETH, THB_WAN, THB_ADA, THB_OMG, THB_BCH, THB_USDT, THB_LTC, THB_XRP, THB_BSV, THB_ZIL, THB_SNT, THB_CVC, THB_LINK, THB_GNT, THB_IOST, THB_ZRX, THB_KNC, THB_ENG, THB_RDN, THB_ABT, THB_MANA, THB_INF, THB_CTXC, THB_XLM, THB_SIX, THB_JFIN, THB_EVX, THB_BNB, THB_POW, THB_DOGE, THB_DAI, THB_BAND, THB_KSM, THB_DOT, UNKNOWN, THB_THB
	public static var allValues: [CoinSymbol] {
		[.THB_BTC, .THB_ETH, .THB_WAN, .THB_ADA, .THB_OMG, .THB_BCH, .THB_USDT, .THB_LTC, .THB_XRP, .THB_BSV, .THB_ZIL, .THB_SNT, .THB_CVC, .THB_LINK, .THB_GNT, .THB_IOST, .THB_ZRX, .THB_KNC, .THB_ENG, .THB_RDN, .THB_ABT, .THB_MANA, .THB_INF, .THB_CTXC, .THB_XLM, .THB_SIX, .THB_JFIN, .THB_EVX, .THB_BNB, .THB_POW, .THB_DOGE, .THB_DAI, .THB_BAND, .THB_KSM, .THB_DOT]
	}


	public var abbreviation: String {
		self.rawValue.replacingOccurrences(of: "THB_", with: "")
	}

	public var name: String {
		switch self {
		case .THB_THB:
			return "THB"
		case .THB_BTC:
		  return "Bitcoin"
		case .THB_ETH:
		  return "Ethereum"
		case .THB_WAN:
		  return "Wancoin"
		case .THB_ADA:
		  return "Cardano"
		case .THB_OMG:
		  return "OmiseGO"
		case .THB_BCH:
		  return "Bitcoin Cash"
		case .THB_USDT:
		  return "Tether"
		case .THB_LTC:
		  return "Litecoin"
		case .THB_XRP:
		  return "XRP"
		case .THB_BSV:
		  return "Bitcoin SV"
		case .THB_ZIL:
		  return "Zilliqa"
		case .THB_SNT:
		  return "StatusNetwork"
		case .THB_CVC:
		  return "Civic"
		case .THB_LINK:
		  return "ChainLink Token"
		case .THB_GNT:
		  return "Golem"
		case .THB_IOST:
		  return "IOSToken"
		case .THB_ZRX:
		  return "0x"
		case .THB_KNC:
		  return "KyberNetwork"
		case .THB_ENG:
		  return "Enigma"
		case .THB_RDN:
		  return "Raiden Network Token"
		case .THB_ABT:
		  return "Arcblock"
		case .THB_MANA:
		  return "Decentraland"
		case .THB_INF:
		  return "InfinitusTokens"
		case .THB_CTXC:
		  return "Cortex Coin"
		case .THB_XLM:
		  return "Stellar"
		case .THB_SIX:
		  return "Six"
		case .THB_JFIN:
		  return "JFIN Coin"
		case .THB_EVX:
		  return "Everex"
		case .THB_BNB:
		  return "Binance's BNB Token"
		case .THB_POW:
		  return "Power Ledger"
		case .THB_DOGE:
		  return "Dogecoin"
		case .THB_DAI:
		  return "Dai Stablecoin"
		case .THB_BAND:
		  return "Band"
		case .THB_KSM:
		  return "Kusama"
		case .THB_DOT:
		  return "Polkadot"
		case .UNKNOWN:
			return "Unknown"
		}
	}

	enum CodingKeys: String, CodingKey {
		case name
	}
}
