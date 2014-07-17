//
//  PriceDetailViewTableCell.h
//  Delsy TA
//
//  Created by Valeriy Buev on 03.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Item;
@class Order;

@interface PriceDetailViewTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelUnit;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageCartWidth;

// Передаем ссылки на заказ и продукт
@property (nonatomic, retain) Item *item;
@property (nonatomic, retain) Order *order;

// Настраивание цветов, разметки, вывод содержимого item
- (void) configure;

@end
