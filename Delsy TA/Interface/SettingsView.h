//
//  SettingsView.h
//  Delsy TA
//
//  Created by Valeriy Buev on 24.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BVAClientListUpdater.h"
#import "BVAPriceUpdater.h"
#import "AllPhotosUpdater.h"

@class AppSettings;

@interface SettingsView : UITableViewController
<BVAClientListUpdaterDelegate, BVAPriceUpdaterDelegate,AllPhotosupdaterDelegate>
{
    BVAClientListUpdater *clientListUpdater;
    BVAPriceUpdater *priceUpdater;
    AllPhotosUpdater *allPhotosUpdater;
    Boolean isManagedObjectContextUpdating;
    Boolean isAllPhotosUpdating;
}

/********** UI-properties and -actions ************/

// ***** Catalog section
// кнопки обновления
@property (weak, nonatomic) IBOutlet UIButton *btnUpdateData;
@property (weak, nonatomic) IBOutlet UIButton *btnUpdateAllPhotos;
// индикаторы обновления
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorUpdatingData;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorAllPhotos;
// Даты последнего обновления
@property (weak, nonatomic) IBOutlet UILabel *labelDataLastUpdate;
// Отображение процесса обновления фотографий
@property (weak, nonatomic) IBOutlet UIProgressView *progressViewUpdatingAllPhotos;
// НЕобходимо ли обновлять все фотографии или только загрузить отсутствующие.
@property (weak, nonatomic) IBOutlet UISwitch *switchNotNeedsUpdateAvailablePhotos;




- (IBAction)OnBtnUpdateDataClick:(id)sender;
- (IBAction)OnBtnUpdateAllPhotosClick:(id)sender;

// ***** TA section
@property (weak, nonatomic) IBOutlet UILabel *labelTAName;

// ***** History section
@property (weak, nonatomic) IBOutlet UITableViewCell *cellRemoveAllHistory;


// ***** "Other" and "Sending" sections

// Получатель письма по умолчанию
@property (weak, nonatomic) IBOutlet UITextField *textFieldDefaultRecipient;
// URL папки с файлами для обновления
@property (weak, nonatomic) IBOutlet UITextField *textFieldUpdateFolderURL;
// URL папки с фотографиями
@property (weak, nonatomic) IBOutlet UITextField *textFieldPhotosFolderURL;

// Пользователь изменил e-mail получателя по умолчанию
- (IBAction)textFieldDefaultRecipientDidEndEditing:(id)sender;
// Пользователь изменил URL папки с файлами для обновления
- (IBAction)textFieldUpdateFolderURLDidEndEditing:(id)sender;
// Пользователь изменил URL папки с фотографиями
- (IBAction)textFieldPhotosFolderURLDidEndEditing:(id)sender;


/********** UI-properties and -actions ************/


// managedObjectContext
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

// AppSettings
@property (strong, nonatomic) AppSettings *appSettings;

@end
