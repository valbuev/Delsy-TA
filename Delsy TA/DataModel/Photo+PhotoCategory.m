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
        photo.is_deleted = [NSNumber numberWithBool:deleted];
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

// Удаляем все фотографии: объекты контекста и сами файлы в хранилище
+ (void) removeDeletedPhotosInMOC: (NSManagedObjectContext *) context{
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"is_deleted == %d",YES];
    [request setPredicate:predicate];
    
    // получаем список всех фотографий, помеченных, как удаленные
    NSError *error;
    NSArray *photos = [context executeFetchRequest:request error:&error];
    if ( !photos ){
        NSLog(@"Error while getting Photos-array for remove them: %@", error.localizedDescription);
    }
    else{
        // формируем список путей к файлам и удаляем объекты контекста
        NSMutableArray * filePathes = [NSMutableArray array];
        for (Photo *photo in photos){
            if( ![photo.filepath isEqualToString:@""] && photo.filepath != nil )
                [filePathes addObject: [photo.filepath copy]];
            [context deleteObject:photo];
        }
        // В фоновом потоке удаляем все файлы из списка
        dispatch_queue_t queue = dispatch_queue_create("ru.bva.DelsyTA", NULL);
        dispatch_async(queue, ^{
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            for(NSString *filePath in filePathes){
                [fileManager removeItemAtPath: filePath error: &error];
                if( error ){
                    NSLog(@"Error while removeng photo-file: %@",error.localizedDescription);
                }
            }
        });
    }
}

// возвращает все фотографии, имеющие по крайней мере url. Если shouldHaveNotFilePath = YES, то берем только те фотографии, которые не имеют пути к файлу.
+ (NSArray *) getAllPhotos:(Boolean) shouldHaveNotFilePath  MOC:(NSManagedObjectContext *) context{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];

    NSPredicate *predicate;
    if(shouldHaveNotFilePath == YES)
        predicate = [NSPredicate predicateWithFormat:@" ((filepath == '') or (filepath = nil)) and ((url != '') and (url != nil))"];
    else
        predicate = [NSPredicate predicateWithFormat:@" (url != '') and (url != nil) "];
    [request setPredicate:predicate];
    [request setFetchLimit:15]; // ограничение количества скачиваемых фотографий (для теста)
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if(error){
        NSLog(@"Error while getting all photos %@",error.localizedDescription);
    }
    return array;
}








@end
