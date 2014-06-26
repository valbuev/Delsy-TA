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
    if (Addresslist == nil){
        NSLog(@"Exception while getting TA`s array for set those deleted %d. Error: %@",isDeleted,error.localizedDescription);
        return;
    }
    else for(address in Addresslist){
        address.deleted = [NSNumber numberWithBool:isDeleted];
    }
}

// Ищет Address с self.addressId = addressId, если находит, то возвращает, иначе, создает новый.
+(Address *) getAddressByAddressId:(NSString *) addressId withMOC:(NSManagedObjectContext *) managedObjectContext{
    Address *address;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Address"
                                              inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"address_id == %@",addressId];
    [request setPredicate:predicate];
    
    NSError *error = nil;
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

// создает и возвращает NSFetchedResultsController. Если deleted == nil , то не учитывая свойство deleted. Если не nil, то учитывает. НЕ ЗАПУСКАЕТ ЕГО!!!
+ (NSFetchedResultsController *) getFetchedResultsController: (NSNumber *) deleted managedObjectContext:(NSManagedObjectContext *) context delegate: (id <NSFetchedResultsControllerDelegate>) delegate{
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Address"
                                              inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    if(deleted)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@" ( deleted == %@ ) AND ( client.deleted == %@ ) ",deleted,deleted];
        [request setPredicate:predicate];
    }
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"client.name" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"address" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, sortDescriptor2, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *controller = [[NSFetchedResultsController alloc]
                                              initWithFetchRequest:request
                                              managedObjectContext:context
                                              sectionNameKeyPath:@"client.name"
                                              cacheName:@"ru.bva.DelsyTA.fetchedResultsControllerForClientList"];
    return controller;
}

@end
