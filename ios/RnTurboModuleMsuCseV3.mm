#import "RnTurboModuleMsuCseV3.h"
#import "RnTurboModuleMsuCseV3-Swift.h"

@interface RnTurboModuleMsuCseV3()
@property (nonatomic, strong) CSE *cseInstance;
@end

@implementation RnTurboModuleMsuCseV3

RCT_EXPORT_MODULE()

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeRnTurboModuleMsuCseV3SpecJSI>(params);
}

- (void)initialize:(BOOL)developmentMode {
    self.cseInstance = [[CSE alloc] initWithDevelopmentMode:developmentMode];
}

- (void)encrypt:(NSString *)pan
    cardHolderName:(NSString *)cardHolderName
    expiryYear:(double)expiryYear
    expiryMonth:(double)expiryMonth
    cvv:(NSString *)cvv
    nonce:(NSString *)nonce
    resolve:(RCTPromiseResolveBlock)resolve
    reject:(RCTPromiseRejectBlock)reject {
    
    if (self.cseInstance == nil) {
        reject(@"NOT_INITIALIZED", @"CSE Module not initialized. Call initialize() first.", nil);
        return;
    }
    
    [self.cseInstance encryptCardWithPan:pan
                     cardHolderName:cardHolderName
                         expiryYear:(NSInteger)expiryYear
                        expiryMonth:(NSInteger)expiryMonth
                                cvv:cvv
                              nonce:nonce
                            success:^(NSString *encrypted) {
                                resolve(encrypted);
                            }
                            failure:^(NSString *error) {
                                reject(@"ENCRYPTION_ERROR", error, nil);
                            }];
}

- (void)encryptCVV:(NSString *)cvv
             nonce:(NSString *)nonce
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject {
    if (self.cseInstance == nil) {
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

- (void)isValidPan:(NSString *)pan
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject {
    if (self.cseInstance == nil) {
        reject(@"NOT_INITIALIZED", @"CSE Module not initialized. Call initialize() first.", nil);
        return;
    }
    
    BOOL isValid = [self.cseInstance isValidPan:pan];
    resolve(@(isValid));
}

- (void)isValidCVV:(NSString *)cvv
               pan:(NSString * _Nullable)pan
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject {
    if (self.cseInstance == nil) {
        reject(@"NOT_INITIALIZED", @"CSE Module not initialized. Call initialize() first.", nil);
        return;
    }
    
    BOOL isValid;
    if (pan != nil) {
        isValid = [self.cseInstance isValidCVVWithCvv:cvv pan:pan];
    } else {
        isValid = [self.cseInstance isValidCVV:cvv];
    }
    resolve(@(isValid));
}

- (void)isValidExpiry:(double)month
                 year:(double)year
              resolve:(RCTPromiseResolveBlock)resolve
               reject:(RCTPromiseRejectBlock)reject {
    if (self.cseInstance == nil) {
        reject(@"NOT_INITIALIZED", @"CSE Module not initialized. Call initialize() first.", nil);
        return;
    }
    
    BOOL isValid = [self.cseInstance isValidExpiryWithMonth:(NSInteger)month year:(NSInteger)year];
    resolve(@(isValid));
}

- (void)detectBrand:(NSString *)pan
            resolve:(RCTPromiseResolveBlock)resolve
             reject:(RCTPromiseRejectBlock)reject {
    if (self.cseInstance == nil) {
        reject(@"NOT_INITIALIZED", @"CSE Module not initialized. Call initialize() first.", nil);
        return;
    }
    
    CardBrand brand = [self.cseInstance detectBrand:pan];
    NSString *brandString = [brand stringValue];
    resolve(brandString);
}

- (void)isValidCardHolderName:(NSString *)name
                      resolve:(RCTPromiseResolveBlock)resolve
                       reject:(RCTPromiseRejectBlock)reject {
    if (self.cseInstance == nil) {
        reject(@"NOT_INITIALIZED", @"CSE Module not initialized. Call initialize() first.", nil);
        return;
    }
    
    BOOL isValid = [self.cseInstance isValidCardHolderName:name];
    resolve(@(isValid));
}

- (void)isValidCardToken:(NSString *)token
                 resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject {
    if (self.cseInstance == nil) {
        reject(@"NOT_INITIALIZED", @"CSE Module not initialized. Call initialize() first.", nil);
        return;
    }
    
    BOOL isValid = [self.cseInstance isValidCardToken:token];
    resolve(@(isValid));
}

- (void)getErrors:(RCTPromiseResolveBlock)resolve
           reject:(RCTPromiseRejectBlock)reject {
    if (self.cseInstance == nil) {
        reject(@"NOT_INITIALIZED", @"CSE Module not initialized. Call initialize() first.", nil);
        return;
    }
    
    NSArray<NSString *> *errors = [self.cseInstance errors];
    resolve(errors);
}

- (void)hasErrors:(RCTPromiseResolveBlock)resolve
           reject:(RCTPromiseRejectBlock)reject {
    if (self.cseInstance == nil) {
        reject(@"NOT_INITIALIZED", @"CSE Module not initialized. Call initialize() first.", nil);
        return;
    }
    
    BOOL hasErrors = [self.cseInstance hasErrors];
    resolve(@(hasErrors));
}

@end