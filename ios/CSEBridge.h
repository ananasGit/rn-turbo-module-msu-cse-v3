#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CSEEncryptResult;
@class CSEEncryptError;

typedef void (^CSEEncryptCallback)(CSEEncryptResult *result);

@interface CSEBridge : NSObject

- (instancetype)initWithDevelopmentMode:(BOOL)developmentMode;

- (void)encryptWithPan:(NSString *)pan
        cardHolderName:(NSString *)cardHolderName
            expiryYear:(NSInteger)expiryYear
           expiryMonth:(NSInteger)expiryMonth
                   cvv:(NSString *)cvv
                 nonce:(NSString *)nonce
              callback:(CSEEncryptCallback)callback;

@end

NS_ASSUME_NONNULL_END