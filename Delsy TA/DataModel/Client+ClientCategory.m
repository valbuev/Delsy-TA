//
//  Client+ClientCategory.m
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "Client+ClientCategory.h"
#import "Item+ItemCategory.h"

@implementation Client (ClientCategory)

+(void)setAllClientsDeleted:(Boolean)isDeleted InManagedObjectContext:(NSManagedObjectContext *)context{
    
    // Получаем все Clients
    Client *client;
    NSArray *ClientList;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Client"
                                              inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error = nil;
    ClientList = [context executeFetchRequest:request error:&error];
    
    // Если нет ошибок, то проходим по списку и помечаем каждый как удаленный
    int n=0;
    if (ClientList == nil){
        NSLog(@"Exception while getting Client`s array for set those deleted %d. Error: %@",isDeleted,error.localizedDescription);
        return;
    }
    else for(client in ClientList){
        client.deleted = [NSNumber numberWithBool:isDeleted];
        n++;
        if(n==20){
            if(![context save:&error]){
                NSLog(@"Exception while setting Client`s array deleted %d. Error: %@",isDeleted,error.localizedDescription);
            }
            n=0;
        }
    }
}

// Ищет Client с self.custAccount = custAccount, если находит, то возвращает, иначе, создает новый.
+(Client *) getClientByCustAccount:(NSString *) custAccount withMOC:(NSManagedObjectContext *) managedObjectContext{
    Client *client;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Client"
                                              inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setFetchLimit:1];
    [request setEntity:entity];
    //[request setFetchBatchSize:50];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cust_account == %@",custAccount];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    //NSLog(@"get client by custAccount: %@",custAccount);
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (array == nil){
        NSLog(@"Exception while getting Client`s array by cust_account. Error: %@",error.localizedDescription);
        client = nil;
    }
    else{
        if( array.count == 0 ){
            client = [[Client alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
            client.cust_account = custAccount;
            client.deleted = [NSNumber numberWithBool:YES];
        }
        else{
            client = [array objectAtIndex:0];
        }
    }
    return client;
}

// Возвращает скидку по продукту для данного клиента
- (NSNumber *) getSaleByItem:(Item *) item{
    //return self.sale;
#warning
    return 0;
}

//+(Client *) getClientByCustAccount:(NSString *) custAccount withMOC:(NSManagedObjectContext *) managedObjectContext{
//    Client *client;
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Client"
//                                              inManagedObjectContext:managedObjectContext];
//            client = [[Client alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
//            client.cust_account = custAccount;
//    return client;
//}

@end
