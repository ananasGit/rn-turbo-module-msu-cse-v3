#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RSAEncryption : NSObject

+ (nullable NSString *)encryptWithPublicKey:(NSString *)publicKey plainText:(NSString *)plainText;

@end

NS_ASSUME_NONNULL_END