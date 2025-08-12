#import "CSEBridge.h"
#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>

@interface CSEBridge()
@property (nonatomic, assign) BOOL developmentMode;
@property (nonatomic, strong) NSString *cachedPublicKey;
@end

@implementation CSEBridge

- (instancetype)initWithDevelopmentMode:(BOOL)developmentMode {
    self = [super init];
    if (self) {
        _developmentMode = developmentMode;
    }
    return self;
}

- (void)encryptWithPan:(NSString *)pan
        cardHolderName:(NSString *)cardHolderName
            expiryYear:(NSInteger)expiryYear
           expiryMonth:(NSInteger)expiryMonth
                   cvv:(NSString *)cvv
                 nonce:(NSString *)nonce
             onSuccess:(void(^)(NSString *encryptedData))onSuccess
               onError:(void(^)(NSString *code, NSString *message))onError {
    
    // Basic validation
    if (!pan || pan.length == 0) {
        onError(@"VALIDATION_FAILED", @"PAN is required");
        return;
    }
    
    if (!cvv || cvv.length == 0) {
        onError(@"VALIDATION_FAILED", @"CVV is required");
        return;
    }
    
    if (!nonce || nonce.length == 0) {
        onError(@"VALIDATION_FAILED", @"Nonce is required");
        return;
    }
    
    // Use real RSA encryption with native Objective-C
    [self performEncryptionWithPan:pan 
                    cardHolderName:cardHolderName 
                        expiryYear:expiryYear 
                       expiryMonth:expiryMonth 
                               cvv:cvv 
                             nonce:nonce 
                         onSuccess:onSuccess 
                           onError:onError];
}

- (void)performEncryptionWithPan:(NSString *)pan
                  cardHolderName:(NSString *)cardHolderName
                      expiryYear:(NSInteger)expiryYear
                     expiryMonth:(NSInteger)expiryMonth
                             cvv:(NSString *)cvv
                           nonce:(NSString *)nonce
                       onSuccess:(void(^)(NSString *encryptedData))onSuccess
                         onError:(void(^)(NSString *code, NSString *message))onError {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // First fetch the public key
        [self fetchPublicKeyWithCompletion:^(NSString *publicKey, NSError *error) {
            if (error || !publicKey) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    onError(@"PUBLIC_KEY_FETCH_FAILED", error.localizedDescription ?: @"Failed to fetch public key");
                });
                return;
            }
            
            // Create the plain text payload
            NSString *paddedMonth = expiryMonth < 10 ? [NSString stringWithFormat:@"0%ld", (long)expiryMonth] : [NSString stringWithFormat:@"%ld", (long)expiryMonth];
            NSString *plainText = [NSString stringWithFormat:@"p=%@&y=%ld&m=%@&c=%@&cn=%@&n=%@", 
                                 [self digitsOnly:pan], 
                                 (long)expiryYear, 
                                 paddedMonth, 
                                 [self digitsOnly:cvv], 
                                 cardHolderName, 
                                 nonce];
            
            // Encrypt the payload
            NSString *encryptedData = [self encryptString:plainText withPublicKey:publicKey];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (encryptedData) {
                    onSuccess(encryptedData);
                } else {
                    onError(@"ENCRYPTION_FAILED", @"Failed to encrypt data");
                }
            });
        }];
    });
}

- (void)fetchPublicKeyWithCompletion:(void(^)(NSString *publicKey, NSError *error))completion {
    if (self.cachedPublicKey) {
        completion(self.cachedPublicKey, nil);
        return;
    }
    
    NSString *endpoint = self.developmentMode ? 
        @"https://test.merchantsafeunipay.com/msu/cse/publickey" : 
        @"https://merchantsafeunipay.com/msu/cse/publickey";
    
    NSURL *url = [NSURL URLWithString:endpoint];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        
        if (!data) {
            completion(nil, [NSError errorWithDomain:@"CSEError" code:1001 userInfo:@{NSLocalizedDescriptionKey: @"No data received"}]);
            return;
        }
        
        NSError *jsonError;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError || !jsonResponse) {
            completion(nil, jsonError ?: [NSError errorWithDomain:@"CSEError" code:1002 userInfo:@{NSLocalizedDescriptionKey: @"Invalid JSON response"}]);
            return;
        }
        
        NSString *publicKey = jsonResponse[@"publicKey"];
        if (!publicKey) {
            completion(nil, [NSError errorWithDomain:@"CSEError" code:1003 userInfo:@{NSLocalizedDescriptionKey: @"Public key not found in response"}]);
            return;
        }
        
        self.cachedPublicKey = publicKey;
        completion(publicKey, nil);
    }];
    
    [task resume];
}

- (NSString *)encryptString:(NSString *)plainText withPublicKey:(NSString *)publicKeyString {
    // Clean up the public key string
    NSString *cleanedKey = [publicKeyString stringByReplacingOccurrencesOfString:@"-----BEGIN PUBLIC KEY-----" withString:@""];
    cleanedKey = [cleanedKey stringByReplacingOccurrencesOfString:@"-----END PUBLIC KEY-----" withString:@""];
    cleanedKey = [cleanedKey stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    cleanedKey = [cleanedKey stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    cleanedKey = [cleanedKey stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // Decode the base64 key
    NSData *keyData = [[NSData alloc] initWithBase64EncodedString:cleanedKey options:0];
    if (!keyData) {
        return nil;
    }
    
    // Create SecKey from the data
    SecKey *publicKey = [self createPublicKeyFromData:keyData];
    if (!publicKey) {
        return nil;
    }
    
    // Convert string to data
    NSData *plainData = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    
    // Encrypt using RSA OAEP with SHA256
    CFErrorRef error = NULL;
    NSData *encryptedData = (NSData *)CFBridgingRelease(
        SecKeyCreateEncryptedData(publicKey, kSecKeyAlgorithmRSAEncryptionOAEPSHA256, (CFDataRef)plainData, &error)
    );
    
    CFRelease(publicKey);
    
    if (error || !encryptedData) {
        if (error) CFRelease(error);
        return nil;
    }
    
    // Return base64 encoded result
    return [encryptedData base64EncodedStringWithOptions:0];
}

- (SecKey *)createPublicKeyFromData:(NSData *)keyData {
    // Create attributes for the public key
    NSDictionary *attributes = @{
        (id)kSecAttrKeyType: (id)kSecAttrKeyTypeRSA,
        (id)kSecAttrKeyClass: (id)kSecAttrKeyClassPublic,
        (id)kSecAttrKeySizeInBits: @2048
    };
    
    CFErrorRef error = NULL;
    SecKey *publicKey = SecKeyCreateWithData((CFDataRef)keyData, (CFDictionaryRef)attributes, &error);
    
    if (error) {
        CFRelease(error);
        return NULL;
    }
    
    return publicKey;
}

- (NSString *)digitsOnly:(NSString *)string {
    NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return [[string componentsSeparatedByCharactersInSet:nonDigits] componentsJoinedByString:@""];
}

@end