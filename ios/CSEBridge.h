#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Simple Objective-C implementation - no Swift bridge needed
@interface CSEBridge : NSObject

- (instancetype)initWithDevelopmentMode:(BOOL)developmentMode;

- (void)encryptWithPan:(NSString *)pan
        cardHolderName:(NSString *)cardHolderName
            expiryYear:(NSInteger)expiryYear
           expiryMonth:(NSInteger)expiryMonth
                   cvv:(NSString *)cvv
                 nonce:(NSString *)nonce
             onSuccess:(void(^)(NSString *encryptedData))onSuccess
               onError:(void(^)(NSString *code, NSString *message))onError;

- (BOOL)isValidPan:(NSString *)pan;
- (BOOL)isValidCVV:(NSString *)cvv withPan:(NSString *)pan;
- (BOOL)isValidExpiryMonth:(NSInteger)month year:(NSInteger)year;
- (NSString *)detectCardBrand:(NSString *)pan;

@end

NS_ASSUME_NONNULL_END