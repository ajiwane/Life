//
//  journalViewController.h
//  JournalDatabase
//
//  Created by karthik jagadeesh on 6/25/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "User.h"
#import "User+UserCategory.h"
#import "LifeHeader.h"
#import "Login+LoginCategory.h"

@interface journalViewController : UIViewController 

@property (strong, nonatomic) IBOutlet UITextField *loginEmail;

@property (strong, nonatomic) IBOutlet UITextField *loginPassword;

@property (strong, nonatomic) UIManagedDocument *lifeDatabase;

@property (strong, nonatomic) User *user;

@end
