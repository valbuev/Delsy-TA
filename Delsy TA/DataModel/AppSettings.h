//
//  AppSettings.h
//  Delsy TA
//
//  Created by Valeriy Buev on 14.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Order, TA;

@interface AppSettings : NSManagedObject

@property (nonatomic, retain) NSDate * clientsListDate;
@property (nonatomic, retain) NSDate * clientsListLastUpdate;
@property (nonatomic, retain) NSDate * priceDate;
@property (nonatomic, retain) NSDate * priceLastUpdate;
@property (nonatomic, retain) NSString * updateFolderURL;
@property (nonatomic, retain) NSString * photosFolderURL;
@property (nonatomic, retain) NSString * defaultRecipient;
@property (nonatomic, retain) TA *currentTA;
@property (nonatomic, retain) Order *lastOrder;

@end
