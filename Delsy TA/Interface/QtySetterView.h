//
//  QtySetterView.h
//  Delsy TA
//
//  Created by Valeriy Buev on 03.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSNumber+NSNumberUnit.h"

@class Item;
@class Order;
@class QtySetterView;

@protocol QtySetterViewDelegate

-(void) qtySetterView:(QtySetterView *) qtySetterView didFinishSettingQty:(NSNumber *) qty unit:(Unit) unit forItem:(Item *) item;

@end

@interface QtySetterView : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *textFieldQty;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentsUnit;
- (IBAction)segmentsUnitChange:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *labelQtyInBaseUnits;

- (IBAction)btn1click:(id)sender;
- (IBAction)btn2click:(id)sender;
- (IBAction)btn3click:(id)sender;
- (IBAction)btn4click:(id)sender;
- (IBAction)btn5click:(id)sender;
- (IBAction)btn6click:(id)sender;
- (IBAction)btn7click:(id)sender;
- (IBAction)btn8click:(id)sender;
- (IBAction)btn9click:(id)sender;
- (IBAction)btn0click:(id)sender;
- (IBAction)btnRemoveClicked:(id)sender;
- (IBAction)btnOKClicked:(id)sender;

@property (nonatomic,retain) Item *item;
@property (nonatomic) Unit startWithUnit;
@property (nonatomic,retain) NSNumber *startWithQty;

@property (nonatomic,weak) id<QtySetterViewDelegate> delegate;

@end
