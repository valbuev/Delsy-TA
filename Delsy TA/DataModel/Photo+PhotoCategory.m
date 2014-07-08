//
//  Photo+PhotoCategory.m
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "Photo+PhotoCategory.h"

@implementation Photo (PhotoCategory)

// Помечает все имеющиеся в базе Photo как удаленные
+(void) setAllPhotosDeleted:(Boolean) deleted InManagedObjectContext:(NSManagedObjectContext *) managedObjectContext{
    
    // Получаем все Photos
    Photo *photo;
    NSArray *photoList;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo"
                                              inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSError *error = nil;
    photoList = [managedObjectContext executeFetchRequest:request error:&error];
    
    // Если нет ошибок, то проходим по списку и помечаем каждый как удаленный
    int n=0;
    if (photoList == nil){
        NSLog(@"Exception while getting Photos array for mark those as deleted %d. Error: %@",deleted,error.localizedDescription);
        return;
    }
    else for(photo in photoList){
        photo.deleted = [NSNumber numberWithBool:deleted];
        n++;
        if(n==20){
            if(![managedObjectContext save:&error]){
                NSLog(@"Exception while setting Photo`s array deleted %d. Error: %@",deleted,error.localizedDescription);
            }
            n=0;
        }
    }
}

// Создает новый объект photo в managedObjectContext
+(Photo *) newPhotoInManObjContext:(NSManagedObjectContext *) managedObjectContext{
    
    Photo *photo;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo"
                                              inManagedObjectContext:managedObjectContext];
    photo = [[Photo alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
    return photo;
}

@end
