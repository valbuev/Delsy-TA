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
#import "PriceMasterView.h"
#import "PriceDetailView.h"
#import "AppDelegate.h"
#import "PriceSplitView.h"

@interface OrderEditView (){
    NSFetchedResultsController *orderController;
    PriceSplitView *priceSplitView;
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

// Заполняем заголовок окна, создаем новый заказ, создаем на основе заказа контроллер, чтобы отслеживать изменения и применять их к таблице
- (void)viewDidLoad
{
    [super viewDidLoad];
    priceSplitView = nil;
    self.navigationItem.title = [NSString stringWithFormat:@"%@ (%@%%)",address.client.name,[address.client.sale floatValueSimpleMaxFrac2]];
    if(!self.order){
        self.order = [Order newOrder:context forAddress:address];
    }
    NSLog(@"OrderEditView viewDidLoad");
    orderController = [order newOrderController];
    orderController.delegate = self;
#warning add observer for order
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc{
    NSLog(@"dealloc OrderEditView");
}

#pragma mark ui-actions and navigation

#warning fill ui-actions and navigation code

// Кнопка "добавить" в навигационной панели
- (IBAction)btnAddOrderLine:(id)sender {
    [self showPrice];
}

- (IBAction)btnMailClicked:(id)sender {
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    return YES;
}


// Показываем Прайс. Передаем в контроллеры нужные переменные
- (void) showPrice{
    // Если не создавали ранее окно прайса, то создаем
    if( !priceSplitView ){
        priceSplitView = [self.storyboard
                          instantiateViewControllerWithIdentifier:@"PriceList"];
        UINavigationController *priceMasterViewNavController = [priceSplitView.viewControllers objectAtIndex:0];
        PriceMasterView *priceMasterView = [priceMasterViewNavController.viewControllers objectAtIndex:0];
        priceMasterView.context = self.context;
        priceSplitView.delegate = priceMasterView;
        PriceDetailView *priceDetailView = [priceSplitView.viewControllers objectAtIndex:1];
        priceDetailView.context = self.context;
        priceDetailView.order = self.order;
        priceMasterView.priceDetailView = priceDetailView;
    }
    UINavigationController *priceMasterViewNavController = [priceSplitView.viewControllers objectAtIndex:0];
    PriceMasterView *priceMasterView = [priceMasterViewNavController.viewControllers objectAtIndex:0];
    // оставляем ссылку, чтобы можно было вернуться назад
    priceMasterView.mainNavigationController = self.navigationController;
    // делаем его активным, вернее главным контроллером окна приложения
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    //[appDelegate setNewRootViewController:splitViewController withAnimation:UIViewAnimationOptionLayoutSubviews];
    appDelegate.window.rootViewController = priceSplitView;
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

// Заполняем ячейку с позицией
-(void) configureCell:(OrderLineCell *) orderLineCell atIndexPath: (NSIndexPath *) indexPath{
    OrderLine *orderLine = [orderController objectAtIndexPath:indexPath];
    orderLineCell.labelName.text = orderLine.itemName;
#warning complete to configure cells
}

// Для таблицы с суммой и кнопкой добавления позиции заполняем ячейки вручную.
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

//для позиций выводим названия типов продуктов
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


// Если нажата ячейка с суммой, то ничего не делаем. Если нажата ячейка добавления позиции, то показываем PriceView. Если нажата ячейка с "позицией", то показываем popup-QtySetter
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if( tableView == self.orderTableView ){
#warning fill code which implement showing of popup-QtySetter
    }
    else{
        if( indexPath.row == 0 ) //sum-cell
        {
        }
        else if (indexPath.row == 1) // addItem-cell
        {
            [self showPrice];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark NSFetchResultsControllerDelegate

//все стандартно

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [self.orderTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.orderTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.orderTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.orderTableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationNone];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell: (OrderLineCell*) [tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.orderTableView endUpdates];
}


@end
