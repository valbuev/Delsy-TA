//
//  NSNumber+bvaLineColor.m
//  Delsy TA
//
//  Created by Valeriy Buev on 24.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "NSNumber+bvaLineColor.h"

@implementation NSNumber (bvaLineColor)

// Возвращает значение NSNumber в виде LineColor
- (LineColor)lineColorValue {
    int intValue = [self intValue];
    NSAssert(intValue > 0 && intValue < 5,
             @"unsupported entity type");
    return (LineColor)intValue;
}

// Возвращает новый объект NSNumber, несущий значение unit
+ (NSNumber *)numberWithEnum:(LineColor)lineColor {
    return [NSNumber numberWithInt:(int)lineColor];
}

@end
