//
//  BVAFileDownloader.h
//  Delsy TA
//
//  Created by Valeriy Buev on 25.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

// класс предназначен для скачивания ClientList.xml, Price.xml и т.д.
// Для  работы с классом, нужно передать url в функции initWithUrl, после чего запустить startDownload.
// Следует заранее подписаться в делегаты, чтобы получить уведомление о окончании загрузки. (файл будет лежать в песочнице)

#import <Foundation/Foundation.h>

@class BVAFileDownloader;

@protocol BVAFileDownloaderDelegate
-(void) BVAFileDownloader:(BVAFileDownloader *)downloader didFinishDownloadingToURL:(NSURL *)location;
-(void) BVAFileDownloader:(BVAFileDownloader *)downloader didFinishWithError:(NSError *) error;
@end

@interface BVAFileDownloader : NSObject
<NSURLSessionDelegate, NSURLSessionTaskDelegate,NSURLSessionDownloadDelegate>
{
    NSURL *url;
    NSURLSession *session;
}

@property (weak) id <BVAFileDownloaderDelegate> delegate;

@end
