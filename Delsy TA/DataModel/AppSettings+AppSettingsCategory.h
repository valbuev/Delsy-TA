//
//  AppSettings+AppSettingsCategory.h
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "AppSettings.h"

@interface AppSettings (AppSettingsCategory)

+ (AppSettings *) getInstance:(NSManagedObjectContext *) context;

@end
