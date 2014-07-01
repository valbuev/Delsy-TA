//
//  Order+OrderCategory.m
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "Order+OrderCategory.h"
#import "Client+ClientCategory.h"
#import "Address+AddressCategory.h"
#import "AppSettings+AppSettingsCategory.h"
#import "TA+TACategory.h"

@implementation Order (OrderCategory)

// Создает и возвращает новый заказ. Вписывает в заказ текущего ТА, адрес, клиента.
+(Order *) newOrder: (NSManagedObjectContext *) context forAddress:(Address *) address{
    Order *order;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Order" inManagedObjectContext:context ];
    order = [[Order alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    
    TA* ta = [AppSettings getInstance:context].currentTA;
    Client *client = address.client;
    
    order.address = address;
    order.client = client;
    order.ta = ta;
    
    order.custAddress = address.address.copy;
    order.custName = client.name.copy;
    order.taName = ta.name.copy;
    order.date = [NSDate date];
    order.sale = client.sale.copy;
    
    return order;
}

// Создает и возвращает NSFetchedResultsController для данного заказа
-(NSFetchedResultsController *) newOrderController{
    
    NSManagedObjectContext *context = self.managedObjectContext;
    NSFetchedResultsController *controller;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"OrderLine" inManagedObjectContext:context];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"order == %@",self];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"item.productType.name" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"item.name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, sortDescriptor2, nil];
    [request setSortDescriptors:sortDescriptors];
    
    controller = [[NSFetchedResultsController alloc]
                                              initWithFetchRequest:request
                                              managedObjectContext:context
                                              sectionNameKeyPath:@"item.produstType.name"
                                              cacheName:@"ru.bva.DelsyTA.fetchedResultsControllerForOrderForEdit"];
    
    return controller;
}

@end
