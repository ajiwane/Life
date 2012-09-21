//
//  EntriesTableViewController.m
//  JournalDatabase
//
//  Created by karthik jagadeesh on 6/27/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import "EntriesTableViewController.h"


@implementation EntriesTableViewController

@synthesize date = _date;
@synthesize user = _user;
@synthesize lifeDatabase = _lifeDatabase;

-(void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"date = %@", self.date];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"datewithtime" ascending:NO]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.lifeDatabase.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

-(void) setDate:(NSDate *)date
{
    _date = date;
    
    [self setupFetchedResultsController];
}

-(void) setUser:(User *)user
{
    _user = user;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Entry Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
   // NSLog(@"Photo: %@", photo);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    cell.textLabel.text = photo.caption;
    
    //NSLog([dateFormatter stringFromDate:photo.date]);
    
    // Configure the cell...

    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //NSDate *date = photo.date;
    if ([segue.destinationViewController respondsToSelector:@selector(setPhoto:)]) {
        [segue.destinationViewController setPhoto:photo];
        //[segue.destinationViewController setLifeDatabase:self.lifeDatabase];
        //[segue.destinationViewController setDate:date];
    }
    
}


@end
