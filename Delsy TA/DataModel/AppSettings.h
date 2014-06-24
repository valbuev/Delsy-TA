//
//  AppSettings.h
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AppSettings : NSManagedObject

@property (nonatomic, retain) NSDate * clientsListDate;
@property (nonatomic, retain) NSDate * clientsListLastUpdate;
@property (nonatomic, retain) NSDate * priceDate;
@property (nonatomic, retain) NSDate * priceLastUpdate;
@property (nonatomic, retain) NSManagedObject *currentTA;

@end
