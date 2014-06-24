//
//  TA.h
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AppSettings, Client;

@interface TA : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *clients;
@property (nonatomic, retain) NSSet *orders;
@property (nonatomic, retain) AppSettings *settings;
@end

@interface TA (CoreDataGeneratedAccessors)

- (void)addClientsObject:(Client *)value;
- (void)removeClientsObject:(Client *)value;
- (void)addClients:(NSSet *)values;
- (void)removeClients:(NSSet *)values;

- (void)addOrdersObject:(NSManagedObject *)value;
- (void)removeOrdersObject:(NSManagedObject *)value;
- (void)addOrders:(NSSet *)values;
- (void)removeOrders:(NSSet *)values;

@end
