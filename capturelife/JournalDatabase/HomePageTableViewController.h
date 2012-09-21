//
//  HomePageTableViewController.h
//  JournalDatabase
//
//  Created by karthik jagadeesh on 6/27/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "User.h"
#import "Media.h"
#import "Photo.h"
#import "Photo+PhotoCategory.h"
#import "CheckIn.h"
#import "Note.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface HomePageTableViewController : CoreDataTableViewController

@property (nonatomic, strong) UIManagedDocument *lifeDatabase;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSArray *dates;
@property (nonatomic, strong) NSMutableDictionary *entries;

@end
