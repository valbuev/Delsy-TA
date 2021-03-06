//
//  Item+ItemCategory.m
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "Item+ItemCategory.h"

@implementation Item (ItemCategory)

// Помечает все имеющиеся в базе Items как удаленные
+(void) setAllItemsDeleted:(Boolean) deleted InManagedObjectContext:(NSManagedObjectContext *) managedObjectContext{
    
    // Получаем все Items
    Item *item;
    NSArray *ItemList;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item"
                                              inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error = nil;
    ItemList = [managedObjectContext executeFetchRequest:request error:&error];
    
    // Если нет ошибок, то проходим по списку и помечаем каждый как удаленный
    int n=0;
    if (ItemList == nil){
        NSLog(@"Exception while getting Items array for mark those as deleted %d. Error: %@",deleted,error.localizedDescription);
        return;
    }
    else for(item in ItemList){
        item.is_deleted = [NSNumber numberWithBool:deleted];
        n++;
        if(n==20){
            if(![managedObjectContext save:&error]){
                NSLog(@"Exception while setting Item`s array deleted %d. Error: %@",deleted,error.localizedDescription);
            }
            n=0;
        }
    }
}

// Ищет Item с itemID = itemID, если находит, то возвращает, иначе, создает новый.
+(Item *) getOrCreateItemByItemID:(NSString *) itemID withMOC:(NSManagedObjectContext *) managedObjectContext{
    
    // Ищем Item с itemID = itemID, если не нашли, то создаем нового, если получаем ошибку, то возвращаем nil
    Item *item;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item"
                                              inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemID like %@",itemID];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (array == nil){
        NSLog(@"Exception while getting Item`s array by ItemID. Error: %@",error.localizedDescription);
        item = nil;
    }
    else{
        if( array.count == 0 ){
            item = [[Item alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
            item.itemID = itemID;
            //NSLog(@"init ta id = %@",ta.id);
        }
        else{
            item = [array objectAtIndex:0];
        }
    }
    return item;
}

// Ищет Item с itemID = itemID, если находит, то возвращает, иначе, nil.
+(Item *) getItemByItemID:(NSString *) itemID withMOC:(NSManagedObjectContext *) managedObjectContext{
    
    // Ищем Item с itemID = itemID, если не нашли, то создаем нового, если получаем ошибку, то возвращаем nil
    Item *item;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item"
                                              inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemID like %@",itemID];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (array == nil){
        NSLog(@"Exception while getting Item`s array by ItemID. Error: %@",error.localizedDescription);
        item = nil;
    }
    else{
        if( array.count == 0 ){
            item = nil;
        }
        else{
            item = [array objectAtIndex:0];
        }
    }
    return item;
}



// создает контроллер неудаленных items сгруппированных по названиям рыб
+(NSFetchedResultsController *) getControllerGroupByFish:(NSManagedObjectContext *) context forProductType:(NSManagedObject *) productType{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(is_deleted == %@) AND (productType == %@)",[NSNumber numberWithBool:NO],productType];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"fish.name" ascending:YES];
    NSSortDescriptor *sort2 = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObjects:sort1,sort2, nil]];
    
    NSFetchedResultsController *controller =
        [[NSFetchedResultsController alloc]
            initWithFetchRequest:request
         managedObjectContext:context
         sectionNameKeyPath:@"fish.name"
         cacheName:@"ru.bva.DelsyTA.fetchRequestForPriceMasterView"];
    
    return controller;
}

+ (NSArray *) getAllItems: (NSManagedObjectContext *) context{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:request error:&error];
    
    if (array == nil){
        NSLog(@"Exception while getting Item`s array. Error: %@",error.localizedDescription);
    }
    return array;
}

// Проверяет, есть ли загруженные фотографии
- (Boolean) haveDownloadedPhotos{
    NSMutableSet *photos = [self.photos mutableCopy];
    static NSPredicate *predicate;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        predicate = [NSPredicate predicateWithFormat:@"filepath != nil and filepath != ''"];
    });
    [photos filterUsingPredicate:predicate];
    if(photos.count > 0)
        return YES;
    return NO;
}

// создает контроллер неудаленных items сгруппированных по производителю и отфильтрованных по типу продукта
+(NSFetchedResultsController *) getControllerGroupByProducer:(NSManagedObjectContext *) context forProductType:(ProductType *) productType {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate = [Item predicateForFilterItemsByProdType: productType fish: nil];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"producer" ascending:YES];
    NSSortDescriptor *sort2 = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObjects:sort1,sort2, nil]];
    
    NSFetchedResultsController *controller =
    [[NSFetchedResultsController alloc]
     initWithFetchRequest:request
     managedObjectContext:context
     sectionNameKeyPath:@"producer"
     cacheName:@"ru.bva.DelsyTA.fetchRequestForPriceDetailView"];
    
    return controller;
}

// создает предикат, предназначенный для фильтрации продуктов по типу продукта и по типу рыбы
+ (NSPredicate *) predicateForFilterItemsByProdType:(ProductType *) prodType fish:(Fish *) fish {
    if( fish != nil )
        return [NSPredicate predicateWithFormat:@"(is_deleted == %@) AND (productType == %@) and (fish == %@)",[NSNumber numberWithBool:NO],prodType,fish];
    else
        return [NSPredicate predicateWithFormat:@"(is_deleted == %@) AND (productType == %@)",[NSNumber numberWithBool:NO],prodType];
}


@end
