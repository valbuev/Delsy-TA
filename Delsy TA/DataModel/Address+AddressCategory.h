//
//  Address+AddressCategory.h
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "Address.h"

@interface Address (AddressCategory)

// помечаем все адреса как удаленные
+ (void) setAllAddressesDeleted:(Boolean)isDeleted InManagedObjectContext: (NSManagedObjectContext *) context;

// Ищет Address с self.addressId = addressId, если находит, то возвращает, иначе, создает новый.
+(Address *) getAddressByAddressId:(NSString *) addressId withMOC:(NSManagedObjectContext *) managedObjectContext;
// Ищет Address с self.addressId = addressId and self.ta = ta, если находит, то возвращает, иначе, создает новый.
+(Address *) getAddressByAddressId:(NSString *) addressId client:(NSManagedObject *) client withMOC:(NSManagedObjectContext *) managedObjectContext;

// создает и возвращает NSFetchedResultsController для конкретного ТА. Если deleted == nil , то не учитывая свойство deleted. Если не nil, то учитывает. НЕ ЗАПУСКАЕТ ЕГО!!!
+ (NSFetchedResultsController *) getFetchedResultsControllerForTA: (NSManagedObject *) ta deleted: (NSNumber *) deleted shouldHaveOrders:(Boolean) shouldHaveOrder managedObjectContext:(NSManagedObjectContext *) context delegate: (id <NSFetchedResultsControllerDelegate>) delegate;

// создает и возвращает NSFetchedResultsController для конкретного ТА. Если deleted == nil , то не учитывая свойство deleted. Если не nil, то учитывает. Использует фильтр по клиентам и адресам в нижнем регистре. НЕ ЗАПУСКАЕТ ЕГО!!!
+ (NSFetchedResultsController *) getFetchedResultsControllerForTA: (NSManagedObject *) ta deleted: (NSNumber *) deleted shouldHaveOrders:(Boolean) shouldHaveOrder filter:(NSString *) filter managedObjectContext:(NSManagedObjectContext *) context delegate: (id <NSFetchedResultsControllerDelegate>) delegate;

@end
