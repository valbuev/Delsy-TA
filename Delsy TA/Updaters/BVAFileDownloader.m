//
//  BVAFileDownloader.m
//  Delsy TA
//
//  Created by Valeriy Buev on 25.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "BVAFileDownloader.h"

@implementation BVAFileDownloader

- (void) initWithUrl: (NSURL *) Url{
    url = Url;
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
}

-(void) startDownload{
    [[session downloadTaskWithURL:url] resume];
}

-(void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
}

@end
