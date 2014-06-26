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


@end
