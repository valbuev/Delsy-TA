//
//  BVAFileDownloader.m
//  Delsy TA
//
//  Created by Valeriy Buev on 25.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "BVAFileDownloader.h"

@implementation BVAFileDownloader

// инициализирует конфиги и запоминает URL файла. Также открывает URL-сессию
- (void) initWithUrl: (NSURL *) Url{
    url = Url;
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.timeoutIntervalForRequest = 10;
    config.timeoutIntervalForResource = 10;
    session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
}

// начинает скачивание
-(void) startDownload{
    [[session downloadTaskWithURL:url] resume];
}

// Этот метод вызывается url-сессией. Говорит о завершении скачивания, передавая локальный URL скачанного файла.
// Здесь мы копируем файл из временного хранилища в песочницу, и оповещаем об этом делегата.
-(void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *urls = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentDirectory = [urls objectAtIndex:0];
    
    NSURL *originalUrl = [NSURL URLWithString:[url lastPathComponent]];
    NSURL *destinationUrl = [documentDirectory URLByAppendingPathComponent:[originalUrl lastPathComponent]];
    NSError *fileManagerError;
    
    [fileManager removeItemAtURL:destinationUrl error:NULL];
    
    [fileManager copyItemAtURL:location toURL:destinationUrl error:&fileManagerError];
    if(fileManagerError != nil){
        id delegate = self.delegate;
        if(delegate != nil){
            [delegate BVAFileDownloader:self didFinishDownloadingToURL:destinationUrl];
        }
    }
    else{
        id delegate = self.delegate;
        if(delegate != nil){
            [delegate BVAFileDownloader:self didFinishWithError:fileManagerError];
        }
    }
}

// Этот метод вызывается url-сессией. Говорит о завершении скачивания. В случае ошибок error != nil.
// Проверяем, нет ли ошибок. Если нет, то ничего не делаем, если да, то оповещаем делегата об этом.
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if(error)
    {
        id delegate = self.delegate;
        if(delegate != nil){
            [delegate BVAFileDownloader:self didFinishWithError:error];
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    // Этот метод вызывается url-сессией. Говорит о том, сколько байт было скачано только что, сколько скачано в общем, сколько весит целый файл. можно использовать для управления ProcessView, чтобы показывать пользователю, сколько еще осталось скачать.
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    // Этот метод вызывается url-сессией. Метод оповещает о том, сколько будет весить скачиваемый файл. Можно использовать для проверки на максимальный размер, например.
}

@end
