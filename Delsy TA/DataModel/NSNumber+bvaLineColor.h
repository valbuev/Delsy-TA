//
//  NSNumber+bvaLineColor.h
//  Delsy TA
//
//  Created by Valeriy Buev on 24.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <Foundation/Foundation.h>

// перечисляемый тип LineColor. Т.е. единица измерения
typedef enum{
    defaultColor = 1,
    blue = 2,
    red = 3,
    green = 4
} LineColor;

@interface NSNumber (bvaLineColor)

+ (NSNumber *)numberWithLineColor:(LineColor)lineColor;
- (LineColor)lineColorValue;

@end
