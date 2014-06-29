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

-(NSFetchedResultsController *)fetchedController{
    if( _fetchedController )
        return _fetchedController;
    
    AppSettings *settings = [AppSettings getInstance:self.managedObjectContext];
    
    _fetchedController = [Address getFetchedResultsControllerForTA: (NSManagedObject *) settings.currentTA deleted:NO managedObjectContext:self.managedObjectContext delegate:self];
    NSError *error;
    [_fetchedController performFetch:&error];
    if(error)
        NSLog(@"error with performing fetchedResultsController in ClientListForNewOrder_View \n Error: %@",error.localizedDescription);
    return _fetchedController;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"AddressCell";
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
    cell.textLabel.text =[NSString stringWithFormat:@"%@", address.address];
    
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
    AppSettings *settings = [AppSettings getInstance:self.managedObjectContext];
    self.fetchedControllerWithFilter = [Address getFetchedResultsControllerForTA:(NSManagedObject *)settings.currentTA deleted:NO filter:searchString managedObjectContext:self.managedObjectContext delegate:self];
    NSError *error;
    [self.fetchedControllerWithFilter performFetch:&error];
    if(error)
        NSLog(@"error with performing fetchedResultsController in ClientListForNewOrder_View \n Error: %@",error.localizedDescription);
    //NSLog(@"creating fetchedresultController with filter: %@",searchString);
    //[controller.searchResultsTableView reloadData];
    return YES;
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
