//
//  PresentationView.m
//  Delsy TA
//
//  Created by Valeriy Buev on 15.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "PresentationView.h"
#import "Item+ItemCategory.h"
#import "Photo+PhotoCategory.h"
#import "Thesis+ThesisCategory.h"

#define ItemName_key @"ItemName"
#define Image_key @"Image"
#define ImageNumberSelector_key @"ImageNumberSelector"
#define Annotation_key @"Annotation"
#define Composition_key @"Composition"
#define OneHundredGramms_key @"OneHundredGramms"
#define ShelfLife_key @"ShelfLife"
#define Thesis_key @"Thesis"

@interface PresentationView ()
<UITableViewDataSource, UITableViewDelegate>
{
    // keys - cellIdentifiers, values - contents
    NSMutableDictionary *cellContents;
    NSMutableArray *cellIdentifiers;
    NSInteger photoNum;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation PresentationView

@synthesize item;
@synthesize delegate;
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
    cellContents = [[NSMutableDictionary alloc] init];
    cellIdentifiers = [[NSMutableArray alloc] init];
    
    [cellContents setObject: self.item.name forKey: ItemName_key];
    [cellIdentifiers addObject:ItemName_key];
    
    NSMutableSet *photos_set = [self.item.photos mutableCopy];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"filepath != nil and filepath != ''"];
    [photos_set filterUsingPredicate:predicate];
    NSMutableArray *photos = [[photos_set allObjects] mutableCopy];
    [photos sortUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [(Photo*)a name];
        NSString *second = [(Photo*)b name];
        if([first rangeOfString:@"main"].location != NSNotFound)
            return NSOrderedAscending;
        if([second rangeOfString:@"main"].location != NSNotFound)
            return NSOrderedDescending;
        return [first compare:second];
    }];
    [cellContents setObject:photos forKey:Image_key];
    [cellIdentifiers addObject:Image_key];
    
    if(photos.count > 1){
        [cellContents setObject:@"yes" forKey:ImageNumberSelector_key];
        [cellIdentifiers addObject:ImageNumberSelector_key];
    }
    photoNum = 0;
    
    if(self.item.annotation){
        [cellContents setObject:self.item.annotation forKey:Annotation_key];
        [cellIdentifiers addObject:Annotation_key];
    }
    
    if(self.item.composition){
        [cellContents setObject:self.item.composition forKey:Composition_key];
        [cellIdentifiers addObject:Composition_key];
    }
    
    if (self.item.hundredGrammsContains){
        [cellContents setObject:self.item.hundredGrammsContains forKey:OneHundredGramms_key];
        [cellIdentifiers addObject:OneHundredGramms_key];
    }
    
    if (self.item.shelfLife){
        [cellContents setObject:[NSString stringWithFormat:@"%d суток",self.item.shelfLife.intValue] forKey:ShelfLife_key];
        [cellIdentifiers addObject:ShelfLife_key];
    }
    
    int n=0;
    for( Thesis *thesis in self.item.thesises){
        NSString *key = [NSString stringWithFormat:@"%@%d",Thesis_key,n];
        [cellContents setObject:thesis.title forKey:key];
        [cellIdentifiers addObject:key];
        n++;
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return cellContents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[cellIdentifiers objectAtIndex:indexPath.row] forIndexPath:indexPath];
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}

- (void) configureCell:(UITableViewCell *) cell forIndexPath:(NSIndexPath *) indexPath{
    NSString *identifier = [cellIdentifiers objectAtIndex:indexPath.row];
    if( [identifier isEqualToString:ItemName_key] ){
        cell.textLabel.text = [self.item.name copy];
    }
    else if( [identifier isEqualToString:Image_key] ){
        NSArray *photos = [cellContents objectForKey:Image_key];
        UIImageView *imageView = (UIImageView *) [cell viewWithTag:1];
        if(photos.count == 0){
            imageView.image = [UIImage imageNamed:@"no_photo.png"];
        }
        else{
            Photo *photo = [photos objectAtIndex:photoNum];
            imageView.image = [UIImage imageWithContentsOfFile:photo.filepath];
        }
    }
    else if([identifier isEqualToString:ImageNumberSelector_key]){
        UISegmentedControl *selector = (UISegmentedControl *) [cell viewWithTag:1];
        NSArray *photos = [cellContents objectForKey:Image_key];
        for(int i= [selector numberOfSegments]; i<photos.count; i++){
            [selector insertSegmentWithTitle:@"" atIndex:i animated:NO];
        }
        for (int i=0; i<photos.count; i++) {
            [selector setTitle:[NSString stringWithFormat:@"%d",i+1] forSegmentAtIndex:i];
        }
        [selector addTarget:self action:@selector(imageNumberSelectorValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    else if( [identifier isEqualToString:Annotation_key] ){
        cell.textLabel.text = [cellContents objectForKey:Annotation_key];
    }
    else if( [identifier isEqualToString:Composition_key] ){
        UILabel *label = (UILabel *) [cell viewWithTag:1];
        label.text = [cellContents objectForKey:Composition_key];
    }
    else if( [identifier isEqualToString:OneHundredGramms_key] ){
        UILabel *label = (UILabel *) [cell viewWithTag:1];
        label.text = [cellContents objectForKey:OneHundredGramms_key];
    }
    else if( [identifier isEqualToString:ShelfLife_key] ){
        UILabel *label = (UILabel *) [cell viewWithTag:1];
        label.text = [cellContents objectForKey:ShelfLife_key];
    }
    else if ( [identifier rangeOfString:Thesis_key].location != NSNotFound ){
        UILabel *label = (UILabel *) [cell viewWithTag:1];
        label.text = [cellContents objectForKey:identifier];
    }
}

- (void) imageNumberSelectorValueChanged:(id) sender{
    UISegmentedControl *selector = (UISegmentedControl *) sender;
    photoNum = selector.selectedSegmentIndex;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[cellIdentifiers indexOfObject:Image_key] inSection:0];
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self configureCell:cell forIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[cellIdentifiers objectAtIndex:indexPath.row]];
    NSString *identifier = [cellIdentifiers objectAtIndex:indexPath.row];
    if([identifier rangeOfString:Thesis_key].location != NSNotFound){
        UILabel *label = (UILabel *) [cell viewWithTag:1];
        CGFloat indent = cell.frame.size.height - label.frame.size.height;
        //CGSize maxLabelSize = CGSizeMake(label.frame.size.width, 100.0f);
        NSString *thesis_str = [cellContents objectForKey:identifier];
        
        //CGRect expectedLabelSize = [[[NSAttributedString alloc] initWithString:thesis_str] boundingRectWithSize:maxLabelSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
        
        UILabel *gettingSizeLabel = [[UILabel alloc] init];
        gettingSizeLabel.font = label.font;
        gettingSizeLabel.text = thesis_str;
        gettingSizeLabel.numberOfLines = 0;
        gettingSizeLabel.lineBreakMode = label.lineBreakMode;
        CGSize maximumLabelSize = CGSizeMake(label.frame.size.width, 100);
        
        CGSize expectSize = [gettingSizeLabel sizeThatFits:maximumLabelSize];
        //CGSize  = [thesis_str sizeWithFont:label.font constrainedToSize:maxLabelSize lineBreakMode:label.lineBreakMode];
        return indent + expectSize.height;
    }
    return cell.frame.size.height;
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

- (IBAction)btnXClicked:(id)sender {
    [self.delegate presentationViewShouldBeClosed:self];
}

@end
