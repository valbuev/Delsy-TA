//
//  Thesis+ThesisCategory.m
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "Thesis+ThesisCategory.h"

@implementation Thesis (ThesisCategory)

// Помечает все имеющиеся в базе Items как удаленные
+(void) removeAllThesisesFromManagedObjectContext:(NSManagedObjectContext *) managedObjectContext{
    
    // Получаем все Thesises
    Thesis *thesis;
    NSArray *ThesisList;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Thesis"
                                              inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error = nil;
    ThesisList = [managedObjectContext executeFetchRequest:request error:&error];
    
    // Если нет ошибок, то проходим по списку и удаляем каждый
    if (ThesisList == nil){
        NSLog(@"Exception while getting Thesises array for delete them. Error: %@",error.localizedDescription);
        return;
    }
    else for(thesis in ThesisList){
        [managedObjectContext deleteObject:thesis];
    }
}

// Создает новый объект thesis в managedObjectContext, привязывает его к item
+(Thesis *) newThesisInManObjContext:(NSManagedObjectContext *) managedObjectContext text:(NSString *) text item:(Item *)item{
    
    if(!text)
        return nil;
    if([text isEqualToString:@""])
        return nil;
    
    Thesis *thesis;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Thesis"
                                              inManagedObjectContext:managedObjectContext];
    thesis = [[Thesis alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
    
    thesis.title = text;
    thesis.item = item;
    
    return thesis;
}

@end
