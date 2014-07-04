//
//  QtySetterView.m
//  Delsy TA
//
//  Created by Valeriy Buev on 03.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "QtySetterView.h"
#import "Item+ItemCategory.h"
#import "NSNumber+NSNumberUnit.h"

@interface QtySetterView (){
    NSArray *units;
    NSArray *unitQtys;
}

@end

@implementation QtySetterView

@synthesize item;
@synthesize delegate;
@synthesize labelQtyInBaseUnits;
@synthesize textFieldQty;
@synthesize segmentsUnit;
@synthesize startWithUnit;

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
    // Do any additional setup after loading the view.
    [self initFromItem];
}

- (void) initFromItem{
    NSNumber * baseUnitQty = [NSNumber numberWithInt:1];
    NSNumber * boxQty = self.item.unitsInBox;
    NSNumber * bigBoxQty = self.item.unitsInBigBox;
    if(boxQty.floatValue == bigBoxQty.floatValue){
        if(boxQty.floatValue == baseUnitQty.floatValue){
            units = [NSArray arrayWithObject:item.unit];
            unitQtys = [NSArray arrayWithObject:baseUnitQty];
        }
        else{
            units = [NSArray arrayWithObjects:item.unit,[NSNumber numberWithUnit:box],nil];
            unitQtys =  [NSArray arrayWithObjects:baseUnitQty,boxQty,nil];
        }
    }
    else if (boxQty.floatValue == baseUnitQty.floatValue){
        units = [NSArray arrayWithObjects:item.unit,[NSNumber numberWithUnit:bigBox],nil];
        unitQtys =  [NSArray arrayWithObjects:baseUnitQty,bigBoxQty,nil];
    }
    else if(bigBoxQty.floatValue == baseUnitQty.floatValue){
        units = [NSArray arrayWithObjects:item.unit,[NSNumber numberWithUnit:box],nil];
        unitQtys =  [NSArray arrayWithObjects:baseUnitQty,boxQty,nil];
    }
    else{
        units = [NSArray arrayWithObjects:item.unit,[NSNumber numberWithUnit:box],[NSNumber numberWithUnit:bigBox],nil];
        unitQtys =  [NSArray arrayWithObjects:baseUnitQty,boxQty,bigBoxQty,nil];
    }
    
    if(units.count == 1){
        [self.segmentsUnit setTitle:((NSNumber *)[unitQtys objectAtIndex:0]).stringValue forSegmentAtIndex:0];
        [self.segmentsUnit setTitle:((NSNumber *)[unitQtys objectAtIndex:0]).stringValue forSegmentAtIndex:1];
        [self.segmentsUnit setSelectedSegmentIndex:0];
        self.segmentsUnit.enabled = NO;
    }
    if(units.count == 2){
        [self.segmentsUnit setTitle:((NSNumber *)[unitQtys objectAtIndex:0]).stringValue forSegmentAtIndex:0];
        [self.segmentsUnit setTitle:((NSNumber *)[unitQtys objectAtIndex:1]).stringValue forSegmentAtIndex:1];
        [self.segmentsUnit setSelectedSegmentIndex:1];
    }
    if(units.count == 3){
        [self.segmentsUnit setTitle:((NSNumber *)[unitQtys objectAtIndex:0]).stringValue forSegmentAtIndex:0];
        [self.segmentsUnit setTitle:((NSNumber *)[unitQtys objectAtIndex:1]).stringValue forSegmentAtIndex:1];
        [self.segmentsUnit insertSegmentWithTitle:((NSNumber *)[unitQtys objectAtIndex:2]).stringValue atIndex:2 animated:NO];
        [self.segmentsUnit setSelectedSegmentIndex:1];
    }
#warning доделать qtysetter. Учесть возможность поштучной продажи
}

-(void) updateLabelQtyInBaseUnits{
    NSNumber * qty = [unitQtys objectAtIndex:self.segmentsUnit.selectedSegmentIndex];
    NSNumber * finalQty = [NSNumber numberWithFloat:(qty.floatValue * self.textFieldQty.text.floatValue)];
    self.labelQtyInBaseUnits.text = [NSString stringWithFormat:@"= %@ %@",finalQty.stringValue,[item.unit unitValueToString]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark btns clicks

- (IBAction)btn1click:(id)sender {
    self.textFieldQty.text = [self.textFieldQty.text stringByAppendingString:@"1"];
    [self updateLabelQtyInBaseUnits];
}

- (IBAction)btn2click:(id)sender {
    self.textFieldQty.text = [self.textFieldQty.text stringByAppendingString:@"2"];
    [self updateLabelQtyInBaseUnits];
}

- (IBAction)btn3click:(id)sender {
    self.textFieldQty.text = [self.textFieldQty.text stringByAppendingString:@"3"];
    [self updateLabelQtyInBaseUnits];
}

- (IBAction)btn4click:(id)sender {
    self.textFieldQty.text = [self.textFieldQty.text stringByAppendingString:@"4"];
    [self updateLabelQtyInBaseUnits];
}

- (IBAction)btn5click:(id)sender {
    self.textFieldQty.text = [self.textFieldQty.text stringByAppendingString:@"5"];
    [self updateLabelQtyInBaseUnits];
}

- (IBAction)btn6click:(id)sender {
    self.textFieldQty.text = [self.textFieldQty.text stringByAppendingString:@"6"];
    [self updateLabelQtyInBaseUnits];
}

- (IBAction)btn7click:(id)sender {
    self.textFieldQty.text = [self.textFieldQty.text stringByAppendingString:@"7"];
    [self updateLabelQtyInBaseUnits];
}

- (IBAction)btn8click:(id)sender {
    self.textFieldQty.text = [self.textFieldQty.text stringByAppendingString:@"8"];
    [self updateLabelQtyInBaseUnits];
}

- (IBAction)btn9click:(id)sender {
    self.textFieldQty.text = [self.textFieldQty.text stringByAppendingString:@"9"];
    [self updateLabelQtyInBaseUnits];
}

- (IBAction)btn0click:(id)sender {
    if(![self.textFieldQty.text isEqualToString:@""]){
        self.textFieldQty.text = [self.textFieldQty.text stringByAppendingString:@"0"];
        [self updateLabelQtyInBaseUnits];
    }
}

- (IBAction)btnRemoveClicked:(id)sender {
    self.textFieldQty.text = @"";
    [self updateLabelQtyInBaseUnits];
}

- (IBAction)btnOKClicked:(id)sender {
    [self.delegate qtySetterView:self didFinishSettingQty:[NSNumber numberWithFloat:self.textFieldQty.text.floatValue] unit:[[units objectAtIndex:self.segmentsUnit.selectedSegmentIndex] unitValue]];
}

- (IBAction)segmentsUnitChange:(id)sender {
    [self updateLabelQtyInBaseUnits];
}
@end