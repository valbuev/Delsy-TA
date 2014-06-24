//
//  OrderLine.h
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item, Order;

@interface OrderLine : NSManagedObject

@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSString * itemName;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * promo;
@property (nonatomic, retain) NSNumber * qty;
@property (nonatomic, retain) NSNumber * unit;
@property (nonatomic, retain) Item *item;
@property (nonatomic, retain) Order *order;

@end
