//
//  Location+LocationCategory.m
//  JournalDatabase
//
//  Created by karthik jagadeesh on 7/15/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import "Location+LocationCategory.h"

@implementation Location (LocationCategory)

+ (Location *)locationWithInfo:(NSDictionary *)locationInfo inManagedObjectContext:(NSManagedObjectContext *)context
{
    Location *location = nil;
    
   // NSLog(@"Location Info: %@",locationInfo);
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    request.predicate = [NSPredicate predicateWithFormat:@"latitude = %@ AND longitude = %@ AND name = %@ AND address = %@", [locationInfo objectForKey:@"LOCATION_INFO_LATITUDE"], [locationInfo objectForKey:@"LOCATION_INFO_LONGITUDE"], [locationInfo objectForKey:@"LOCATION_INFO_NAME"], [locationInfo objectForKey:@"LOCATION_INFO_ADDRESS"]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
   // NSLog(@"matches in Location %@",matches);
    
    if (!matches) {
        return  nil;
        //error
    } else if ([matches count] == 0){
        NSLog(@"Saving Location matches count is 0");
        location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:context];
        location.name = [locationInfo objectForKey:@"LOCATION_INFO_NAME"];
        location.address = [locationInfo objectForKey:@"LOCATION_INFO_ADDRESS"];
        location.latitude = [locationInfo objectForKey:@"LOCATION_INFO_LATITUDE"];
        location.longitude = [locationInfo objectForKey:@"LOCATION_INFO_LONGITUDE"];
        
        //********* must take user info */
        //photo.whoAdded = [User userWithInfo:[photoInfo objectForKey:PHOTO_USER_INFO] inManagedObjectContext:context];
        //*********
    } else {
        location = [matches lastObject];
    }
    return location;
    
}


@end
