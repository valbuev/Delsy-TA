//
//  OrderEditView.h
//  Delsy TA
//
//  Created by Valeriy Buev on 01.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class Address;
@class Order;

@interface OrderEditView : UIViewController
<NSFetchedResultsControllerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *context;

@property (nonatomic, strong) Address *address;

@property (nonatomic, strong) Order *order;

@property (weak, nonatomic) IBOutlet UITableView *orderTableView;
@property (weak, nonatomic) IBOutlet UITableView *sumAndAddPositionTableView;

- (IBAction)btnAddOrderLine:(id)sender;
- (IBAction)btnMailClicked:(id)sender;

@end
