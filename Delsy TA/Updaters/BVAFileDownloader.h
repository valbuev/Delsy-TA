//
//  BVAFileDownloader.h
//  Delsy TA
//
//  Created by Valeriy Buev on 25.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BVAFileDownloader : NSObject
<NSURLSessionDelegate, NSURLSessionTaskDelegate,NSURLSessionDownloadDelegate>
{
    NSURL *url;
    NSURLSession *session;
}

@end
