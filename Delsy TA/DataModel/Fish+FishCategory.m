//
//  Fish+FishCategory.m
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "Fish+FishCategory.h"

@implementation Fish (FishCategory)

// Ищет Fish с fishName = fishName, если находит, то возвращает, иначе, создает новый.
+(Fish *) getFishByName:(NSString *) fishName withMOC:(NSManagedObjectContext *) managedObjectContext{
    
    // Ищем Fish с name = fishName, если не нашли, то создаем нового, если получаем ошибку, то возвращаем nil
    Fish *fish;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Fish"
                                              inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like %@",fishName];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (array == nil){
        NSLog(@"Exception while getting Fish`s array by fishName. Error: %@",error.localizedDescription);
        fish = nil;
    }
    else{
        if( array.count == 0 ){
            fish = [[Fish alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
            fish.name = fishName;
            //NSLog(@"init ta id = %@",ta.id);
        }
        else{
            fish = [array objectAtIndex:0];
        }
    }
    return fish;
}

// Удаляет во всех Fish все связи с ProductType
+(void) removeAllProductTypesRelationShipsFromAllFishes_InManagedObjectContext:(NSManagedObjectContext *) managedObjectContext{
    
    // Получаем все Fishes
    Fish *fish;
    NSArray *fishList;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Fish"
                                              inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error = nil;
    fishList = [managedObjectContext executeFetchRequest:request error:&error];
    
    // Если нет ошибок, то проходим по списку и удаляем все связи с ProductType
    if (fishList == nil){
        NSLog(@"Exception while getting Fishes array for remove all those relationShips with ProductTypes. Error: %@",error.localizedDescription);
        return;
    }
    else for(fish in fishList){
        [fish removeProductTypes:fish.productTypes];
    }
}

/*+(NSArray *) getFishesForProdType:(ProductType *) productType context: (NSManagedObjectContext *) context {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Fish" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@""]
}*/

// Возвращает созданный контроллер. Секции - типы продукта, ячейки - виды рыб. Фильтр - имеется хотся бы один не удаленный товар из этой категории.
/*+(NSFetchedResultsController *) getControllerOfFishesWithoutDeletedItemsAndGroupedByProductType: (NSManagedObjectContext *) context{
    NSFetchedResultsController *controller;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Fish" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY items.is_deleted == %@", [NSNumber numberWithBool:NO]];
    [request setPredicate:predicate];
    
    //NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"productTypes.name" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor2, nil]];
    
    controller = [[NSFetchedResultsController alloc]
                  initWithFetchRequest:request
                  managedObjectContext:context
                  sectionNameKeyPath:@"productTypes.name"
                  cacheName:@"ru.bva.DelsyTA.fetchRequestForPriceMasterView"];
    
    return controller;
}*/

@end
