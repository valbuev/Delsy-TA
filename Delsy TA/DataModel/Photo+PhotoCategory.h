//
//  Photo+PhotoCategory.h
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "Photo.h"

@interface Photo (PhotoCategory)

// Помечает все имеющиеся в базе Photo как удаленные
+(void) setAllPhotosDeleted:(Boolean) deleted InManagedObjectContext:(NSManagedObjectContext *) managedObjectContext;

// Создает новый объект photo в managedObjectContext
+(Photo *) newPhotoInManObjContext:(NSManagedObjectContext *) managedObjectContext;

// Удаляем все фотографии: объекты контекста и сами файлы в хранилище
+ (void) removeDeletedPhotosInMOC: (NSManagedObjectContext *) context;

// возвращает все фотографии, имеющие по крайней мере url. Если shouldHaveNotFilePath = YES, то берем только те фотографии, которые не имеют пути к файлу.
+ (NSArray *) getAllPhotos:(Boolean) shouldHaveNotFilePath  MOC:(NSManagedObjectContext *) context;

@end
