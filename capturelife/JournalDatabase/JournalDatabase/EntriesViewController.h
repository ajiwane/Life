//
//  EntriesViewController.h
//  JournalDatabase
//
//  Created by karthik jagadeesh on 7/8/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Media.h"
#import "CheckIn.h"
#import "Note.h"
#import "Location.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Mapkit/Mapkit.h>
#import "LifeHeader.h"

@interface EntriesViewController : UIViewController <MKMapViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, AVAudioPlayerDelegate>
@property (nonatomic, strong) UIManagedDocument *lifeDatabase;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSMutableArray *scrollViewEntries;
@property (nonatomic, strong) NSNumber *selectedEntryNumber;
@property (nonatomic, strong) UIView *topBarView;
@property (nonatomic, strong) MKMapView *mapview;
@property (nonatomic, strong) CLLocation *userLocation;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSNumber *entryEditNumber;
@property (nonatomic, strong) NSObject *entryEditObject;
@property (nonatomic, strong) NSString *entryOperation;
@property (nonatomic, strong) UIButton *videoButton;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapRec;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) UIButton *currentAudioButton;

@end
