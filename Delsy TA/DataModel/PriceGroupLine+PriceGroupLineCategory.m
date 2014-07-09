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

+ (NSArray *) getAllPriceGroupLines: (NSManagedObjectContext *) context{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PriceGroupLine" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:request error:&error];
    
    if (array == nil){
        NSLog(@"Exception while getting PriceGroupLine`s array. Error: %@",error.localizedDescription);
    }
    return array;
}


@end
