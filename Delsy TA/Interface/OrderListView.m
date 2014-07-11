//
//  OrderListView.m
//  Delsy TA
//
//  Created by Valeriy Buev on 11.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "OrderListView.h"

#import "Address+AddressCategory.h"
#import "Client+ClientCategory.h"
#import "Order+OrderCategory.h"
#import "OrderPresentView.h"

@interface OrderListView () {
    NSMutableArray *orders;
    NSDateFormatter *dateFormatter;
}

@end

@implementation OrderListView

@synthesize context;
@synthesize address;

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
    
    orders = [NSMutableArray array];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM yyyy, hh:mm"];
    if(self.context && self.address){
        self.navigationItem.title = [NSString stringWithFormat:@"Заказы клиента: \"%@\"",address.client.name];
        orders = [[Order getAllOrdersByAddress:self.address MOC:self.context] mutableCopy];
        [self.tableView reloadData];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return orders.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"OrderCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Order *order = [orders objectAtIndex:indexPath.row];
    NSString *isSent = @"";
    if(order.isSent.boolValue == YES)
        isSent = @"(отправлено)";
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [dateFormatter stringFromDate:order.date],isSent ];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ руб.",
                                 order.amount];
    
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Order *order = [orders objectAtIndex:indexPath.row];
        [orders removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.context deleteObject:order];
        [self.context save:nil];
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    OrderPresentView *orderPresentView = segue.destinationViewController;
    NSIndexPath *indexPath = [self.tableView.indexPathsForSelectedRows objectAtIndex:0];
    Order *order = [orders objectAtIndex:indexPath.row];
    orderPresentView.context = self.context;
    orderPresentView.address = order.address;
    orderPresentView.order = order;
}


@end
