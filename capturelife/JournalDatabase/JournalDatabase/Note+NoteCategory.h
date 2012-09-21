//
//  Note+NoteCategory.h
//  JournalDatabase
//
//  Created by Karthik Jagadeesh on 7/2/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import "Note.h"
#import "User+UserCategory.h"

@interface Note (NoteCategory)

+ (Note *)noteWithInfo:(NSDictionary *)noteInfo inManagedObjectContext:(NSManagedObjectContext *)context;

@end
