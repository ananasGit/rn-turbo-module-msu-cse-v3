#import "CSE.h"
#import "CardUtils.h"
#import "RSAEncryption.h"

typedef NS_ENUM(NSInteger, EncryptionErrorType) {
    EncryptionErrorTypeRequestFailed,
    EncryptionErrorTypeUnknownException,
    EncryptionErrorTypeValidationFailed,
    EncryptionErrorTypePublicKeyEncodingFailed,
    EncryptionErrorTypeEncryptionFailed
};

@interface EncryptionError : NSError
@property (nonatomic, assign) EncryptionErrorType errorType;
+ (instancetype)errorWithType:(EncryptionErrorType)type description:(NSString *)description;
@end

@implementation EncryptionError
+ (instancetype)errorWithType:(EncryptionErrorType)type description:(NSString *)description {
    EncryptionError *error = [[EncryptionError alloc] initWithDomain:@"CSEEncryptionError" code:type userInfo:@{NSLocalizedDescriptionKey: description}];
    error.errorType = type;
    return error;
}
@end

// Forward declarations
@protocol EncryptRequest <NSObject>
- (BOOL)validate;
- (NSArray<NSString *> *)errors;
- (NSString *)plain;
@end

@protocol CSEApi <NSObject>
- (void)fetchPublicKeyWithCallback:(void(^)(NSString * _Nullable publicKey, NSError * _Nullable error))callback;
@end

@interface CSEApiImpl : NSObject <CSEApi>
@property (nonatomic, assign) BOOL developmentMode;
@property (nonatomic, strong, nullable) NSString *publicKey;
- (instancetype)initWithDevelopmentMode:(BOOL)developmentMode;
@end

@interface CvvEncryptionRequest : NSObject <EncryptRequest>
@property (nonatomic, strong) NSString *cvv;
@property (nonatomic, strong) NSString *nonce;
@property (nonatomic, strong) NSMutableArray<NSString *> *_errors;
- (instancetype)initWithCvv:(NSString *)cvv nonce:(NSString *)nonce;
@end

@interface CardEncryptRequest : NSObject <EncryptRequest>
@property (nonatomic, strong) NSString *pan;
@property (nonatomic, strong) NSString *cardHolderName;
@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) NSInteger month;
@property (nonatomic, strong) NSString *cvv;
@property (nonatomic, strong) NSString *nonce;
@property (nonatomic, strong) NSMutableArray<NSString *> *_errors;
- (instancetype)initWithPan:(NSString *)pan cardHolderName:(NSString *)cardHolderName year:(NSInteger)year month:(NSInteger)month cvv:(NSString *)cvv nonce:(NSString *)nonce;
@end

@interface CSE ()
@property (nonatomic, strong) NSMutableArray<NSString *> *_errors;
@property (nonatomic, strong) id<CSEApi> cseApi;
@end

@implementation CSE

- (instancetype)initWithDevelopmentMode:(BOOL)developmentMode {
    if (self = [super init]) {
        self._errors = [[NSMutableArray alloc] init];
        self.cseApi = [[CSEApiImpl alloc] initWithDevelopmentMode:developmentMode];
    }
    return self;
}

- (NSArray<NSString *> *)errors {
    return [self._errors copy];
}

- (BOOL)hasErrors {
    return self._errors.count > 0;
}

- (BOOL)isValidCVV:(NSString *)cvv {
    return [CardUtils isValidCVV:cvv];
}

- (BOOL)isValidCVV:(NSString *)cvv pan:(NSString *)pan {
    return [CardUtils isValidCVV:cvv pan:pan];
}

- (BOOL)isValidCardHolderName:(NSString *)name {
    return [CardUtils isValidCardHolderName:name];
}

- (BOOL)isValidPan:(NSString *)pan {
    return [CardUtils isValidPan:pan];
}

- (BOOL)isValidCardToken:(NSString *)token {
    return [CardUtils isValidCardToken:token];
}

- (CardBrandType)detectBrand:(NSString *)pan {
    return [CardUtils possibleCardBrand:pan];
}

- (BOOL)isValidExpiryWithMonth:(NSInteger)month year:(NSInteger)year {
    return [CardUtils isValidExpiryWithMonth:month year:year];
}

- (void)encryptCVVOnlyWithCvv:(NSString *)cvv nonce:(NSString *)nonce success:(EncryptSuccessBlock)success failure:(EncryptFailureBlock)failure {
    CvvEncryptionRequest *request = [[CvvEncryptionRequest alloc] initWithCvv:cvv nonce:nonce];
    [self encryptRequest:request success:success failure:failure];
}

- (void)encryptCardWithPan:(NSString *)pan cardHolderName:(NSString *)cardHolderName expiryYear:(NSInteger)expiryYear expiryMonth:(NSInteger)expiryMonth cvv:(NSString *)cvv nonce:(NSString *)nonce success:(EncryptSuccessBlock)success failure:(EncryptFailureBlock)failure {
    CardEncryptRequest *request = [[CardEncryptRequest alloc] initWithPan:pan cardHolderName:cardHolderName year:expiryYear month:expiryMonth cvv:cvv nonce:nonce];
    [self encryptRequest:request success:success failure:failure];
}

- (void)encryptRequest:(id<EncryptRequest>)request success:(EncryptSuccessBlock)success failure:(EncryptFailureBlock)failure {
    [self._errors removeAllObjects];
    
    if (![request validate]) {
        self._errors = [[request errors] mutableCopy];
        dispatch_async(dispatch_get_main_queue(), ^{
            failure(@"Validation failed");
        });
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.cseApi fetchPublicKeyWithCallback:^(NSString * _Nullable publicKey, NSError * _Nullable error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(error.localizedDescription);
                });
            } else if (publicKey) {
                NSString *plainText = [request plain];
                NSString *encrypted = [RSAEncryption encryptWithPublicKey:publicKey plainText:plainText];
                if (encrypted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        success(encrypted);
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        failure(@"Encryption failed");
                    });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure(@"Public key fetch failed");
                });
            }
        }];
    });
}

@end

// MARK: - CSEApiImpl

@implementation CSEApiImpl

- (instancetype)initWithDevelopmentMode:(BOOL)developmentMode {
    if (self = [super init]) {
        self.developmentMode = developmentMode;
    }
    return self;
}

- (NSString *)endpoint {
    if (self.developmentMode) {
        return @"https://test.merchantsafeunipay.com/msu/cse/publickey";
    } else {
        return @"https://merchantsafeunipay.com/msu/cse/publickey";
    }
}

- (void)fetchPublicKeyWithCallback:(void(^)(NSString * _Nullable publicKey, NSError * _Nullable error))callback {
    if (self.publicKey) {
        callback(self.publicKey, nil);
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[self endpoint]];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            callback(nil, error);
        } else if (data) {
            NSError *jsonError;
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError) {
                callback(nil, jsonError);
            } else {
                NSString *publicKey = result[@"publicKey"];
                if (publicKey) {
                    self.publicKey = publicKey;
                    callback(publicKey, nil);
                } else {
                    NSError *error = [NSError errorWithDomain:@"CSE" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Missing public key in response"}];
                    callback(nil, error);
                }
            }
        } else {
            NSError *error = [NSError errorWithDomain:@"CSE" code:1 userInfo:@{NSLocalizedDescriptionKey: @"No data received"}];
            callback(nil, error);
        }
    }];
    [task resume];
}

@end

// MARK: - CvvEncryptionRequest

@implementation CvvEncryptionRequest

- (instancetype)initWithCvv:(NSString *)cvv nonce:(NSString *)nonce {
    if (self = [super init]) {
        self.cvv = cvv;
        self.nonce = nonce;
        self._errors = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)validate {
    [self._errors removeAllObjects];
    
    if (![CardUtils isValidCVV:self.cvv]) {
        [self._errors addObject:@"CVV_INVALID"];
    }
    
    if (![CardUtils validateNonce:self.nonce]) {
        [self._errors addObject:@"NONCE_MISSING_OR_INVALID"];
    }
    
    return self._errors.count == 0;
}

- (NSArray<NSString *> *)errors {
    return [self._errors copy];
}

- (NSString *)plain {
    return [NSString stringWithFormat:@"c=%@&n=%@", self.cvv, self.nonce];
}

@end

// MARK: - CardEncryptRequest

@implementation CardEncryptRequest

- (instancetype)initWithPan:(NSString *)pan cardHolderName:(NSString *)cardHolderName year:(NSInteger)year month:(NSInteger)month cvv:(NSString *)cvv nonce:(NSString *)nonce {
    if (self = [super init]) {
        self.pan = [CardUtils digitsOnly:pan];
        self.cardHolderName = cardHolderName;
        self.year = year;
        self.month = month;
        self.cvv = [CardUtils digitsOnly:cvv];
        self.nonce = nonce;
        self._errors = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)validate {
    [self._errors removeAllObjects];
    
    if (![CardUtils isValidPan:self.pan]) {
        [self._errors addObject:@"PAN_INVALID"];
    }
    
    if (![CardUtils isValidExpiryWithMonth:self.month year:self.year]) {
        [self._errors addObject:@"EXPIRY_INVALID"];
    }
    
    if (![CardUtils isValidCardHolderName:self.cardHolderName]) {
        [self._errors addObject:@"CARD_HOLDER_NAME_INVALID"];
    }
    
    if (![CardUtils isValidCVV:self.cvv pan:self.pan]) {
        [self._errors addObject:@"CVV_INVALID"];
    }
    
    if (![CardUtils validateNonce:self.nonce]) {
        [self._errors addObject:@"NONCE_MISSING_OR_INVALID"];
    }
    
    return self._errors.count == 0;
}

- (NSArray<NSString *> *)errors {
    return [self._errors copy];
}

- (NSString *)paddedMonth:(NSInteger)month {
    if (month < 10) {
        return [NSString stringWithFormat:@"0%ld", (long)month];
    } else {
        return [NSString stringWithFormat:@"%ld", (long)month];
    }
}

- (NSString *)plain {
    return [NSString stringWithFormat:@"p=%@&y=%ld&m=%@&c=%@&cn=%@&n=%@", 
            self.pan, (long)self.year, [self paddedMonth:self.month], self.cvv, self.cardHolderName, self.nonce];
}

@end