//
//  Order+OrderCategory.m
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "Order+OrderCategory.h"
#import "Client+ClientCategory.h"
#import "Address+AddressCategory.h"
#import "AppSettings+AppSettingsCategory.h"
#import "TA+TACategory.h"
#import "OrderLine+OrderLineCategory.h"
#import "NSNumber+NSNumberUnit.h"
#import "Item+ItemCategory.h"

@implementation Order (OrderCategory)

// Создает и возвращает новый заказ. Вписывает в заказ текущего ТА, адрес, клиента.
+(Order *) newOrder: (NSManagedObjectContext *) context forAddress:(Address *) address{
    Order *order;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Order" inManagedObjectContext:context ];
    order = [[Order alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
    
    TA* ta = [AppSettings getInstance:context].currentTA;
    Client *client = address.client;
    
    order.address = address;
    order.client = client;
    order.ta = ta;
    
    order.custAddress = address.address.copy;
    order.custName = client.name.copy;
    order.taName = ta.name.copy;
    order.date = [NSDate date];

    //order.sale = 0;//client.sale.copy;
    
    return order;
}

// Создает и возвращает NSFetchedResultsController для данного заказа
-(NSFetchedResultsController *) newOrderController{
    
    NSManagedObjectContext *context = self.managedObjectContext;
    NSFetchedResultsController *controller;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"OrderLine" inManagedObjectContext:context];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"order == %@",self];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"item.productType.name" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"item.name" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor1, sortDescriptor2, nil];
    [request setSortDescriptors:sortDescriptors];
    
    controller = [[NSFetchedResultsController alloc]
                                              initWithFetchRequest:request
                                              managedObjectContext:context
                                              sectionNameKeyPath:@"item.productType.name"
                                              cacheName:nil];
    
    return controller;
}

//Добавляет позицию в текущий заказ. Если позиция с таким продуктом уже есть, то она заменяется.
- (void) addItem:(Item *) item qty:(NSNumber *) qty unit:(Unit) unit{
    
    OrderLine *orderLine;
    for(OrderLine *orderLineIndex in self.orderLines){
        if(orderLineIndex.item == item){
            orderLine = orderLineIndex;
            break;
        }
    }
    // Если уже есть такая позиция, а количество = 0, то удаляем ее
    if( orderLine != nil && qty.floatValue == 0){
        [self.managedObjectContext deleteObject:orderLine];
        [self reCalculateAmount];
        return;
    }
    // Если такой позиции нет, и количество = 0, то выходим, ничего не делая
    else if (qty.floatValue == 0){
        return;
    }
    if( !orderLine ){
        orderLine = [OrderLine newOrderLine:self.managedObjectContext forItem:item forOrder:self];
    }
    orderLine.qty = qty;
    orderLine.unit = [NSNumber numberWithUnit:unit];
    float localQty;
    if(unit == unitBox){
        localQty = item.unitsInBox.floatValue;
    }
    else if(unit == unitBigBox){
        localQty = item.unitsInBigBox.floatValue;
    }
    else{
        localQty = 1;
    }
    
    float localPrice = [self.client getPriceByItem:item].floatValue;
    orderLine.baseUnitQty = [NSNumber numberWithFloat: localQty * qty.floatValue ];
    orderLine.price = [NSNumber numberWithFloat:localPrice];
    orderLine.amount = [NSNumber numberWithFloat:(localPrice*localQty*qty.floatValue)];
    [self reCalculateAmount];
}

// Пересчитывает сумму заказа
-(void) reCalculateAmount{
    float value = 0;
    for (OrderLine *line in self.orderLines){
        value += line.amount.floatValue;
    }
    self.amount = [NSNumber numberWithFloat:value];
    [self.managedObjectContext save:nil];
}

// Сохраняет Заказ в xml-файл и возвращает его адрес
- (NSURL *) saveOrder2XMLFile
{
    [self reCalculateAmount];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *urls = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentDirectory = [urls objectAtIndex:0];
    NSURL *filePath = [documentDirectory URLByAppendingPathComponent:@"mail.xml"];
    
    NSString *order_str = [NSString new];
    order_str = [order_str stringByAppendingString:@"<?xml version=\"1.0\" encoding=\"windows-1251\"?>"];
    
    order_str = [order_str stringByAppendingString:@"<import>"];
    
    order_str = [order_str stringByAppendingFormat:@"<clientId>%@</clientId>",self.client.cust_account];
    order_str = [order_str stringByAppendingFormat:@"<clientAddressId>%@</clientAddressId>",self.address.address_id];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy"];
    order_str = [order_str stringByAppendingFormat:@"<deliveryDate>%@</deliveryDate>",[formatter stringFromDate:self.deliveryDate]];
    
    
    order_str = [order_str stringByAppendingString:@"<orders>"];
    
    for(OrderLine *orderLine in self.orderLines)
    {
        order_str = [order_str stringByAppendingString:@"<order>"];
        
        order_str = [order_str stringByAppendingFormat:@"<itemId>%@</itemId>",orderLine.item.itemID];
        order_str = [order_str stringByAppendingFormat:@"<qty>%@</qty>",orderLine.baseUnitQty.stringValue];
        
        order_str = [order_str stringByAppendingString:@"</order>"];
    }
    
    order_str = [order_str stringByAppendingString:@"</orders>"];
    
    order_str = [order_str stringByAppendingString:@"</import>"];
    
    [order_str writeToURL:filePath atomically:YES encoding:NSWindowsCP1251StringEncoding error:nil];
    
    return filePath;
}

//Сохраняет заказ в удобочитаемом виде в строку. Возвращает эту строку.
-(NSString *) saveOrder2str
{
    [self reCalculateAmount];
    NSString *order_str = [NSString new];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"ru"]];
    [formatter setDateFormat:@"dd MMMM yyyy, hh:mm:ss"];
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    [formatter2 setLocale:[NSLocale localeWithLocaleIdentifier:@"ru"]];
    [formatter2 setDateFormat:@"dd.MM.yyyy"];
    order_str = [order_str stringByAppendingFormat:@"\n\tЗаказ на имя \"\"%@\"\", адрес:\"\"%@\"\".\nПринял торговый представитель: %@.\nДата и время принятия заказа: %@ .\nДата поставки: %@.\nСумма: %@ руб.",
                 self.custName,
                 self.custAddress,
                 self.taName,
                 [formatter stringFromDate:self.date],
                 [formatter2 stringFromDate:self.deliveryDate],
                 self.amount.stringValue];
    
    order_str = [order_str stringByAppendingString:@"\n   Заказы: \n\n"];
    
    for(OrderLine *orderLine in self.orderLines)
    {
        order_str = [order_str stringByAppendingString:@"\n"];
        order_str = [order_str stringByAppendingFormat:@"%@, ",orderLine.item.itemID];
        order_str = [order_str stringByAppendingFormat:@"%@, ",orderLine.itemName];
        order_str = [order_str stringByAppendingFormat:@"\n Количество в базовых единицах: %@ %@,",
                     orderLine.baseUnitQty.stringValue,[orderLine.item.unit unitValueToString]];
        order_str = [order_str stringByAppendingFormat:@"\n Цена: %@ руб./%@,",
                     orderLine.price.stringValue,[orderLine.item.unit unitValueToString]];
        order_str = [order_str stringByAppendingFormat:@"\n Сумма: %@ руб.",
                     orderLine.amount.stringValue];
        order_str = [order_str stringByAppendingFormat:@"\n"];
    }
    return order_str;
}

// ВОзвращает все заказы выбранного адреса, сортированные по дате (последние вверху)
+(NSArray *) getAllOrdersByAddress:(Address *) address MOC:(NSManagedObjectContext *) context {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Order" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"address == %@",address];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSArray *results = [context executeFetchRequest:request error:nil];
    return results;
}

// Возвращает новый заказ, в котором присутствуют те же позиции, за исключением отсутствующих в прайсе продуктов.
-(Order *) newOrderUsingThis{
    Order *newOrder = [Order newOrder:self.managedObjectContext forAddress:self.address];
    for(OrderLine *line in self.orderLines){
        [newOrder addItem:line.item qty:[line.qty copy] unit:[line.unit unitValue]];
    }
    [newOrder reCalculateAmount];
    return newOrder; 
}

@end
