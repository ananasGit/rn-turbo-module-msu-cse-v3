#import "RnTurboModuleMsuCseV3.h"
#import "RnTurboModuleMsuCseV3Impl.h"

@implementation RnTurboModuleMsuCseV3

RCT_EXPORT_MODULE()

// Create instance of Objective-C implementation class
RnTurboModuleMsuCseV3Impl *implementation = [[RnTurboModuleMsuCseV3Impl alloc] init];

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeRnTurboModuleMsuCseV3SpecJSI>(params);
}

- (void)initialize:(BOOL)developmentMode {
    [implementation initializeWithDevelopmentMode:developmentMode];
}

- (void)encrypt:(NSString *)pan
    cardHolderName:(NSString *)cardHolderName
    expiryYear:(double)expiryYear
    expiryMonth:(double)expiryMonth
    cvv:(NSString *)cvv
    nonce:(NSString *)nonce
    resolve:(RCTPromiseResolveBlock)resolve
    reject:(RCTPromiseRejectBlock)reject {
    
    [implementation encryptWithPan:pan
                    cardHolderName:cardHolderName
                        expiryYear:(NSInteger)expiryYear
                       expiryMonth:(NSInteger)expiryMonth
                               cvv:cvv
                             nonce:nonce
                           resolve:resolve
                            reject:reject];
}

- (void)encryptCVV:(NSString *)cvv
             nonce:(NSString *)nonce
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject {
    
    [implementation encryptCVVWithCvv:cvv
                                nonce:nonce
                              resolve:resolve
                               reject:reject];
}

- (void)isValidPan:(NSString *)pan
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject {
    
    BOOL isValid = [implementation isValidPan:pan];
    resolve(@(isValid));
}

- (void)isValidCVV:(NSString *)cvv
               pan:(nullable NSString *)pan
           resolve:(RCTPromiseResolveBlock)resolve
            reject:(RCTPromiseRejectBlock)reject {
    
    BOOL isValid = [implementation isValidCVV:cvv pan:pan];
    resolve(@(isValid));
}

- (void)isValidExpiry:(double)month
                 year:(double)year
              resolve:(RCTPromiseResolveBlock)resolve
               reject:(RCTPromiseRejectBlock)reject {
    
    BOOL isValid = [implementation isValidExpiryWithMonth:(NSInteger)month year:(NSInteger)year];
    resolve(@(isValid));
}

- (void)detectBrand:(NSString *)pan
            resolve:(RCTPromiseResolveBlock)resolve
             reject:(RCTPromiseRejectBlock)reject {
    
    NSString *brandString = [implementation detectBrand:pan];
    resolve(brandString);
}

- (void)isValidCardHolderName:(NSString *)name
                      resolve:(RCTPromiseResolveBlock)resolve
                       reject:(RCTPromiseRejectBlock)reject {
    
    BOOL isValid = [implementation isValidCardHolderName:name];
    resolve(@(isValid));
}

- (void)isValidCardToken:(NSString *)token
                 resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject {
    
    BOOL isValid = [implementation isValidCardToken:token];
    resolve(@(isValid));
}

- (void)getErrors:(RCTPromiseResolveBlock)resolve
           reject:(RCTPromiseRejectBlock)reject {
    
    NSArray<NSString *> *errors = [implementation getErrors];
    resolve(errors);
}

- (void)hasErrors:(RCTPromiseResolveBlock)resolve
           reject:(RCTPromiseRejectBlock)reject {
    
    BOOL hasErrors = [implementation hasErrors];
    resolve(@(hasErrors));
}

@end