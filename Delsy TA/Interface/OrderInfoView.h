//
//  OrderInfoView.h
//  Delsy TA
//
//  Created by Valeriy Buev on 10.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Order;

@interface OrderInfoView : UITableViewController

//info about client
@property (weak, nonatomic) IBOutlet UILabel *labelCustAccount;
@property (weak, nonatomic) IBOutlet UILabel *labelClientName;
@property (weak, nonatomic) IBOutlet UILabel *labelPriceGroupName;
@property (weak, nonatomic) IBOutlet UILabel *labelLineSaleName;

// info about client address
@property (weak, nonatomic) IBOutlet UILabel *labelAddressID;
@property (weak, nonatomic) IBOutlet UILabel *labelAddress;

//info about TA
@property (weak, nonatomic) IBOutlet UILabel *labelTA_id;
@property (weak, nonatomic) IBOutlet UILabel *labelTA_name;

@property (nonatomic,retain) Order *order;

@end
