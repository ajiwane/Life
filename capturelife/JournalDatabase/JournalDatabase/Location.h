//
//  Location.h
//  JournalDatabase
//
//  Created by karthik jagadeesh on 7/22/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CheckIn, Media, Note;

@interface Location : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *checkin;
@property (nonatomic, retain) NSSet *media;
@property (nonatomic, retain) NSSet *note;
@end

@interface Location (CoreDataGeneratedAccessors)

- (void)addCheckinObject:(CheckIn *)value;
- (void)removeCheckinObject:(CheckIn *)value;
- (void)addCheckin:(NSSet *)values;
- (void)removeCheckin:(NSSet *)values;

- (void)addMediaObject:(Media *)value;
- (void)removeMediaObject:(Media *)value;
- (void)addMedia:(NSSet *)values;
- (void)removeMedia:(NSSet *)values;

- (void)addNoteObject:(Note *)value;
- (void)removeNoteObject:(Note *)value;
- (void)addNote:(NSSet *)values;
- (void)removeNote:(NSSet *)values;

@end
