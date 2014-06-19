//
//  Thesis.h
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

@interface Thesis : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Item *item;

@end
