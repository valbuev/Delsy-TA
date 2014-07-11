//
//  OrderListView.h
//  Delsy TA
//
//  Created by Valeriy Buev on 11.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Address;

@interface OrderListView : UITableViewController


@property (nonatomic,retain) NSManagedObjectContext *context;
@property (nonatomic,retain) Address *address;

@end
