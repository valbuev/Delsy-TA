//
//  OrderInfoView.m
//  Delsy TA
//
//  Created by Valeriy Buev on 10.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "OrderInfoView.h"
#import "Order+OrderCategory.h"
#import "Client+ClientCategory.h"
#import "PriceGroup+PriceGroupCategory.h"
#import "LineSale+LineSaleCategory.h"
#import "Address+AddressCategory.h"
#import "TA+TACategory.h"

@interface OrderInfoView ()

@end

@implementation OrderInfoView

@synthesize labelAddress;
@synthesize labelAddressID;
@synthesize labelClientName;
@synthesize labelCustAccount;
@synthesize labelLineSaleName;
@synthesize labelPriceGroupName;
@synthesize labelTA_id;
@synthesize labelTA_name;
@synthesize order;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if( self.order ){
        self.labelCustAccount.text = order.client.cust_account;
        self.labelClientName.text = order.client.name;
        self.labelPriceGroupName.text = order.client.priceGroup.name;
        self.labelLineSaleName.text = order.client.lineSale.name;
        
        self.labelAddressID.text = order.address.address_id;
        self.labelAddress.text = order.address.address;
        
        self.labelTA_id.text = order.ta.id;
        self.labelTA_name.text = order.ta.name;
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
