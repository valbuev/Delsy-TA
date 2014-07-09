//
//  PriceGroupLine+PriceGroupLineCategory.h
//  Delsy TA
//
//  Created by Valeriy Buev on 08.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "PriceGroupLine.h"

@interface PriceGroupLine (PriceGroupLineCategory)

// Создает новый объект PriceGroupLine в managedObjectContext
+(PriceGroupLine *) newPriceGroupLineInManObjContext:(NSManagedObjectContext *) managedObjectContext;

+ (NSArray *) getAllPriceGroupLines: (NSManagedObjectContext *) context;

@end
