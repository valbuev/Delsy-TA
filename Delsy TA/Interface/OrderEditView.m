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

@interface OrderEditView ()
<PriceViewDelegate>{
    NSFetchedResultsController *orderController;
    PriceSplitView *priceSplitView;
    Boolean isThatWindowShowing;
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

-(void) saveManageObjectContext{
    if(self.context == nil){
        NSLog(@"OrderEditView.managedObjectContext = nil");
        abort();
    }
    else{
        NSError *error;
        [self.context save:&error];
        if(error){
            NSLog(@"OrderEditView.managedObjectContext error while saving: %@",error.localizedDescription);
            abort();
        }
    }
}

// Заполняем заголовок окна, создаем новый заказ, создаем на основе заказа контроллер, чтобы отслеживать изменения и применять их к таблице
- (void)viewDidLoad
{
    [super viewDidLoad];
    isThatWindowShowing = YES;
    priceSplitView = nil;
    self.navigationItem.title = [NSString stringWithFormat:@"%@ (%@%%)",address.client.name,[address.client.sale floatValueSimpleMaxFrac2]];
    if(!self.order){
        self.order = [Order newOrder:context forAddress:address];
    }
    NSLog(@"OrderEditView viewDidLoad");
    orderController = [order newOrderController];
    orderController.delegate = self;
    [orderController performFetch:nil];
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
    
    //подписываемся на PriceMasterView, чтобы знать, когда он закроется.
    // Выставляем флаг, что мы в фоне.
    priceMasterView.delegate = self;
    isThatWindowShowing = NO;
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
    orderLineCell.labelUnit.text = [orderLine.unit unitValueToString];
    orderLineCell.labelAmount.text = [orderLine.amount floatValueFrac2or0];
    orderLineCell.labelPrice.text = [orderLine.price floatValueFrac2or0];
    orderLineCell.labelCurrentUnitQty.text = [orderLine.qty floatValueSimpleMaxFrac3];
    orderLineCell.labelBaseUnitQty.text = [NSString stringWithFormat:@"%@ %@",[orderLine.baseUnitQty floatValueSimpleMaxFrac3],[orderLine.item.unit unitValueToString]];
    if(orderLine.item.promo.boolValue == YES)
        orderLineCell.labelPrice.textColor = [UIColor redColor];
    orderLineCell.backgroundColor = [orderLine.item.lineColor lineColor:[UIColor whiteColor]];
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
            //[self.orderTableView reloadData];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == self.orderTableView)
        return YES;
    else
        return NO;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == self.orderTableView){
        switch (editingStyle) {
            case UITableViewCellEditingStyleDelete:
                [self.context deleteObject:[orderController objectAtIndexPath:indexPath]];
                [self saveManageObjectContext];
                break;
                
            default:
                break;
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == self.orderTableView){
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

#pragma mark NSFetchResultsControllerDelegate

//все стандартно

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller{
    if( isThatWindowShowing == YES )
        [self.orderTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    //Если не в фоне, то показываем изменения
    if( isThatWindowShowing == YES ){
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [self.orderTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                                   withRowAnimation:UITableViewRowAnimationNone];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.orderTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                                   withRowAnimation:UITableViewRowAnimationLeft];
                break;
        }
        // Обновляем таблицу с кнопкой и суммой, чтобы отобразить корректно сумму
        [self.sumAndAddPositionTableView reloadData];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.orderTableView;
    
    //Если не в фоне, то показываем изменения
    if( isThatWindowShowing == YES ){
        switch(type) {
                
            case NSFetchedResultsChangeInsert:
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                 withRowAnimation:UITableViewRowAnimationNone];
                break;
                
            case NSFetchedResultsChangeDelete:
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                 withRowAnimation:UITableViewRowAnimationLeft];
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
        // Обновляем таблицу с кнопкой и суммой, чтобы отобразить корректно сумму
        [self.sumAndAddPositionTableView reloadData];
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if( isThatWindowShowing == YES )
        [self.orderTableView endUpdates];
}

#pragma mark PriceViewDelegate

- (void)priceViewWillFinishShowing{
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        // ставим обратно флаг, что мы не в фоне
        isThatWindowShowing = YES;
        // Обновляем таблицу, так как она не содержит обновления
        [self.orderTableView reloadData];
        // Обновляем таблицу с кнопкой и суммой, чтобы отобразить корректно сумму
        [self.sumAndAddPositionTableView reloadData];
    }];
}


@end
