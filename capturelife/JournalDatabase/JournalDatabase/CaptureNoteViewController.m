//
//  CaptureNoteViewController.m
//  JournalDatabase
//
//  Created by Karthik Jagadeesh on 7/2/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import "CaptureNoteViewController.h"
#import <QuartzCore/QuartzCore.h>
@implementation CaptureNoteViewController
@synthesize note = _note;
@synthesize user = _user;
@synthesize lifeDatabase = _lifeDatabase;

- (void)setUser:(User *)user 
{
    _user = user;
}

- (IBAction)captureNote:(id)sender {
    NSString * content = self.note.text;
    NSDate * todaysDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString * justDate = [dateFormatter stringFromDate:todaysDate];
    NSDate * date = [dateFormatter dateFromString:justDate];
    
    NSDictionary *noteInfo = [NSDictionary dictionaryWithObjectsAndKeys:content, @"NOTE_INFO_CONTENT", todaysDate, @"NOTE_INFO_DATEWITHTIME", date, @"NOTE_INFO_DATE", self.user, @"NOTE_INFO_USER", nil];
    [Note noteWithInfo:noteInfo inManagedObjectContext:self.lifeDatabase.managedObjectContext];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) setLifeDatabase:(UIManagedDocument *)lifeDatabase
{
    _lifeDatabase = lifeDatabase;
}

-(void) viewDidLoad {
    [super viewDidLoad];
    UIImage *currentImg = [UIImage imageNamed:@"desk.jpg"];
    UIImageView* topImageView = [[UIImageView alloc] initWithImage:currentImg];
    CGRect rect = [[UIScreen mainScreen] bounds];
    topImageView.frame = CGRectMake(0, 200, rect.size.width, rect.size.height*0.6);
    //[self.view addSubview:topImageView];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(100, 250, 100, 100);
    backButton.backgroundColor = [UIColor colorWithRed:28.0/255.0 green:28.0/255 blue:28.0/255 alpha:0.6];
    [[backButton layer] setCornerRadius:8.0f];
    [[backButton layer] setBorderWidth:4.0f];
    UIColor *borderColor = [UIColor colorWithRed:10.0/255.0 green:10.0/255 blue:10.0/255 alpha:0.6];
    [backButton.layer setBorderColor:borderColor.CGColor];
    [self.view addSubview:backButton];
    
   // UIView *test = [[UIView alloc] initWithFrame:CGRectMake(100, 500, 150, 80)];
    //test.layer.cornerRadius = 0.8;
   // [self.view addSubview:test];
}

- (void)viewDidUnload {
    [self setNote:nil];
    [self setNote:nil];
    [super viewDidUnload];
}
@end
