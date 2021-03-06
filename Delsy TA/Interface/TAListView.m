//
//  TAListView.m
//  Delsy TA
//
//  Created by Valeriy Buev on 25.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "TAListView.h"
#import "TA+TACategory.h"
#import "AppSettings+AppSettingsCategory.h"

@interface TAListView ()

@end

@implementation TAListView

-(void) saveManageObjectContext{
    if(self.managedObjectContext == nil){
        NSLog(@"TAListView.managedObjectContext = nil");
        abort();
    }
    else{
        NSError *error;
        [self.managedObjectContext save:&error];
        if(error){
            NSLog(@"TAListView.managedObjectContext = nil");
            abort();
        }
    }
}

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
    if(self.managedObjectContext){
        taList = [TA getAllNonDeletedTA:self.managedObjectContext];
    }
    else{
        taList = [NSArray array];
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return taList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TACell" forIndexPath:indexPath];
    
    TA *ta = [taList objectAtIndex:indexPath.row];
    cell.textLabel.text = ta.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AppSettings *appSettings = [AppSettings getInstance:self.managedObjectContext];
    TA *ta = [taList objectAtIndex:indexPath.row];
    if(appSettings.currentTA != ta){
        appSettings.lastOrder = nil;
    }
    appSettings.currentTA = ta;
    [self saveManageObjectContext];
    [self.navigationController popViewControllerAnimated:YES];
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
