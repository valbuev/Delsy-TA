//
//  ClientListForNewOrder_View.h
//  Delsy TA
//
//  Created by Valeriy Buev on 26.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ClientListForNewOrder_View : UITableViewController
<NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
