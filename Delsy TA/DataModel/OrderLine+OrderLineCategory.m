//
//  OrderLine+OrderLineCategory.m
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "OrderLine+OrderLineCategory.h"
#import "Item+ItemCategory.h"
#import "Order+OrderCategory.h"

@implementation OrderLine (OrderLineCategory)
// Создает и возвращает новую позицию.
+ (OrderLine *) newOrderLine:(NSManagedObjectContext *) context forItem:(Item *) item forOrder:(Order *) order{
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"OrderLine" inManagedObjectContext:context];
    OrderLine *orderLine = [[OrderLine alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    
    orderLine.item = item;
    orderLine.order = order;
    orderLine.itemName = [item.name copy];
    orderLine.promo = [item.promo copy];
    
    return orderLine;
}

//-(void)willChangeValueForKey:(NSString *)key{
//    [super willChangeValueForKey:key];
//    [self.order willChangeValueForKey:@"orderLines"];
//}
//
//-(void)didChangeValueForKey:(NSString *)key{
//    [super didChangeValueForKey:key];
//    [self.order didChangeValueForKey:@"orderLines"];
//}

@end
