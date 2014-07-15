//
//  PresentationView.h
//  Delsy TA
//
//  Created by Valeriy Buev on 15.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PresentationView;
@class Item;
@protocol PresentationViewDelegate

- (void) presentationViewShouldBeClosed:(PresentationView *) presentationView ;

@end

@interface PresentationView : UIViewController


@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) id <PresentationViewDelegate> delegate;
@property (nonatomic, retain) Item *item;

- (IBAction)btnXClicked:(id)sender;

@end
