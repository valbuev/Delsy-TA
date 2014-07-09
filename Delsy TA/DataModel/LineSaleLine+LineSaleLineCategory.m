//
//  LineSaleLine+LineSaleLineCategory.m
//  Delsy TA
//
//  Created by Valeriy Buev on 08.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "LineSaleLine+LineSaleLineCategory.h"

@implementation LineSaleLine (LineSaleLineCategory)

// Создает новый объект LineSaleLine в managedObjectContext
+(LineSaleLine *) newLineSaleLineInManObjContext:(NSManagedObjectContext *) managedObjectContext{
    
    LineSaleLine *lineSaleLine;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LineSaleLine"
                                              inManagedObjectContext:managedObjectContext];
    lineSaleLine = [[LineSaleLine alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
    return lineSaleLine;
}

@end
