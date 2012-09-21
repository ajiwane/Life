//
//  User.h
//  JournalDatabase
//
//  Created by karthik jagadeesh on 7/22/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CheckIn, Login, Media, Note, Photo, Status;

@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSDate * dob;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSSet *checkin;
@property (nonatomic, retain) Login *login;
@property (nonatomic, retain) NSSet *media;
@property (nonatomic, retain) NSSet *note;
@property (nonatomic, retain) NSSet *photo;
@property (nonatomic, retain) NSSet *status;
@end

@interface User (CoreDataGeneratedAccessors)

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

- (void)addPhotoObject:(Photo *)value;
- (void)removePhotoObject:(Photo *)value;
- (void)addPhoto:(NSSet *)values;
- (void)removePhoto:(NSSet *)values;

- (void)addStatusObject:(Status *)value;
- (void)removeStatusObject:(Status *)value;
- (void)addStatus:(NSSet *)values;
- (void)removeStatus:(NSSet *)values;

@end
