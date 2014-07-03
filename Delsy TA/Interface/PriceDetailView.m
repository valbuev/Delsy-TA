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

@interface PriceDetailView (){
    Client * client;
}

@end

@implementation PriceDetailView

@synthesize context;
@synthesize order;
@synthesize controller;
@synthesize section;
@synthesize tableView;

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
    int sectionNum = indexPath.section;
    if(self.section != -1){
        sectionNum = self.section;
    }
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:sectionNum];
    static NSString *cellIdentifier = @"Item";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    Item *item = [controller objectAtIndexPath:newIndexPath];
    UILabel *labelName = (UILabel *) [cell viewWithTag:1];
    labelName.text = item.name;
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section1{
    if(section1 == 0)
    return 6;
    return 3;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 2;
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
