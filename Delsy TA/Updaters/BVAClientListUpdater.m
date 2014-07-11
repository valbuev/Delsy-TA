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
#import "PriceGroup+PriceGroupCategory.h"
#import "PriceGroupLine+PriceGroupLineCategory.h"
#import "LineSale+LineSaleCategory.h"
#import "LineSaleLine+LineSaleLineCategory.h"
#import "Item+ItemCategory.h"

@implementation BVAClientListUpdater
@synthesize managedObjectContext;
@synthesize delegate;

# pragma mark initialization

-(void)startUpdating{
    lineSales = [NSMutableArray array];
    priceGroups = [NSMutableArray array];
    errors = [NSMutableArray array];
    [self startUpdatingPriceGroupsAndLineSales];
    if(delegate)
        [delegate BVAClientListUpdaterDidStartUpdating:self];
}

//обновляем сначала ценовые группы и скидки по строке, потом список клиентов
-(void) startUpdatingClientList{
    clientListDownloader = [[BVAFileDownloader alloc] init];
    [clientListDownloader initWithUrl:[NSURL URLWithString:@"http://195.112.235.1/Invent/Clients.xml"]];
    clientListDownloader.delegate = self;
    [clientListDownloader startDownload];
}

//обновляем сначала ценовые группы и скидки по строке, потом список клиентов
-(void) startUpdatingPriceGroupsAndLineSales{
    PriceGroupsAndLineSalesDownloader = [[BVAFileDownloader alloc] init];
    [PriceGroupsAndLineSalesDownloader initWithUrl:[NSURL URLWithString:@"http://195.112.235.1/Invent/PriceGroupsAndLineSales.xml"]];
    PriceGroupsAndLineSalesDownloader.delegate = self;
    [PriceGroupsAndLineSalesDownloader startDownload];
}

-(Boolean) saveManageObjectContext{
    if(self.managedObjectContext == nil){
        [errors addObject:[NSError errorWithDomain:@"savingMOC" code:9998
                                          userInfo:[NSDictionary dictionaryWithObject:@"clientListUpdater.moc = nil" forKey:@"info"]]];
        return NO;
    }
    else{
        NSError *error;
        [self.managedObjectContext save:&error];
        if(error){
            [errors addObject:error];
            return NO;
        }
        return YES;
    }
}

# pragma mark downloading

// Скачивание завершено, меняем кодировку, парсим xml в NSDictionary и отправляем его на обработку сохранение
-(void) BVAFileDownloader:(BVAFileDownloader *)downloader didFinishDownloadingToURL:(NSURL *)location{
    NSLog(@"\n\n\ndone\n\n\n");
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
        // Запускаем в главном потоке, чтобы избежать ошибок CoreData
        if(downloader == clientListDownloader){
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                [self saveParsedClientsDictionaryIntoCoreData];
            }];
        }
        else if (downloader == PriceGroupsAndLineSalesDownloader){
            //NSLog(@"saveParsedPriceGroupsAndLineSalesDictionaryIntoCoreData");
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                [self saveParsedPriceGroupsAndLineSalesDictionaryIntoCoreData];
            }];
        }
    }
    if(downloader == clientListDownloader)
        clientListDownloader = nil;
    else if (downloader == PriceGroupsAndLineSalesDownloader)
        PriceGroupsAndLineSalesDownloader = nil;
}



-(void) saveErrorAndSayDelegateAboutError:(NSError *)error{
    [errors addObject:error];
    [self sayDelegateAboutErrors];
}

// не удалось скачать файл - заканчиваем и сообщаем делегату
-(void) BVAFileDownloader:(BVAFileDownloader *)downloader didFinishWithError:(NSError *)error{
    [errors addObject:[error copy]];
    [self sayDelegateAboutErrors];
    clientListDownloader = nil;
}

// Завершаем обновление с ошибкой и сообщаем об этом делегату
-(void) sayDelegateAboutErrors{
    id delegate_buf = delegate;
    if(delegate_buf != nil){
        [delegate_buf BVAClientListUpdater:self didStopUpdatingWithErrors:errors];
    }
}

#pragma mark clients-dictionary to coreData

// Переводим данные из словаря в CoreData
-(void) saveParsedClientsDictionaryIntoCoreData{
    //NSLog(@"\n\nstart updating Clientlist\n\n");
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
    [Client setAllClientsDeleted:YES InManagedObjectContext:self.managedObjectContext];
    [Address setAllAddressesDeleted:YES InManagedObjectContext:self.managedObjectContext];
    
    /*for( PriceGroup *priceGroup in priceGroups){
        NSLog(@"priceGroup: %@",priceGroup.name);
    }
    for( LineSale *lineSale in lineSales){
        NSLog(@"lineSale: %@",lineSale.name);
    }
    
    NSArray *array = [LineSale getAllLineSales:self.managedObjectContext];
    for( LineSale *lineSale in array){
        NSLog(@"lineSale: %@",lineSale.name);
    }*/
    
    // сохраняем
    [self saveTAListIntoCoreData:TAdicts];
    //NSLog(@"\n%@",TAdicts);
    
    AppSettings *appSettings = [AppSettings getInstance:self.managedObjectContext];
    appSettings.clientsListLastUpdate = [NSDate date];
    TA *currentTA = appSettings.currentTA;
    if( currentTA )
        if( currentTA.deleted.boolValue == YES )
            appSettings.currentTA = nil;
    [self saveManageObjectContext];
    
    //NSLog(@"\n\ndone updating Clientlist\n\n");
    
    if(delegate)
        [delegate BVAClientListUpdater:self didFinishUpdatingWithErrors:errors];
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
        
        // Сохраняем клиентов и адреса текущего ТА
        [self saveAddressListIntoCoreData:addressDicts forTA:ta];
        [self saveManageObjectContext];
        //NSLog(@"\nTA: %@ \n%@",ta.name,addressDicts);
    }
}

-(void) saveAddressListIntoCoreData: (NSObject *) addressDicts forTA: (TA *) ta {
    // Если получили на вход словарь, то для этого агента один клиент, поэтому сразу посылаем в обработку
    // Если - список, то проходим по всем элементам списка - словарям с  адресами
    // На самом деле в xml они записаны как <client>, но записаны там АДРЕСА с информацией о клиенте
    if( [addressDicts isKindOfClass:[NSDictionary class]] ){
        [self saveAddressIntoCoreData:(NSDictionary *)addressDicts forTA:ta];
    }
    else if( [addressDicts isKindOfClass:[NSArray class]] ){
        int i=0;
        for( NSDictionary *adrDict in (NSArray *)addressDicts){
            [self saveAddressIntoCoreData:adrDict forTA:ta];
            i++;
            if(i>20){
                [self saveManageObjectContext];
                i=0;
            }
        }
    }
}

-(void) saveAddressIntoCoreData: (NSDictionary *) adrDict forTA:(TA *) ta{
    if(![adrDict isKindOfClass:[NSDictionary class]]){
        //NSLog(@"\n adrDict is not a kind of NSDictionary-class: \n%@ \n TA: %@",adrDict,ta.name);
        [errors addObject:[NSError errorWithDomain:@"saveParsedDictionaryIntoCoreData" code:9996
                                          userInfo:[NSDictionary dictionaryWithObject:@"adrDict is not a kind of NSDictionary-class" forKey:@"info"]]];
        return;
    }
    NSArray *addressDictKeys = [adrDict allKeys];
    // Если нет каких-либо ключей, переходим к следующему Address
    if( ![addressDictKeys containsObject:@"name"]
       || ![addressDictKeys containsObject:@"custAccount"]
       || ![addressDictKeys containsObject:@"address"]
       || ![addressDictKeys containsObject:@"addressId"]){
        [errors addObject:[NSError errorWithDomain:@"saveParsedDictionaryIntoCoreData" code:9997
                                          userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"<client> tag dont contain any keys, keys: %@",addressDictKeys] forKey:@"info"]]];
        return;
    }
    NSString *clientName = [adrDict objectForKey:@"name"];
    NSString *custAccount = [adrDict objectForKey:@"custAccount"];
    NSString *addressName = [adrDict objectForKey:@"address"];
    NSString *addressId = [adrDict objectForKey:@"addressId"];
    NSString *priceGroup_str = [adrDict objectForKey:@"priceGroup"];
    NSString *lineSale_str = [adrDict objectForKey:@"lineSale"];
    // Если какие-либо значения не верны, переходим к следующему Address
    if( [clientName isEqualToString:@""]
       || [custAccount isEqualToString:@""]
       || [addressName isEqualToString:@""]
       || [addressId isEqualToString:@""]
       ){
        [errors addObject:[NSError errorWithDomain:@"saveParsedDictionaryIntoCoreData" code:9997
                                          userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"<client> tag contain any wrong values: clientName:%@ custAccount:%@ addressName:%@ addressId:%@",clientName,custAccount,addressName,addressId] forKey:@"info"]]];
        return;
    }
    
    // Запрашиваем managedObject с id = custAccount и устанавливаем значения
    //NSLog(@"\nTA: %@\n1 %@ %@ %@",ta.name,custAccount,clientName,clientSale);
    Client *client = [Client getClientByCustAccount:custAccount withMOC:self.managedObjectContext];
    // Запрашиваем managedObject с id = addressId и устанавливаем значения
    //NSLog(@"\nTA: %@\n%@ %@",ta.name,addressId,addressName);
    Address *address = [Address getAddressByAddressId:addressId withMOC:self.managedObjectContext];
    
    //NSLog(@"\nTA: %@\n2 %@ %@ %@",ta.name,custAccount,clientName,clientSale);
    if(client.deleted){

        client.priceGroup = (PriceGroup *)[self priceGroupFromMutableArrayByName:priceGroup_str];
        client.lineSale = (LineSale *)[self lineSaleFromMutableArrayByName:lineSale_str];
        //NSLog(@"\nclient: %@ ta: %@ \npriceGroup: %@, priceGroup_str: %@\n lineSale: %@ sale1: %@ sale2: %@  lineSale_str: %@",clientName,ta.name,client.priceGroup.name,priceGroup_str,client.lineSale.name,client.lineSale.allSale1,client.lineSale.allSale1,lineSale_str);
        client.name = clientName;
        client.deleted = NO;
        client.ta = ta;
    }
    address.address = addressName;
    address.deleted = NO;
    address.client = client;
    //NSLog(@"\nTA: %@\n3 %@ %@ %@",ta.name,custAccount,clientName,clientSale);
}

- (NSObject *) priceGroupFromMutableArrayByName:(NSString *) name{
    if(!name)
        return nil;
    else if( [name isEqualToString:@""] )
        return nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@",name];
    NSArray *array = [priceGroups filteredArrayUsingPredicate:predicate];
    if( array.count == 0 )
        return nil;
    else
        return [array objectAtIndex:0];
}

- (NSObject *) lineSaleFromMutableArrayByName:(NSString *) name{
    if(!name)
        return nil;
    else if( [name isEqualToString:@""] )
        return nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@",name];
    NSArray *array = [lineSales filteredArrayUsingPredicate:predicate];
    if( array.count == 0 )
        return nil;
    else
        return [array objectAtIndex:0];
}

#pragma mark priceGroupsAndLineSales-dictionary to coreData

// Переводим данные из словаря в CoreData
-(void) saveParsedPriceGroupsAndLineSalesDictionaryIntoCoreData{
    //NSLog(@"saveParsedPriceGroupsAndLineSalesDictionaryIntoCoreData");
    NSError *error = [NSError errorWithDomain:@"saveParsedDictionaryIntoCoreData" code:9999
                                     userInfo:[NSDictionary dictionaryWithObject:@"Incorrect data" forKey:@"info"]];
    if(![parseResults.allKeys containsObject:@"PriceGroups"]){
        [self saveErrorAndSayDelegateAboutError:error];
        return;
    }
    if(![parseResults.allKeys containsObject:@"LineSales"]){
        [self saveErrorAndSayDelegateAboutError:error];
        return;
    }
    [PriceGroup removePriceGroupsFromManagedObjectContext:self.managedObjectContext];
    [LineSale removeLineSalesFromManagedObjectContext:self.managedObjectContext];
    [self saveManageObjectContext];
    
    //NSLog(@"\n\nstart updating priceGroups\n\n");
    NSDictionary *priceGroupsDict = [parseResults objectForKey:@"PriceGroups"];
    [self savePriceGroupsIntoCoreData:priceGroupsDict];
    [self saveManageObjectContext];
    //NSLog(@"\n\ndone updating priceGroups\n\n");
    
    //NSLog(@"\n\nstart updating lineSales\n\n");
    NSDictionary *LineSalesDict = [parseResults objectForKey:@"LineSales"];
    [self saveLineSalesIntoCoreData:LineSalesDict];
    [self saveManageObjectContext];
    //NSLog(@"\n\ndone updating lineSales \n\n");
    
    [self startUpdatingClientList];
}

- (void) saveLineSalesIntoCoreData:(NSDictionary *) lineSalesDict{
    if( lineSalesDict.allKeys.count == 0 )
        return;
    NSArray *lineSaleDicts;
    if( [[lineSalesDict objectForKey:@"LineSale"] isKindOfClass:[NSArray class]] ){
        lineSaleDicts = [lineSalesDict objectForKey:@"LineSale"];
    }
    else{
        lineSaleDicts = [NSArray arrayWithObject:[lineSalesDict objectForKey:@"LineSale"]];
    }
    for(NSDictionary *lineSale in lineSaleDicts){
        [self saveLineSaleIntoCoreData:lineSale];
        [self saveManageObjectContext];
    }
}

- (void) saveLineSaleIntoCoreData:(NSDictionary *)lineSaleDict{
    if(lineSaleDict.allKeys == 0){
        [errors addObject:[NSError errorWithDomain:@"saveLineSaleIntoCoreData" code:9993
                                          userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"LineSale dont contain any attributes"] forKey:@"info"]]];
        return;
    }
    if(![lineSaleDict objectForKey:@"_id"]){
        [errors addObject:[NSError errorWithDomain:@"saveLineSaleIntoCoreData" code:9993
                                          userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"LineSale dont contain id-attributes"] forKey:@"info"]]];
        return;
    }
    
    NSString *lineSaleId = [lineSaleDict objectForKey:@"_id"];
    LineSale *lineSale = [LineSale newLineSaleInManObjContext:self.managedObjectContext];
    lineSale.name = lineSaleId;
    
    //записываем в список, для последующего быстрого доступа и поиска
    [lineSales addObject:lineSale];
    
    //NSLog(@"lineSale: %@",lineSale.name);
    
    NSDictionary *lineSaleAllSaleDict = [lineSaleDict objectForKey:@"allSale"];
    if(!lineSaleAllSaleDict){
        lineSale.allSale1 = [NSNumber numberWithFloat:0];
        lineSale.allSale2 = [NSNumber numberWithFloat:0];
    }
    else {
        NSString *sale1_str = [lineSaleAllSaleDict objectForKey:@"sale1"];
        if ( !sale1_str )
            lineSale.allSale1 = [NSNumber numberWithFloat:0];
        else
            lineSale.allSale1 = [NSNumber numberWithFloat: sale1_str.floatValue];
        
        NSString *sale2_str = [lineSaleAllSaleDict objectForKey:@"sale2"];
        if ( !sale2_str )
            lineSale.allSale2 = [NSNumber numberWithFloat:0];
        else
            lineSale.allSale2 = [NSNumber numberWithFloat: sale2_str.floatValue];
    }
    
    NSObject *lineSaleLinesDict = [lineSaleDict objectForKey:@"item"];
    if( !lineSaleLinesDict )
        return;
    NSArray *lineSaleLinesArray;
    if( [lineSaleLinesDict isKindOfClass:[NSArray class]] ){
        lineSaleLinesArray = (NSArray *) lineSaleLinesDict;
    }
    else{
        lineSaleLinesArray = [NSArray arrayWithObject:lineSaleLinesDict];
    }
    int n=0;
    for( NSDictionary *lineSaleLineDict in lineSaleLinesArray){
        [self saveLineSaleLineIntoCoreData:lineSaleLineDict lineSale:lineSale];
        n++;
        if(n==10){
            n=0;
            [self saveManageObjectContext];
        }
    }
}

- (void) saveLineSaleLineIntoCoreData:(NSDictionary *) lineSaleLineDict lineSale:(LineSale *) lineSale{
    NSString *itemId = [lineSaleLineDict objectForKey:@"itemId"];
    NSString *sale1 = [lineSaleLineDict objectForKey:@"sale1"];
    NSString *sale2 = [lineSaleLineDict objectForKey:@"sale2"];
    if( !itemId ){
        [errors addObject:[NSError errorWithDomain:@"saveLineSaleLineIntoCoreData" code:9992
                                          userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"LineSaleLine dont contain itemId-attribute"] forKey:@"info"]]];
        return;
    }
    if( !sale1 )
        sale1 = @"";
    if( !sale2 )
        sale2 = @"";
    
    LineSaleLine *lineSaleLine = [LineSaleLine newLineSaleLineInManObjContext:self.managedObjectContext];
    
    lineSaleLine.sale1 = [NSNumber numberWithFloat: sale1.floatValue];
    lineSaleLine.sale2 = [NSNumber numberWithFloat: sale2.floatValue];
    lineSaleLine.itemID = itemId;
    lineSaleLine.lineSale = lineSale;
}

- (void) savePriceGroupsIntoCoreData:(NSDictionary *) priceGroupsDict{
    if([priceGroupsDict allKeys].count == 0 )
        return;
    NSArray *priceGroupDicts;
    if(![[priceGroupsDict objectForKey:@"PriceGroup"] isKindOfClass:[NSArray class]]){
        priceGroupDicts = [NSArray arrayWithObject:[priceGroupsDict objectForKey:@"PriceGroup"]];
    }
    else{
        priceGroupDicts = [priceGroupsDict objectForKey:@"PriceGroup"];
    }
    for(NSDictionary *priceGroup in priceGroupDicts){
        //NSLog(@"\n\nstart updating priceGroup\n\n");
        [self savePriceGroupIntoCoreData:priceGroup];
        [self saveManageObjectContext];
        //NSLog(@"\n\ndone updating priceGroup\n\n");
    }
}

- (void) savePriceGroupIntoCoreData:(NSDictionary *) priceGroupDict {
    if([priceGroupDict objectForKey:@"_id"] == nil){
        [errors addObject:[NSError errorWithDomain:@"savePriceGroupIntoCoreData" code:9997
                                          userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"priceGroup-tag dont contain id-attribute"] forKey:@"info"]]];
        return;
    }
    if([priceGroupDict objectForKey:@"item"] == nil){
        [errors addObject:[NSError errorWithDomain:@"savePriceGroupIntoCoreData" code:9997
                                          userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"priceGroup-tag dont contain items"] forKey:@"info"]]];
        return;
    }
    PriceGroup *priceGroup = [PriceGroup newPriceGroupInManObjContext:self.managedObjectContext];
    priceGroup.name = [priceGroupDict objectForKey:@"_id"];
    
    //записываем в список, для последующего быстрого доступа и поиска
    [priceGroups addObject:priceGroup];
    //NSLog(@"priceGroup: %@",priceGroup.name);
    
    NSArray *itemDicts; // PriceGroupLineDicts
    if([[priceGroupDict objectForKey:@"item"] isKindOfClass:[NSArray class]]){
        itemDicts = [priceGroupDict objectForKey:@"item"];
    }
    else{
        itemDicts = [NSArray arrayWithObject:[priceGroupDict objectForKey:@"item"]];
    }
    int n=0;
    //NSLog(@"start saving PriceGroupLines into Core Data");
    for (NSDictionary *priceGroupLineDict in itemDicts) {
        [self savePriceGroupLineIntoCoreData:priceGroupLineDict priceGroup:priceGroup];
        n++;
        if(n==10){
            //NSLog(@"saving context in saving PriceGroupLines into Core Data");
            [self saveManageObjectContext];
            //NSLog(@"end of saving context in saving PriceGroupLines into Core Data");
            n=0;
        }
    }
}

- (void) savePriceGroupLineIntoCoreData:(NSDictionary *) priceGroupLineDict priceGroup:(PriceGroup *) priceGroup {
    NSNumber *price;
    NSString *itemId;
    NSNumber *plusable;
    if(![priceGroupLineDict objectForKey:@"itemId"]){
        [errors addObject:[NSError errorWithDomain:@"savePriceGroupLineIntoCoreData" code:9997
                                          userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"priceGroupLine-tag dont contain itemId"] forKey:@"info"]]];
        return;
    }
    else{
        itemId = [priceGroupLineDict objectForKey:@"itemId"];
    }
    if(![priceGroupLineDict objectForKey:@"price"]){
        [errors addObject:[NSError errorWithDomain:@"savePriceGroupLineIntoCoreData" code:9997
                                          userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"priceGroupLine-tag dont contain price"] forKey:@"info"]]];
        return;
    }
    else{
        price = [NSNumber numberWithFloat:[[priceGroupLineDict objectForKey:@"price"] floatValue]];
    }
    if( ![priceGroupLineDict objectForKey:@"price"] ){
        plusable = [NSNumber numberWithBool:YES];
    }
    if([[priceGroupLineDict objectForKey:@"plusable"] intValue] == 1){
        plusable = [NSNumber numberWithBool:YES];
    }
    else{
        plusable = [NSNumber numberWithBool:NO];
    }
    PriceGroupLine *priceGroupLine = [PriceGroupLine newPriceGroupLineInManObjContext:self.managedObjectContext];
    priceGroupLine.itemID = itemId;
    priceGroupLine.priceGroup = priceGroup;
    priceGroupLine.plusable = plusable;
    priceGroupLine.price = price;
}



@end
