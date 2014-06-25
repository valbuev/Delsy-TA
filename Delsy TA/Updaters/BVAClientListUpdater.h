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
#import "XMLDictionary.h"

@class BVAClientListUpdater;
@protocol BVAClientListUpdater
-(void) BVAClientListUpdater:(BVAClientListUpdater *) updater didFinishUpdatingWithErrors:(NSArray*) errors;
-(void) BVAClientListUpdater:(BVAClientListUpdater *)updater didStopUpdatingWithErrors:(NSArray *)errors;
-(void) BVAClientListUpdaterDidStartUpdating:(BVAClientListUpdater *)updater;
@end

@interface BVAClientListUpdater : NSObject
<BVAFileDownloaderDelegate>{
    BVAFileDownloader *fileDownloader;
    NSMutableArray *errors;
}

@property (nonatomic, weak) id <BVAClientListUpdater> delegate;
@property (nonatomic, weak) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) IBOutlet UILabel *labelText;

-(void) startUpdating;

@end
