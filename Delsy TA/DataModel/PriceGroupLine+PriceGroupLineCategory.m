//
//  PriceGroupLine+PriceGroupLineCategory.m
//  Delsy TA
//
//  Created by Valeriy Buev on 08.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "PriceGroupLine+PriceGroupLineCategory.h"

@implementation PriceGroupLine (PriceGroupLineCategory)

// Создает новый объект PriceGroupLine в managedObjectContext
+(PriceGroupLine *) newPriceGroupLineInManObjContext:(NSManagedObjectContext *) managedObjectContext{
    
    PriceGroupLine *priceGroupLine;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PriceGroupLine"
                                              inManagedObjectContext:managedObjectContext];
    priceGroupLine = [[PriceGroupLine alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
    return priceGroupLine;
}

@end
