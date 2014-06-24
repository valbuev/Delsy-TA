//
//  Downloader.h
//  Delsy TA
//
//  Created by Valeriy Buev on 24.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *DownloadURLString = @"http://195.112.235.1/InventPhotos/Photo410964349main.jpg";

@interface Downloader : NSObject
<NSURLSessionDelegate, NSURLSessionDownloadDelegate, NSURLSessionTaskDelegate>

//@property (nonatomic, retain) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic,retain) NSMutableArray *tasks;

-(void) startDownload;

@end
