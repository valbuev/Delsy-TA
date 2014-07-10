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

// Ищет LineSale с self.name = name, если находит, то возвращает, иначе, return nil.
+(LineSale *) getLineSaleByName:(NSString *) name withMOC:(NSManagedObjectContext *) managedObjectContext{
    LineSale *lineSale;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LineSale"
                                              inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setFetchLimit:1];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@",name];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (array == nil){
        NSLog(@"Exception while getting LineSale`s array by name. Error: %@",error.localizedDescription);
        lineSale = nil;
    }
    else{
        if( array.count == 0 ){
            lineSale = nil;
        }
        else{
            lineSale = [array objectAtIndex:0];
        }
    }
    return lineSale;
}

+ (NSArray *) getAllLineSales: (NSManagedObjectContext *) context{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LineSale" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:request error:&error];
    
    if (array == nil){
        NSLog(@"Exception while getting LineSale`s array. Error: %@",error.localizedDescription);
    }
    return array;
}

@end
