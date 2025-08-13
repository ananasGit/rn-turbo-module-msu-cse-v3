#import "RSAEncryption.h"
#import <Security/Security.h>

@implementation RSAEncryption

+ (nullable NSString *)encryptWithPublicKey:(NSString *)publicKey plainText:(NSString *)plainText {
    if (!publicKey || !plainText) return nil;
    
    NSData *plainData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    if (!plainData) return nil;
    
    @try {
        NSData *encryptedData = [self encryptWithRSAPublicKeyData:plainData pubkeyBase64:publicKey tagName:@""];
        if (!encryptedData) return nil;
        
        return [encryptedData base64EncodedStringWithOptions:0];
    } @catch (NSException *exception) {
        return nil;
    }
}

+ (nullable NSData *)encryptWithRSAPublicKeyData:(NSData *)data 
                                    pubkeyBase64:(NSString *)pubkeyBase64 
                                         tagName:(NSString *)tagName {
    
    // Create unique tag name using hash of public key (matching PaytenASEE logic)
    NSString *tagName1 = [NSString stringWithFormat:@"PUBLIC-%lu", (unsigned long)[pubkeyBase64 hash]];
    
    SecKeyRef keyRef = [self getRSAKeyFromKeychain:tagName1];
    if (keyRef == NULL) {
        keyRef = [self addRSAPublicKey:pubkeyBase64 tagName:tagName1];
    }
    
    if (keyRef == NULL) {
        return nil;
    }
    
    NSData *result = [self encryptWithRSAKey:data rsaKeyRef:keyRef];
    CFRelease(keyRef);
    return result;
}

+ (nullable NSData *)encryptWithRSAKey:(NSData *)data rsaKeyRef:(SecKeyRef)rsaKeyRef {
    // Use OAEP SHA256 algorithm to match PaytenASEE implementation
    SecKeyAlgorithm algorithm = kSecKeyAlgorithmRSAEncryptionOAEPSHA256;
    CFErrorRef error = NULL;
    
    CFDataRef cipherText = SecKeyCreateEncryptedData(rsaKeyRef, algorithm, (__bridge CFDataRef)data, &error);
    
    if (error) {
        CFRelease(error);
        return nil;
    }
    
    if (!cipherText) return nil;
    
    NSData *result = (__bridge_transfer NSData *)cipherText;
    return result;
}

+ (nullable SecKeyRef)addRSAPublicKey:(NSString *)pubkeyBase64 tagName:(NSString *)tagName {
    // Clean the public key (remove PEM headers and whitespace)
    NSString *cleanedKey = [self cleanPublicKey:pubkeyBase64];
    if (!cleanedKey) return NULL;
    
    // Decode base64
    NSData *pubkeyData = [[NSData alloc] initWithBase64EncodedString:cleanedKey 
                                                             options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (!pubkeyData) return NULL;
    
    // Delete any existing key with same tag
    [self deleteRSAKeyFromKeychain:tagName];
    
    // Add key to keychain
    NSDictionary *queryFilter = @{
        (__bridge NSString *)kSecClass: (__bridge NSString *)kSecClassKey,
        (__bridge NSString *)kSecAttrKeyType: (__bridge NSString *)kSecAttrKeyTypeRSA,
        (__bridge NSString *)kSecAttrApplicationTag: tagName,
        (__bridge NSString *)kSecValueData: pubkeyData,
        (__bridge NSString *)kSecAttrKeyClass: (__bridge NSString *)kSecAttrKeyClassPublic,
        (__bridge NSString *)kSecReturnPersistentRef: @YES
    };
    
    OSStatus result = SecItemAdd((__bridge CFDictionaryRef)queryFilter, NULL);
    if (result != noErr && result != errSecDuplicateItem) {
        return NULL;
    }
    
    return [self getRSAKeyFromKeychain:tagName];
}

+ (nullable SecKeyRef)getRSAKeyFromKeychain:(NSString *)tagName {
    NSDictionary *queryFilter = @{
        (__bridge NSString *)kSecClass: (__bridge NSString *)kSecClassKey,
        (__bridge NSString *)kSecAttrKeyType: (__bridge NSString *)kSecAttrKeyTypeRSA,
        (__bridge NSString *)kSecAttrApplicationTag: tagName,
        (__bridge NSString *)kSecReturnRef: @YES
    };
    
    CFTypeRef keyPtr = NULL;
    OSStatus result = SecItemCopyMatching((__bridge CFDictionaryRef)queryFilter, &keyPtr);
    
    if (result != noErr || keyPtr == NULL) {
        return NULL;
    }
    
    return (SecKeyRef)keyPtr;
}

+ (void)deleteRSAKeyFromKeychain:(NSString *)tagName {
    NSDictionary *queryFilter = @{
        (__bridge NSString *)kSecClass: (__bridge NSString *)kSecClassKey,
        (__bridge NSString *)kSecAttrKeyType: (__bridge NSString *)kSecAttrKeyTypeRSA,
        (__bridge NSString *)kSecAttrApplicationTag: tagName
    };
    
    SecItemDelete((__bridge CFDictionaryRef)queryFilter);
}

+ (nullable NSString *)cleanPublicKey:(NSString *)publicKey {
    if (!publicKey) return nil;
    
    NSMutableString *cleaned = [publicKey mutableCopy];
    
    // Remove PEM headers and footers
    [cleaned replaceOccurrencesOfString:@"-----BEGIN PUBLIC KEY-----" withString:@"" options:0 range:NSMakeRange(0, cleaned.length)];
    [cleaned replaceOccurrencesOfString:@"-----END PUBLIC KEY-----" withString:@"" options:0 range:NSMakeRange(0, cleaned.length)];
    [cleaned replaceOccurrencesOfString:@"-----BEGIN RSA PUBLIC KEY-----" withString:@"" options:0 range:NSMakeRange(0, cleaned.length)];
    [cleaned replaceOccurrencesOfString:@"-----END RSA PUBLIC KEY-----" withString:@"" options:0 range:NSMakeRange(0, cleaned.length)];
    
    // Remove whitespace and newlines
    [cleaned replaceOccurrencesOfString:@"\n" withString:@"" options:0 range:NSMakeRange(0, cleaned.length)];
    [cleaned replaceOccurrencesOfString:@"\r" withString:@"" options:0 range:NSMakeRange(0, cleaned.length)];
    [cleaned replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, cleaned.length)];
    [cleaned replaceOccurrencesOfString:@"\t" withString:@"" options:0 range:NSMakeRange(0, cleaned.length)];
    
    return [cleaned copy];
}

@end