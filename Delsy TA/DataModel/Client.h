//
//  Client.h
//  Delsy TA
//
//  Created by Valeriy Buev on 08.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Address, LineSale, Order, PriceGroup, TA;

@interface Client : NSManagedObject

@property (nonatomic, retain) NSString * cust_account;
@property (nonatomic, retain) NSNumber * is_deleted;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *addresses;
@property (nonatomic, retain) NSSet *orders;
@property (nonatomic, retain) TA *ta;
@property (nonatomic, retain) PriceGroup *priceGroup;
@property (nonatomic, retain) LineSale *lineSale;
@end

@interface Client (CoreDataGeneratedAccessors)

- (void)addAddressesObject:(Address *)value;
- (void)removeAddressesObject:(Address *)value;
- (void)addAddresses:(NSSet *)values;
- (void)removeAddresses:(NSSet *)values;

- (void)addOrdersObject:(Order *)value;
- (void)removeOrdersObject:(Order *)value;
- (void)addOrders:(NSSet *)values;
- (void)removeOrders:(NSSet *)values;

@end
