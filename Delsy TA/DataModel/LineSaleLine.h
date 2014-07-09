//
//  LineSaleLine.h
//  Delsy TA
//
//  Created by Valeriy Buev on 08.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item, LineSale;

@interface LineSaleLine : NSManagedObject

@property (nonatomic, retain) NSNumber * sale1;
@property (nonatomic, retain) NSNumber * sale2;
@property (nonatomic, retain) LineSale *lineSale;
@property (nonatomic, retain) Item *item;

@end
