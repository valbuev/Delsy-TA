//
//  PriceGroup+PriceGroupCategory.h
//  Delsy TA
//
//  Created by Valeriy Buev on 08.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "PriceGroup.h"

@interface PriceGroup (PriceGroupCategory)

// Удаляет все группы ценников по строке
+(void) removePriceGroupsFromManagedObjectContext:(NSManagedObjectContext *) managedObjectContext;

// Создает новый объект PriceGroup в managedObjectContext
+(PriceGroup *) newPriceGroupInManObjContext:(NSManagedObjectContext *) managedObjectContext;

// Ищет PriceGroup с self.name = name, если находит, то возвращает, иначе, return nil.
+(PriceGroup *) getPriceGroupByName:(NSString *) name withMOC:(NSManagedObjectContext *) managedObjectContext;

@end
