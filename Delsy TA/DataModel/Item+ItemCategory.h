//
//  Item+ItemCategory.h
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "Item.h"
#import "NSNumber+NSNumberUnit.h"
#import "NSNumber+bvaLineColor.h"

@interface Item (ItemCategory)

// Помечает все имеющиеся в базе Items как удаленные
+(void) setAllItemsDeleted:(Boolean) deleted InManagedObjectContext:(NSManagedObjectContext *) managedObjectContext;

// Ищет Item с itemID = itemID, если находит, то возвращает, иначе, создает новый.
+(Item *) getItemByItemID:(NSString *) itemID withMOC:(NSManagedObjectContext *) managedObjectContext;

@end
