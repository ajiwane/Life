//
//  User+UserCategory.m
//  JournalDatabase
//
//  Created by karthik jagadeesh on 6/25/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import "User+UserCategory.h"

@implementation User (UserCategory)

+ (User *)userWithInfo:(NSDictionary *)userInfo inManagedObjectContext:(NSManagedObjectContext *)context 
{
    User *user = nil; 
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    Login * tmpLogin = (Login *)[userInfo objectForKey:@"USER_INFO_LOGIN"];
    request.predicate = [NSPredicate predicateWithFormat:@"login.email = %@", tmpLogin.email];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        //error
    } else if ([matches count] == 0) {
        //update user info here
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
        user.id = [userInfo objectForKey:@"USER_INFO_ID"];
        user.firstName = [userInfo objectForKey:@"USER_INFO_FIRSTNAME"];
        user.lastName = [userInfo objectForKey:@"USER_INFO_LASTNAME"];
        user.age = [userInfo objectForKey:@"USER_INFO_AGE"];
        user.gender = [userInfo objectForKey:@"USER_INFO_GENDER"];
        user.dob = [userInfo objectForKey:@"USER_INFO_DOB"];
        user.login = [userInfo objectForKey:@"USER_INFO_LOGIN"];
    } else {
        user = [matches lastObject];
    }
    return user;
}

@end
