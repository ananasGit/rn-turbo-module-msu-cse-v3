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
        @"https://entegrasyon.asseco-see.com.tr/msu/cse/publickey" : 
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

- (NSString *)encryptString:(NSString *)plainText withPublicKey:(NSString *)publicKeyString API_AVAILABLE(ios(10.0)) {
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
    SecKeyRef publicKey = [self createPublicKeyFromData:keyData];
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

- (SecKeyRef)createPublicKeyFromData:(NSData *)keyData API_AVAILABLE(ios(10.0)) {
    // Create attributes for the public key
    NSDictionary *attributes = @{
        (id)kSecAttrKeyType: (id)kSecAttrKeyTypeRSA,
        (id)kSecAttrKeyClass: (id)kSecAttrKeyClassPublic,
        (id)kSecAttrKeySizeInBits: @2048
    };
    
    CFErrorRef error = NULL;
    SecKeyRef publicKey = SecKeyCreateWithData((CFDataRef)keyData, (CFDictionaryRef)attributes, &error);
    
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

#pragma mark - Card Validation Methods

- (BOOL)isValidPan:(NSString *)pan {
    NSString *panDigits = [self digitsOnly:pan];
    return [self luhnCheck:panDigits] && [self isValidCardLength:panDigits];
}

- (BOOL)isValidCVV:(NSString *)cvv withPan:(NSString *)pan {
    if (cvv.length == 0) return NO;
    
    NSString *cvvDigits = [self digitsOnly:cvv];
    NSString *cardBrand = [self detectCardBrand:pan];
    
    if ([cardBrand isEqualToString:@"unknown"] && cvvDigits.length >= 3 && cvvDigits.length <= 4) {
        return YES;
    }
    if ([cardBrand isEqualToString:@"american-express"] && cvvDigits.length == 4) {
        return YES;
    }
    return cvvDigits.length == 3;
}

- (BOOL)isValidExpiryMonth:(NSInteger)month year:(NSInteger)year {
    if (month < 1 || month > 12) return NO;
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSInteger normalizedYear = [self normalizeYear:year];
    NSInteger currentYear = [calendar component:NSCalendarUnitYear fromDate:now];
    NSInteger currentMonth = [calendar component:NSCalendarUnitMonth fromDate:now];
    
    if (normalizedYear < currentYear) return NO;
    if (normalizedYear == currentYear && month < currentMonth) return NO;
    
    return YES;
}

- (NSString *)detectCardBrand:(NSString *)pan {
    NSString *panDigits = [self digitsOnly:pan];
    
    // American Express: 34, 37
    if ([self hasPrefix:panDigits prefixes:@[@"34", @"37"]]) {
        return @"american-express";
    }
    
    // Dinacard: 9891, 655670-655697, 657371-657398
    NSArray *dinacardPrefixes = @[@"9891", @"655670", @"655671", @"655672", @"655673", @"655674", @"655675", @"655676", @"655677", @"655678", @"655679", @"655680", @"655681", @"655682", @"655683", @"655684", @"655685", @"655686", @"655687", @"655688", @"655689", @"655690", @"655691", @"655692", @"655693", @"655694", @"655695", @"655696", @"655697", @"657371", @"657372", @"657373", @"657374", @"657375", @"657376", @"657377", @"657378", @"657379", @"657380", @"657381", @"657382", @"657383", @"657384", @"657385", @"657386", @"657387", @"657388", @"657389", @"657390", @"657391", @"657392", @"657393", @"657394", @"657395", @"657396", @"657397", @"657398"];
    if ([self hasPrefix:panDigits prefixes:dinacardPrefixes]) {
        return @"dinacard";
    }
    
    // Discover: 60, 64, 65
    if ([self hasPrefix:panDigits prefixes:@[@"60", @"64", @"65"]]) {
        return @"discover";
    }
    
    // JCB: 35
    if ([self hasPrefix:panDigits prefixes:@[@"35"]]) {
        return @"jcb";
    }
    
    // Diners Club: 300-305, 309, 36, 38, 39
    if ([self hasPrefix:panDigits prefixes:@[@"300", @"301", @"302", @"303", @"304", @"305", @"309", @"36", @"38", @"39"]]) {
        return @"diners-club";
    }
    
    // Visa: 4
    if ([self hasPrefix:panDigits prefixes:@[@"4"]]) {
        return @"visa";
    }
    
    // Maestro: 56, 58, 67, 502, 503, 506, 639, 5018, 6020
    if ([self hasPrefix:panDigits prefixes:@[@"56", @"58", @"67", @"502", @"503", @"506", @"639", @"5018", @"6020"]]) {
        return @"maestro";
    }
    
    // Mastercard: 2221-2720, 50-55, 67
    NSArray *mastercardPrefixes = @[@"2221", @"2222", @"2223", @"2224", @"2225", @"2226", @"2227", @"2228", @"2229", @"223", @"224", @"225", @"226", @"227", @"228", @"229", @"23", @"24", @"25", @"26", @"270", @"271", @"2720", @"50", @"51", @"52", @"53", @"54", @"55", @"67"];
    if ([self hasPrefix:panDigits prefixes:mastercardPrefixes]) {
        return @"mastercard";
    }
    
    // UnionPay: 62
    if ([self hasPrefix:panDigits prefixes:@[@"62"]]) {
        return @"union-pay";
    }
    
    // Troy: 979200-979299
    NSMutableArray *troyPrefixes = [NSMutableArray array];
    for (int i = 979200; i <= 979299; i++) {
        [troyPrefixes addObject:[NSString stringWithFormat:@"%d", i]];
    }
    if ([self hasPrefix:panDigits prefixes:troyPrefixes]) {
        return @"troy";
    }
    
    return @"unknown";
}

#pragma mark - Helper Methods

- (BOOL)luhnCheck:(NSString *)number {
    if (number.length == 0) return NO;
    
    NSInteger sum = 0;
    BOOL alternate = NO;
    
    for (NSInteger i = number.length - 1; i >= 0; i--) {
        NSInteger digit = [[number substringWithRange:NSMakeRange(i, 1)] integerValue];
        
        if (alternate) {
            digit *= 2;
            if (digit > 9) {
                digit = (digit % 10) + 1;
            }
        }
        
        sum += digit;
        alternate = !alternate;
    }
    
    return (sum % 10) == 0;
}

- (BOOL)isValidCardLength:(NSString *)pan {
    NSString *cardBrand = [self detectCardBrand:pan];
    NSInteger length = pan.length;
    
    if ([cardBrand isEqualToString:@"american-express"]) {
        return length == 15;
    } else if ([cardBrand isEqualToString:@"diners-club"]) {
        return length == 14;
    } else if ([cardBrand isEqualToString:@"visa"]) {
        return length == 16 || length == 19;
    } else if ([cardBrand isEqualToString:@"maestro"]) {
        return length >= 12 && length <= 19;
    } else if ([cardBrand isEqualToString:@"unknown"]) {
        return NO;
    } else {
        return length == 16;
    }
}

- (BOOL)hasPrefix:(NSString *)number prefixes:(NSArray<NSString *> *)prefixes {
    for (NSString *prefix in prefixes) {
        if ([number hasPrefix:prefix]) {
            return YES;
        }
    }
    return NO;
}

- (NSInteger)normalizeYear:(NSInteger)year {
    if (year >= 0 && year < 100) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSInteger currentYear = [calendar component:NSCalendarUnitYear fromDate:[NSDate date]];
        NSInteger century = (currentYear / 100) * 100;
        return century + year;
    }
    return year;
}

@end