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
+(Item *) getOrCreateItemByItemID:(NSString *) itemID withMOC:(NSManagedObjectContext *) managedObjectContext;

// Ищет Item с itemID = itemID, если находит, то возвращает, иначе, nil.
+(Item *) getItemByItemID:(NSString *) itemID withMOC:(NSManagedObjectContext *) managedObjectContext;

// создает контроллер неудаленных items сгруппированных по названиям рыб
+(NSFetchedResultsController *) getControllerGroupByFish:(NSManagedObjectContext *) context forProductType:(NSManagedObject *) productType;

+ (NSArray *) getAllItems: (NSManagedObjectContext *) context;

// Проверяет, есть ли загруженные фотографии
- (Boolean) haveDownloadedPhotos;

// создает контроллер неудаленных items сгруппированных по производителю и отфильтрованных по типу продукта
+(NSFetchedResultsController *) getControllerGroupByProducer:(NSManagedObjectContext *) context forProductType:(ProductType *) productType ;

// создает предикат, предназначенный для фильтрации продуктов по типу продукта и по типу рыбы
+ (NSPredicate *) predicateForFilterItemsByProdType:(ProductType *) prodType fish:(Fish *) fish ;

@end
