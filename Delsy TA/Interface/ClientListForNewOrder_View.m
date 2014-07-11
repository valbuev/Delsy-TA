//
//  ClientListForNewOrder_View.m
//  Delsy TA
//
//  Created by Valeriy Buev on 26.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "ClientListForNewOrder_View.h"
#import "Address+AddressCategory.h"
#import "Client+ClientCategory.h"
#import "AppSettings+AppSettingsCategory.h"
#import "OrderEditView.h"

@interface ClientListForNewOrder_View (){
    
}
//AddressCell
//ClientNameCell

@property (strong, nonatomic) NSFetchedResultsController *fetchedController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedControllerWithFilter;

@end

@implementation ClientListForNewOrder_View

@synthesize fetchedController = _fetchedController;
@synthesize fetchedControllerWithFilter;
@synthesize clientListViewResult;
@synthesize order;

-(NSFetchedResultsController *)fetchedController{
    if( _fetchedController )
        return _fetchedController;
    
    AppSettings *settings = [AppSettings getInstance:self.managedObjectContext];
    
    // Если далее нужно будет показать список заказов, то показываем и удаленных клиентов, и не удаленных
    NSNumber * deleted = nil;
    Boolean shouldHaveOrders = NO;
    if( self.clientListViewResult != ClientListViewResult_OpenOrderListView ){
        deleted = [NSNumber numberWithBool:NO];
    }
    else {
        shouldHaveOrders = YES;
    }
    NSLog(@"nsfetchedResultsController init in ClientListView: clientListViewResult = %d",self.clientListViewResult);
    
    _fetchedController = [Address getFetchedResultsControllerForTA: (NSManagedObject *) settings.currentTA deleted:deleted shouldHaveOrders:shouldHaveOrders managedObjectContext:self.managedObjectContext delegate:self];
    NSError *error;
    [_fetchedController performFetch:&error];
    if(error)
        NSLog(@"error with performing fetchedResultsController in ClientListForNewOrder_View \n Error: %@",error.localizedDescription);
    return _fetchedController;
}

// Во время инициализации из сториборда выставляем дефолтные переменные
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        self.clientListViewResult = ClientListViewResult_Default;
    }
    return self;
}

#warning create search section index (like 'a', 'b' and i.e.)

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.tableView == tableView )
        return self.fetchedController.sections.count;
    if(self.fetchedControllerWithFilter)
        return self.fetchedControllerWithFilter.sections.count;
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.tableView == tableView){
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedController.sections objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    else if (self.fetchedControllerWithFilter){
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedControllerWithFilter.sections objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    return 0;
}

- (void) configureAddressCell:(UITableViewCell *) cell atIndexPath:(NSIndexPath *) indexPath address:(Address *) address{
    if(self.clientListViewResult != ClientListViewResult_OpenOrderListView){
        cell.textLabel.text =[NSString stringWithFormat:@"%@", address.address];
    }
    else {
        cell.textLabel.text =[NSString stringWithFormat:@"%@", address.address];
        if(address.deleted.boolValue == YES){
            cell.textLabel.textColor = [UIColor grayColor];
        } else {
            cell.textLabel.textColor = [UIColor blackColor];
        }
        cell.detailTextLabel.text = [NSString stringWithFormat:@"(%d)", (int) address.orders.count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifierDefault = @"AddressCell";
    // Для перехода на список заказов клиента используетя другой прототип ячейки
    static NSString *cellIdentifierOrderList = @"AddressCellForViewingClientOrders";
    
    NSString *cellIdentifier;
    if( self.clientListViewResult != ClientListViewResult_OpenOrderListView )
        cellIdentifier = cellIdentifierDefault;
    else
        cellIdentifier = cellIdentifierOrderList;
    
    UITableViewCell *cell;
    
    Address *address;
    if(self.tableView == tableView){
        cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        address = (Address *) [self.fetchedController objectAtIndexPath:indexPath];
    }
    else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        address = (Address *) [self.fetchedControllerWithFilter objectAtIndexPath:indexPath];
    }
    
    [self configureAddressCell:cell atIndexPath:indexPath address:address];
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(self.tableView == tableView){
        static NSString *cellIdentifier = @"ClientNameCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedController.sections objectAtIndex:section];
        cell.textLabel.text = [sectionInfo name];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    else {
        static NSString *cellIdentifier = @"ClientNameCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedControllerWithFilter.sections objectAtIndex:section];
        cell.textLabel.text = [sectionInfo name];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(self.tableView != tableView){
        if(self.fetchedControllerWithFilter){
            id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedControllerWithFilter.sections objectAtIndex:section];
            return [sectionInfo name];
        }
    }
    return @"";
}

#pragma mark search diaplay controller

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    // Если далее нужно будет показать список заказов, то показываем и удаленных клиентов, и не удаленных
    NSNumber * deleted = nil;
    Boolean shouldHaveOrders = NO;
    if( self.clientListViewResult != ClientListViewResult_OpenOrderListView ){
        deleted = [NSNumber numberWithBool:NO];
    }
    else {
        shouldHaveOrders = YES;
    }
    
    AppSettings *settings = [AppSettings getInstance:self.managedObjectContext];
    self.fetchedControllerWithFilter = [Address getFetchedResultsControllerForTA:(NSManagedObject *)settings.currentTA deleted:deleted shouldHaveOrders:shouldHaveOrders filter:searchString managedObjectContext:self.managedObjectContext delegate:self];
    NSError *error;
    [self.fetchedControllerWithFilter performFetch:&error];
    if(error)
        NSLog(@"error with performing fetchedResultsController in ClientListForNewOrder_View \n Error: %@",error.localizedDescription);
    //NSLog(@"creating fetchedresultController with filter: %@",searchString);
    //[controller.searchResultsTableView reloadData];
    return YES;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"OrderEditView"]){
        Address *address;
        if([self.searchDisplayController isActive]){
            NSIndexPath *indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            address = [self.fetchedControllerWithFilter objectAtIndexPath:indexPath];
        } else {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            address = [self.fetchedController objectAtIndexPath:indexPath];
        }
        OrderEditView *orderEditView = segue.destinationViewController;
        orderEditView.address = address;
        orderEditView.context = self.managedObjectContext;
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if([identifier isEqualToString:@"OrderEditView"]
       && self.clientListViewResult == ClientListViewResult_OpenOrderEditView){
        return YES;
    }
    else if([identifier isEqualToString:@"OrderListView"]
            && self.clientListViewResult == ClientListViewResult_OpenOrderListView) {
        return YES;
    }
    return NO;
}


@end
