//
//  ProductType.h
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

@interface ProductType : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *fishes;
@property (nonatomic, retain) NSSet *items;
@end

@interface ProductType (CoreDataGeneratedAccessors)

- (void)addFishesObject:(NSManagedObject *)value;
- (void)removeFishesObject:(NSManagedObject *)value;
- (void)addFishes:(NSSet *)values;
- (void)removeFishes:(NSSet *)values;

- (void)addItemsObject:(Item *)value;
- (void)removeItemsObject:(Item *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
