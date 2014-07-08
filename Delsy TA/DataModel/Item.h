//
//  Item.h
//  Delsy TA
//
//  Created by Valeriy Buev on 08.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Fish, OrderLine, Photo, ProductType, Thesis;

@interface Item : NSManagedObject

@property (nonatomic, retain) NSString * annotation;
@property (nonatomic, retain) NSString * composition;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSString * hundredGrammsContains;
@property (nonatomic, retain) NSString * itemID;
@property (nonatomic, retain) NSNumber * lineColor;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * producer;
@property (nonatomic, retain) NSNumber * promo;
@property (nonatomic, retain) NSNumber * shelfLife;
@property (nonatomic, retain) NSNumber * unit;
@property (nonatomic, retain) NSNumber * unitsInBigBox;
@property (nonatomic, retain) NSNumber * unitsInBox;
@property (nonatomic, retain) Fish *fish;
@property (nonatomic, retain) NSSet *orderLines;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) ProductType *productType;
@property (nonatomic, retain) NSSet *thesises;
@property (nonatomic, retain) NSSet *priceGroupLines;
@property (nonatomic, retain) NSSet *lineSaleLines;
@end

@interface Item (CoreDataGeneratedAccessors)

- (void)addOrderLinesObject:(OrderLine *)value;
- (void)removeOrderLinesObject:(OrderLine *)value;
- (void)addOrderLines:(NSSet *)values;
- (void)removeOrderLines:(NSSet *)values;

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

- (void)addThesisesObject:(Thesis *)value;
- (void)removeThesisesObject:(Thesis *)value;
- (void)addThesises:(NSSet *)values;
- (void)removeThesises:(NSSet *)values;

- (void)addPriceGroupLinesObject:(NSManagedObject *)value;
- (void)removePriceGroupLinesObject:(NSManagedObject *)value;
- (void)addPriceGroupLines:(NSSet *)values;
- (void)removePriceGroupLines:(NSSet *)values;

- (void)addLineSaleLinesObject:(NSManagedObject *)value;
- (void)removeLineSaleLinesObject:(NSManagedObject *)value;
- (void)addLineSaleLines:(NSSet *)values;
- (void)removeLineSaleLines:(NSSet *)values;

@end
