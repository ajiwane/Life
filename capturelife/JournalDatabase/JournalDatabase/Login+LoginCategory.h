//
//  Login+LoginCategory.h
//  JournalDatabase
//
//  Created by karthik jagadeesh on 6/26/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import "Login.h"
#import "User.h"

@interface Login (LoginCategory)

+ (Login *)loginWithInfo:(NSDictionary *)loginInfo inManagedObjectContext:(NSManagedObjectContext *)context;

+ (BOOL) doesEmailExit:(NSString *)email inManangedObjectContext:(NSManagedObjectContext *)context;

+ (BOOL) checkUser:(NSDictionary *)loginInfo inManangedObjectContext:(NSManagedObjectContext *)context;
@end
