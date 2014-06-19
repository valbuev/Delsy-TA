//
//  Client.h
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Client : NSManagedObject

@property (nonatomic, retain) NSString * cust_account;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * sale;
@property (nonatomic, retain) NSSet *addresses;
@property (nonatomic, retain) NSSet *orders;
@property (nonatomic, retain) NSManagedObject *ta;
@end

@interface Client (CoreDataGeneratedAccessors)

- (void)addAddressesObject:(NSManagedObject *)value;
- (void)removeAddressesObject:(NSManagedObject *)value;
- (void)addAddresses:(NSSet *)values;
- (void)removeAddresses:(NSSet *)values;

- (void)addOrdersObject:(NSManagedObject *)value;
- (void)removeOrdersObject:(NSManagedObject *)value;
- (void)addOrders:(NSSet *)values;
- (void)removeOrders:(NSSet *)values;

@end
