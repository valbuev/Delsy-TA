//
//  Item.h
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Item : NSManagedObject

@property (nonatomic, retain) NSString * annotation;
@property (nonatomic, retain) NSString * composition;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSString * hundredGrammsContains;
@property (nonatomic, retain) NSString * itemID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * producer;
@property (nonatomic, retain) NSNumber * promo;
@property (nonatomic, retain) NSNumber * shelfLife;
@property (nonatomic, retain) NSNumber * unit;
@property (nonatomic, retain) NSNumber * unitsInBox;
@property (nonatomic, retain) NSManagedObject *fish;
@property (nonatomic, retain) NSSet *orderLines;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) NSManagedObject *productType;
@property (nonatomic, retain) NSSet *thesises;
@end

@interface Item (CoreDataGeneratedAccessors)

- (void)addOrderLinesObject:(NSManagedObject *)value;
- (void)removeOrderLinesObject:(NSManagedObject *)value;
- (void)addOrderLines:(NSSet *)values;
- (void)removeOrderLines:(NSSet *)values;

- (void)addPhotosObject:(NSManagedObject *)value;
- (void)removePhotosObject:(NSManagedObject *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

- (void)addThesisesObject:(NSManagedObject *)value;
- (void)removeThesisesObject:(NSManagedObject *)value;
- (void)addThesises:(NSSet *)values;
- (void)removeThesises:(NSSet *)values;

@end
