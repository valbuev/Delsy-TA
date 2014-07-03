//
//  PriceDetailView.h
//  Delsy TA
//
//  Created by Valeriy Buev on 02.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//


// Все построено по такому принципу: когда в мастер-вью нажимается секция, то в этот вью (detail) передается индекс секции (если выбран вид рыбы) или -1 (если просто была нажата секция). Если -1, то отображаем все виды рыб в одной таблице. Разбиваем на секции, соответственно, по рыбам. Если номер был передан, то отображаем только эту секцию.

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class Order;
@class ProductType;
@class Fish;

@interface PriceDetailView : UIViewController
<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,retain) NSManagedObjectContext *context;
@property (nonatomic,retain) Order *order;
@property (nonatomic,weak) NSFetchedResultsController *controller;
@property (nonatomic) NSInteger section;

@property (nonatomic,weak) IBOutlet UITableView *tableView;

@end
