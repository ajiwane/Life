//
//  CaptureNoteViewController.h
//  JournalDatabase
//
//  Created by Karthik Jagadeesh on 7/2/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"
#import "Note+NoteCategory.h"
#import "User.h"

@interface CaptureNoteViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *note;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) UIManagedDocument *lifeDatabase;

@end
