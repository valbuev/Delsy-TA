//
//  NSNumber+BVAFormatter.h
//  Delsy TA
//
//  Created by Valeriy Buev on 01.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (BVAFormatter)

// Возвращает строку, соответствующую примерам:
// 1.0000 - @"1"
// 1.2000 - @"1.2"
// 1.2300 - @"1.23"
// 1.2340 - @"1.234"
// 1.2345 - @"1.234"
- (NSString *) floatValueSimpleMaxFrac3;
// Возвращает строку, соответствующую примерам:
// 1.0000 - @"1"
// 1.2000 - @"1.2"
// 1.2300 - @"1.23"
// 1.2340 - @"1.23"
// 1.2345 - @"1.23"
- (NSString *) floatValueSimpleMaxFrac2;
// Возвращает строку, соответствующую примерам:
// 1.0000 - @"1"
// 1.2000 - @"1.20"
// 1.2300 - @"1.23"
// 1.2340 - @"1.23"
// 1.2345 - @"1.23"
- (NSString *) floatValueFrac2or0;

@end
