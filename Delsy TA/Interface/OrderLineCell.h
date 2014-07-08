//
//  OrderLineCell.h
//  Delsy TA
//
//  Created by Valeriy Buev on 01.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderLineCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelUnit;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrentUnitQty;
@property (weak, nonatomic) IBOutlet UILabel *labelBaseUnitQty;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelAmount;

@end
