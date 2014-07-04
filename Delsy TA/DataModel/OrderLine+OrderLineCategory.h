//
//  OrderLine+OrderLineCategory.h
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "OrderLine.h"

@class Item;
@class Order;
@interface OrderLine (OrderLineCategory)

// Создает и возвращает новую позицию.
+ (OrderLine *) newOrderLine:(NSManagedObjectContext *) context forItem:(Item *) item forOrder:(Order *) order;

@end
