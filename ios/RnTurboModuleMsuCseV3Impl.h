#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@class CSE;

NS_ASSUME_NONNULL_BEGIN

@interface RnTurboModuleMsuCseV3Impl : NSObject

@property (nonatomic, strong, nullable) CSE *cseInstance;
@property (nonatomic, assign) BOOL isDevelopmentMode;

- (void)initializeWithDevelopmentMode:(BOOL)developmentMode;

- (void)encryptWithPan:(NSString *)pan
        cardHolderName:(NSString *)cardHolderName
            expiryYear:(NSInteger)expiryYear
           expiryMonth:(NSInteger)expiryMonth
                   cvv:(NSString *)cvv
                 nonce:(NSString *)nonce
               resolve:(RCTPromiseResolveBlock)resolve
                reject:(RCTPromiseRejectBlock)reject;

- (void)encryptCVVWithCvv:(NSString *)cvv
                    nonce:(NSString *)nonce
                  resolve:(RCTPromiseResolveBlock)resolve
                   reject:(RCTPromiseRejectBlock)reject;

- (BOOL)isValidPan:(NSString *)pan;

- (BOOL)isValidCVV:(NSString *)cvv pan:(nullable NSString *)pan;

- (BOOL)isValidExpiryWithMonth:(NSInteger)month year:(NSInteger)year;

- (NSString *)detectBrand:(NSString *)pan;

- (BOOL)isValidCardHolderName:(NSString *)name;

- (BOOL)isValidCardToken:(NSString *)token;

- (NSArray<NSString *> *)getErrors;

- (BOOL)hasErrors;

@end

NS_ASSUME_NONNULL_END