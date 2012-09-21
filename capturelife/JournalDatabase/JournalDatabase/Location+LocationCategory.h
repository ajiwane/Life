//
//  Location+LocationCategory.h
//  JournalDatabase
//
//  Created by karthik jagadeesh on 7/15/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import "Location.h"

@interface Location (LocationCategory)

+ (Location *)locationWithInfo:(NSDictionary *)locationInfo inManagedObjectContext:(NSManagedObjectContext *)context;

@end
