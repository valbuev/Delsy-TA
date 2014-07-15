//
//  AllPhotosUpdater.m
//  Delsy TA
//
//  Created by Valeriy Buev on 15.07.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "AllPhotosUpdater.h"
#import "Photo+PhotoCategory.h"
#import "Item+ItemCategory.h"
#import "AppDelegate.h"

@interface AllPhotosUpdater()
{
    NSMutableArray *downloadTasks;
    NSArray *photos;
    int countOfCompletedTasks;
    NSMutableArray *errors;
    NSURLSession *mysession;
}

@end

@implementation AllPhotosUpdater
@synthesize delegate;
@synthesize context;
@synthesize needsUpdateAvailablePhotos;

- (NSURLSession *) backgroundSession{
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfiguration:@"ru.bva.DelsyTA.backgroundSessoinForDownloadingPhotos"];
        config.HTTPMaximumConnectionsPerHost = 3;
        config.timeoutIntervalForRequest = 5;
        config.timeoutIntervalForResource = 5;
        //[config setAllowsCellularAccess:YES];
        session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    });
    return session;
}

- (void)dealloc{
    NSLog(@"allPhotosUpdater dealloced");
}

- (void) startDownloading{
    errors = [[NSMutableArray alloc] init];
    photos = [Photo getAllPhotos:!self.needsUpdateAvailablePhotos MOC:self.context];
    countOfCompletedTasks = 0;
    mysession = [self backgroundSession];
    //for(int i=0;i<photos.count;i++)
#warning
    NSLog(@"count of photos: %d",photos.count);
    for(int i=0;i<5;i++){
        Photo *photo = [photos objectAtIndex:i];
        NSURLSessionDownloadTask *task = [mysession downloadTaskWithURL:[NSURL URLWithString:photo.url]];
        [downloadTasks addObject:task];
        NSLog(@"position: %d real: %d",[downloadTasks indexOfObject:task],i);
    }
    for(NSURLSessionDownloadTask *task in downloadTasks){
        [task resume];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didFinishDownloadingToURL");
    });
    countOfCompletedTasks++;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *urls = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentDirectory = [urls objectAtIndex:0];
    
    NSURL *originalUrl = [NSURL URLWithString:[downloadTask.originalRequest.URL lastPathComponent]];
    NSURL *destinationUrl = [documentDirectory URLByAppendingPathComponent:[originalUrl lastPathComponent]];
    NSError *fileManagerError;
    
    [fileManager removeItemAtURL:destinationUrl error:NULL];
    
    [fileManager copyItemAtURL:location toURL:destinationUrl error:&fileManagerError];
    if(fileManagerError == nil){
        Photo *photo = [photos objectAtIndex:[downloadTasks indexOfObject:downloadTask]];
        NSLog(@"itemname : %@", photo.item.name);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            photo.filepath = destinationUrl.absoluteString;
            NSError *error;
            [self.context save:&error];
            if(error)
               [errors addObject:error];
        });
    }
    else{
        [errors addObject:fileManagerError];
    }
    
    id myDelegate = self.delegate;
    if(myDelegate != nil){
        [myDelegate AllPhotosUpdater:self
                 didCompleteUpdating: countOfCompletedTasks
                averageCountOfPhotos: downloadTasks.count];
    }
    else{
        NSLog(@"delegate = nil");
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    NSLog(@"didCompleteWithError");

    if(error){
        [errors addObject:error];
        NSLog(@"error: %@ - %@", task , error );
    } else {
        NSLog(@"success: %@",task);
    }
    
    [self callCompletionHandlerIfFinished];
}

- (void) callCompletionHandlerIfFinished{
    [mysession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks1){
        NSUInteger count = dataTasks.count + uploadTasks.count + downloadTasks1.count;
        if (count == 0) {
            // все таски закончены
            NSLog(@"all tasks ended");
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            if (appDelegate.backgroundSessionCompletionHandler) {
                void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
                appDelegate.backgroundSessionCompletionHandler = nil;
                completionHandler();
            }
            
            id myDelegate = self.delegate;
            if(myDelegate != nil){
                [myDelegate AllPhotosUpdater:self didFinishUpdatingWithErrors:errors];
            }
            else{
                NSLog(@"delegate = nil");
            }
        }
    }];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    NSLog(@"didWriteData");
}


@end
