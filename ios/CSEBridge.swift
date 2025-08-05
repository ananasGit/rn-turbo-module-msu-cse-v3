import Foundation

@objc public class CSEBridge: NSObject {
    private let cse: CSE
    
    @objc public init(developmentMode: Bool) {
        self.cse = CSE(developmentMode: developmentMode)
        super.init()
    }
    
    @objc public func encrypt(pan: String,
                             cardHolderName: String,
                             expiryYear: Int,
                             expiryMonth: Int,
                             cvv: String,
                             nonce: String,
                             callback: @escaping (CSEEncryptResult) -> Void) {
        
        cse.encrypt(pan: pan,
                   cardHolderName: cardHolderName,
                   expiryYear: expiryYear,
                   expiryMonth: expiryMonth,
                   cvv: cvv,
                   nonce: nonce) { result in
            
            let bridgeResult = CSEEncryptResult()
            
            switch result {
            case .success(let encryptedData):
                bridgeResult.type = CSEEncryptResultTypeSuccess
                bridgeResult.data = encryptedData
            case .error(let error):
                bridgeResult.type = CSEEncryptResultTypeError
                let bridgeError = CSEEncryptError()
                bridgeError.code = self.errorCodeString(error)
                bridgeError.message = self.errorMessage(error)
                bridgeResult.error = bridgeError
            }
            
            callback(bridgeResult)
        }
    }
    
    private func errorCodeString(_ error: EncryptionError) -> String {
        switch error {
        case .requestFailed:
            return "REQUEST_FAILED"
        case .unknownException:
            return "UNKNOWN_EXCEPTION"
        case .validationFailed:
            return "VALIDATION_FAILED"
        case .publicKeyEncodingFailed:
            return "PUBLIC_KEY_ENCODING_FAILED"
        case .encryptionFailed:
            return "ENCRYPTION_FAILED"
        }
    }
    
    private func errorMessage(_ error: EncryptionError) -> String {
        switch error {
        case .requestFailed:
            return "Request failed"
        case .unknownException(let underlyingError):
            return "Unknown exception: \(underlyingError.localizedDescription)"
        case .validationFailed:
            return "Validation failed"
        case .publicKeyEncodingFailed(let message):
            return "Public key encoding failed: \(message)"
        case .encryptionFailed(let message):
            return "Encryption failed: \(message)"
        }
    }
}
