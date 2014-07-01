//
//  NSNumber+BVAFormatter.m
//  Delsy TA
//
//  Created by Valeriy Buev on 01.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "NSNumber+BVAFormatter.h"

@implementation NSNumber (BVAFormatter)

- (NSString *) floatValueSimpleMaxFrac3{
    float value = self.floatValue;
    if( ((int)(value*1000))/1000.0 < value )
        return [NSString stringWithFormat:@"%.3f",value];
    return self.stringValue;
}
- (NSString *) floatValueSimpleMaxFrac2{
    float value = self.floatValue;
    if( ((int)(value*100))/100.0 < value )
        return [NSString stringWithFormat:@"%.2f",value];
    return self.stringValue;
}

@end
