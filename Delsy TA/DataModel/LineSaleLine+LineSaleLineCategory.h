//
//  LineSaleLine+LineSaleLineCategory.h
//  Delsy TA
//
//  Created by Valeriy Buev on 08.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "LineSaleLine.h"

@interface LineSaleLine (LineSaleLineCategory)

// Создает новый объект LineSaleLine в managedObjectContext
+(LineSaleLine *) newLineSaleLineInManObjContext:(NSManagedObjectContext *) managedObjectContext;

@end
