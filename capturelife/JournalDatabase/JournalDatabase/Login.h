//
//  Login.h
//  JournalDatabase
//
//  Created by karthik jagadeesh on 7/22/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Login : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) User *user;

@end
