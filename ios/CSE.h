#import <Foundation/Foundation.h>
#import "CardBrand.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^EncryptSuccessBlock)(NSString *encrypted);
typedef void (^EncryptFailureBlock)(NSString *error);

@interface CSE : NSObject

@property (nonatomic, readonly) NSArray<NSString *> *errors;
@property (nonatomic, readonly) BOOL hasErrors;

- (instancetype)initWithDevelopmentMode:(BOOL)developmentMode;

- (BOOL)isValidCVV:(NSString *)cvv;
- (BOOL)isValidCVV:(NSString *)cvv pan:(NSString *)pan;
- (BOOL)isValidCardHolderName:(NSString *)name;
- (BOOL)isValidPan:(NSString *)pan;
- (BOOL)isValidCardToken:(NSString *)token;
- (CardBrandType)detectBrand:(NSString *)pan;
- (BOOL)isValidExpiryWithMonth:(NSInteger)month year:(NSInteger)year;

- (void)encryptCVVOnlyWithCvv:(NSString *)cvv
                        nonce:(NSString *)nonce
                      success:(EncryptSuccessBlock)success
                      failure:(EncryptFailureBlock)failure;

- (void)encryptCardWithPan:(NSString *)pan
            cardHolderName:(NSString *)cardHolderName
                expiryYear:(NSInteger)expiryYear
               expiryMonth:(NSInteger)expiryMonth
                       cvv:(NSString *)cvv
                     nonce:(NSString *)nonce
                   success:(EncryptSuccessBlock)success
                   failure:(EncryptFailureBlock)failure;

@end

NS_ASSUME_NONNULL_END