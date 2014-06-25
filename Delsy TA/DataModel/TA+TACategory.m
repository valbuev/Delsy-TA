//
//  TA+TACategory.m
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "TA+TACategory.h"

@implementation TA (TACategory)

+(TA *) getTAbyID:(NSString *) taID withMOC:(NSManagedObjectContext *) managedObjectContext{
    
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
        }
        else{
            ta = [array objectAtIndex:0];
        }
    }
    return ta;
}

+(void) setAllTADeleted:(Boolean) deleted InManagedObjectContext:(NSManagedObjectContext *) managedObjectContext{
    TA *ta;
    NSArray *TAlist;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TA"
                                              inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error = nil;
    TAlist = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (TAlist == nil){
        NSLog(@"Exception while getting TA`s array for set those deleted %d. Error: %@",deleted,error.localizedDescription);
        return;
    }
    else for(ta in TAlist){
        ta.deleted = [NSNumber numberWithBool:deleted];
    }
}

@end
