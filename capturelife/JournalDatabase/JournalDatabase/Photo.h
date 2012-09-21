//
//  Photo.h
//  JournalDatabase
//
//  Created by karthik jagadeesh on 7/22/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSData * bitmap;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDate * datewithtime;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) User *whoAdded;

@end
