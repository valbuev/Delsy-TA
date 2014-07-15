//
//  AppDelegate.h
//  Delsy TA
//
//  Created by Valeriy Buev on 16.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>


@property (strong, nonatomic) UIWindow *window;

// This variables uses for get access to CoreData.
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(void) setNewRootViewController: (UIViewController *) newRootViewController withAnimation:(UIViewAnimationOptions) options;

// для загрузки всех фотографий
@property (copy) void (^backgroundSessionCompletionHandler)();

@end
