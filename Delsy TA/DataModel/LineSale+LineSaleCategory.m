//
//  LineSale+LineSaleCategory.m
//  Delsy TA
//
//  Created by Valeriy Buev on 08.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "LineSale+LineSaleCategory.h"

@implementation LineSale (LineSaleCategory)

// Удаляет все скидки по строке
+(void) removeLineSalesFromManagedObjectContext:(NSManagedObjectContext *) managedObjectContext{
    
    // Получаем все LineSAles
    LineSale *lineSale;
    NSArray *lineSaleList;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LineSale"
                                              inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error = nil;
    lineSaleList = [managedObjectContext executeFetchRequest:request error:&error];
    
    // Если нет ошибок, то проходим по списку и удаляем каждый
    int n=0;
    if (lineSaleList == nil){
        NSLog(@"Exception while getting LineSales array for delete them. Error: %@",error.localizedDescription);
        return;
    }
    else for(lineSale in lineSaleList){
        [managedObjectContext deleteObject:lineSale];
        n++;
        if(n==20){
            if(![managedObjectContext save:&error]){
                NSLog(@"Exception while deleting LineSales Error: %@",error.localizedDescription);
            }
            n=0;
        }
    }
}

// Создает новый объект LineSale в managedObjectContext
+(LineSale *) newLineSaleInManObjContext:(NSManagedObjectContext *) managedObjectContext{
    
    LineSale *lineSale;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LineSale"
                                              inManagedObjectContext:managedObjectContext];
    lineSale = [[LineSale alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
    return lineSale;
}

@end
