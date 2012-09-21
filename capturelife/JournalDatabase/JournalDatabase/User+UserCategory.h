//
//  User+UserCategory.h
//  JournalDatabase
//
//  Created by karthik jagadeesh on 6/25/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import "User.h"
#import "Login.h"

@interface User (UserCategory)

+ (User *)userWithInfo:(NSDictionary *)userInfo inManagedObjectContext:(NSManagedObjectContext *)context;
@end
