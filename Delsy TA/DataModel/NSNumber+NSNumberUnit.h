//
//  NSNumber+NSNumberUnit.h
//  Delsy TA
//
//  Created by Valeriy Buev on 18.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//
//  Категория (расширение класса, путем добавления методов) для класса NSNumber
//  Расширяет класс для хранения в нем единицы измерения (кг, шт и т.д.)
//
//

#import <Foundation/Foundation.h>

// перечисляемый тип Unit. Т.е. единица измерения
typedef enum {
    kg = 1,
    piece = 2,
    box = 3,
    bigBox = 4
} Unit;

@interface NSNumber (NSNumberUnit)

+ (NSNumber *)numberWithUnit:(Unit)unit;
- (Unit)unitValue;

@end
