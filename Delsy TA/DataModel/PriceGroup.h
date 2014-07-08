//
//  PriceGroup.h
//  Delsy TA
//
//  Created by Valeriy Buev on 08.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Client, PriceGroupLine;

@interface PriceGroup : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *priceGroupLines;
@property (nonatomic, retain) NSSet *clients;
@end

@interface PriceGroup (CoreDataGeneratedAccessors)

- (void)addPriceGroupLinesObject:(PriceGroupLine *)value;
- (void)removePriceGroupLinesObject:(PriceGroupLine *)value;
- (void)addPriceGroupLines:(NSSet *)values;
- (void)removePriceGroupLines:(NSSet *)values;

- (void)addClientsObject:(Client *)value;
- (void)removeClientsObject:(Client *)value;
- (void)addClients:(NSSet *)values;
- (void)removeClients:(NSSet *)values;

@end
