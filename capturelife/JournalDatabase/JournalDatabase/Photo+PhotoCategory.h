//
//  Photo+PhotoCategory.h
//  JournalDatabase
//
//  Created by karthik jagadeesh on 6/26/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import "Photo.h"

@interface Photo (PhotoCategory)

+ (Photo *)photoWithInfo:(NSDictionary *)photoInfo inManagedObjectContext:(NSManagedObjectContext *)context;

@end
