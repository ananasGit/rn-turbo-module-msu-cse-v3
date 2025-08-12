//
//  CardBrand.swift
//  MsuCse
//
//  Created by Jasmin Suljic on 25/12/2019.
//

import Foundation

@objc public enum CardBrand: Int, CaseIterable {
    case Visa = 0
    case Mastercard = 1
    case Maestro = 2
    case AmericanExpress = 3
    case DinersClub = 4
    case Discover = 5
    case Jcb = 6
    case Troy = 7
    case Dinacard = 8
    case UnionPay = 9
    case Unknown = 10
    
    public var stringValue: String {
        switch self {
        case .Visa: return "visa"
        case .Mastercard: return "mastercard"
        case .Maestro: return "maestro"
        case .AmericanExpress: return "american-express"
        case .DinersClub: return "diners-club"
        case .Discover: return "discover"
        case .Jcb: return "jcb"
        case .Troy: return "troy"
        case .Dinacard: return "dinacard"
        case .UnionPay: return "union-pay"
        case .Unknown: return "unknown"
        }
    }
}
