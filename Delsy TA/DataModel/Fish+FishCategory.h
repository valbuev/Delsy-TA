//
//  Fish+FishCategory.h
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "Fish.h"

@interface Fish (FishCategory)

// Ищет Fish с fishName = fishName, если находит, то возвращает, иначе, создает новый.
+(Fish *) getFishByName:(NSString *) fishName withMOC:(NSManagedObjectContext *) managedObjectContext;

// Удаляет во всех Fish все связи с ProductType
+(void) removeAllProductTypesRelationShipsFromAllFishes_InManagedObjectContext:(NSManagedObjectContext *) managedObjectContext;

@end
