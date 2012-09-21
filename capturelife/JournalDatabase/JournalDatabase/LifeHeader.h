//
//  LifeHeader.h
//  JournalDatabase
//
//  Created by karthik jagadeesh on 7/9/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>

@interface LifeHeader : NSObject 
extern NSString * const DATE_FORMAT_FOR_MEDIA_FILES;
extern NSString * const PHOTO;
extern NSString * const VIDEO;
extern NSString * const AUDIO;
extern NSString * const CHECKIN;
extern NSString * const NOTE;
extern NSString * const PHOTO_EXTENSION;
extern NSString * const VIDEO_EXTENSION;
extern NSString * const AUDIO_EXTENSION;
extern NSString * const DATE_FORMAT;
extern NSString * const MEDIA_ENTITY;
extern NSString * const NOTE_ENTITY;
extern NSString * const CHECKIN_ENTITY;
extern NSString * const DATABASE;
extern NSString * const CHECKIN_IMAGE;
extern NSString * const NOTE_IMAGE;
extern NSString * const CAMERA_IMAGE;
extern NSString * const VIDEO_IMAGE;
extern NSString * const AUDIO_IMAGE;
extern NSString * const PLAY_IMAGE;
extern NSString * const PAUSE_IMAGE;
extern NSString * const PLAY_AUDIO_IMAGE;

+ (BOOL ) stringIsEmpty:(NSString *) aString;
+ (BOOL ) stringIsEmpty:(NSString *) aString shouldCleanWhiteSpace:(BOOL)cleanWhileSpace;
+ (UIColor *) getBackgroundColor;
+ (UIColor *) getButtonBackgroundColor;
+ (UIColor *) getBorderColor;
+ (NSString *) stringFromDate:(NSDate *) date;
+(UIColor *) getMintColor;
+(UIColor *) getBarBackgroundColor;
+(UIImage *) imageFromColor:(UIColor *) color;
+(UIButton *) getButton;
+ (BOOL)connected ;
@end
