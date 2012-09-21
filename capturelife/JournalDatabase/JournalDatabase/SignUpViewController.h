//
//  SignUpViewController.h
//  JournalDatabase
//
//  Created by karthik jagadeesh on 6/29/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LifeHeader.h"
#import "User+UserCategory.h"
#import "Login+LoginCategory.h"
#import <CoreData/CoreData.h>
//#import "CoreDataUIViewController.h"

@interface SignUpViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) UIManagedDocument *lifeDatabase;
@property (nonatomic, strong) User *user;
@property (strong, nonatomic) NSFetchedResultsController *fetchedLoginResultsController;
@property (strong, nonatomic) UIDatePicker *dateOfBirthPicker;
@property (strong, nonatomic) UIView *dobBox;
@property (strong, nonatomic) UITextField *firstName;
@property (strong, nonatomic) UITextField *lastName;
@property (strong, nonatomic) UITextField *email; 
@property (strong, nonatomic) UITextField *confirmEmail; 
@property (strong, nonatomic) UITextField *password; 
@property (strong, nonatomic) UITextField *confirmPassword; 
@property (strong, nonatomic) UIButton *dateOfBirthButton; 
@property (strong, nonatomic) UIButton *maleButton; 
@property (strong, nonatomic) UIButton *femaleButton;
@property (strong, nonatomic) NSDate *dob;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) UIButton *faceButton;

@end
