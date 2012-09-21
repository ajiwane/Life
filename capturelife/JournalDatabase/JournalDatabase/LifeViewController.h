//
//  LifeViewController.h
//  JournalDatabase
//
//  Created by Karthik Jagadeesh on 7/7/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "User.h"
#import "Media+MediaCategory.h"
#import "Photo.h"
#import "Photo+PhotoCategory.h"
#import "CheckIn.h"
#import "Note.h"
#import "Location.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "LifeHeader.h"
#import <CoreLocation/CoreLocation.h>


@interface LifeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate, CLLocationManagerDelegate> 
{
    UITableView *tableView;
    UIButton *stopButton;
    UIButton *recordButton ;
    UIButton *cacncelAudioButton;
    UIButton *playAudioButton;
    UIButton *saveAudioButton;
    UILabel *recordingLabel;
    UILabel *stopWatchLabel;
    NSMutableDictionary *recordSetting;
    NSTimer *stopWatchTimer;
	NSString *recordingPath;
	
	NSDate *startDate;
	
}

@property (nonatomic, strong) UIManagedDocument *lifeDatabase;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSArray *dates;
@property (nonatomic, strong) NSMutableDictionary *entries;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *scrollViewEntries;
@property (nonatomic, strong) NSNumber *selectedEntryNumber;
@property (nonatomic, strong) UIView *dateBox;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) NSString *entryOperation;
@property (nonatomic, strong) NSString *entryType;
@property (nonatomic, strong) NSData *entryData;
@property (nonatomic, strong) CLLocationManager *myLocationManager;
@property (nonatomic, strong) UIView *audioView;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSDate *entryDate;
@property (nonatomic, strong) NSURL *entryURL;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSString *networkAvailable;

- (NSDictionary *) audioRecordingSettings;

@end
