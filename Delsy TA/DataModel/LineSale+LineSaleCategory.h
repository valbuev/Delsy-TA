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

@end
