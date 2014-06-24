//
//  Fish.h
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item, ProductType;

@interface Fish : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *items;
@property (nonatomic, retain) NSSet *productTypes;
@end

@interface Fish (CoreDataGeneratedAccessors)

- (void)addItemsObject:(Item *)value;
- (void)removeItemsObject:(Item *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

- (void)addProductTypesObject:(ProductType *)value;
- (void)removeProductTypesObject:(ProductType *)value;
- (void)addProductTypes:(NSSet *)values;
- (void)removeProductTypes:(NSSet *)values;

@end
