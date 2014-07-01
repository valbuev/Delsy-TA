//
//  OrderEditView.m
//  Delsy TA
//
//  Created by Valeriy Buev on 01.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "OrderEditView.h"
#import "Address+AddressCategory.h"
#import "Client+ClientCategory.h"
#import "Order+OrderCategory.h"
#import "OrderLine+OrderLineCategory.h"
#import "Item+ItemCategory.h"
#import "NSNumber+BVAFormatter.h"
#import "OrderLineCell.h"

@interface OrderEditView (){
    NSFetchedResultsController *orderController;
}

@end

@implementation OrderEditView

@synthesize address;
@synthesize context;
@synthesize order;
@synthesize orderTableView;
@synthesize sumAndAddPositionTableView;

#pragma mark initialization and basic view-controller tasks

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = [NSString stringWithFormat:@"%@ (%@%%)",address.client.name,[address.client.sale floatValueSimpleMaxFrac2]];
    if(!self.order){
        self.order = [Order newOrder:context forAddress:address];
    }
    NSLog(@"OrderEditView viewDidLoad");
    orderController = [order newOrderController];
    orderController.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark ui-actions

- (IBAction)btnAddOrderLine:(id)sender {
}

#pragma mark table-view delegating and datasourcing

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if( tableView == self.orderTableView ){
        if(orderController){
            id<NSFetchedResultsSectionInfo> sectionInfo = [orderController.sections objectAtIndex:section];
            return [sectionInfo numberOfObjects];
        }
        return 0;
    }
    else{
        // Если это нижняя таблица с суммой и кнопкой "добавить позицию"
        return 2;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if( tableView == self.orderTableView ){
        if(orderController){
            return orderController.sections.count;
        }
        return 0;
    }
    else{
        // Если это нижняя таблица с суммой и кнопкой "добавить позицию"
        return 1;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if( tableView == self.orderTableView ){
        
        static NSString *cellIdentifier = @"OrderLine";
        OrderLineCell *orderLineCell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier forIndexPath: indexPath];
        
        OrderLine *orderLine = [orderController objectAtIndexPath:indexPath];
        orderLineCell.labelName.text = orderLine.itemName;
        
        return orderLineCell;
    }
    else{
        static NSString *cellIdsum = @"Sum";
        static NSString *cellIdAddItem = @"AddItem";
        UITableViewCell *cell;
        if( indexPath.row == 0 ) { // sum
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdsum forIndexPath:indexPath];
            UILabel *sumLabel = (UILabel *) [cell.contentView viewWithTag:1];
            NSNumber *amount = self.order.amount;
            sumLabel.text = [NSString stringWithFormat:@"Сумма: %@ руб.",[amount floatValueSimpleMaxFrac2]];
        }
        else { // AddItem
            cell = [tableView dequeueReusableCellWithIdentifier: cellIdAddItem forIndexPath: indexPath];
        }
        return cell;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if( tableView == self.orderTableView ){
        id <NSFetchedResultsSectionInfo> sectionInfo = [orderController.sections objectAtIndex:section];
        return [sectionInfo name];
    }
    else{
        // Если это нижняя таблица с суммой и кнопкой "добавить позицию"
        return @"";
    }
}


@end
