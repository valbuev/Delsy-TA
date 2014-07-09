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

+ (NSArray *) getAllLineSaleLines: (NSManagedObjectContext *) context{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LineSaleLine" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:request error:&error];
    
    if (array == nil){
        NSLog(@"Exception while getting LineSaleLine`s array. Error: %@",error.localizedDescription);
    }
    return array;
}


@end
