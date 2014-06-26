//
//  SettingsView.h
//  Delsy TA
//
//  Created by Valeriy Buev on 24.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BVAClientListUpdater.h"

@class AppSettings;

@interface SettingsView : UITableViewController
<BVAClientListUpdaterDelegate>
{
    BVAClientListUpdater *clientListUpdater;
    Boolean isManagedObjectContextUpdating;
}

// Catalog section
// кнопки обновления
@property (weak, nonatomic) IBOutlet UIButton *btnUpdateClientList;
@property (weak, nonatomic) IBOutlet UIButton *btnUpdatePriceList;
@property (weak, nonatomic) IBOutlet UIButton *btnUpdateAllPhotos;
// индикаторы обновления
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorClientList;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorPriceList;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorAllPhotos;
// Даты последнего обновления
@property (weak, nonatomic) IBOutlet UILabel *labelClientListLastUpdate;
@property (weak, nonatomic) IBOutlet UILabel *labelPriceListLastUpdate;
// Отображение процесса обновления фотографий
@property (weak, nonatomic) IBOutlet UIProgressView *progressViewUpdatingAllPhotos;

- (IBAction)OnBtnUpdateClientListClick:(id)sender;
- (IBAction)OnBtnUpdatePriceListClick:(id)sender;
- (IBAction)OnBtnUpdateAllPhotosClick:(id)sender;

// TA section
@property (weak, nonatomic) IBOutlet UILabel *labelTAName;

// History section
@property (weak, nonatomic) IBOutlet UITableViewCell *cellRemoveAllHistory;

// managedObjectContext
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

// AppSettings
@property (strong, nonatomic) AppSettings *appSettings;

@end
