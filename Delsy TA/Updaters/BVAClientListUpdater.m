//
//  BVAClientListUpdater.m
//  Delsy TA
//
//  Created by Valeriy Buev on 25.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "BVAClientListUpdater.h"
#import "TA+TACategory.h"
#import "Client+ClientCategory.h"
#import "AppSettings+AppSettingsCategory.h"
#import "Address+AddressCategory.h"
#import "XMLDictionary.h"

@implementation BVAClientListUpdater
@synthesize managedObjectContext;
@synthesize delegate;

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
        XMLDictionaryParser *parser = [[XMLDictionaryParser alloc] init];
        parseResults = [parser dictionaryWithString:str];
        [self saveParsedDictionaryIntoCoreData];
    }
    fileDownloader = nil;
}

-(void) saveParsedDictionaryIntoCoreData{
    NSError *error = [NSError errorWithDomain:@"saveParsedDictionaryIntoCoreData" code:9999 userInfo:[NSDictionary dictionaryWithObject:@"Incorrect data" forKey:@"info"]];
    if(![parseResults.allKeys containsObject:@"TA"]){
        [self saveErrorAndSayDelegateAboutError:error];
        return;
    }
    // dictionaries with TA (which contains arrays of clients-dictionaries)
    NSArray *TAdicts = [parseResults valueForKey:@"TA"];
    //если не нашлось ни одного ТА, завершаем с ошибкой
    if(TAdicts.count <1){
        [self saveErrorAndSayDelegateAboutError:error];
        return;
    }
    // Помечаем все ТА-managedObject-ы как deleted
    [TA setAllTADeleted:YES InManagedObjectContext:self.managedObjectContext];
    // проходим по всем словарям
    for(int ta_dict_number = 0; ta_dict_number < TAdicts.count; ta_dict_number++){
        NSDictionary *TAdict = [TAdicts objectAtIndex:ta_dict_number];
        NSArray *TAdictKeys = TAdict.allKeys;
        // Если нет каких-либо ключей, переходим к следующему ТА
        if( ![TAdictKeys containsObject:@"name"]
           || ![TAdictKeys containsObject:@"id"]
           || ![TAdictKeys containsObject:@"client"] ){
            [errors addObject:[NSError errorWithDomain:@"saveParsedDictionaryIntoCoreData" code:9998 userInfo:[NSDictionary dictionaryWithObject:@"TAdict dont contain any keys" forKey:@"info"]]];
            continue;
        }
        NSString *TAname = [TAdict objectForKey:@"name"];
        NSString *TAid = [TAdict objectForKey:@"id"];
        NSArray *clientDicts = [TAdict objectForKey:@"client"];
        // Если какие-либо из объектов словаря пусты, переходим к следующему ТА
        if( [TAname isEqualToString:@""]
           || [TAid isEqualToString:@""]
           || clientDicts.count == 0 ){
            [errors addObject:[NSError errorWithDomain:@"saveParsedDictionaryIntoCoreData" code:9998 userInfo:[NSDictionary dictionaryWithObject:@"TAdict dont contain any keys" forKey:@"info"]]];
            continue;
        }
        // Запрашиваем managedObject с id = TAid
        TA *ta = [TA getTAbyID:TAid withMOC:self.managedObjectContext];
        ta.name = TAname;
        ta.deleted = NO;
    }
}

-(void) saveErrorAndSayDelegateAboutError:(NSError *)error{
    [errors addObject:error];
    [self sayDelegateAboutErrors];
}

-(void) BVAFileDownloader:(BVAFileDownloader *)downloader didFinishWithError:(NSError *)error{
    [errors addObject:[error copy]];
    [self sayDelegateAboutErrors];
    fileDownloader = nil;
}

-(void) sayDelegateAboutErrors{
    id delegate_buf = delegate;
    if(delegate_buf != nil){
        [delegate_buf BVAClientListUpdater:self didStopUpdatingWithErrors:errors];
    }
}

@end
