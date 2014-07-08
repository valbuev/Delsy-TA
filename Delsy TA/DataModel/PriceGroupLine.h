//
//  PriceGroupLine.h
//  Delsy TA
//
//  Created by Valeriy Buev on 08.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

@interface PriceGroupLine : NSManagedObject

@property (nonatomic, retain) NSNumber * plusable;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) Item *item;
@property (nonatomic, retain) NSManagedObject *priceGroup;

@end
