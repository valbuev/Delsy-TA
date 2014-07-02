//
//  PriceMasterView.h
//  Delsy TA
//
//  Created by Valeriy Buev on 02.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class PriceDetailView;
@interface PriceMasterView : UITableViewController
<UISplitViewControllerDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic,strong) NSManagedObjectContext *context;
@property (nonatomic,strong) UINavigationController *mainNavigationController;
@property (nonatomic,weak) PriceDetailView *priceDetailView;
- (IBAction)btnDone:(id)sender;

@end
