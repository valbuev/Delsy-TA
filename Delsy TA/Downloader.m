//
//  Downloader.m
//  Delsy TA
//
//  Created by Valeriy Buev on 24.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "Downloader.h"
#import "AppDelegate.h"

@implementation Downloader

@synthesize tasks;


- (NSURLSession *) backgroundSession{
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfiguration:@"ru.bva.DelsyTA"];
        config.HTTPMaximumConnectionsPerHost = 1;
        config.timeoutIntervalForResource = 20;
        config.timeoutIntervalForRequest = 8;
        session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    });
    return session;
}

-(void) startDownload {
    self.tasks = [NSMutableArray array];
    for(int i=0;i<10;i++){
        NSURLSessionDownloadTask *downloadTask = [[self backgroundSession] downloadTaskWithURL:[NSURL URLWithString:DownloadURLString]];
        [self.tasks addObject:downloadTask];
        [downloadTask resume];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *urls = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentDirectory = [urls objectAtIndex:0];
    
    NSURL *originalUrl = [NSURL URLWithString:[[NSURL URLWithString:DownloadURLString] lastPathComponent]];
    NSURL *destinationUrl = [documentDirectory URLByAppendingPathComponent:[originalUrl lastPathComponent]];
    NSError *fileManagerError;
    
    [fileManager removeItemAtURL:destinationUrl error:NULL];
    
    [fileManager copyItemAtURL:location toURL:destinationUrl error:&fileManagerError];
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    double progress = (double) totalBytesWritten / (double) totalBytesExpectedToWrite;
    //NSLog(@"download: %@ progress: %f", downloadTask, progress);
    dispatch_async(dispatch_get_main_queue(), ^{
        // self.progressView.progress = progress;
    });
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if(error){
        NSLog(@"error: %@ - %@",task,error);
    }
    else {
        NSLog(@"success: %@",task);
    }
    //self.downloadTask = nil;
    [self callCompletionHandlerIfFinished];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}

-(void) callCompletionHandlerIfFinished{
    NSLog(@"call completion handler");
    [[self backgroundSession] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks){
        NSUInteger count = [dataTasks count] + [uploadTasks count] + [downloadTasks count];
        if(count == 0){
            NSLog(@"all tasks ended");
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            if(appDelegate.sessionCompletionHandler == nil) return;
            void (^completionHandler)() = appDelegate.sessionCompletionHandler;
            appDelegate.sessionCompletionHandler = nil;
            completionHandler();
        }
    }];
}

@end