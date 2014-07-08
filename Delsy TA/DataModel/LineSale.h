//
//  LineSale.h
//  Delsy TA
//
//  Created by Valeriy Buev on 08.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Client;

@interface LineSale : NSManagedObject

@property (nonatomic, retain) NSNumber * allSale;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *clients;
@property (nonatomic, retain) NSSet *lineSaleLines;
@end

@interface LineSale (CoreDataGeneratedAccessors)

- (void)addClientsObject:(Client *)value;
- (void)removeClientsObject:(Client *)value;
- (void)addClients:(NSSet *)values;
- (void)removeClients:(NSSet *)values;

- (void)addLineSaleLinesObject:(NSManagedObject *)value;
- (void)removeLineSaleLinesObject:(NSManagedObject *)value;
- (void)addLineSaleLines:(NSSet *)values;
- (void)removeLineSaleLines:(NSSet *)values;

@end
