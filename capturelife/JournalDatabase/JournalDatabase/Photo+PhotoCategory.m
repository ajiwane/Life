//
//  Photo+PhotoCategory.m
//  JournalDatabase
//
//  Created by karthik jagadeesh on 6/26/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import "Photo+PhotoCategory.h"

@implementation Photo (PhotoCategory)

+ (Photo *)photoWithInfo:(NSDictionary *)photoInfo inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"date = %@", [photoInfo objectForKey:@"PHOTO_INFO_DATEWITHTIME"]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        //error
    } else if ([matches count] == 0) {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.bitmap = [photoInfo objectForKey:@"PHOTO_INFO_BITMAP"];
        photo.caption = [photoInfo objectForKey:@"PHOTO_INFO_CAPTION"];
        photo.date = [photoInfo objectForKey:@"PHOTO_INFO_DATE"];
        photo.location = [photoInfo objectForKey:@"PHOTO_INFO_LOCATION"];
        photo.datewithtime = [photoInfo objectForKey:@"PHOTO_INFO_DATEWITHTIME"];
        photo.whoAdded = [photoInfo objectForKey:@"PHOTO_INFO_WHOADDED"];
        
        
        //********* must take user info */
        //photo.whoAdded = [User userWithInfo:[photoInfo objectForKey:PHOTO_USER_INFO] inManagedObjectContext:context];
        //*********
        
        
        //update user info here
    } else {
        photo = [matches lastObject];
    } 
    return photo;

}

@end
