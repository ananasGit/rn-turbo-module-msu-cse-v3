import Foundation
import Security

@objcMembers class RnTurboModuleMsuCseV3Impl: NSObject {
    
    private var cseInstance: CSE?
    private var isDevelopmentMode: Bool = false
    
    func initialize(developmentMode: Bool) {
        self.isDevelopmentMode = developmentMode
        self.cseInstance = CSE(developmentMode: developmentMode)
    }
    
    func encrypt(
        pan: String,
        cardHolderName: String,
        expiryYear: Int,
        expiryMonth: Int,
        cvv: String,
        nonce: String,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
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
    
    func encryptCVV(
        cvv: String,
        nonce: String,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
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
    
    func isValidPan(_ pan: String) -> Bool {
        guard let cse = cseInstance else {
            return false
        }
        return cse.isValidPan(pan)
    }
    
    func isValidCVV(_ cvv: String, pan: String?) -> Bool {
        guard let cse = cseInstance else {
            return false
        }
        
        if let pan = pan {
            return cse.isValidCVV(cvv: cvv, pan: pan)
        } else {
            return cse.isValidCVV(cvv)
        }
    }
    
    func isValidExpiry(month: Int, year: Int) -> Bool {
        guard let cse = cseInstance else {
            return false
        }
        return cse.isValidExpiry(month: month, year: year)
    }
    
    func detectBrand(_ pan: String) -> String {
        guard let cse = cseInstance else {
            return CardBrand.unknown.stringValue
        }
        let brand = cse.detectBrand(pan)
        return brand.stringValue
    }
    
    func isValidCardHolderName(_ name: String) -> Bool {
        guard let cse = cseInstance else {
            return false
        }
        return cse.isValidCardHolderName(name)
    }
    
    func isValidCardToken(_ token: String) -> Bool {
        guard let cse = cseInstance else {
            return false
        }
        return cse.isValidCardToken(token)
    }
    
    func getErrors() -> [String] {
        guard let cse = cseInstance else {
            return ["CSE Module not initialized"]
        }
        return cse.errors
    }
    
    func hasErrors() -> Bool {
        guard let cse = cseInstance else {
            return true
        }
        return cse.hasErrors
    }
}