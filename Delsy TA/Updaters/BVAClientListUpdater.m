//
//  BVAClientListUpdater.m
//  Delsy TA
//
//  Created by Valeriy Buev on 25.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "BVAClientListUpdater.h"

@implementation BVAClientListUpdater
@synthesize managedObjectContext;
@synthesize delegate;
@synthesize labelText;

-(void)startUpdating{
    errors = [NSMutableArray array];
    fileDownloader = [[BVAFileDownloader alloc] init];
    [fileDownloader initWithUrl:[NSURL URLWithString:@"http://195.112.235.1/Invent/Clients.xml"]];
    fileDownloader.delegate = self;
    [fileDownloader startDownload];
}

-(void) BVAFileDownloader:(BVAFileDownloader *)downloader didFinishDownloadingToURL:(NSURL *)location{
    NSError *error;
    NSString *str = [NSString stringWithContentsOfURL:location encoding:NSWindowsCP1251StringEncoding error:&error];
    //str = [str stringByReplacingOccurrencesOfString:@"encoding=\"windows-1251\"" withString:@""];
    if(error){
        [errors addObject:error];
        [self sayDelegateAboutErrors];
    }
    else{
        NSDate *date1 = [NSDate date];
        XMLDictionaryParser *parser = [[XMLDictionaryParser alloc] init];
        NSDictionary *dict = [parser dictionaryWithString:str];
        //NSLog(@"%@",dict);
        NSDate *date2 = [NSDate date];
        NSArray *array = [dict objectForKey:@"TA"];
        dict = [array objectAtIndex:0];
        array = [dict objectForKey:@"client"];
        dict = [array objectAtIndex:0];
        labelText.text = [NSString stringWithFormat:@"%@", [dict objectForKey:@"address"]];
        NSLog(@"%@", [dict objectForKey:@"address"]);
        NSLog(@"1: %f",[date1 timeIntervalSince1970]);
        NSLog(@"2: %f",[date2 timeIntervalSince1970]);
    }
    fileDownloader = nil;
    NSLog(@"finish");
}

-(void) BVAFileDownloader:(BVAFileDownloader *)downloader didFinishWithError:(NSError *)error{
    [errors addObject:[error copy]];
    [self sayDelegateAboutErrors];
    fileDownloader = nil;
    NSLog(@"error");
}

-(void) sayDelegateAboutErrors{
    id delegate_buf = delegate;
    if(delegate_buf != nil){
        [delegate_buf BVAClientListUpdater:self didStopUpdatingWithErrors:errors];
    }
}

@end
