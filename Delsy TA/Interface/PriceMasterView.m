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


@interface PriceMasterView ()
<NSFetchedResultsControllerDelegate>
{
    //NSFetchedResultsController *controller;
    NSArray *productTypes;
    NSInteger activeSection;
    Boolean isActiveSectionOpened;
}

@property (nonatomic,retain) NSFetchedResultsController *controller;

@property (nonatomic, retain) NSFetchedResultsController *prodTypesAndFishes;

@end

@implementation PriceMasterView

@synthesize context;
@synthesize mainNavigationController;
@synthesize priceDetailView;
@synthesize controller = _controller;
@synthesize prodTypesAndFishes = _prodTypesAndFishes;

#pragma mark initialization and basic viewcontroller functions

- (NSFetchedResultsController *) prodTypesAndFishes {
    return _prodTypesAndFishes;
}

-(NSFetchedResultsController *)controller{
    if(_controller != nil)
        return _controller;
    ProductType *productType = [productTypes objectAtIndex:activeSection];
    _controller = [Item getControllerGroupByFish:self.context forProductType:productType];
    //_controller.delegate = self;
    [_controller performFetch:nil];
    self.priceDetailView.productType = productType;
    [self.priceDetailView reloadData];
    return _controller;
}

- (IBAction)btnDone:(id)sender {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate setNewRootViewController:self.mainNavigationController withAnimation:UIViewAnimationOptionTransitionNone];
    // Обязательно зануляем ссылку, так как она сильная. Иначе будет циклическая ссылка, так как в OrderEditView хранится обратная ссылка. Объекты никогда не освободятся из памяти.
    self.mainNavigationController = nil;
    if(self.delegate){
        [self.delegate priceViewWillFinishShowing];
    }
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

-(IBAction)sectionViewPressed:(UIButton *)btn{
    long section = btn.tag - 1;
    if(section == activeSection){
        if(isActiveSectionOpened == YES){
            isActiveSectionOpened = NO;
            if(self.priceDetailView.fish != nil){
                self.priceDetailView.fish = nil;
                [self.priceDetailView reloadData];
            }
            NSMutableArray *array = [NSMutableArray array];
            for(int i=0;i<self.controller.sections.count;i++){
                [array addObject:[NSIndexPath indexPathForRow:i inSection:activeSection]];
            }
            [self.tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationRight];
        }
        else{
            isActiveSectionOpened = YES;
            NSMutableArray *array = [NSMutableArray array];
            for(int i=0;i<self.controller.sections.count;i++){
                [array addObject:[NSIndexPath indexPathForRow:i inSection:activeSection]];
            }
            [self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationRight];
        }
    }
    else{
        if(isActiveSectionOpened == YES){
            isActiveSectionOpened = NO;
            /*NSMutableArray *array = [NSMutableArray array];
            for(int i=0;i<self.controller.sections.count;i++){
                [array addObject:[NSIndexPath indexPathForRow:i inSection:activeSection]];
            }
            [self.tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationRight];*/
            
        }
        long prevActiveSection = activeSection;
        activeSection = section;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:prevActiveSection]
                      withRowAnimation:UITableViewRowAnimationFade];
        isActiveSectionOpened = YES;
        ProductType *productType = [productTypes objectAtIndex:section];
        [NSFetchedResultsController deleteCacheWithName:@"ru.bva.DelsyTA.fetchRequestForPriceMasterView"];
        [self.controller.fetchRequest setPredicate:
             [NSPredicate predicateWithFormat:@"(is_deleted == %@) AND (productType == %@)",
              [NSNumber numberWithBool:NO],productType]];
        [self.controller performFetch:nil];
        
        self.priceDetailView.productType = productType;
        self.priceDetailView.fish = nil;
        [self.priceDetailView reloadData];
        
//        NSMutableArray *array = [NSMutableArray array];
//        for(int i=0;i<self.controller.sections.count;i++){
//            [array addObject:[NSIndexPath indexPathForRow:i inSection:section]];
//        }
//        [self.tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:activeSection]
                      withRowAnimation:UITableViewRowAnimationRight];
    }
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
    //NSLog(@"working section = %d activesection = %d count =  %d",section,activeSection,self.controller.sections.count);
    if(section == activeSection && isActiveSectionOpened == YES){
        //
        return self.controller.sections.count;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"working 3");
    static NSString *cellIdentifier = @"Fish";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    //Fish *fish = [controller objectAtIndexPath:indexPath];
    if(indexPath.section == activeSection && isActiveSectionOpened == YES){
        // Устанавливаем текст, причем делаем увеличенные пробелы между буквами
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.controller.sections objectAtIndex:indexPath.row];
        NSString *text = [NSString stringWithFormat:@"%@ (%lu)", [sectionInfo name], (unsigned long)[sectionInfo numberOfObjects]];
        NSAttributedString *attributedText =
        [[NSAttributedString alloc]
         initWithString:text
         attributes: @{ NSKernAttributeName : @(1.3f) }];
        cell.textLabel.attributedText = attributedText;
        // цвет выделения ячейки
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
    UIButton *btn = (UIButton *) [cell viewWithTag:1];
    UILabel *label =  (UILabel *) [cell viewWithTag:2];
    ProductType *productType = [productTypes objectAtIndex:section];
    label.text = productType.name;
    // чтобы лейбл пропускал события типа нажатия делаем след.:
    label.userInteractionEnabled = NO;
    //cell.userInteractionEnabled = NO;
    //вешаем на кнопку функцию по нажатию.
    [btn addTarget:self action:@selector(sectionViewPressed:) forControlEvents:UIControlEventTouchUpInside];
    //cell.backgroundColor = cell.viewForBaselineLayout.backgroundColor;
    if(section == activeSection){
         cell.contentView.backgroundColor = [UIColor colorWithRed:(130.0/255.0) green:(190.0/255.0) blue:(240.0/255.0) alpha:1.0];
    }
    
    btn.tag = section + 1;
    return cell.contentView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}


// в ios7 эту функцию для кастомного хедера нужно реализовывать обязательно, даже если в storyboard или nib-е указана высота header-а. Иначе нумерация групп будет с 1.
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Item *firstItemInSection = [self.controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.row]];
    self.priceDetailView.fish = firstItemInSection.fish;
    [self.priceDetailView reloadData];
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
