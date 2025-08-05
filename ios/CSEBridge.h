#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CSEEncryptResultType) {
    CSEEncryptResultTypeSuccess = 0,
    CSEEncryptResultTypeError = 1
};

@interface CSEEncryptError : NSObject
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *message;
@end

@interface CSEEncryptResult : NSObject
@property (nonatomic, assign) CSEEncryptResultType type;
@property (nonatomic, strong, nullable) NSString *data;
@property (nonatomic, strong, nullable) CSEEncryptError *error;
@end

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