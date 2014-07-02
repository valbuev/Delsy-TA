//
//  PriceDetailView.h
//  Delsy TA
//
//  Created by Valeriy Buev on 02.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class Order;
@class ProductType;
@class Fish;

@interface PriceDetailView : UIViewController

@property (nonatomic,retain) NSManagedObjectContext *context;
@property (nonatomic,retain) Order *order;
@property (nonatomic,retain) ProductType *productType;
@property (nonatomic,retain) Fish *fish;

@end
