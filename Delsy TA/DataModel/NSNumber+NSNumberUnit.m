//
//  NSNumber+NSNumberUnit.m
//  Delsy TA
//
//  Created by Valeriy Buev on 18.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "NSNumber+NSNumberUnit.h"

@implementation NSNumber (NSNumberUnit)

// Возвращает значение NSNumber в виде Unit
- (Unit)unitValue {
    int intValue = [self intValue];
    NSAssert(intValue > 0 && intValue < 5,
             @"unsupported entity type");
    return (Unit)intValue;
}

// Возвращает новый объект NSNumber, несущий значение unit
+ (NSNumber *)numberWithUnit:(Unit)unit {
    return [NSNumber numberWithInt:(int)unit];
}

// Возвращает unit в строковом виде
- (NSString *)unitValueToString{
    static NSString* strKG = @"кг";
    static NSString* strPIECE = @"шт";
    static NSString* strBOX = @"кор";
    static NSString* strBIGBOX = @"б.кор";
    switch (self.unitValue) {
        case kg:
            return strKG;
            break;
        case piece:
            return strPIECE;
            break;
        case box:
            return strBOX;
            break;
        case bigBox:
            return strBIGBOX;
            break;
        default:
            return strKG;
            break;
    }
}

@end
