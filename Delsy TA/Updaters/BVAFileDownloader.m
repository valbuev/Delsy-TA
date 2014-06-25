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
    config.timeoutIntervalForRequest = 30;
    config.timeoutIntervalForResource = 30;
    mySession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
}

// начинает скачивание
-(void) startDownload{
    [[mySession downloadTaskWithURL:url] resume];
    NSLog(@"start");
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
    if(fileManagerError == nil){
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
    mySession = nil;
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
    mySession = nil;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    // Этот метод вызывается url-сессией. Говорит о том, сколько байт было скачано только что, сколько скачано в общем, сколько весит целый файл. можно использовать для управления ProcessView, чтобы показывать пользователю, сколько еще осталось скачать.
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    // Этот метод вызывается url-сессией. Метод оповещает о том, сколько будет весить скачиваемый файл. Можно использовать для проверки на максимальный размер, например.
}

/*
 -(void)BVAFileDownloader:(BVAFileDownloader *)downloader didFinishDownloadingToURL:(NSURL *)location{
 NSError *error;
 NSString *str = [NSString stringWithContentsOfURL:location encoding:NSWindowsCP1251StringEncoding error:&error];
 str = [str stringByReplacingOccurrencesOfString:@"encoding=\"windows-1251\"" withString:@""];
 //NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
 //str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
 self.labelText.text = str;
 NSLog(@"str = %@",str);
 NSLog(@"encoding error = %@",error);
 }
 */

@end
