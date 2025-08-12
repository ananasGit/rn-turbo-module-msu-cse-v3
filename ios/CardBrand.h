#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CardBrandType) {
    CardBrandVisa = 0,
    CardBrandMastercard = 1,
    CardBrandMaestro = 2,
    CardBrandAmericanExpress = 3,
    CardBrandDinersClub = 4,
    CardBrandDiscover = 5,
    CardBrandJcb = 6,
    CardBrandTroy = 7,
    CardBrandDinacard = 8,
    CardBrandUnionPay = 9,
    CardBrandUnknown = 10
};

NS_ASSUME_NONNULL_BEGIN

@interface CardBrand : NSObject

+ (NSString *)stringValueForBrand:(CardBrandType)brand;

@end

NS_ASSUME_NONNULL_END