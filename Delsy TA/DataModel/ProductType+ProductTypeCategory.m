//
//  ProductType+ProductTypeCategory.m
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "ProductType+ProductTypeCategory.h"

@implementation ProductType (ProductTypeCategory)

// Ищет ProductType с name = name, если находит, то возвращает, иначе, создает новый.
+(ProductType *) getProductTypeByName:(NSString *) name withMOC:(NSManagedObjectContext *) managedObjectContext{
    
    // Ищем ProductType с name = name, если не нашли, то создаем нового, если получаем ошибку, то возвращаем nil
    ProductType *productType;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ProductType"
                                              inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@",name];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (array == nil){
        NSLog(@"Exception while getting ProductType`s array by name. Error: %@",error.localizedDescription);
        productType = nil;
    }
    else{
        if( array.count == 0 ){
            productType = [[ProductType alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
            productType.name = name;
        }
        else{
            productType = [array objectAtIndex:0];
        }
    }
    return productType;
}

// Возвращает созданный request. Фильтр - имеется хотся бы один не удаленный товар из этой категории.
+(NSFetchRequest *) getRequestWithoutDeletedItems: (NSManagedObjectContext *) context{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ProductType" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY items.deleted == %@",[NSNumber numberWithBool:NO]];
     [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor1, nil]];
    
    return request;
}

@end
