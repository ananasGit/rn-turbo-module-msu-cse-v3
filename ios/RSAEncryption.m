#import "RSAEncryption.h"
#import <Security/Security.h>

@implementation RSAEncryption

+ (nullable NSString *)encryptWithPublicKey:(NSString *)publicKey plainText:(NSString *)plainText {
    if (!publicKey || !plainText) return nil;
    
    // Remove PEM headers/footers and whitespace
    NSString *cleanKey = [self cleanPublicKey:publicKey];
    if (!cleanKey) return nil;
    
    // Create SecKey from the public key string
    SecKeyRef secKey = [self createSecKeyFromPublicKey:cleanKey];
    if (!secKey) return nil;
    
    // Convert plain text to data
    NSData *plainData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    if (!plainData) {
        CFRelease(secKey);
        return nil;
    }
    
    // Encrypt the data
    CFErrorRef error = NULL;
    NSData *encryptedData = (NSData *)CFBridgingRelease(
        SecKeyCreateEncryptedData(secKey, kSecKeyAlgorithmRSAEncryptionPKCS1, (CFDataRef)plainData, &error)
    );
    
    CFRelease(secKey);
    
    if (error) {
        CFRelease(error);
        return nil;
    }
    
    if (!encryptedData) return nil;
    
    // Return base64 encoded result
    return [encryptedData base64EncodedStringWithOptions:0];
}

+ (nullable NSString *)cleanPublicKey:(NSString *)publicKey {
    if (!publicKey) return nil;
    
    NSMutableString *cleaned = [publicKey mutableCopy];
    
    // Remove common PEM headers and footers
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

+ (nullable SecKeyRef)createSecKeyFromPublicKey:(NSString *)publicKey {
    // Decode base64
    NSData *keyData = [[NSData alloc] initWithBase64EncodedString:publicKey options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (!keyData) return NULL;
    
    // Create SecKey attributes
    NSDictionary *attributes = @{
        (NSString *)kSecAttrKeyType: (NSString *)kSecAttrKeyTypeRSA,
        (NSString *)kSecAttrKeyClass: (NSString *)kSecAttrKeyClassPublic,
        (NSString *)kSecAttrKeySizeInBits: @2048
    };
    
    CFErrorRef error = NULL;
    SecKeyRef secKey = SecKeyCreateWithData((CFDataRef)keyData, (CFDictionaryRef)attributes, &error);
    
    if (error) {
        CFRelease(error);
        return NULL;
    }
    
    return secKey;
}

@end