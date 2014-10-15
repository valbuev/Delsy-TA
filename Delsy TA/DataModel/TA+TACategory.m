//
//  TA+TACategory.m
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "TA+TACategory.h"

@implementation TA (TACategory)

// Ищет ТА с id = taID, если находит, то возвращает, иначе, создает новый.
+(TA *) getTAbyID:(NSString *) taID withMOC:(NSManagedObjectContext *) managedObjectContext{
    
    // Ищем ТА с id = taID, если не нашли, то создаем нового, если получаем ошибку, то возвращаем nil
    TA *ta;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TA"
                                              inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@",taID];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (array == nil){
        NSLog(@"Exception while getting TA`s array by ta-id. Error: %@",error.localizedDescription);
        ta = nil;
    }
    else{
        if( array.count == 0 ){
            ta = [[TA alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
            ta.id = taID;
            //NSLog(@"init ta id = %@",ta.id);
        }
        else{
            ta = [array objectAtIndex:0];
        }
    }
    return ta;
}

// Помечает все имеющиеся в базе ТА как удаленные
+(void) setAllTADeleted:(Boolean) deleted InManagedObjectContext:(NSManagedObjectContext *) managedObjectContext{
    
    // Получаем всех ТА
    TA *ta;
    NSArray *TAlist;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TA"
                                              inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error = nil;
    TAlist = [managedObjectContext executeFetchRequest:request error:&error];
    
    // Если нет ошибок, то проходим по списку и помечаем каждый как удаленный
    if (TAlist == nil){
        NSLog(@"Exception while getting TA`s array for set those deleted %d. Error: %@",deleted,error.localizedDescription);
        return;
    }
    else for(ta in TAlist){
        ta.is_deleted = [NSNumber numberWithBool:deleted];
    }
}

// Возвращает все ТА (и удаленные и неудаленные)
+(NSArray *)getAllTA:(NSManagedObjectContext *) context{
    NSArray *TAlist;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TA"
                                              inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    TAlist = [context executeFetchRequest:request error:&error];
    
    if (TAlist == nil){
        NSLog(@"Exception while getting TA`s array . Error: %@",error.localizedDescription);
        //return nil;
    }
    return TAlist;
}

// Возвращает все ТА (неудаленные)
+(NSArray *)getAllNonDeletedTA:(NSManagedObjectContext *) context{
    NSArray *TAlist;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TA"
                                              inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"is_deleted = %@",NO];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    TAlist = [context executeFetchRequest:request error:&error];
    
    if (TAlist == nil){
        NSLog(@"Exception while getting TA`s array . Error: %@",error.localizedDescription);
        //return nil;
    }
    return TAlist;
}

@end
