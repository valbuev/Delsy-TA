//
//  PriceDetailView.m
//  Delsy TA
//
//  Created by Valeriy Buev on 02.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "PriceDetailView.h"
#import "Order+OrderCategory.h"
#import "Client+ClientCategory.h"
#import "Item+ItemCategory.h"
#import "PriceDetailViewTableCell.h"
#import "NSNumber+BVAFormatter.h"
#import "QtySetterView.h"
#import "NSNumber+bvaLineColor.h"

@interface PriceDetailView()
<QtySetterViewDelegate>
{
}

@property (nonatomic,retain) UIPopoverController *localPopoverController;
@property (nonatomic,retain) NSFetchedResultsController *controller;

@end

@implementation PriceDetailView

@synthesize context;
@synthesize order;
@synthesize controller = _controller;
@synthesize fish;
@synthesize productType;
@synthesize tableView;
@synthesize localPopoverController;

#pragma mark initialization and basic ui actions

-(NSFetchedResultsController *)controller{
    if(_controller != nil)
        return _controller;
    _controller = [Item getControllerGroupByProducer:self.context
                                      forProductType:self.productType];
    [_controller performFetch:nil];
    NSLog(@"create controller");
    return _controller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.fish = nil; // нет конкретного типа рыбы, т.е. отображаются все.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) saveManageObjectContext{
    if(self.context == nil){
        NSLog(@"PriceDetailView.managedObjectContext = nil");
        abort();
    }
    else{
        NSError *error;
        [self.context save:&error];
        if(error){
            NSLog(@"PriceDetailView.managedObjectContext error while saving: %@",error.localizedDescription);
            abort();
        }
    }
}

- (void) reloadData {
    [NSFetchedResultsController deleteCacheWithName:@"ru.bva.DelsyTA.fetchRequestForPriceDetailView"];
    [self.controller.fetchRequest setPredicate:[Item predicateForFilterItemsByProdType: self.productType
                                                                                  fish: self.fish]];
    [self.controller performFetch:nil];
    [self.tableView reloadData];
    NSLog(@"relod data");
}

#pragma mark uitableViewDelegate, DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.controller.sections.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section1{
    id <NSFetchedResultsSectionInfo> sectionInfo;
    sectionInfo = [self.controller.sections objectAtIndex:section1];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Item *item = [self.controller objectAtIndexPath:indexPath];
    
    static NSString *cellIdentifier = @"Item";
    PriceDetailViewTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.item = item;
    cell.order = self.order;
    [cell configure];
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section1{
    return 25;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo;
    sectionInfo = [self.controller.sections objectAtIndex:section];
    return [sectionInfo name];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    PriceDetailViewTableCell *cell = (PriceDetailViewTableCell *) [self.tableView cellForRowAtIndexPath:indexPath];
    
    QtySetterView *qtySetter = [self.storyboard instantiateViewControllerWithIdentifier:@"QtySetter"];
    qtySetter.item = cell.item;
    qtySetter.delegate = self;
    qtySetter.order = self.order;
    
    
    self.localPopoverController = [[UIPopoverController alloc] initWithContentViewController:qtySetter];
    self.localPopoverController.delegate = self;
    
    [self.localPopoverController presentPopoverFromRect:cell.labelName.bounds inView:cell.labelName
                          permittedArrowDirections:UIPopoverArrowDirectionLeft
                                          animated:NO];
    
}

#pragma mark popoverDelegate

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController{
    [self.localPopoverController dismissPopoverAnimated:NO];
    return NO;
}

#pragma mark QtySetterDelegate

- (void)qtySetterView:(QtySetterView *)qtySetterView didFinishSettingQty:(NSNumber *)qty unit:(Unit)unit forItem:(Item *)item{
    [self.localPopoverController dismissPopoverAnimated:NO];
    [order addItem:item qty:qty unit:unit];
    [self saveManageObjectContext];
}


@end
