//
//  LineSale+LineSaleCategory.h
//  Delsy TA
//
//  Created by Valeriy Buev on 08.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "LineSale.h"

@interface LineSale (LineSaleCategory)

// Удаляет все скидки по строке
+(void) removeLineSalesFromManagedObjectContext:(NSManagedObjectContext *) managedObjectContext;

// Создает новый объект LineSale в managedObjectContext
+(LineSale *) newLineSaleInManObjContext:(NSManagedObjectContext *) managedObjectContext;

// Ищет LineSale с self.name = name, если находит, то возвращает, иначе, return nil.
+(LineSale *) getLineSaleByName:(NSString *) name withMOC:(NSManagedObjectContext *) managedObjectContext;

@end
