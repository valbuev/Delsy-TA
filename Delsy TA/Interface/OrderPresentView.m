//
//  OrderPresentView.m
//  Delsy TA
//
//  Created by Valeriy Buev on 11.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "OrderPresentView.h"
#import "OrderEditView.h"
#import "Address+AddressCategory.h"
#import "Client+ClientCategory.h"
#import "Order+OrderCategory.h"
#import "OrderLine+OrderLineCategory.h"
#import "Item+ItemCategory.h"
#import "NSNumber+BVAFormatter.h"
#import "OrderLineCell.h"
#import "LineSale+LineSaleCategory.h"
#import "OrderInfoView.h"

@interface OrderPresentView ()
<NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController *orderController;
}
@end

@implementation OrderPresentView
@synthesize address;
@synthesize context;
@synthesize order;
@synthesize orderTableView;
@synthesize sumAndNewOrderTableView;

#pragma mark initialization and basic view-controller tasks

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm dd.MM.yy"];
    self.navigationItem.title = [NSString stringWithFormat:@"%@ (%@)",self.address.client.name,[formatter stringFromDate:order.date]];
    orderController = [order newOrderController];
    orderController.delegate = self;
    [orderController performFetch:nil];
    self.sumAndNewOrderTableView.rowHeight = 44.0f;
    [self.orderTableView reloadData];
    [self.sumAndNewOrderTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"Info"]){
        OrderInfoView *orderInfoView = (OrderInfoView *) segue.destinationViewController;
        orderInfoView.order = self.order;
    }
    if([segue.identifier isEqualToString:@"OrderEditView"]){
        Order *newOrder = [self.order newOrderUsingThis];
        OrderEditView *orderEditView = segue.destinationViewController;
        orderEditView.context = self.context;
        orderEditView.order = newOrder;
        orderEditView.address = self.address;
    }
}
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if([identifier isEqualToString:@"OrderEditView"]){
        if(self.order.client.is_deleted.boolValue == YES
           || self.order.address.is_deleted.boolValue == YES){
            //
            return NO;
        }
        else {
            // Делаем все тут, потому что по другому никак не получается очистить стек навигейшн-контроллера, не оставляя в нем navigation-item-ы
            Order *newOrder = [self.order newOrderUsingThis];
            OrderEditView *orderEditView = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderEditView"];
            orderEditView.context = self.context;
            orderEditView.order = newOrder;
            orderEditView.address = self.address;
            UINavigationController *controller = self.navigationController;
            [controller popToRootViewControllerAnimated:NO];
            [controller pushViewController:orderEditView animated:YES];
            
            return NO;
        }
    }
    return YES;
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
        // Если это нижняя таблица с суммой и кнопкой "создать заказ на основе этого"
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
        // Если это нижняя таблица с суммой и кнопкой "создать заказ на основе этого"
        return 1;
    }
}

// Заполняем ячейку с позицией
-(void) configureCell:(OrderLineCell *) orderLineCell atIndexPath: (NSIndexPath *) indexPath{
    OrderLine *orderLine = [orderController objectAtIndexPath:indexPath];
    orderLineCell.labelName.text = orderLine.itemName;
    orderLineCell.labelUnit.text = [orderLine.unit unitValueToString];
    orderLineCell.labelAmount.text = [orderLine.amount floatValueFrac2or0];
    orderLineCell.labelPrice.text = [orderLine.price floatValueFrac2or0];
    orderLineCell.labelCurrentUnitQty.text = [orderLine.qty floatValueSimpleMaxFrac3];
    orderLineCell.labelBaseUnitQty.text = [NSString stringWithFormat:@"%@ %@",[orderLine.baseUnitQty floatValueSimpleMaxFrac3],[orderLine.item.unit unitValueToString]];
    if(orderLine.promo.boolValue == YES)
        orderLineCell.labelPrice.textColor = [UIColor redColor];
    orderLineCell.backgroundColor = [orderLine.item.lineColor lineColor:[UIColor whiteColor]];
}

// Для таблицы с суммой и кнопкой перевода на редактирование заполняем ячейки вручную.
// Для таблицы с позициями создаем ячейку и передаем ее на заполнение в функцию configureCell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if( tableView == self.orderTableView ){
        
        static NSString *cellIdentifier = @"OrderLine";
        OrderLineCell *orderLineCell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier forIndexPath: indexPath];
        
        [self configureCell:orderLineCell atIndexPath:indexPath];
        return orderLineCell;
    }
    else{
        static NSString *cellIdsum = @"Sum";
        static NSString *cellIdAddItem = @"NewOrder";
        UITableViewCell *cell;
        if( indexPath.row == 0 ) { // sum
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdsum forIndexPath:indexPath];
            UILabel *sumLabel = (UILabel *) [cell.contentView viewWithTag:1];
            NSNumber *amount = self.order.amount;
            sumLabel.text = [NSString stringWithFormat:@"%@ руб.", [amount floatValueSimpleMaxFrac2]];
        }
        else { // AddItem
            cell = [tableView dequeueReusableCellWithIdentifier: cellIdAddItem forIndexPath: indexPath];
        }
        return cell;
    }
}

//для позиций выводим названия типов продуктов
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if( tableView == self.orderTableView ){
        id <NSFetchedResultsSectionInfo> sectionInfo = [orderController.sections objectAtIndex:section];
        return [sectionInfo name];
    }
    else{
        return @"";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if( tableView == self.orderTableView ){
    }
    else{
        if( indexPath.row == 0 ) //sum-cell
        {
        }
        else if (indexPath.row == 1) // addItem-cell
        {
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
