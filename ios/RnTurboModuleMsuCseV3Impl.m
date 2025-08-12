#import "RnTurboModuleMsuCseV3Impl.h"
#import "CSE.h"
#import "CardBrand.h"

@implementation RnTurboModuleMsuCseV3Impl

- (instancetype)init {
    if (self = [super init]) {
        self.isDevelopmentMode = NO;
        self.cseInstance = nil;
    }
    return self;
}

- (void)initializeWithDevelopmentMode:(BOOL)developmentMode {
    self.isDevelopmentMode = developmentMode;
    self.cseInstance = [[CSE alloc] initWithDevelopmentMode:developmentMode];
}

- (void)encryptWithPan:(NSString *)pan
        cardHolderName:(NSString *)cardHolderName
            expiryYear:(NSInteger)expiryYear
           expiryMonth:(NSInteger)expiryMonth
                   cvv:(NSString *)cvv
                 nonce:(NSString *)nonce
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject {
    
    if (!self.cseInstance) {
        reject(@"NOT_INITIALIZED", @"CSE Module not initialized. Call initialize() first.", nil);
        return;
    }
    
    [self.cseInstance encryptCardWithPan:pan
                          cardHolderName:cardHolderName
                              expiryYear:expiryYear
                             expiryMonth:expiryMonth
                                     cvv:cvv
                                   nonce:nonce
                                 success:^(NSString *encrypted) {
                                     resolve(encrypted);
                                 }
                                 failure:^(NSString *error) {
                                     reject(@"ENCRYPTION_ERROR", error, nil);
                                 }];
}

- (void)encryptCVVWithCvv:(NSString *)cvv
                    nonce:(NSString *)nonce
                  resolve:(RCTPromiseResolveBlock)resolve
                   reject:(RCTPromiseRejectBlock)reject {
    
    if (!self.cseInstance) {
        reject(@"NOT_INITIALIZED", @"CSE Module not initialized. Call initialize() first.", nil);
        return;
    }
    
    [self.cseInstance encryptCVVOnlyWithCvv:cvv
                                      nonce:nonce
                                    success:^(NSString *encrypted) {
                                        resolve(encrypted);
                                    }
                                    failure:^(NSString *error) {
                                        reject(@"ENCRYPTION_ERROR", error, nil);
                                    }];
}

- (BOOL)isValidPan:(NSString *)pan {
    if (!self.cseInstance) {
        return NO;
    }
    return [self.cseInstance isValidPan:pan];
}

- (BOOL)isValidCVV:(NSString *)cvv pan:(nullable NSString *)pan {
    if (!self.cseInstance) {
        return NO;
    }
    
    if (pan) {
        return [self.cseInstance isValidCVV:cvv pan:pan];
    } else {
        return [self.cseInstance isValidCVV:cvv];
    }
}

- (BOOL)isValidExpiryWithMonth:(NSInteger)month year:(NSInteger)year {
    if (!self.cseInstance) {
        return NO;
    }
    return [self.cseInstance isValidExpiryWithMonth:month year:year];
}

- (NSString *)detectBrand:(NSString *)pan {
    if (!self.cseInstance) {
        return [CardBrand stringValueForBrand:CardBrandUnknown];
    }
    CardBrandType brand = [self.cseInstance detectBrand:pan];
    return [CardBrand stringValueForBrand:brand];
}

- (BOOL)isValidCardHolderName:(NSString *)name {
    if (!self.cseInstance) {
        return NO;
    }
    return [self.cseInstance isValidCardHolderName:name];
}

- (BOOL)isValidCardToken:(NSString *)token {
    if (!self.cseInstance) {
        return NO;
    }
    return [self.cseInstance isValidCardToken:token];
}

- (NSArray<NSString *> *)getErrors {
    if (!self.cseInstance) {
        return @[@"CSE Module not initialized"];
    }
    return [self.cseInstance errors];
}

- (BOOL)hasErrors {
    if (!self.cseInstance) {
        return YES;
    }
    return [self.cseInstance hasErrors];
}

@end