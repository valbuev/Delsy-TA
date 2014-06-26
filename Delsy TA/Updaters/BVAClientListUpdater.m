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
    [fileDownloader initWithUrl:[NSURL URLWithString:@"http://195.112.235.1/Invent/Clients_test.xml"]];
    fileDownloader.delegate = self;
    [fileDownloader startDownload];
    if(delegate)
        [delegate BVAClientListUpdaterDidStartUpdating:self];
}

// Скачивание завершено, меняем кодировку, парсим xml в NSDictionary и отправляем его на обработку сохранение
-(void) BVAFileDownloader:(BVAFileDownloader *)downloader didFinishDownloadingToURL:(NSURL *)location{
    NSLog(@"done");
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

// Переводим данные из словаря в CoreData
-(void) saveParsedDictionaryIntoCoreData{
    NSError *error = [NSError errorWithDomain:@"saveParsedDictionaryIntoCoreData" code:9999
                                     userInfo:[NSDictionary dictionaryWithObject:@"Incorrect data" forKey:@"info"]];
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
    
        // Помечаем все Client & Address-managedObject-ы как deleted
    [Address setAllAddressesDeleted:YES InManagedObjectContext:self.managedObjectContext];
    
        // сохраняем
    [self saveTAListIntoCoreData:TAdicts];
    //NSLog(@"\n%@",TAdicts);
    
    AppSettings *appSettings = [AppSettings getInstance:self.managedObjectContext];
    appSettings.clientsListLastUpdate = [NSDate date];
    TA *currentTA = appSettings.currentTA;
    if( currentTA )
        if( currentTA.deleted.boolValue == YES )
            appSettings.currentTA = nil;
    if(delegate)
        [delegate BVAClientListUpdater:self didFinishUpdatingWithErrors:errors];
    NSLog(@"done");
#warning You must save context after updating !!!
}

-(void) saveTAListIntoCoreData: (NSArray *) TAdicts
{
        //проходим по всем словарям
    for( NSDictionary *TAdict in TAdicts ){
        NSArray *TAdictKeys = TAdict.allKeys;
            // Если нет каких-либо ключей, переходим к следующему ТА
        if( ![TAdictKeys containsObject:@"_name"]
           || ![TAdictKeys containsObject:@"_id"]
           || ![TAdictKeys containsObject:@"client"] ){
            [errors addObject:[NSError errorWithDomain:@"saveParsedDictionaryIntoCoreData" code:9998
                                              userInfo:[NSDictionary dictionaryWithObject:@"TAdict dont contain any keys" forKey:@"info"]]];
            continue;
        }
        NSString *TAname = [TAdict objectForKey:@"_name"];
        NSString *TAid = [TAdict objectForKey:@"_id"];
        NSArray *addressDicts = [TAdict objectForKey:@"client"];
            // Если какие-либо из объектов словаря пусты, переходим к следующему ТА
        if( [TAname isEqualToString:@""]
           || [TAid isEqualToString:@""]
           || addressDicts.count == 0 ){
            [errors addObject:[NSError errorWithDomain:@"saveParsedDictionaryIntoCoreData" code:9998
                                              userInfo:[NSDictionary dictionaryWithObject:@"TAdict dont contain any keys" forKey:@"info"]]];
            continue;
        }
            // Запрашиваем managedObject с id = TAid и устанавливаем значения
        TA *ta = [TA getTAbyID:TAid withMOC:self.managedObjectContext];
        ta.name = TAname;
        ta.deleted = NO;
        
        [self saveAddressListIntoCoreData:addressDicts forTA:ta];
    }
}

-(void) saveAddressListIntoCoreData: (NSArray *) addressDicts forTA: (TA *) ta {
        // проходим по всем адресам
        // На самом деле в xml они записаны как <client>, но записаны там АДРЕСА с информацией о клиенте
    for( NSDictionary *adrDict in addressDicts ){
        NSArray *addressDictKeys = [adrDict allKeys];
            // Если нет каких-либо ключей, переходим к следующему Address
        if( ![addressDictKeys containsObject:@"name"]
           || ![addressDictKeys containsObject:@"custAccount"]
           || ![addressDictKeys containsObject:@"address"]
           || ![addressDictKeys containsObject:@"addressId"]
           || ![addressDictKeys containsObject:@"sale"]){
            [errors addObject:[NSError errorWithDomain:@"saveParsedDictionaryIntoCoreData" code:9997
                                              userInfo:[NSDictionary dictionaryWithObject:@"<client> tag dont contain any keys" forKey:@"info"]]];
            continue;
        }
        NSString *clientName = [adrDict objectForKey:@"name"];
        NSString *custAccount = [adrDict objectForKey:@"custAccount"];
        NSString *addressName = [adrDict objectForKey:@"address"];
        NSString *addressId = [adrDict objectForKey:@"addressId"];
        NSNumber *clientSale = [NSNumber numberWithInt:[[adrDict objectForKey:@"sale"] floatValue]];
            // Если какие-либо значения не верны, переходим к следующему Address
        if( [clientName isEqualToString:@""]
           || [custAccount isEqualToString:@""]
           || [addressName isEqualToString:@""]
           || [addressId isEqualToString:@""]
           || clientSale.floatValue > 99
           || clientSale.floatValue < 0 ){
            [errors addObject:[NSError errorWithDomain:@"saveParsedDictionaryIntoCoreData" code:9997
                                              userInfo:[NSDictionary dictionaryWithObject:@"<client> tag contain any wrong values" forKey:@"info"]]];
        }
        
            // Запрашиваем managedObject с id = addressId и устанавливаем значения
        Address *address = [Address getAddressByAddressId:addressId withMOC:self.managedObjectContext];
            // Запрашиваем managedObject с id = custAccount и устанавливаем значения
        Client *client = [Client getClientByCustAccount:custAccount withMOC:self.managedObjectContext];
        
        client.name = clientName;
        client.sale = clientSale;
        client.deleted = NO;
        client.ta = ta;
        address.address = addressName;
        address.deleted = NO;
        address.client = client;
    }
}

-(void) saveErrorAndSayDelegateAboutError:(NSError *)error{
    [errors addObject:error];
    [self sayDelegateAboutErrors];
}

// не удалось скачать файл - заканчиваем и сообщаем делегату
-(void) BVAFileDownloader:(BVAFileDownloader *)downloader didFinishWithError:(NSError *)error{
    [errors addObject:[error copy]];
    [self sayDelegateAboutErrors];
    fileDownloader = nil;
}

// Завершаем обновление с ошибкой и сообщаем об этом делегату
-(void) sayDelegateAboutErrors{
    id delegate_buf = delegate;
    if(delegate_buf != nil){
        [delegate_buf BVAClientListUpdater:self didStopUpdatingWithErrors:errors];
    }
}

@end
