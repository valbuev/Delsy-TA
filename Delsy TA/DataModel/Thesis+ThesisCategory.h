//
//  Thesis+ThesisCategory.h
//  Delsy TA
//
//  Created by Valeriy Buev on 19.06.14.
//  Copyright (c) 2014 bva. All rights reserved.
//

#import "Thesis.h"

@interface Thesis (ThesisCategory)

// Помечает все имеющиеся в базе Items как удаленные
+(void) removeAllThesisesFromManagedObjectContext:(NSManagedObjectContext *) managedObjectContext;

@end
