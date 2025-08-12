#import <Foundation/Foundation.h>
#import "CardBrand.h"

NS_ASSUME_NONNULL_BEGIN

@interface CardUtils : NSObject

+ (BOOL)isValidCVV:(NSString *)cvv;
+ (BOOL)isValidCVV:(NSString *)cvv pan:(NSString *)pan;
+ (BOOL)isValidCardHolderName:(NSString *)name;
+ (BOOL)isValidPan:(NSString *)pan;
+ (BOOL)isValidCardToken:(NSString *)token;
+ (CardBrandType)possibleCardBrand:(NSString *)pan;
+ (BOOL)isValidExpiryWithMonth:(NSInteger)month year:(NSInteger)year;
+ (BOOL)validateNonce:(NSString *)nonce;
+ (NSString *)digitsOnly:(NSString *)string;

@end

NS_ASSUME_NONNULL_END