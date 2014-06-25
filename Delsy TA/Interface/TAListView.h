//
//  TAListView.h
//  Delsy TA
//
//  Created by Valeriy Buev on 25.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TAListView : UITableViewController{
    NSArray *taList;
}

@property (nonatomic,weak) NSManagedObjectContext *managedObjectContext;

@end
