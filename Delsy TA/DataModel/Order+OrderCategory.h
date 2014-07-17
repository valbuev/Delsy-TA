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

// Пересчитывает сумму заказа
-(void) reCalculateAmount;

//Сохраняет заказ в удобочитаемом виде в строку. Возвращает эту строку.
-(NSString *) saveOrder2str;

// Сохраняет Заказ в xml-файл и возвращает его адрес
- (NSURL *) saveOrder2XMLFile;

// ВОзвращает все заказы выбранного адреса, сортированные по дате (последние вверху)
+(NSArray *) getAllOrdersByAddress:(Address *) address MOC:(NSManagedObjectContext *) context;

// Возвращает новый заказ, в котором присутствуют те же позиции, за исключением отсутствующих в прайсе продуктов.
-(Order *) newOrderUsingThis;

// Удаляет все заказы данного агента и возвращает nil, если нет ошибки, или ошибку, если есть.
+ (NSError *) removeAllOrdersForTA:(TA *) ta inMOC:(NSManagedObjectContext *) context;

@end
