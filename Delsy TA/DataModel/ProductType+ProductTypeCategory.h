//
//  ProductType+ProductTypeCategory.h
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "ProductType.h"

@interface ProductType (ProductTypeCategory)

// Ищет ProductType с name = name, если находит, то возвращает, иначе, создает новый.
+(ProductType *) getProductTypeByName:(NSString *) name withMOC:(NSManagedObjectContext *) managedObjectContext;

@end
