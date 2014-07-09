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
    Client * client;
}

@property (nonatomic,retain) UIPopoverController *localPopoverController;

@end

@implementation PriceDetailView

@synthesize context;
@synthesize order;
@synthesize controller;
@synthesize section;
@synthesize tableView;
@synthesize localPopoverController;

#pragma mark initialization and basic ui actions

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
    section = -1; // нет конкретного типа рыбы, т.е. отображаются все.
    client = self.order.client;
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

#pragma mark uitableViewDelegate, DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.section == -1) // нет конкретного типа рыбы, т.е. отображаются все.
    {
        if(self.controller)
            return self.controller.sections.count;
        else
            return 0;
    }
    else{
        if(self.controller)
            return 1;
        else
            return 0;
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section1{
    id <NSFetchedResultsSectionInfo> sectionInfo;
    if(self.section == -1) // нет конкретного типа рыбы, т.е. отображаются все.
    {
        sectionInfo = [self.controller.sections objectAtIndex:section1];
    }
    else{
        sectionInfo = [self.controller.sections objectAtIndex:self.section];
    }
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    long sectionNum = indexPath.section;
    if(self.section != -1){
        sectionNum = self.section;
    }
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:sectionNum];
    Item *item = [controller objectAtIndexPath:newIndexPath];
    
    static NSString *cellIdentifier = @"Item";
    PriceDetailViewTableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    [self configureCell:cell item:item];
    
    // цвет выделения ячейки
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:(180.0/255.0) green:(220.0/255.0) blue:(255.0/255.0) alpha:1.0];
    bgColorView.layer.masksToBounds = YES;
    cell.selectedBackgroundView = bgColorView;
    
    return cell;
}

- (void) configureCell:(PriceDetailViewTableCell *) cell item:(Item *) item{
    cell.labelName.text = item.name;
    cell.labelUnit.text = [item.unit unitValueToString];
    cell.labelPrice.text = [[client getPriceByItem:item] floatValueFrac2or0];
    cell.backgroundColor = [item.lineColor lineColor:[UIColor whiteColor]];
    if(item.promo.boolValue == YES)
        cell.labelPrice.textColor = [UIColor redColor];
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section1{
    if(section1 == 0)
    return 6;
    return 3;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 2;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    long sectionNum = indexPath.section;
    if(self.section != -1){
        sectionNum = self.section;
    }
    
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:sectionNum];
    
    Item *item = [controller objectAtIndexPath:newIndexPath];
    
    PriceDetailViewTableCell *cell = (PriceDetailViewTableCell *) [self.tableView cellForRowAtIndexPath:indexPath];
    
    QtySetterView *qtySetter = [self.storyboard instantiateViewControllerWithIdentifier:@"QtySetter"];
    qtySetter.item = item;
    qtySetter.delegate = self;
    
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

/*-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section1{
    int newSection = section1;
    if(self.section != -1){
        newSection = self.section;
    }
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.controller.sections objectAtIndex:newSection];
    return [sectionInfo name];
}*/



@end
