//
//  AppSettings+AppSettingsCategory.m
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "AppSettings+AppSettingsCategory.h"

@implementation AppSettings (AppSettingsCategory)

+ (AppSettings *) getInstance:(NSManagedObjectContext *) context
{
    AppSettings *instance;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AppSettings"
                                              inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error = nil;
    NSArray *array = [context executeFetchRequest:request error:&error];
    
    if (array == nil){
        NSLog(@"Exception while getting AppSettings`s array. Error: %@",error.localizedDescription);
        instance = nil;
    }
    else{
        if( array.count == 0 ){
            instance = [[AppSettings alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
        }
        else{
            instance = [array objectAtIndex:0];
        }
    }
    
    return instance;
}

@end
