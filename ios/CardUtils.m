#import "CardUtils.h"

@implementation CardUtils

static const NSInteger LENGTH_COMMON_CARD = 16;
static const NSInteger LENGTH_AMERICAN_EXPRESS = 15;
static const NSInteger LENGTH_DINERS_CLUB = 14;
static NSArray<NSNumber *> *MAESTRO_CARD_LENGTH;
static NSArray<NSNumber *> *VISA_CARD_LENGTH;

+ (void)initialize {
    if (self == [CardUtils class]) {
        MAESTRO_CARD_LENGTH = @[@12, @13, @14, @15, @16, @17, @18, @19];
        VISA_CARD_LENGTH = @[@16, @19];
    }
}

+ (NSString *)digitsOnly:(NSString *)string {
    if (!string) return @"";
    NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    return [[string componentsSeparatedByCharactersInSet:nonDigits] componentsJoinedByString:@""];
}

+ (BOOL)isValidCVV:(NSString *)cvv {
    if (!cvv || cvv.length == 0) return NO;
    NSString *digits = [self digitsOnly:cvv];
    return digits.length >= 3 && digits.length <= 4;
}

+ (BOOL)isValidCVV:(NSString *)cvv pan:(NSString *)pan {
    if (!cvv || cvv.length == 0) return NO;
    if (!pan || pan.length == 0) return NO;
    
    NSString *cvvDigits = [self digitsOnly:cvv];
    CardBrandType brand = [self possibleCardBrand:pan];
    
    if (brand == CardBrandAmericanExpress) {
        return cvvDigits.length == 4;
    } else {
        return cvvDigits.length == 3;
    }
}

+ (BOOL)isValidCardHolderName:(NSString *)name {
    if (!name || name.length == 0) return NO;
    NSString *trimmed = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return trimmed.length >= 2 && trimmed.length <= 50;
}

+ (BOOL)isValidPan:(NSString *)pan {
    if (!pan || pan.length == 0) return NO;
    NSString *digits = [self digitsOnly:pan];
    
    // Check length
    if (digits.length < 12 || digits.length > 19) return NO;
    
    // Luhn algorithm check
    return [self luhnCheck:digits];
}

+ (BOOL)luhnCheck:(NSString *)cardNumber {
    NSInteger sum = 0;
    BOOL alternate = NO;
    
    for (NSInteger i = cardNumber.length - 1; i >= 0; i--) {
        NSInteger digit = [[cardNumber substringWithRange:NSMakeRange(i, 1)] integerValue];
        
        if (alternate) {
            digit *= 2;
            if (digit > 9) {
                digit = (digit % 10) + 1;
            }
        }
        sum += digit;
        alternate = !alternate;
    }
    
    return (sum % 10) == 0;
}

+ (BOOL)isValidCardToken:(NSString *)token {
    if (!token || token.length == 0) return NO;
    return token.length >= 10;
}

+ (CardBrandType)possibleCardBrand:(NSString *)pan {
    if (!pan || pan.length == 0) return CardBrandUnknown;
    NSString *digits = [self digitsOnly:pan];
    
    // American Express
    if ([self hasPrefix:digits prefixes:@[@"34", @"37"]]) {
        return CardBrandAmericanExpress;
    }
    
    // Visa
    if ([self hasPrefix:digits prefixes:@[@"4"]]) {
        return CardBrandVisa;
    }
    
    // Mastercard
    NSArray *mastercardPrefixes = @[
        @"2221", @"2222", @"2223", @"2224", @"2225", @"2226", @"2227", @"2228", @"2229",
        @"223", @"224", @"225", @"226", @"227", @"228", @"229",
        @"23", @"24", @"25", @"26",
        @"270", @"271", @"2720",
        @"50", @"51", @"52", @"53", @"54", @"55", @"67"
    ];
    if ([self hasPrefix:digits prefixes:mastercardPrefixes]) {
        return CardBrandMastercard;
    }
    
    // Maestro
    if ([self hasPrefix:digits prefixes:@[@"56", @"58", @"67", @"502", @"503", @"506", @"639", @"5018", @"6020"]]) {
        return CardBrandMaestro;
    }
    
    // Discover
    if ([self hasPrefix:digits prefixes:@[@"60", @"64", @"65"]]) {
        return CardBrandDiscover;
    }
    
    // JCB
    if ([self hasPrefix:digits prefixes:@[@"35"]]) {
        return CardBrandJcb;
    }
    
    // Diners Club
    NSArray *dinersClubPrefixes = @[@"300", @"301", @"302", @"303", @"304", @"305", @"309", @"36", @"38", @"39"];
    if ([self hasPrefix:digits prefixes:dinersClubPrefixes]) {
        return CardBrandDinersClub;
    }
    
    // UnionPay
    if ([self hasPrefix:digits prefixes:@[@"62"]]) {
        return CardBrandUnionPay;
    }
    
    // Troy
    NSArray *troyPrefixes = @[
        @"979200", @"979201", @"979202", @"979203", @"979204", @"979205",
        @"979206", @"979207", @"979208", @"979209", @"979210", @"979211",
        @"979212", @"979213"
    ];
    if ([self hasPrefix:digits prefixes:troyPrefixes]) {
        return CardBrandTroy;
    }
    
    return CardBrandUnknown;
}

+ (BOOL)hasPrefix:(NSString *)string prefixes:(NSArray<NSString *> *)prefixes {
    for (NSString *prefix in prefixes) {
        if ([string hasPrefix:prefix]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isValidExpiryWithMonth:(NSInteger)month year:(NSInteger)year {
    if (month < 1 || month > 12) return NO;
    if (year < 1000) return NO; // Expecting full year format (e.g., 2024)
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *nowComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:now];
    
    NSInteger currentYear = [nowComponents year];
    NSInteger currentMonth = [nowComponents month];
    
    if (year < currentYear) return NO;
    if (year == currentYear && month < currentMonth) return NO;
    
    // Don't allow expiry dates too far in the future (20 years)
    if (year > currentYear + 20) return NO;
    
    return YES;
}

+ (BOOL)validateNonce:(NSString *)nonce {
    if (!nonce || nonce.length == 0) return NO;
    return nonce.length >= 8;
}

@end