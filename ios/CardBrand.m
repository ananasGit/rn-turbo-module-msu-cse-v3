#import "CardBrand.h"

@implementation CardBrand

+ (NSString *)stringValueForBrand:(CardBrandType)brand {
    switch (brand) {
        case CardBrandVisa:
            return @"visa";
        case CardBrandMastercard:
            return @"mastercard";
        case CardBrandMaestro:
            return @"maestro";
        case CardBrandAmericanExpress:
            return @"american-express";
        case CardBrandDinersClub:
            return @"diners-club";
        case CardBrandDiscover:
            return @"discover";
        case CardBrandJcb:
            return @"jcb";
        case CardBrandTroy:
            return @"troy";
        case CardBrandDinacard:
            return @"dinacard";
        case CardBrandUnionPay:
            return @"union-pay";
        case CardBrandUnknown:
        default:
            return @"unknown";
    }
}

@end