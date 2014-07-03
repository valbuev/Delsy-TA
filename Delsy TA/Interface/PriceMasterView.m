//
//  PriceMasterView.m
//  Delsy TA
//
//  Created by Valeriy Buev on 02.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "PriceMasterView.h"
#import "AppDelegate.h"
#import "ProductType+ProductTypeCategory.h"
#import "Fish+FishCategory.h"
#import "PriceDetailView.h"
#import "Item+ItemCategory.h"


@interface PriceMasterView (){
    //NSFetchedResultsController *controller;
    NSArray *productTypes;
    NSInteger activeSection;
    Boolean isActiveSectionOpened;
}

@property (nonatomic,retain) NSFetchedResultsController *controller;

@end

@implementation PriceMasterView

@synthesize context;
@synthesize mainNavigationController;
@synthesize priceDetailView;
@synthesize controller = _controller;

#pragma mark initialization and basic viewcontroller functions

-(NSFetchedResultsController *)controller{
    if(_controller != nil)
        return _controller;
    ProductType *productType = [productTypes objectAtIndex:activeSection];
    _controller = [Item getControllerGroupByFish:self.context forProductType:productType];
    _controller.delegate = self;
    [_controller performFetch:nil];
    return _controller;
}

- (IBAction)btnDone:(id)sender {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate setNewRootViewController:self.mainNavigationController withAnimation:UIViewAnimationOptionTransitionNone];
    // Обязательно зануляем ссылку, так как она сильная. Иначе будет циклическая ссылка, так как в OrderEditView хранится обратная ссылка. Объекты никогда не освободятся из памяти.
    self.mainNavigationController = nil;
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
    NSLog(@"PriceMasterView viewDidLoad");
    NSFetchRequest * request = [ProductType getRequestWithoutDeletedItems:context];
    productTypes = [context executeFetchRequest:request error:nil];
    if( productTypes.count > 0 ){
        activeSection = 0;
        isActiveSectionOpened = YES;
    }
    else{
        activeSection = -1;
        isActiveSectionOpened = YES;
    }
    [self.tableView reloadData];
}

-(void)dealloc{
    NSLog(@"PriceMasterView dealloc");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation{
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return productTypes.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == activeSection && isActiveSectionOpened == YES){
        //
        return self.controller.sections.count;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Fish";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    //Fish *fish = [controller objectAtIndexPath:indexPath];
    if(indexPath.section == activeSection && isActiveSectionOpened == YES){
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.controller.sections objectAtIndex:indexPath.row];
        cell.textLabel.text = [sectionInfo name];
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor colorWithRed:(150.0/255.0) green:(210.0/255.0) blue:(255.0/255.0) alpha:1.0]; // perfect color suggested by @mohamadHafez
        bgColorView.layer.masksToBounds = YES;
        cell.selectedBackgroundView = bgColorView;
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    static NSString *cellIdentifier1 = @"ProductType1";
    static NSString *cellIdentifier2 = @"ProductType2";
    UITableViewCell *cell;
    //четные с одним цветом, нечетные - с другим.
    if(section % 2){
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
    }
    else{
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
    }
    //id <NSFetchedResultsSectionInfo> sectionInfo = [controller.sections objectAtIndex:section];
    ProductType *productType = [productTypes objectAtIndex:section];
    cell.textLabel.text = productType.name;
    //cell.backgroundColor = cell.viewForBaselineLayout.backgroundColor;
    if(section == activeSection){
        cell.selected = YES;
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor colorWithRed:(170.0/255.0) green:(220.0/255.0) blue:(255.0/255.0) alpha:1.0]; // perfect color suggested by @mohamadHafez
        bgColorView.layer.masksToBounds = YES;
        cell.selectedBackgroundView = bgColorView;
    }
    cell.tag = section + 1;
    UIButton *btn;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}


// в ios7 эту функцию для кастомного хедера нужно реализовывать обязательно, даже если в storyboard или nib-е указана высота header-а. Иначе нумерация групп будет с 1.
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 35;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
