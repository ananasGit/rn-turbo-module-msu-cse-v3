import Foundation
import Security

@objc public class RnTurboModuleMsuCseV3Impl: NSObject {
    
    private var cseInstance: CSE?
    private var isDevelopmentMode: Bool = false
    
    @objc public func initialize(developmentMode: Bool) {
        self.isDevelopmentMode = developmentMode
        self.cseInstance = CSE(developmentMode: developmentMode)
    }
    
    @objc public func encrypt(
        pan: String,
        cardHolderName: String,
        expiryYear: Int,
        expiryMonth: Int,
        cvv: String,
        nonce: String,
        resolve: @escaping (Any?) -> Void,
        reject: @escaping (String?, String?, Error?) -> Void
    ) {
        guard let cse = cseInstance else {
            reject("NOT_INITIALIZED", "CSE Module not initialized. Call initialize() first.", nil)
            return
        }
        
        cse.encryptCard(
            pan: pan,
            cardHolderName: cardHolderName,
            expiryYear: expiryYear,
            expiryMonth: expiryMonth,
            cvv: cvv,
            nonce: nonce,
            success: { encrypted in
                resolve(encrypted)
            },
            failure: { error in
                reject("ENCRYPTION_ERROR", error, nil)
            }
        )
    }
    
    @objc public func encryptCVV(
        cvv: String,
        nonce: String,
        resolve: @escaping (Any?) -> Void,
        reject: @escaping (String?, String?, Error?) -> Void
    ) {
        guard let cse = cseInstance else {
            reject("NOT_INITIALIZED", "CSE Module not initialized. Call initialize() first.", nil)
            return
        }
        
        cse.encryptCVVOnly(
            cvv: cvv,
            nonce: nonce,
            success: { encrypted in
                resolve(encrypted)
            },
            failure: { error in
                reject("ENCRYPTION_ERROR", error, nil)
            }
        )
    }
    
    @objc public func isValidPan(_ pan: String) -> Bool {
        guard let cse = cseInstance else {
            return false
        }
        return cse.isValidPan(pan)
    }
    
    @objc public func isValidCVV(_ cvv: String, pan: String?) -> Bool {
        guard let cse = cseInstance else {
            return false
        }
        
        if let pan = pan {
            return cse.isValidCVV(cvv: cvv, pan: pan)
        } else {
            return cse.isValidCVV(cvv)
        }
    }
    
    @objc public func isValidExpiry(month: Int, year: Int) -> Bool {
        guard let cse = cseInstance else {
            return false
        }
        return cse.isValidExpiry(month: month, year: year)
    }
    
    @objc public func detectBrand(_ pan: String) -> String {
        guard let cse = cseInstance else {
            return CardBrand.Unknown.stringValue
        }
        let brand = cse.detectBrand(pan)
        return brand.stringValue
    }
    
    @objc public func isValidCardHolderName(_ name: String) -> Bool {
        guard let cse = cseInstance else {
            return false
        }
        return cse.isValidCardHolderName(name)
    }
    
    @objc public func isValidCardToken(_ token: String) -> Bool {
        guard let cse = cseInstance else {
            return false
        }
        return cse.isValidCardToken(token)
    }
    
    @objc public func getErrors() -> [String] {
        guard let cse = cseInstance else {
            return ["CSE Module not initialized"]
        }
        return cse.errors
    }
    
    @objc public func hasErrors() -> Bool {
        guard let cse = cseInstance else {
            return true
        }
        return cse.hasErrors
    }
}