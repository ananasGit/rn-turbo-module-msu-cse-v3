#import "CSEBridge.h"

@interface CSEBridge()
@property (nonatomic, assign) BOOL developmentMode;
@end

@implementation CSEBridge

- (instancetype)initWithDevelopmentMode:(BOOL)developmentMode {
    self = [super init];
    if (self) {
        _developmentMode = developmentMode;
    }
    return self;
}

- (void)encryptWithPan:(NSString *)pan
        cardHolderName:(NSString *)cardHolderName
            expiryYear:(NSInteger)expiryYear
           expiryMonth:(NSInteger)expiryMonth
                   cvv:(NSString *)cvv
                 nonce:(NSString *)nonce
             onSuccess:(void(^)(NSString *encryptedData))onSuccess
               onError:(void(^)(NSString *code, NSString *message))onError {
    
    // Basic validation
    if (!pan || pan.length == 0) {
        onError(@"VALIDATION_FAILED", @"PAN is required");
        return;
    }
    
    if (!cvv || cvv.length == 0) {
        onError(@"VALIDATION_FAILED", @"CVV is required");
        return;
    }
    
    if (!nonce || nonce.length == 0) {
        onError(@"VALIDATION_FAILED", @"Nonce is required");
        return;
    }
    
    // For now, return a mock encrypted result
    // TODO: Implement actual MSU CSE encryption
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Simulate async encryption
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *mockEncrypted = [NSString stringWithFormat:@"encrypted_%@_%@", pan, nonce];
            onSuccess(mockEncrypted);
        });
    });
}

@end