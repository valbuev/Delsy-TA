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
+ (NSNumber *)numberWithLineColor:(LineColor)lineColor {
    return [NSNumber numberWithInt:(int)lineColor];
}

// Возвращает цвет для данного значения
- (UIColor *) lineColor: (UIColor *) defaultLineColor{
    if([self lineColorValue] == defaultColor)
        return defaultLineColor;
    else if ([self lineColorValue] == red)
        return [UIColor colorWithRed:255.0/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    else if ([self lineColorValue] == green)
        return [UIColor colorWithRed:240/255.0 green:255/255.0 blue:240/255.0 alpha:1];
    else // blue
        return [UIColor colorWithRed:240/255.0 green:240/255.0 blue:255/255.0 alpha:1];
}

@end
