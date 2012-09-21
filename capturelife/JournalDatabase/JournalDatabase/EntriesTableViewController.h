//
//  EntriesTableViewController.h
//  JournalDatabase
//
//  Created by karthik jagadeesh on 6/27/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "User.h"
#import "Photo.h"

@interface EntriesTableViewController : CoreDataTableViewController

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) UIManagedDocument *lifeDatabase;

@end
