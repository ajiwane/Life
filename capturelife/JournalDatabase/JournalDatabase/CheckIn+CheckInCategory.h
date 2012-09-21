//
//  CheckIn+CheckInCategory.h
//  JournalDatabase
//
//  Created by Karthik Jagadeesh on 7/5/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import "CheckIn.h"

@interface CheckIn (CheckInCategory)

+ (CheckIn *)checkInWithInfo:(NSDictionary *)checkInInfo inManagedObjectContext:(NSManagedObjectContext *)context;

@end
