//
//  OrderPresentView.h
//  Delsy TA
//
//  Created by Valeriy Buev on 11.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Address;
@class Order;

@interface OrderPresentView : UIViewController
<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *context;

@property (nonatomic, strong) Address *address;

@property (nonatomic, strong) Order *order;

@property (weak, nonatomic) IBOutlet UITableView *orderTableView;
@property (weak, nonatomic) IBOutlet UITableView *sumAndNewOrderTableView;

@end
