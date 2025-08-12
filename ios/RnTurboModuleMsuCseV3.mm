#import "RnTurboModuleMsuCseV3.h"

@interface RnTurboModuleMsuCseV3()

@property (nonatomic, strong) CSEBridge *cse;

@end

@implementation RnTurboModuleMsuCseV3
RCT_EXPORT_MODULE()

- (void)initialize:(BOOL)developmentMode {
    self.cse = [[CSEBridge alloc] initWithDevelopmentMode:developmentMode];
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
                   onSuccess:^(NSString *encryptedData) {
                       resolve(encryptedData);
                   }
                     onError:^(NSString *code, NSString *message) {
                       reject(code, message, nil);
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
    
    BOOL isValid = [self.cse isValidCVV:cvv withPan:pan];
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
    
    BOOL isValid = [self.cse isValidExpiryMonth:(NSInteger)month year:(NSInteger)year];
    resolve(@(isValid));
}

- (void)detectBrand:(NSString *)pan
            resolve:(RCTPromiseResolveBlock)resolve
             reject:(RCTPromiseRejectBlock)reject {
    if (self.cse == nil) {
        reject(@"NOT_INITIALIZED", @"CSE Module not initialized. Call initialize() first.", nil);
        return;
    }
    
    NSString *brand = [self.cse detectCardBrand:pan];
    resolve(brand);
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeRnTurboModuleMsuCseV3SpecJSI>(params);
}

@end
