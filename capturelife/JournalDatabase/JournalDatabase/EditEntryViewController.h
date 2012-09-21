//
//  EditEntryViewController.h
//  JournalDatabase
//
//  Created by karthik jagadeesh on 7/10/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "LifeHeader.h"
#import "Media+MediaCategory.h"
#import "Note+NoteCategory.h"
#import "CheckIn+CheckInCategory.h"
#import "Location+LocationCategory.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreLocation/CoreLocation.h>

@interface EditEntryViewController : UIViewController <CLLocationManagerDelegate, NSXMLParserDelegate>
@property (nonatomic, strong) UIManagedDocument *lifeDatabase;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSObject *entryEditObject;
@property (nonatomic, strong) UITextView *note;
@property (nonatomic, strong) UIView *entryView;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UIScrollView *topScrollView;
@property (nonatomic, strong) NSString *entryOperation;
@property (nonatomic, strong) NSData *entryData;
@property (nonatomic, strong) NSString *entryType;
@property (nonatomic, strong) NSString *firstTimeTyping;
@property (nonatomic, strong) CLLocationManager *myLocationManager;
@property (nonatomic, strong) CLLocation *userLocation;
@property (nonatomic, strong) NSMutableArray *places;
@property (nonatomic, strong) NSMutableDictionary *place;
@property (nonatomic, strong) NSString *currentXMLProperty;
@property (nonatomic, strong) UIScrollView *locationScrollView;
@property (nonatomic, strong) UIScrollView *editEntryScrollView;
@property (nonatomic, strong) NSString *locationButtonState;
@property (nonatomic, strong) UIButton *locationButton;
@property (nonatomic, strong) UIButton *friendsButton;
@property (nonatomic, strong) NSNumber *placeSelectedIndex;
@property (nonatomic, strong) NSDate *entryDate;
@property (nonatomic, strong) NSString *locationChanged;
@property (nonatomic, strong) NSURL *entryURL;
@property (nonatomic, strong) NSString *networkAvailable;

-(BOOL)saveNewEntry;
-(BOOL)updateEntry;
@end
