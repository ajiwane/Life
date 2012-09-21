//
//  HomePageTableViewController.m
//  JournalDatabase
//
//  Created by karthik jagadeesh on 6/27/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import "HomePageTableViewController.h"
#define CELL_HEIGHT 180
#define HEADER_HEIGHT 30
#define SCROLL_VIEW_HEIGHT 150
#define ITEM_WIDTH 150

@implementation HomePageTableViewController

@synthesize lifeDatabase = _lifeDatabase;
@synthesize user = _user;
@synthesize entries = _entries;
@synthesize dates = _dates;

-(void)fetchFlickerDataIntoDocument:(UIManagedDocument *)document
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    NSDate *dateFromString = [[NSDate alloc] init];
    // voila!
    dateFromString = [dateFormatter dateFromString:strDate];
    //[dateFormatter release];
    
    NSString *myString = @"Test string.";
    const char *utfString = [myString UTF8String];
    NSData *myData = [NSData dataWithBytes: utfString length: strlen(utfString)];
    
    
    NSDictionary *photoInfo = [NSDictionary dictionaryWithObjectsAndKeys: myData, @"PHOTO_INFO_BITMAP", dateFromString, @"PHOTO_INFO_DATE", @"1stphoto", @"PHOTO_INFO_CAPTION", [NSDate date], @"PHOTO_INFO_DATEWITHTIME", nil];
    NSDictionary *photoInfo2 = [NSDictionary dictionaryWithObjectsAndKeys: myData, @"PHOTO_INFO_BITMAP", dateFromString, @"PHOTO_INFO_DATE", @"2ndphoto", @"PHOTO_INFO_CAPTION", [NSDate date], @"PHOTO_INFO_DATEWITHTIME", nil];
    NSDictionary *photoInfo3 = [NSDictionary dictionaryWithObjectsAndKeys: myData, @"PHOTO_INFO_BITMAP", dateFromString, @"PHOTO_INFO_DATE", @"3rdphoto", @"PHOTO_INFO_CAPTION", [NSDate date], @"PHOTO_INFO_DATEWITHTIME", nil];
    NSDictionary *photoInfo4 = [NSDictionary dictionaryWithObjectsAndKeys: myData, @"PHOTO_INFO_BITMAP", dateFromString, @"PHOTO_INFO_DATE", @"4thphoto", @"PHOTO_INFO_CAPTION", [NSDate date], @"PHOTO_INFO_DATEWITHTIME", nil];
    Photo *p = [Photo photoWithInfo:photoInfo inManagedObjectContext:document.managedObjectContext];
    p.whoAdded.id = [NSNumber numberWithInt:1];
    p = [Photo photoWithInfo:photoInfo2 inManagedObjectContext:document.managedObjectContext];
    p.whoAdded.id = [NSNumber numberWithInt:1];
    p = [Photo photoWithInfo:photoInfo3 inManagedObjectContext:document.managedObjectContext];
    p.whoAdded.id = [NSNumber numberWithInt:1];
    p = [Photo photoWithInfo:photoInfo4 inManagedObjectContext:document.managedObjectContext];
    p.whoAdded.id = [NSNumber numberWithInt:1];
    
}

-(void) setEntries:(NSDictionary *)entries
{
    if (_entries != entries) {
        _entries = entries;
    }
}


-(void)setupFetchedResultsController2
{
    
     NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Media"];
     request.predicate = [NSPredicate predicateWithFormat:@"whoAdded.id = %@", self.user.id];
    request.resultType = NSManagedObjectResultType;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"datewithtime" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];

    
    NSError *error;
    NSArray *mediaObjects = [self.lifeDatabase.managedObjectContext executeFetchRequest:request error:&error];
     NSLog(@"NUMOF Mediaobjects: %i",[mediaObjects count]);
     
}

-(void)setupFetchedResultsController
{
    // initializing the request for each table
    NSFetchRequest *requestMedia = [[NSFetchRequest alloc] init];
    NSFetchRequest *requestNote = [[NSFetchRequest alloc] init];
    NSFetchRequest *requestCheckin = [[NSFetchRequest alloc] init];

    // creating the entity description for each table
    NSEntityDescription *mediaEntity = [NSEntityDescription entityForName:@"Media" inManagedObjectContext:self.lifeDatabase.managedObjectContext];
    NSEntityDescription *noteEntity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.lifeDatabase.managedObjectContext];
    NSEntityDescription *checkInEntity = [NSEntityDescription entityForName:@"CheckIn" inManagedObjectContext:self.lifeDatabase.managedObjectContext];

    requestMedia.predicate = [NSPredicate predicateWithFormat:@"whoAdded.id = %@", self.user.id];
    requestNote.predicate = [NSPredicate predicateWithFormat:@"whoAdded.id = %@", self.user.id];
    requestCheckin.predicate = [NSPredicate predicateWithFormat:@"whoAdded.id = %@", self.user.id];
    
    // setting up the entity of request for each table
    requestMedia.entity = mediaEntity; 
    requestNote.entity = noteEntity;
    requestCheckin.entity = checkInEntity;
    
    // all requests should return distinct results
    requestMedia.returnsDistinctResults = YES;
    requestCheckin.returnsDistinctResults = YES;
    requestNote.returnsDistinctResults = YES;
    
    // all request should return an nsdictionaryresulttype
    requestMedia.resultType = NSManagedObjectResultType;
    requestNote.resultType = NSManagedObjectResultType;
    requestCheckin.resultType = NSManagedObjectResultType;
    
    // same sort descriptor will be used for all tables since they are all
    // sorted using the same attribute (datewithtime)
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"datewithtime" ascending:YES];
    
    // set sort descriptor for each request
    [requestMedia setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [requestNote setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [requestCheckin setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];

    
    // execute the request using managed object context
    NSError *error;
    NSArray *medias = [self.lifeDatabase.managedObjectContext executeFetchRequest:requestMedia error:&error];
    
    NSArray *checkins = [self.lifeDatabase.managedObjectContext executeFetchRequest:requestCheckin error:&error];
        
    NSArray *notes = [self.lifeDatabase.managedObjectContext executeFetchRequest:requestNote error:&error];
    
    
    /*
    if ([photos isKindOfClass:[NSArray class]]) {
        NSLog(@"Dates is Array");
    } else if ([photos isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Dates is dic");
    }
    */
    
    self.entries = [[NSMutableDictionary alloc] init];
    NSLog(@"count from media query %i", [medias count]);
    NSLog(@"count from checkin query %i", [checkins count]);
    NSLog(@"count from note query %i", [notes count]);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    // Take the 4 separate arrays and merge in one array
    NSMutableSet *set = [NSMutableSet setWithArray:medias];
    [set addObjectsFromArray:notes];
    [set addObjectsFromArray:checkins];
    NSArray *allEntries = [set allObjects];
    
    //NSLog(@"All entries so far: %@", allEntries);
    
    //separate out the entries based on day
    for (int i =0 ; i< [allEntries count]; i++) {
        NSString *dateString = nil;
        NSObject *ith = [allEntries objectAtIndex:i]; 
        if ([ith isKindOfClass:[Media class]]) {
            Photo *obj = (Photo *)ith;
            dateString = [dateFormatter stringFromDate:obj.date];
           // NSLog(@"This is a photo");
        } else if ([ith isKindOfClass:[Note class]]) {
            Note *obj = (Note *)ith;
            dateString = [dateFormatter stringFromDate:obj.date];
           // NSLog(@"This is a note");
        } else if ([ith isKindOfClass:[CheckIn class]]) {
            CheckIn *obj = (CheckIn *)ith;        
            dateString = [dateFormatter stringFromDate:obj.date];
           // NSLog(@"This is a checkin");
        }
        
       // NSLog(@"ith: %@", ith);
        NSMutableArray *arrayOfEntry = [self.entries objectForKey:dateString];
       // NSLog(@"%@", dateString);
        if (!arrayOfEntry) {
            arrayOfEntry = [[NSMutableArray alloc] init];
            [arrayOfEntry addObject:ith];
            [self.entries setObject:arrayOfEntry forKey:dateString];
        } else {
            [arrayOfEntry addObject:ith];
        }
    }
    
   // NSLog(@"%@", self.entries);

    self.dates = [self.entries allKeys];    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES];
    NSArray *sorters = [[NSArray alloc] initWithObjects:sorter, nil];
    self.dates = [self.dates sortedArrayUsingDescriptors:sorters];
    
    [self.tableView reloadData];
    
    //NSLog(@"Dates: %@",self.dates);
    
   // NSDate *o = [self.dates objectAtIndex:0];
    
   // NSLog(@"object should be date %a",[o description]);
    //[request release];
    //[self.tableView reloadData];
    
    
   // NSLog(@"Dates: %@",self.dates);
    /*
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.lifeDatabase.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSLog(@"fetched result: %@", self.dates);
    */
}

- (void)useDocument
{
    if(![[NSFileManager defaultManager] fileExistsAtPath:[self.lifeDatabase.fileURL path]]) {
        NSLog(@"Document is new");
        [self.lifeDatabase saveToURL:self.lifeDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [self setupFetchedResultsController];
            //[self fetchFlickerDataIntoDocument:self.lifeDatabase];
        }];
    } else if (self.lifeDatabase.documentState == UIDocumentStateClosed) {
        NSLog(@"Document is closed");
        [self.lifeDatabase openWithCompletionHandler:^(BOOL success) {
            [self setupFetchedResultsController];
        }];
    } else if (self.lifeDatabase.documentState == UIDocumentStateNormal) {
        NSLog(@"Document is open");
        [self setupFetchedResultsController];
    }
}

- (void)setLifeDatabase:(UIManagedDocument *)lifeDatabase
{
   // NSLog(@"i am in the set lifedatabase of Homepage");

    if(_lifeDatabase != lifeDatabase) {
        NSLog(@"i am in the set life database if");
        _lifeDatabase = lifeDatabase;
        [self useDocument];
    }
}

-(void) setUser:(User *)user
{
   // NSLog(@"i am in the set user");
    _user = user;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.lifeDatabase) {
        NSLog(@"Reseting PhotoDase again");
        
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Default Photo Database"];
        self.lifeDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
        //[self useDocument];
    }
    //
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.entries.allKeys count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    static NSString *CellIdentifier = @"Day Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return cell;*/
    
 /*  
    static NSString *CellIdentifier = @"Day Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    cell.textLabel.text = [dateFormatter stringFromDate:photo.date];
    
    NSLog(@"row index: %i",indexPath.row);
    
    NSArray *currencies = [NSArray arrayWithObjects:@"Dollar", @"Euro", @"Pound", @"hello", @"222", @"45gfg", nil];
    NSString *name = (NSString *)[currencies objectAtIndex:indexPath.row];
    NSLog(@"name: %@", name);
    cell.textLabel.text = name;
    
    //NSLog([dateFormatter stringFromDate:photo.date]);
    
    // Configure the cell...
    
    return cell;
*/
    
    
    //[self.tableView reloadData];
    static NSString *CellIdentifier = @"Day Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    //NSLog(@"IndexPath %@",indexPath);
   // NSLog(@"IndexPath.section %@",indexPath.section);
   // NSInteger *row = indexPath.row;
    //NSLog(@"Indexpath. row %i", row);
    
    
    //NSLog(@"INdexpath length: %@",[indexPath length]);
   // NSUInteger *rowArray = [indexPath indexAtPosition:indexPath.section];
    //NSLog(@"NSrowArray %@",rowArray);
    
    NSLog(@"NSDATES: %@",self.dates);
    
    NSString *date = [self.dates objectAtIndex:indexPath.row];
    //date = (NSDate *)[self.dates objectAtIndex:indexPath.row];
    //if ([dat isKindOfClass:[NSDictionary class]])
     //   date = [(NSDictionary *)d objectForKey:@"date"];
    NSLog(@"date in cell: %@",date);
    
    NSArray *itemsForDate = [self.entries objectForKey:date];

    cell.accessoryType = UITableViewCellAccessoryNone;
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, CELL_HEIGHT)];
    view.backgroundColor = [UIColor colorWithRed:135.0/255.0 green:206/255.0 blue:235.0/255.0 alpha:1.0];
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, HEADER_HEIGHT)];
    headerView.backgroundColor = [UIColor colorWithRed:135.0/255.0 green:206/255.0 blue:235.0/255.0 alpha:1.0];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 1, rect.size.width-2, HEADER_HEIGHT-1)];
    headerLabel.backgroundColor = [UIColor colorWithRed:135.0/255.0 green:206/255.0 blue:235.0/255.0 alpha:1.0];
    [headerLabel setTextColor:[UIColor blackColor]];
    //[headerLabel setBackgroundColor:[UIColor clearColor]];
    headerLabel.text = date;
  
    [headerView addSubview:headerLabel];
    [view   addSubview:headerView];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, rect.size.width, SCROLL_VIEW_HEIGHT)];
    scrollView.backgroundColor = [UIColor colorWithRed:192.0/255.0 green:192.0/255.0 blue:192.0/255.0 alpha:1.0];
    scrollView.contentSize = CGSizeMake(ITEM_WIDTH*[itemsForDate count],SCROLL_VIEW_HEIGHT);
    for (int i=0; i<[itemsForDate count]; i++)
    {
        //NSURL *url = [NSURL URLWithString:[itemsForDate objectAtIndex:i]];
        
        //NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIButton *buttonForItem = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        buttonForItem.frame = CGRectMake((ITEM_WIDTH+2)*i, 0, ITEM_WIDTH, SCROLL_VIEW_HEIGHT);
        
        NSObject *obj = [itemsForDate objectAtIndex:i]; 
        if ([obj isKindOfClass:[Media class]]) {
            Media *mediaObj = (Media *)obj;
            NSString *type = mediaObj.type;
            NSLog(@"MediaObj Type: %@",type);
           
            NSURL *url = [NSURL fileURLWithPath:mediaObj.source];
            
           // NSLog(@"%@", [type compare:@"video"]);
            if([type isEqualToString:@"video"]) {
                
                AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
                AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                NSError *err = NULL;
                CMTime time = CMTimeMake(1, 10);
                CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
               // NSLog(@"err==%@, imageRef==%@", err, imgRef);
                UIImage *currentImg = [[UIImage alloc] initWithCGImage:imgRef];
                [buttonForItem setBackgroundImage:currentImg forState:UIControlStateNormal];
                [buttonForItem setImage:[UIImage imageNamed:@"play.png"]  forState:UIControlStateNormal];
            } else if([type isEqualToString:@"photo"]) {
                
                NSData *imageData = [NSData dataWithContentsOfURL:url];
                [buttonForItem setBackgroundImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
                
            }
            
            NSLog(@"File URL: %@", mediaObj.source);
        } else if ([obj isKindOfClass:[Note class]]) {
            Note *noteObj = (Note *)obj;
           // UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake((ITEM_WIDTH+2)*i, 0, ITEM_WIDTH, SCROLL_VIEW_HEIGHT)];
            //headerLabel.text = noteObj.content;
            //b//uttonForItem.titleLabel.text = noteObj.content;
            
            [buttonForItem setTitle:noteObj.note forState:UIControlStateNormal];
            
            NSLog(@"Note description: %@", noteObj.note);
        } else if ([obj isKindOfClass:[CheckIn class]]) {
            CheckIn *checkInObj = (CheckIn *)obj;
            NSString *checkedIn = @"Checked in at ";
            [checkedIn stringByAppendingString:checkInObj.place];
            //buttonForItem.titleLabel.text =  checkedIn;
            [buttonForItem setTitle:checkedIn forState:UIControlStateNormal];
            
            //NSLog(@"CheckInLocation: %@", checkInObj.location);
        }
        
        
       // NSData *imageData= (NSData *)[(NSDictionary *)[itemsForDate objectAtIndex:i] objectForKey:@"bitmap"];
       // UIImage *image = [UIImage imageWithData:imageData];
       // UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
       // imageView.frame = CGRectMake(ITEM_WIDTH*i, 0, ITEM_WIDTH, SCROLL_VIEW_HEIGHT);
       // imageView.contentMode = UIViewContentModeScaleAspectFit;
        [scrollView addSubview:buttonForItem];
    }
    [view addSubview:scrollView];
    
    [cell.contentView addSubview:view];
    
    
    return cell;
    
   
    
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSDate *date = photo.date;
    if ([segue.destinationViewController respondsToSelector:@selector(setDate:)]) {
        [segue.destinationViewController setUser:self.user];
        [segue.destinationViewController setLifeDatabase:self.lifeDatabase];
        [segue.destinationViewController setDate:date];
    }
    
}

@end