//
//  BVAPriceUpdater.m
//  Delsy TA
//
//  Created by Valeriy Buev on 29.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

// ПРедназначен для скачивания прайса, распарсивания его и загрузки в CoreData.

#import "BVAPriceUpdater.h"
#import "AppSettings+AppSettingsCategory.h"
#import "XMLDictionary.h"
#import "Item+ItemCategory.h"
#import "Thesis+ThesisCategory.h"
#import "ProductType+ProductTypeCategory.h"
#import "Fish+FishCategory.h"
#import "Photo+PhotoCategory.h"
#import "LineSaleLine+LineSaleLineCategory.h"
#import "PriceGroupLine+PriceGroupLineCategory.h"

@interface BVAPriceUpdater (){
    
}

@property (nonatomic,retain) AppSettings *appSettings;

@end

@implementation BVAPriceUpdater
@synthesize managedObjectContext;
@synthesize delegate;
@synthesize appSettings = _appSettings;

- (AppSettings *)appSettings{
    if(_appSettings != nil)
        return _appSettings;
    _appSettings = [AppSettings getInstance:self.managedObjectContext];
    return _appSettings;
}

-(void)startUpdating{
    priceGroupLines = [NSMutableArray arrayWithArray:[PriceGroupLine getAllPriceGroupLines:self.managedObjectContext]];
    lineSaleLines = [NSMutableArray arrayWithArray:[LineSaleLine getAllLineSaleLines:self.managedObjectContext]];
    errors = [NSMutableArray array];
    fileDownloader = [[BVAFileDownloader alloc] init];
    NSString *url_str = [NSString stringWithFormat:@"%@Price_iOS.xml",self.appSettings.updateFolderURL];
    [fileDownloader initWithUrl:[NSURL URLWithString:url_str]];
    fileDownloader.delegate = self;
    [fileDownloader startDownload];
    if(delegate)
        [delegate BVAPriceUpdaterDidStartUpdating:self];
}

-(Boolean) saveManageObjectContext{
    if(self.managedObjectContext == nil){
        [errors addObject:[NSError errorWithDomain:@"savingMOC" code:9998
                                          userInfo:[NSDictionary dictionaryWithObject:@"PriceUpdater.moc = nil" forKey:@"info"]]];
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
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            [self saveParsedDictionaryIntoCoreData];
            //NSLog(@"%@",parseResults);
        }];
    }
    fileDownloader = nil;
}


// Переводим данные из словаря в CoreData
-(void) saveParsedDictionaryIntoCoreData{
    NSError *error = [NSError errorWithDomain:@"saveParsedDictionaryIntoCoreData" code:9999
                                     userInfo:[NSDictionary dictionaryWithObject:@"Incorrect data" forKey:@"info"]];
    if(![parseResults.allKeys containsObject:@"ProductType"]){
        [self saveErrorAndSayDelegateAboutError:error];
        return;
    }
    // dictionaries with Producttypes (which contains arrays of items-dictionaries)
    NSArray *ProductTypeDicts = [parseResults valueForKey:@"ProductType"];
    //если не нашлось ни одного ТА, завершаем с ошибкой
    if(ProductTypeDicts.count <1){
        [self saveErrorAndSayDelegateAboutError:error];
        return;
    }
    
    // Помечаем все Item-managedObject-ы как deleted
    [Item setAllItemsDeleted:YES InManagedObjectContext:self.managedObjectContext];
#pragma mark saveManagedObjectContext
    [self saveManageObjectContext];
    
    // Удаляем все тезисы
    [Thesis removeAllThesisesFromManagedObjectContext:self.managedObjectContext];
#pragma mark saveManagedObjectContext
    [self saveManageObjectContext];
    
    // Удаляем все связи Fish-ProductType, чтобы потом было проще выводить вложенный список
    [Fish removeAllProductTypesRelationShipsFromAllFishes_InManagedObjectContext:self.managedObjectContext];
#pragma mark saveManagedObjectContext
    [self saveManageObjectContext];
    
    // Помечаем все фото как удаленные. Найденные в ходе импорта будут помечены как неудаленные.
    // Для новых будут созданы соответствующие классы, а все старые в конце импорта будут удалены.
    [Photo setAllPhotosDeleted:YES InManagedObjectContext:self.managedObjectContext];
#pragma mark saveManagedObjectContext
    [self saveManageObjectContext];
    
    // сохраняем
    [self saveProductTypeListIntoCoreData:ProductTypeDicts];
    //NSLog(@"\n%@",ProductTypeDicts);
    
#pragma mark saveManagedObjectContext
    [self saveManageObjectContext];
    
    // Удаляем все фотографии: объекты контекста и сами файлы в хранилище
    [Photo removeDeletedPhotosInMOC:self.managedObjectContext];
    
    // Записываем в Настройки новую дату последнего обновления
    self.appSettings.priceLastUpdate = [NSDate date];
#pragma mark saveManagedObjectContext
    [self saveManageObjectContext];
    if(delegate){
        [delegate BVAPriceUpdater:self didFinishUpdatingWithErrors:errors];
    }
    NSLog(@"\n\n\ndone\n\n\n");
}



-(void) saveProductTypeListIntoCoreData: (NSArray *) ProductTypeDicts
{
    //проходим по всем словарям
    //NSLog(@"%@",ProductTypeDicts);
    for( NSDictionary *ProductTypeDict in ProductTypeDicts ){
        NSArray *ProductTypeDictKeys = ProductTypeDict.allKeys;
        // Если нет каких-либо ключей, переходим к следующему ProductType
        if( ![ProductTypeDictKeys containsObject:@"_title"]
           || ![ProductTypeDictKeys containsObject:@"item"] ){
            [errors addObject:[NSError errorWithDomain:@"saveParsedDictionaryIntoCoreData" code:9998
                                              userInfo:[NSDictionary dictionaryWithObject:@"ProductTypeDict don't contain any keys" forKey:@"info"]]];
            continue;
        }
        NSString *productTypeName = [ProductTypeDict objectForKey:@"_title"];
        NSArray *itemsDicts = [ProductTypeDict objectForKey:@"item"];
        // Если какие-либо из объектов словаря пусты, переходим к следующему ProductType
        if( [productTypeName isEqualToString:@""]
           || itemsDicts.count == 0 ){
            [errors addObject:[NSError errorWithDomain:@"saveParsedDictionaryIntoCoreData" code:9998
                                              userInfo:[NSDictionary dictionaryWithObject:
                                                        [NSString stringWithFormat:@"productTypeDict don't contain any values: title: %@ items-count: %d",productTypeName,(int)itemsDicts.count] forKey:@"info"]]];
            continue;
        }
        // Запрашиваем managedObject с name = productTypeName и устанавливаем значения
        ProductType *productType = [ProductType getProductTypeByName:productTypeName withMOC:self.managedObjectContext];
        
        // Сохраняем items and fishes текущего productType
        [self saveItemListIntoCoreData:itemsDicts forProductType:productType];
#pragma mark saveManagedObjectContext
        [self saveManageObjectContext];
        //NSLog(@"\nTA: %@ \n%@",ta.name,addressDicts);
    }
}

-(void) saveItemListIntoCoreData: (NSObject *) itemDicts forProductType: (ProductType *) productType {
    // Если получили на вход словарь, то для этого productType один item, поэтому сразу посылаем в обработку
    // Если - список, то проходим по всем элементам списка - словарям с продуктами
    // Вид рыбы записан как атрибут тега <item>
    if( [itemDicts isKindOfClass:[NSDictionary class]] ){
        [self saveItemIntoCoreData:(NSDictionary *)itemDicts forProductType:productType];
    }
    else if( [itemDicts isKindOfClass:[NSArray class]] ){
        int i=0;
        for( NSDictionary *itemDict in (NSArray *)itemDicts){
            [self saveItemIntoCoreData:itemDict forProductType:productType];
            i++;
            if(i>5){
#pragma mark saveManagedObjectContext
                [self saveManageObjectContext];
                i=0;
            }
        }
    }
}


-(void) saveItemIntoCoreData: (NSDictionary *) itemDict forProductType:(ProductType *) productType{
    if(![itemDict isKindOfClass:[NSDictionary class]]){
        NSLog(@"\n itemDict is not a kind of NSDictionary-class: \n%@ \n ProductType: %@",itemDict,productType.name);
        [errors addObject:[NSError errorWithDomain:@"saveParsedDictionaryIntoCoreData" code:9996
                                          userInfo:[NSDictionary dictionaryWithObject:@"itemDict is not a kind of NSDictionary-class" forKey:@"info"]]];
        return;
    }
    NSArray *itemDictKeys = [itemDict allKeys];
    // Если нет каких-либо ключей, переходим к следующему Item
    if( ![itemDictKeys containsObject:@"_fishType"]
       || ![itemDictKeys containsObject:@"_title"]
       || ![itemDictKeys containsObject:@"itemname"]
       || ![itemDictKeys containsObject:@"_price"]
       || ![itemDictKeys containsObject:@"_unit"]
       || ![itemDictKeys containsObject:@"_unitsInBox"]
       || ![itemDictKeys containsObject:@"_unitsInBigBox"]){
        [errors addObject:[NSError errorWithDomain:@"saveParsedDictionaryIntoCoreData" code:9997
                                          userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"<item> tag dont contain any keys, keys: %@",itemDictKeys] forKey:@"info"]]];
        return;
    }
    NSString *itemName = [itemDict objectForKey:@"itemname"];
    NSString *itemID = [itemDict objectForKey:@"_title"];
    NSNumber *itemPrice = [NSNumber numberWithFloat: [[itemDict objectForKey:@"_price"] floatValue]];
    NSString *itemUnit = [itemDict objectForKey:@"_unit"];
    NSNumber *itemUnitsInBox = [NSNumber numberWithFloat:[[itemDict objectForKey:@"_unitsInBox"] floatValue] ];
    NSNumber *itemUnitsInBigBox = [NSNumber numberWithFloat:[[itemDict objectForKey:@"_unitsInBigBox"] floatValue] ];
    NSString *fishName = [itemDict objectForKey:@"_fishType"];
    NSLog(@"1");
    // Если какие-либо значения не верны, переходим к следующему Item
    if( [itemName isEqualToString:@""]
       || [itemID isEqualToString:@""]
       || !(itemPrice.floatValue > 0)
       || [itemUnit isEqualToString:@""]
       || !( [itemUnit isEqualToString:@"шт"] || [itemUnit isEqualToString:@"кг"] )
       || !(itemUnitsInBox.floatValue >0)
       || !(itemUnitsInBigBox.floatValue >0)
       || [fishName isEqualToString:@""] ){
        if([fishName isEqualToString:@""]){
            [errors addObject:[NSError errorWithDomain:@"ВНИМАНИЕ !!!" code:9997 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Скажите менеджеру, чтобы завел новый тип рыбы для этого товара: Имя: %@ itemID: %@",itemName,itemID] forKey:@"info"]]];
//            [errors addObject:[NSError errorWithDomain:@"errorWithParsing" code:9997 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Скажите менеджеру, чтобы завел новый тип рыбы для этого товара: Имя: %@ itemID: %@",itemName,itemID] forKey:@"info"]]];
        }
        else
            [errors addObject:[NSError errorWithDomain:@"saveParsedDictionaryIntoCoreData" code:9997
                                          userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"<item> tag contain any wrong values: itemName:%@ itemID:%@ itemPrice:%@ itemUnit:%@ itemUnitsInBox:%@ itemUnitsInBigBox:%@ fishName:%@",itemName,itemID,itemPrice,itemUnit,itemUnitsInBox,itemUnitsInBigBox,fishName] forKey:@"info"]]];
        return;
    }
    
    // Запрашиваем managedObject с name = fishName
    //NSLog(@"\nTA: %@\n1 %@ %@ %@",ta.name,custAccount,clientName,clientSale);
    Fish *fish = [Fish getFishByName:fishName withMOC:self.managedObjectContext];
    // Запрашиваем managedObject с itemID = itemID и устанавливаем значения
    //NSLog(@"\nTA: %@\n%@ %@",ta.name,addressId,addressName);
    Item *item = [Item getOrCreateItemByItemID:itemID withMOC:self.managedObjectContext];
    item.is_deleted = [NSNumber numberWithBool:NO];
    
    [fish addProductTypesObject:productType];
    item.fish = fish;
    item.productType = productType;
    item.name = itemName;
    item.price = itemPrice;
    item.unit = [NSNumber numberWithUnit:[itemUnit isEqualToString:@"кг"] ? unitKG : unitPiece ];
    item.unitsInBox = itemUnitsInBox;
    item.unitsInBigBox = itemUnitsInBigBox;
    NSString *ABCvalue = [itemDict objectForKey:@"ABCvalue"];
    if(!ABCvalue){
        item.lineColor = [NSNumber numberWithLineColor:defaultColor];
    }
    else if([ABCvalue isEqualToString:@"Empty"]){
        item.lineColor = [NSNumber numberWithLineColor:defaultColor];
    }
    else if ([ABCvalue isEqualToString:@"A"]){
        item.lineColor = [NSNumber numberWithLineColor:red];
    }
    else if ([ABCvalue isEqualToString:@"B"]){
        item.lineColor = [NSNumber numberWithLineColor:green];
    }
    else if ([ABCvalue isEqualToString:@"C"]){
        item.lineColor = [NSNumber numberWithLineColor:blue];
    }
    else{
        item.lineColor = [NSNumber numberWithLineColor:defaultColor];
    }
    item.producer = [NSString stringWithFormat:@"%@",[itemDict objectForKey:@"_company"]];
    NSString *isAction = [itemDict objectForKey:@"_isAction"];
    if(!isAction){
        item.promo = [NSNumber numberWithBool:NO];
    } else {
        item.promo = [NSNumber numberWithBool:isAction.boolValue];
    }
    NSString *itemShelfLife = [itemDict objectForKey:@"bestBefore"];
    if(itemShelfLife){
        if(itemShelfLife.intValue > 0){
            item.shelfLife = [NSNumber numberWithInt:itemShelfLife.intValue];
        }
    }
    NSString *itemComposition = [itemDict objectForKey:@"consist"];
    if(itemComposition){
        if(![itemComposition isEqualToString:@""]){
            item.composition = itemComposition;
        }
    }
    NSString *itemAnnotation = [itemDict objectForKey:@"annotation"];
    if(itemAnnotation){
        if(![itemAnnotation isEqualToString:@""]){
            item.annotation = itemAnnotation;
        }
    }
    NSString *photo_main = [itemDict objectForKey:@"photo"];
    [self addPhoto:photo_main ForItem:item];
    NSString *photo_1 = [itemDict objectForKey:@"photo1"];
    [self addPhoto:photo_1 ForItem:item];
    NSString *photo_2 = [itemDict objectForKey:@"photo2"];
    [self addPhoto:photo_2 ForItem:item];
    NSString *photo_3 = [itemDict objectForKey:@"photo3"];
    [self addPhoto:photo_3 ForItem:item];
    NSString *photo_4 = [itemDict objectForKey:@"photo4"];
    [self addPhoto:photo_4 ForItem:item];
    
    NSString *stoGramm = [itemDict objectForKey:@"stoGramm"];
    if(stoGramm){
        if ( ![stoGramm isEqualToString:@""]) {
            item.hundredGrammsContains = stoGramm;
        }
    }
    
    NSString *thesis1 = [itemDict objectForKey:@"thesis1"];
    [Thesis newThesisInManObjContext:self.managedObjectContext text:thesis1 item:item];
    NSString *thesis2 = [itemDict objectForKey:@"thesis2"];
    [Thesis newThesisInManObjContext:self.managedObjectContext text:thesis2 item:item];
    NSString *thesis3 = [itemDict objectForKey:@"thesis3"];
    [Thesis newThesisInManObjContext:self.managedObjectContext text:thesis3 item:item];
    NSString *thesis4 = [itemDict objectForKey:@"thesis4"];
    [Thesis newThesisInManObjContext:self.managedObjectContext text:thesis4 item:item];
    //NSLog(@"start of updating priceGroups-items references");
    // Заполняем "Группы ценников" и "скидки по строке". Ищем по itemID и оставляем на себя ссылку.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemID = %@",itemID];
    NSArray *array = [priceGroupLines filteredArrayUsingPredicate:predicate];
    int n = 0;
    for( PriceGroupLine *priceGroupLine in array ){
        priceGroupLine.item = item;
        n++;
        if(n == 10){
            n=0;
            [self saveManageObjectContext];
        }
    }
    array = [lineSaleLines filteredArrayUsingPredicate:predicate];
    for( LineSaleLine *lineSaleLine in array ){
        lineSaleLine.item = item;
        n++;
        if(n == 10){
            n=0;
            [self saveManageObjectContext];
        }
    }
    //NSLog(@"end of updating priceGroups-items references");
}

#pragma mark filling photo's url
-(void) addPhoto: (NSString *) photoName ForItem: (Item *) item{
    if(photoName){
        if(![photoName isEqualToString:@""]){
            for(Photo *photo in item.photos){
                if([photo.name isEqualToString:photoName])
                {
                    photo.is_deleted = NO;
                    return;
                }
            }
            Photo *photo = [Photo newPhotoInManObjContext:self.managedObjectContext];
            photo.name = photoName;
            photo.item = item;
            photo.url = [NSString stringWithFormat:@"%@%@",self.appSettings.photosFolderURL,photoName];
            photo.filepath = @"";
            photo.is_deleted = [NSNumber numberWithBool:NO];
        }
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
        [delegate_buf BVAPriceUpdater:self didStopUpdatingWithErrors:errors];
    }
}

@end
