//
//  PresentationView.m
//  Delsy TA
//
//  Created by Valeriy Buev on 15.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "PresentationView.h"
#import "Item+ItemCategory.h"
#import "Photo+PhotoCategory.h"

@interface PresentationView ()

@end

@implementation PresentationView

@synthesize item;
@synthesize delegate;
@synthesize imageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(self.item.photos.count >0){
        for(Photo *photo in item.photos){
            if(![photo.filepath isEqualToString:@""]){
                [self.imageView setImage:[UIImage imageWithContentsOfFile:photo.filepath]];
                break;
            }
            else if( ![photo.url isEqualToString:@""] ){
                NSLog(@"url: %@",photo.url);
            }
            else {
                NSLog(@"Empty in %d",(int) item.photos.count);
            }
        }
    }
    else{
        NSLog(@"Нет фоток");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnXClicked:(id)sender {
    [self.delegate presentationViewShouldBeClosed:self];
}

@end
