//
//  BVAClientListUpdater.h
//  Delsy TA
//
//  Created by Valeriy Buev on 25.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

// ПРедназначен для скачивания списка клиентов, распарсивания его и загрузки в CoreData.

#import <Foundation/Foundation.h>
#import "BVAFileDownloader.h"

@class BVAClientListUpdater;
@protocol BVAClientListUpdaterDelegate
-(void) BVAClientListUpdater:(BVAClientListUpdater *) updater didFinishUpdatingWithErrors:(NSArray*) errors;
-(void) BVAClientListUpdater:(BVAClientListUpdater *)updater didStopUpdatingWithErrors:(NSArray *)errors;
-(void) BVAClientListUpdaterDidStartUpdating:(BVAClientListUpdater *)updater;
@end

@interface BVAClientListUpdater : NSObject
<BVAFileDownloaderDelegate>{
    BVAFileDownloader *clientListDownloader;
    BVAFileDownloader *PriceGroupsAndLineSalesDownloader;
    NSMutableArray *errors;
    NSDictionary *parseResults;
    // массивы для хранения ссылок на объекты. Для быстрого доступа и поиска при обновлении списка клиентов.
    NSMutableArray *priceGroups;
    NSMutableArray *lineSales;
}

@property (nonatomic, weak) id <BVAClientListUpdaterDelegate> delegate;
@property (nonatomic, weak) NSManagedObjectContext *managedObjectContext;

-(void) startUpdating;

@end
