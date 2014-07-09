//
//  Order.h
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Address, Client, TA;

@interface Order : NSManagedObject

@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSString * custAddress;
@property (nonatomic, retain) NSString * custName;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDate * deliveryDate;
@property (nonatomic, retain) NSNumber * isSent;
@property (nonatomic, retain) NSString * taName;
@property (nonatomic, retain) Address *address;
@property (nonatomic, retain) Client *client;
@property (nonatomic, retain) NSSet *orderLines;
@property (nonatomic, retain) TA *ta;
@end

@interface Order (CoreDataGeneratedAccessors)

- (void)addOrderLinesObject:(NSManagedObject *)value;
- (void)removeOrderLinesObject:(NSManagedObject *)value;
- (void)addOrderLines:(NSSet *)values;
- (void)removeOrderLines:(NSSet *)values;

@end
