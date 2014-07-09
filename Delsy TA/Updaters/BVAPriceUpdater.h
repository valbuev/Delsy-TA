//
//  BVAPriceUpdater.h
//  Delsy TA
//
//  Created by Valeriy Buev on 29.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

// ПРедназначен для скачивания прайса, распарсивания его и загрузки в CoreData.

#import <Foundation/Foundation.h>
#import "BVAFileDownloader.h"

@class BVAPriceUpdater;
@protocol BVAPriceUpdaterDelegate
-(void) BVAPriceUpdater:(BVAPriceUpdater *) updater didFinishUpdatingWithErrors:(NSArray*) errors;
-(void) BVAPriceUpdater:(BVAPriceUpdater *)updater didStopUpdatingWithErrors:(NSArray *)errors;
-(void) BVAPriceUpdaterDidStartUpdating:(BVAPriceUpdater *)updater;
@end

@interface BVAPriceUpdater : NSObject
<BVAFileDownloaderDelegate>{
    BVAFileDownloader *fileDownloader;
    NSMutableArray *errors;
    NSDictionary *parseResults;
    NSMutableArray *priceGroupLines;
    NSMutableArray *lineSaleLines;
}

@property (nonatomic, weak) id <BVAPriceUpdaterDelegate> delegate;
@property (nonatomic, weak) NSManagedObjectContext *managedObjectContext;

-(void) startUpdating;

@end
