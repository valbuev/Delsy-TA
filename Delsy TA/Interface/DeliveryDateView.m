//
//  DeliveryDateView.m
//  Delsy TA
//
//  Created by Valeriy Buev on 10.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "DeliveryDateView.h"
#import "Order+OrderCategory.h"
#import <MessageUI/MessageUI.h>

@interface DeliveryDateView () <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIDatePicker *DatePicker;
- (IBAction)btnCreateEMailClicked:(id)sender;

@end

@implementation DeliveryDateView
@synthesize DatePicker;

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
    [self.DatePicker setMinimumDate:[NSDate date]];
    [self.DatePicker setDate:[[NSDate date] dateByAddingTimeInterval:24*60*60] animated:NO];
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

- (IBAction)btnCreateEMailClicked:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:
         [NSString stringWithFormat:@"Заказ от %@",
          self.order.custName]];
        
#warning add default recipient
        
        self.order.date = [NSDate date];
        self.order.deliveryDate = self.DatePicker.date;
        [self.order.managedObjectContext save:nil];
        
        [controller setMessageBody:[self.order saveOrder2str] isHTML:NO];
        NSData * attachment = [NSData dataWithContentsOfURL:[self.order saveOrder2XMLFile]];
        [controller addAttachmentData:attachment mimeType:@"text/xml" fileName:@"order.xml"];
        if (controller) [self presentViewController:controller animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Почта недоступна" message:@"Невозможно отправить письмо!" delegate:nil cancelButtonTitle:@":(" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        self.order.isSent = [NSNumber numberWithBool:YES];
        [self.order.managedObjectContext save:nil];
    }
    else if (result == MFMailComposeResultFailed ){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Неудача!" message:@"Не удалось отправить письмо!" delegate:nil cancelButtonTitle:@":(" otherButtonTitles:nil];
        [alert show];
    }
    else if( result == MFMailComposeResultSaved ){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Сохранено" message:@"Не забудьте отправить письмо!" delegate:nil cancelButtonTitle:@":)" otherButtonTitles:nil];
        [alert show];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
