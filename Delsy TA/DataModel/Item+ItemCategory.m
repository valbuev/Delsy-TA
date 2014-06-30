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
    if (ItemList == nil){
        NSLog(@"Exception while getting Items array for mark those as deleted %d. Error: %@",deleted,error.localizedDescription);
        return;
    }
    else for(item in ItemList){
        item.deleted = [NSNumber numberWithBool:deleted];
    }
}

// Ищет Item с itemID = itemID, если находит, то возвращает, иначе, создает новый.
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


@end
