//
//  Media+MediaCategory.m
//  JournalDatabase
//
//  Created by karthik jagadeesh on 7/6/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import "Media+MediaCategory.h"

@implementation Media (MediaCategory)

+ (Media *)mediaWithInfo:(NSDictionary *)mediaInfo inManagedObjectContext:(NSManagedObjectContext *)context
{
    Media *media = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Media"];
    request.predicate = [NSPredicate predicateWithFormat:@"datewithtime = %@", [mediaInfo objectForKey:@"MEDIA_INFO_DATEWITHTIME"]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches) {
        //error
        media = nil;
    } else if ([matches count] == 0) {
        media = [NSEntityDescription insertNewObjectForEntityForName:@"Media" inManagedObjectContext:context];
        
        media.source = [mediaInfo objectForKey:@"MEDIA_INFO_SOURCE"];
        media.note = [mediaInfo objectForKey:@"MEDIA_INFO_NOTE"];
        media.date = [mediaInfo objectForKey:@"MEDIA_INFO_DATE"];
        //media.location = [mediaInfo objectForKey:@"MEDIA_INFO_LOCATION"];
        media.datewithtime = [mediaInfo objectForKey:@"MEDIA_INFO_DATEWITHTIME"];
        media.type = [mediaInfo objectForKey:@"MEDIA_INFO_TYPE"];
        media.whoAdded = [mediaInfo objectForKey:@"MEDIA_INFO_WHOADDED"];
        media.whichLocation = [mediaInfo objectForKey:@"MEDIA_INFO_LOCATION"];
        
        //update user info here
    } else {
        media = [matches lastObject];
    } 
    return media;
}
@end
