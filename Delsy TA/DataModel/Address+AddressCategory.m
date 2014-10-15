//
//  Address+AddressCategory.m
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "Address+AddressCategory.h"
#import "Client+ClientCategory.h"

@implementation Address (AddressCategory)

+(void)setAllAddressesDeleted:(Boolean)isDeleted InManagedObjectContext:(NSManagedObjectContext *)context{
    
    // Получаем все Addresses
    Address *address;
    NSArray *Addresslist;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Address"
                                              inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error = nil;
    Addresslist = [context executeFetchRequest:request error:&error];
    
    // Если нет ошибок, то проходим по списку и помечаем каждый как удаленный
    int n=0;
    if (Addresslist == nil){
        NSLog(@"Exception while getting TA`s array for set those deleted %d. Error: %@",isDeleted,error.localizedDescription);
        return;
    }
    else for(address in Addresslist){
        address.is_deleted = [NSNumber numberWithBool:isDeleted];
        n++;
        if(n==20){
            if(![context save:&error]){
                NSLog(@"Exception while setting Address`s array deleted %d. Error: %@",isDeleted,error.localizedDescription);
            }
            n=0;
        }
    }
}

 //Ищет Address с self.addressId = addressId, если находит, то возвращает, иначе, создает новый.
+(Address *) getAddressByAddressId:(NSString *) addressId withMOC:(NSManagedObjectContext *) managedObjectContext{
    Address *address;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Address"
                                              inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setFetchLimit:1];
    [request setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"address_id == %@",addressId];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    //NSLog(@"get address by addressId: %@",addressId);
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (array == nil){
        NSLog(@"Exception while getting Address`s array by address_id. Error: %@",error.localizedDescription);
        address = nil;
    }
    else{
        if( array.count == 0 ){
            address = [[Address alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
            address.address_id = addressId;
        }
        else{
            address = [array objectAtIndex:0];
        }
    }
    return address;
}

//+(Address *) getAddressByAddressId:(NSString *) addressId withMOC:(NSManagedObjectContext *) managedObjectContext{
//    Address *address;
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Address"
//                                              inManagedObjectContext:managedObjectContext];
//            address = [[Address alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
//            address.address_id = addressId;
//    return address;
//}

// Ищет Address с self.addressId = addressId and self.ta = ta, если находит, то возвращает, иначе, создает новый.
+(Address *) getAddressByAddressId:(NSString *) addressId client:(NSManagedObject *) client withMOC:(NSManagedObjectContext *) managedObjectContext{
    Address *address;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Address"
                                              inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setFetchLimit:1];
    [request setEntity:entity];
    //[request setFetchBatchSize:50];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"address_id == %@ AND client = %@",addressId,client];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    //NSLog(@"get address by addressId: %@",addressId);
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (array == nil){
        NSLog(@"Exception while getting Address`s array by address_id. Error: %@",error.localizedDescription);
        address = nil;
    }
    else{
        if( array.count == 0 ){
            address = [[Address alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
            address.address_id = addressId;
            address.is_deleted = [NSNumber numberWithBool:YES];
        }
        else{
            address = [array objectAtIndex:0];
        }
    }
    return address;
}

// создает и возвращает NSFetchedResultsController для конкретного ТА. Если deleted == nil , то не учитывая свойство deleted. Если не nil, то учитывает. НЕ ЗАПУСКАЕТ ЕГО!!!
+ (NSFetchedResultsController *) getFetchedResultsControllerForTA: (NSManagedObject *) ta deleted: (NSNumber *) deleted shouldHaveOrders:(Boolean) shouldHaveOrder managedObjectContext:(NSManagedObjectContext *) context delegate: (id <NSFetchedResultsControllerDelegate>) delegate{
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Address"
                                              inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    // *** Predicate
        NSMutableArray *predicates = [NSMutableArray array];
        [predicates addObject:[NSPredicate predicateWithFormat:@"client.ta == %@",ta]];
    
        if(deleted != nil) {
            [predicates addObject:[NSPredicate predicateWithFormat:@"( is_deleted == %d ) AND ( client.is_deleted == %d ) ",deleted.boolValue,deleted.boolValue]];
        }
        if(shouldHaveOrder == YES) {
            [predicates addObject:[NSPredicate predicateWithFormat:@"orders.@count > 0"]];
        }
        
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        [request setPredicate:predicate];
    // *** Predicate
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"client.name" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"address" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, sortDescriptor2, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]
                                              initWithFetchRequest:request
                                              managedObjectContext:context
                                              sectionNameKeyPath:@"client.name"
                                              cacheName:nil];
    controller.delegate = delegate;
    return controller;
}

// создает и возвращает NSFetchedResultsController для конкретного ТА. Если deleted == nil , то не учитывая свойство deleted. Если не nil, то учитывает. Использует фильтр по клиентам и адресам в нижнем регистре. НЕ ЗАПУСКАЕТ ЕГО!!!
+ (NSFetchedResultsController *) getFetchedResultsControllerForTA: (NSManagedObject *) ta deleted: (NSNumber *) deleted shouldHaveOrders:(Boolean) shouldHaveOrder filter:(NSString *) filter managedObjectContext:(NSManagedObjectContext *) context delegate: (id <NSFetchedResultsControllerDelegate>) delegate{
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Address"
                                              inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    // *** Predicate
        NSMutableArray *predicates = [NSMutableArray array];
        [predicates addObject:[NSPredicate predicateWithFormat:@"client.ta == %@",ta]];
        //NSLog(@"%@",deleted);
        if(deleted != nil)
        {
            [predicates addObject:[NSPredicate predicateWithFormat:@"( is_deleted == %d ) AND ( client.is_deleted == %d ) ",deleted.boolValue,deleted.boolValue]];
        }
        if(shouldHaveOrder == YES){
            [predicates addObject:[NSPredicate predicateWithFormat:@"orders.@count > 0"]];
        }
        [predicates addObject:[NSPredicate predicateWithFormat:@"address contains[cd] %@ OR client.name contains[cd] %@",filter,filter]];
        
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        [request setPredicate:predicate];
    // *** Predicate
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"client.name" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"address" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, sortDescriptor2, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]
                                              initWithFetchRequest:request
                                              managedObjectContext:context
                                              sectionNameKeyPath:@"client.name"
                                              cacheName:nil];
    controller.delegate = delegate;
    return controller;
}

@end
