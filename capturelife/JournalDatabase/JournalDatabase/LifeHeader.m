//
//  LifeHeader.m
//  JournalDatabase
//
//  Created by karthik jagadeesh on 7/9/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import "LifeHeader.h"

@implementation LifeHeader

NSString * const DATE_FORMAT_FOR_MEDIA_FILES = @"MM_dd_yyyy_HH_mm_ss";
NSString * const DATE_FORMAT = @"MM-dd-yyyy";
NSString * const PHOTO = @"photo";
NSString * const VIDEO = @"video";
NSString * const AUDIO = @"audio";
NSString * const CHECKIN = @"checkin";
NSString * const NOTE = @"note";
NSString * const PHOTO_EXTENSION = @"png";
NSString * const VIDEO_EXTENSION = @"mp4";
NSString * const AUDIO_EXTENSION = @"m4a";
NSString * const MEDIA_ENTITY = @"Media";
NSString * const NOTE_ENTITY = @"Note";
NSString * const CHECKIN_ENTITY = @"CheckIn";
NSString * const DATABASE = @"LifeDatabase";
NSString * const CHECKIN_IMAGE = @"map.jpg";
NSString * const NOTE_IMAGE = @"note1.jpg";
NSString * const CAMERA_IMAGE = @"cam2.jpg";
//NSString * const VIDEO_IMAGE = @"video.jpeg";
NSString * const VIDEO_IMAGE = @"8MM.jpg";
NSString * const AUDIO_IMAGE = @"mike.jpg";
NSString * const PLAY_IMAGE = @"play.png";
NSString * const PAUSE_IMAGE = @"pause.jpg";
NSString * const PLAY_AUDIO_IMAGE = @"playButton.jpg";
//UIColor *BACKGROUND_COLOR = [UIColor colorWithRed:28.0/255.0 green:28.0/255 blue:28.0/255 alpha:0.6];

+ (NSString *) stringFromDate:(NSDate *) date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DATE_FORMAT];
    NSString * dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

+(UIImage *) imageFromColor:(UIColor *) color
{   
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+(UIButton *) getButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [LifeHeader getButtonBackgroundColor];
    UIImage *tmp = [LifeHeader imageFromColor:[UIColor blackColor]];
    [button setBackgroundImage:tmp forState:UIControlStateHighlighted];
    return button;
}

+ (BOOL)connected 
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];  
    NetworkStatus networkStatus = [reachability currentReachabilityStatus]; 
    return !(networkStatus == NotReachable);
}

+ (BOOL ) stringIsEmpty:(NSString *) aString {
    
    if ((NSNull *) aString == [NSNull null]) {
        return YES;
    }
    
    if (aString == nil) {
        return YES;
    } else if ([aString length] == 0) {
        return YES;
    } else {
        aString = [aString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([aString length] == 0) {
            return YES;
        }
    }
    
    return NO;  
}

+ (BOOL ) stringIsEmpty:(NSString *) aString shouldCleanWhiteSpace:(BOOL)cleanWhileSpace {
    
    if ((NSNull *) aString == [NSNull null]) {
        return YES;
    }
    
    if (aString == nil) {
        return YES;
    } else if ([aString length] == 0) {
        return YES;
    } 
    
    if (cleanWhileSpace) {
        aString = [aString stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([aString length] == 0) {
            return YES;
        }
    }
    
    return NO;  
}

+ (UIColor *) getButtonBackgroundColor 
{
    return [UIColor colorWithRed:28.0/255.0 green:28.0/255.0 blue:28.0/255.0 alpha:.8];
}

+ (UIColor *) getBackgroundColor {
    return [UIColor colorWithRed:28.0/255.0 green:28.0/255 blue:28.0/255 alpha:0.4];
}

+(UIColor *) getBorderColor {
    return [UIColor colorWithRed:10.0/255.0 green:10.0/255 blue:10.0/255 alpha:0.6];
}

+(UIColor *) getMintColor {
    return [UIColor colorWithRed:245.0/255.0 green:255.0/255 blue:250.0/255 alpha:0.6];
}

+(UIColor *) getBarBackgroundColor {
    return [UIColor colorWithRed:28.0/255.0 green:28.0/255 blue:28.0/255 alpha:0.8];
}



@end
