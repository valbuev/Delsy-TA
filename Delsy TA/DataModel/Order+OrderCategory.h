//
//  Order+OrderCategory.h
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "Order.h"
#import "NSNumber+NSNumberUnit.h"

@class Item;

@interface Order (OrderCategory)

// Создает и возвращает новый заказ. Вписывает в заказ текущего ТА, адрес, клиента.
+(Order *) newOrder: (NSManagedObjectContext *) context forAddress:(Address *) address;

// Создает и возвращает NSFetchedResultsController для данного заказа
-(NSFetchedResultsController *) newOrderController;

//Добавляет позицию в текущий заказ. Если позиция с таким продуктом уже есть, то она заменяется.
- (void) addItem:(Item *) item qty:(NSNumber *) qty unit:(Unit) unit;

@end
