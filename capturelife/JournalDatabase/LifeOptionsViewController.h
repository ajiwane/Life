//
//  LifeOptionsViewController.h
//  JournalDatabase
//
//  Created by karthik jagadeesh on 6/29/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Media+MediaCategory.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>

@interface LifeOptionsViewController : UIViewController <AVAudioPlayerDelegate, AVAudioRecorderDelegate>

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) UIManagedDocument *lifeDatabase;
//@property (nonatomic, strong) AVAudioRecorder *audioRecorder; 
//@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end
