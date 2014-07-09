//
//  Client+ClientCategory.h
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "Client.h"

@class Item;

@interface Client (ClientCategory)

// ПОмечает всех Клиентов, как удаленные
+(void)setAllClientsDeleted:(Boolean)isDeleted InManagedObjectContext:(NSManagedObjectContext *)context;

// Ищет Client с self.custAccount = custAccount, если находит, то возвращает, иначе, создает новый.
+(Client *) getClientByCustAccount:(NSString *) custAccount withMOC:(NSManagedObjectContext *) managedObjectContext;

// Возвращает скидку по продукту для данного клиента
- (NSNumber *) getSaleByItem:(Item *) item;

// Возвращает цену продукта для данного клиента с учетом ценовых соглашений и скидок по строке
- (NSNumber *) getPriceByItem:(Item *) item;

@end
