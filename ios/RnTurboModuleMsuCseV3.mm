#import "RnTurboModuleMsuCseV3.h"
#import "RnTurboModuleMsuCseV3-Swift.h"

@interface RnTurboModuleMsuCseV3()

@property (nonatomic, strong) CSE *cse;

@end

@implementation RnTurboModuleMsuCseV3
RCT_EXPORT_MODULE()

- (void)initialize:(BOOL)developmentMode {
    self.cse = [[CSE alloc] initWithDevelopmentMode:developmentMode];
}

- (void)encrypt:(NSString *)pan
    cardHolderName:(NSString *)cardHolderName
    expiryYear:(double)expiryYear
    expiryMonth:(double)expiryMonth
    cvv:(NSString *)cvv
    nonce:(NSString *)nonce
    resolve:(RCTPromiseResolveBlock)resolve
    reject:(RCTPromiseRejectBlock)reject {
    
    if (self.cse == nil) {
        reject(@"NOT_INITIALIZED", @"CSE Module not initialized. Call initialize() first.", nil);
        return;
    }
    
    [self.cse encryptWithPan:pan
              cardHolderName:cardHolderName
                  expiryYear:(NSInteger)expiryYear
                 expiryMonth:(NSInteger)expiryMonth
                         cvv:cvv
                       nonce:nonce
                    callback:^(EncryptResult *result) {
                        switch (result.tag) {
                            case EncryptResultSuccess: {
                                NSString *encrypted = result.success;
                                resolve(encrypted);
                                break;
                            }
                            case EncryptResultError: {
                                EncryptionError *error = result.error;
                                reject(@"ENCRYPTION_ERROR", [error localizedDescription], nil);
                                break;
                            }
                        }
                    }];
}

- (void)isValidPan:(NSString *)pan
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject {
    if (self.cse == nil) {
        reject(@"NOT_INITIALIZED", @"CSE Module not initialized. Call initialize() first.", nil);
        return;
    }
    
    BOOL isValid = [self.cse isValidPan:pan];
    resolve(@(isValid));
}

- (void)isValidCVV:(NSString *)cvv
               pan:(NSString * _Nullable)pan
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject {
    if (self.cse == nil) {
        reject(@"NOT_INITIALIZED", @"CSE Module not initialized. Call initialize() first.", nil);
        return;
    }
    
    BOOL isValid;
    if (pan != nil) {
        isValid = [self.cse isValidCVVWithCvv:cvv pan:pan];
    } else {
        isValid = [self.cse isValidCVV:cvv];
    }
    resolve(@(isValid));
}

- (void)isValidExpiry:(double)month
                 year:(double)year
              resolve:(RCTPromiseResolveBlock)resolve
               reject:(RCTPromiseRejectBlock)reject {
    if (self.cse == nil) {
        reject(@"NOT_INITIALIZED", @"CSE Module not initialized. Call initialize() first.", nil);
        return;
    }
    
    BOOL isValid = [self.cse isValidExpiryWithMonth:(NSInteger)month year:(NSInteger)year];
    resolve(@(isValid));
}

- (void)detectBrand:(NSString *)pan
            resolve:(RCTPromiseResolveBlock)resolve
             reject:(RCTPromiseRejectBlock)reject {
    if (self.cse == nil) {
        reject(@"NOT_INITIALIZED", @"CSE Module not initialized. Call initialize() first.", nil);
        return;
    }
    
    CardBrand brand = [self.cse detectBrand:pan];
    NSString *brandString = [brand rawValue];
    resolve(brandString);
}

- (void)encryptCVV:(NSString *)cvv
             nonce:(NSString *)nonce
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject {
    if (self.cse == nil) {
        reject(@"NOT_INITIALIZED", @"CSE Module not initialized. Call initialize() first.", nil);
        return;
    }
    
    [self.cse encryptWithCvv:cvv
                       nonce:nonce
                    callback:^(EncryptResult *result) {
                        switch (result.tag) {
                            case EncryptResultSuccess: {
                                NSString *encrypted = result.success;
                                resolve(encrypted);
                                break;
                            }
                            case EncryptResultError: {
                                EncryptionError *error = result.error;
                                reject(@"ENCRYPTION_ERROR", [error localizedDescription], nil);
                                break;
                            }
                        }
                    }];
}

- (void)isValidCardHolderName:(NSString *)name
                      resolve:(RCTPromiseResolveBlock)resolve
                       reject:(RCTPromiseRejectBlock)reject {
    if (self.cse == nil) {
        reject(@"NOT_INITIALIZED", @"CSE Module not initialized. Call initialize() first.", nil);
        return;
    }
    
    BOOL isValid = [self.cse isValidCardHolderName:name];
    resolve(@(isValid));
}

- (void)isValidCardToken:(NSString *)token
                 resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject {
    if (self.cse == nil) {
        reject(@"NOT_INITIALIZED", @"CSE Module not initialized. Call initialize() first.", nil);
        return;
    }
    
    BOOL isValid = [self.cse isValidCardToken:token];
    resolve(@(isValid));
}

- (void)getErrors:(RCTPromiseResolveBlock)resolve
           reject:(RCTPromiseRejectBlock)reject {
    if (self.cse == nil) {
        reject(@"NOT_INITIALIZED", @"CSE Module not initialized. Call initialize() first.", nil);
        return;
    }
    
    NSArray<NSString *> *errors = [self.cse errors];
    resolve(errors);
}

- (void)hasErrors:(RCTPromiseResolveBlock)resolve
           reject:(RCTPromiseRejectBlock)reject {
    if (self.cse == nil) {
        reject(@"NOT_INITIALIZED", @"CSE Module not initialized. Call initialize() first.", nil);
        return;
    }
    
    BOOL hasErrors = [self.cse hasErrors];
    resolve(@(hasErrors));
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeRnTurboModuleMsuCseV3SpecJSI>(params);
}

@end
