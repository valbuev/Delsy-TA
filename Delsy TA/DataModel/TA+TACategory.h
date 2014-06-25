//
//  TA+TACategory.h
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "TA.h"

@interface TA (TACategory)

// MOC - ManagedObjectContext

// Ищет ТА с id = taID, если находит, то возвращает, иначе, создает новый.
+(TA *) getTAbyID:(NSString *) taID withMOC:(NSManagedObjectContext *) managedObjectContext;
+(void) setAllTADeleted:(Boolean) deleted InManagedObjectContext:(NSManagedObjectContext *) managedObjectContext;
+(NSArray *)getAllTA:(NSManagedObjectContext *) context;

@end
