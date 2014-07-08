//
//  PriceGroup+PriceGroupCategory.m
//  Delsy TA
//
//  Created by Valeriy Buev on 08.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "PriceGroup+PriceGroupCategory.h"

@implementation PriceGroup (PriceGroupCategory)

// Удаляет все группы ценников по строке
+(void) removePriceGroupsFromManagedObjectContext:(NSManagedObjectContext *) managedObjectContext{
    
    // Получаем все LineSAles
    PriceGroup *priceGroup;
    NSArray *priceGroupList;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PriceGroup"
                                              inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error = nil;
    priceGroupList = [managedObjectContext executeFetchRequest:request error:&error];
    
    // Если нет ошибок, то проходим по списку и удаляем каждый
    int n=0;
    if (priceGroupList == nil){
        NSLog(@"Exception while getting PriceGroups array for delete them. Error: %@",error.localizedDescription);
        return;
    }
    else for(priceGroup in priceGroupList){
        [managedObjectContext deleteObject:priceGroup];
        n++;
        if(n==20){
            if(![managedObjectContext save:&error]){
                NSLog(@"Exception while deleting PriceGroups Error: %@",error.localizedDescription);
            }
            n=0;
        }
    }
}

// Создает новый объект PriceGroup в managedObjectContext
+(PriceGroup *) newPriceGroupInManObjContext:(NSManagedObjectContext *) managedObjectContext{
    
    PriceGroup *priceGroup;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PriceGroup"
                                              inManagedObjectContext:managedObjectContext];
    priceGroup = [[PriceGroup alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
    return priceGroup;
}

@end
