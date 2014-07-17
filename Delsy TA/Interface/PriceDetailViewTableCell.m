//
//  PriceDetailViewTableCell.m
//  Delsy TA
//
//  Created by Valeriy Buev on 03.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "PriceDetailViewTableCell.h"
#import "Item+ItemCategory.h"
#import "Order+OrderCategory.h"
#import "OrderLine+OrderLineCategory.h"
#import "Client+ClientCategory.h"
#import "NSNumber+BVAFormatter.h"

@implementation PriceDetailViewTableCell{

}

@synthesize labelName;
@synthesize labelPrice;
@synthesize labelUnit;
@synthesize imageCartWidth;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

// В сториборд обычно используется именно этот инит
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //self.imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        // цвет выделения ячейки
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = [UIColor colorWithRed:(180.0/255.0) green:(220.0/255.0) blue:(255.0/255.0) alpha:1.0];
        bgColorView.layer.masksToBounds = YES;
        self.selectedBackgroundView = bgColorView;
        //NSLog(@"init with coder");
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

// Переопределяем set-метод свойства item. Если тот же самый item на входе, что и у нас, то ничего не делаем. Если нет, и если наш _item не nil, то отписываемся от текущего. Далее назначаем новый item  и подписываемся на него. Это нужно для отслеживания изменений в корзине.
- (void)setItem:(Item *)item{
    if(_item == item){
        return;
    }
    if(_item){
        [_item removeObserver:self forKeyPath:@"orderLines"];
        //NSLog(@"remove observer");
    }
    _item = item;
    [_item addObserver:self forKeyPath:@"orderLines" options:NSKeyValueObservingOptionInitial context:nil];
    //NSLog(@"set item: %@",item.name);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// Настраивание цветов, разметки, вывод содержимого item
- (void) configure{
    self.labelName.text = self.item.name;
    self.labelUnit.text = [self.item.unit unitValueToString];
    self.labelPrice.text = [[self.order.client getPriceByItem:self.item] floatValueFrac2or0];
    self.backgroundColor = [self.item.lineColor lineColor:[UIColor whiteColor]];
    if(self.item.promo.boolValue == YES)
        self.labelPrice.textColor = [UIColor redColor];
}

// Проверяем, есть ли наш item в заказе. Ищем соответствующую позицию, если находим, то показываем картинку с корзиной
- (void) confirmIsThisItemInOrder{
    
    //self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"item == %@",self.item];
    NSMutableSet *orderLines = [self.order.orderLines mutableCopy];
    [orderLines filterUsingPredicate:predicate];
    if( orderLines.count > 0 ) {
        self.imageCartWidth.constant = 40.0f;
        //[self.imageView setFrame:CGRectMake(self.imageView.bounds.origin.x, self.imageView.bounds.origin.y, 40.0f, self.imageView.bounds.size.height)];
        //NSLog(@"40f");
    }
    else{
        self.imageCartWidth.constant = 0.0f;
    }
    //[self setNeedsUpdateConstraints];
}

// Если изменились orderLines, то отправляем на проверку наличия продукта в корзине (см выше)
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"orderLines"]){
        [self confirmIsThisItemInOrder];
    }
}

// Не забываем удалить себя из слушателей
-(void)dealloc{
    [self.item removeObserver:self forKeyPath:@"orderLines"];
}



@end
