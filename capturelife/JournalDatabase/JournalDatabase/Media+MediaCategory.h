//
//  Media+MediaCategory.h
//  JournalDatabase
//
//  Created by karthik jagadeesh on 7/6/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import "Media.h"

@interface Media (MediaCategory)

+ (Media *)mediaWithInfo:(NSDictionary *)mediaInfo inManagedObjectContext:(NSManagedObjectContext *)context;

@end
