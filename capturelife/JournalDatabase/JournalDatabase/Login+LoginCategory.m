//
//  Login+LoginCategory.m
//  JournalDatabase
//
//  Created by karthik jagadeesh on 6/26/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import "Login+LoginCategory.h"
#import "User+UserCategory.h"

@implementation Login (LoginCategory)

+ (Login *)loginWithInfo:(NSDictionary *)loginInfo inManagedObjectContext:(NSManagedObjectContext *)context
{
    Login *login = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Login"];
    request.predicate = [NSPredicate predicateWithFormat:@"email == %@", [loginInfo objectForKey:@"LOGIN_INFO_EMAIL"]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"email" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
   // NSLog(@"Matches found in Login+Category; %@ with count:%i",matches, [matches count]);
    
    if (!matches ) {
        //error
    } else if ([matches count] == 0) {
        login = [NSEntityDescription insertNewObjectForEntityForName:@"Login" inManagedObjectContext:context];
        
        login.email = (NSString *)[loginInfo objectForKey:@"LOGIN_INFO_EMAIL"];
        login.password = [loginInfo objectForKey:@"LOGIN_INFO_PASSWORD"];
         
        //********* must take user info */
        //login.user = [loginInfo objectForKey:@"LOGIN_INFO_USER"];
        //*********
        
        
        //update user info here
    } else {
        login = [matches lastObject];
    }
    
    
    NSLog(@"Login object got create %@",login);
    
    return login;
    
}

+ (BOOL) doesEmailExit:(NSString *)email inManangedObjectContext:(NSManagedObjectContext *)context
{
    BOOL ret = NO;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Login"];
    request.predicate = [NSPredicate predicateWithFormat:@"email = %@", email];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"email" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        //error
    } else if([matches count] >= 1) {
        return YES;
    } else if ([matches count] == 0) {
        return NO;
    }
    return ret;
}

+ (BOOL) checkUser:(NSDictionary *)loginInfo inManangedObjectContext:(NSManagedObjectContext *)context
{
    BOOL ret = NO;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Login"];
    request.predicate = [NSPredicate predicateWithFormat:@"email == %@ AND password == %@", [loginInfo objectForKey:@"LOGIN_INFO_EMAIL"], [loginInfo objectForKey:@"LOGIN_INFO_PASSWORD"]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"email" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    NSLog(@"matches count is %i", [matches count]);
    if (!matches) {
        //error
    } else if([matches count] >= 1) {
        return YES;
    } else if ([matches count] == 0) {
        return NO;
    }
    return ret;
}

@end
