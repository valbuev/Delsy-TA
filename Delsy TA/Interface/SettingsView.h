//
//  SettingsView.h
//  Delsy TA
//
//  Created by Valeriy Buev on 24.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsView : UITableViewController



// Catalog section
@property (weak, nonatomic) IBOutlet UIButton *btnUpdateClientList;
@property (weak, nonatomic) IBOutlet UIButton *btnUpdatePriceList;
@property (weak, nonatomic) IBOutlet UIButton *btnUpdateAllPhotos;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorClientList;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorPriceList;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorAllPhotos;
@property (weak, nonatomic) IBOutlet UILabel *labelClientListLastUpdate;
@property (weak, nonatomic) IBOutlet UILabel *labelPriceListLastUpdate;
@property (weak, nonatomic) IBOutlet UIProgressView *progressViewUpdatingAllPhotos;

- (IBAction)OnBtnUpdateClientListClick:(id)sender;
- (IBAction)OnBtnUpdatePriceListClick:(id)sender;
- (IBAction)OnBtnUpdateAllPhotosClick:(id)sender;

// TA section
@property (weak, nonatomic) IBOutlet UILabel *labelTAName;

// History section
@property (weak, nonatomic) IBOutlet UITableViewCell *cellRemoveAllHistory;


@end
