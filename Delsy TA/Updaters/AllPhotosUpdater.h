//
//  AllPhotosUpdater.h
//  Delsy TA
//
//  Created by Valeriy Buev on 15.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AllPhotosUpdater;
@protocol AllPhotosupdaterDelegate

// сообщает делегату о том, что на данный момент обновлено countOfUpdatedPhotos фотографий из countOfPhotos
- (void) AllPhotosUpdater:(AllPhotosUpdater *) updater didCompleteUpdating:(int) countOfUpdatedPhotos averageCountOfPhotos:(int) countOfPhotos;
// сообщает делегату о том, что обновление завершено
- (void) AllPhotosUpdater:(AllPhotosUpdater *)updater didFinishUpdatingWithErrors:(NSArray *) errors;

@end

@interface AllPhotosUpdater : NSObject
<NSURLSessionDownloadDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>
{
    
}

- (void) startDownloading;

@property (nonatomic,weak) id <AllPhotosupdaterDelegate> delegate;
@property (nonatomic,retain) NSManagedObjectContext *context;
// нужно ли обновлять уже имеющиеся фотографии. YES - нужно.
@property (nonatomic) Boolean needsUpdateAvailablePhotos;

@end
