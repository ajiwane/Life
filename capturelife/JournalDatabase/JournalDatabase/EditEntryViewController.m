//
//  EditEntryViewController.m
//  JournalDatabase
//
//  Created by karthik jagadeesh on 7/10/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import "EditEntryViewController.h"

@implementation EditEntryViewController
@synthesize lifeDatabase = _lifeDatabase;
@synthesize user = _user;
@synthesize entryEditObject = _entryEditObject;
@synthesize note = _note;
@synthesize entryView = _entryView;
@synthesize doneButton = _doneButton;
@synthesize topScrollView = _topScrollView;
@synthesize entryOperation = _entryOperation;
@synthesize entryData = _entryData;
@synthesize entryType = _entryType;
@synthesize firstTimeTyping = _firstTimeTyping;
@synthesize myLocationManager = _myLocationManager;
@synthesize places = _places;
@synthesize place = _place;
@synthesize currentXMLProperty = _currentXMLProperty;
@synthesize locationScrollView = _locationScrollView;
@synthesize editEntryScrollView = _editEntryScrollView;
@synthesize locationButtonState = _locationButtonState;
@synthesize locationButton = _locationButton;
@synthesize placeSelectedIndex = _placeSelectedIndex;
@synthesize friendsButton = _friendsButton;
@synthesize entryDate = _entryDate;
@synthesize userLocation = _userLocation;
@synthesize locationChanged = _locationChanged;
@synthesize entryURL =_entryURL;
@synthesize networkAvailable = _networkAvailable;

#define BAR_HEIGHT 50
#define IMAGE_HEIGHT 80
#define IMAGE_WIDTH 80

-(void) setEntryURL:(NSURL *)entryURL
{
    _entryURL = entryURL;
}

-(void) setEntryDate:(NSDate *)entryDate
{
    _entryDate  = entryDate;
}

- (void)setLifeDatabase:(UIManagedDocument *)lifeDatabase
{
    if(_lifeDatabase != lifeDatabase) {
        _lifeDatabase = lifeDatabase;
    }
}

-(void) setEntryType:(NSString *)entryType
{
    _entryType = entryType;
}

-(void) setEntryData:(NSData *)entryData
{
    _entryData = entryData;
}

-(void) setUser:(User *)user
{
    _user = user;
}

-(void) setEntryOperation:(NSString *)entryOperation
{
    _entryOperation = entryOperation;
}

-(void) setEntryEditObject:(NSObject *)entryEditObject
{
    _entryEditObject = entryEditObject;
}



/*******
 Getting Location Lists start here
 ********/



- (void) findAddress
{
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/xml?key=AIzaSyBO2EGTRqmXh2vtd7aJcxygS6hpKj5xsUY&radius=500&sensor=false&location=%f,%f", self.userLocation.coordinate.latitude,self.userLocation.coordinate.longitude];
    NSURL *googlePlacesURL = [NSURL URLWithString:urlString];
    
    NSData *xmlData = [NSData dataWithContentsOfURL:googlePlacesURL];
    NSString *xml = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
    
    self.places = [[NSMutableArray alloc] init];
    
    [parser setDelegate:self];
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    
    [parser parse];
}

-(void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    self.currentXMLProperty = string;
}

-(void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"result"]) {
        self.place = [[NSMutableDictionary alloc] init];
    }
}

-(void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"result"]) {
        [self.places addObject:self.place];
    } else if ([elementName isEqualToString:@"name"]) {
        [self.place setValue:self.currentXMLProperty forKey:@"name"];
    } else if ([elementName isEqualToString:@"vicinity"]) {
        [self.place setValue:self.currentXMLProperty forKey:@"vicinity"];
    }
}

/*******
 Getting Location Lists end here
 ********/
- (void)useDocument
{
    NSLog(@"In EditEntryViewController USeDOcument");
    if(![[NSFileManager defaultManager] fileExistsAtPath:[self.lifeDatabase.fileURL path]]) {
        NSLog(@"Document is new");
        [self.lifeDatabase saveToURL:self.lifeDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            // [self setupFetchedResultsController];
            //[self fetchFlickerDataIntoDocument:self.lifeDatabase];
        }];
    } else if (self.lifeDatabase.documentState == UIDocumentStateClosed) {
        NSLog(@"Document is closed");
        [self.lifeDatabase openWithCompletionHandler:^(BOOL success) {
            //[self setupFetchedResultsController];
        }];
    } else if (self.lifeDatabase.documentState == UIDocumentStateNormal) {
        NSLog(@"Document is open in edit view control");
        //[self setupFetchedResultsController];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.networkAvailable = @"NO";
    
    if (!self.lifeDatabase) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:DATABASE];
        self.lifeDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    [self useDocument];
    //NSLog(@"Entry to edit: %@",self.entryEditObject);
    
    if([LifeHeader connected]) {
        self.networkAvailable = @"YES";
    }
    
}



- (void)viewDidLoad
{   
    [super viewDidLoad];
    self.networkAvailable = @"NO";
    if([LifeHeader connected]) {
        self.networkAvailable = @"YES";
    }
    
    self.view.autoresizesSubviews = YES;
    self.locationButtonState = @"CLOSE";
    self.locationChanged = @"NO";
    self.placeSelectedIndex = [[NSNumber alloc] initWithInt:0];;
    
    
    self.userLocation =nil;
    /**************
     Must aadd this in a thread
     **********/
    if(self.entryOperation == @"save") {
        NSLog(@"printing network status: %@", self.networkAvailable);
        if(self.networkAvailable == @"YES"){
            
        if ([CLLocationManager locationServicesEnabled]) {
            self.myLocationManager = [[CLLocationManager alloc] init];
            self.myLocationManager.delegate = self;
            self.myLocationManager.purpose = @"To provide functionality based on user's current location.";
            [self.myLocationManager startUpdatingLocation]; 
            self.userLocation = self.myLocationManager.location;
        } else {
           // if()
            //NSString *latitude = 
            /* Location services are not enabled. Take appropriate action: for instance, prompt the user to enable the location services */
            NSLog(@"Location services are not enabled");
            
        }
            NSLog(@"Trying to find address");
            [self findAddress];
        }
        
    } else if(self.entryOperation == @"edit") {
        //MUSt READ LOCATION FROM LOCATION TABLE FOR THE ENTRY
        // location = CLLocationCoordinate2DMake(, //CLLocationDegrees longitude)
    }
    if(self.places!=nil) {
        self.place = (NSMutableDictionary *)[self.places objectAtIndex:0];
    }
    NSLog(@"Self.place at the first time %@",self.place);
    //NSLog(@"Printing list of addresses %@", self.places);
    /**********
     End thread here
     ***********/
    
    
    self.firstTimeTyping = @"NO";
    
    NSLog(@"TYPE: %@",self.entryType);
    /***************/
    UIImage *currentImg = [UIImage imageNamed:@"paper32.jpg"];
    UIImageView* topImageView = [[UIImageView alloc] initWithImage:currentImg];
    CGRect rect1 = [[UIScreen mainScreen] bounds];
    topImageView.frame = CGRectMake(0, 0, rect1.size.width, rect1.size.height);
    [self.view addSubview:topImageView];
    /******************/
    self.navigationController.navigationBarHidden = YES;
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    self.topScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, BAR_HEIGHT, rect.size.width, rect.size.height)];
    self.topScrollView.pagingEnabled=NO;
    self.topScrollView.contentSize = CGSizeMake(rect.size.width, rect.size.height + 1);
    /**Adding TOpbarView*/
    UIView * topBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, BAR_HEIGHT)];
    topBarView.backgroundColor = [LifeHeader getBackgroundColor];
    
   
    UIButton *cancelButton = [LifeHeader getButton];
    [[cancelButton layer] setCornerRadius:4.0f];
    cancelButton.frame = CGRectMake(10, 10, 70, 30);
    [cancelButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [topBarView addSubview:cancelButton];
    
    UIButton *saveButton = [LifeHeader getButton];
    [[saveButton layer] setCornerRadius:4.0f];
    saveButton.frame = CGRectMake(rect.size.width-60, 10, 50, 30);
    [saveButton addTarget:self action:@selector(saveEntry) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    [topBarView addSubview:saveButton];
    
    [self.view addSubview:topBarView];
    
    /***********Adding DOne button**/
    self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.doneButton.showsTouchWhenHighlighted = YES;
    //[[UIView alloc] initWithFrame:CGRectMake(self.entryView.frame.size.width*0.5 - 15 + 7, BAR_HEIGHT, 15, 30)];
    self.doneButton.frame = CGRectMake(rect.size.width*0.5 - 30, BAR_HEIGHT, 60, 15);
    [self.doneButton addTarget:self action:@selector(hideKeyboard) forControlEvents:UIControlEventTouchUpInside];
    
    self.doneButton.backgroundColor = [LifeHeader getBackgroundColor];
    [[self.doneButton layer] setMasksToBounds:YES];
    [[self.doneButton layer] setCornerRadius:3.0f];
    [[self.doneButton layer] setBorderWidth:1.0f];
    [self.doneButton setFont:[UIFont fontWithName:@"ArialMT" size:10]];
    [self.doneButton.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    self.doneButton.enabled = YES;
    self.doneButton.hidden = YES;
    
    /**Adding ScrollView */
    self.editEntryScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(7, 15, rect.size.width-14, 350)];
    self.editEntryScrollView.pagingEnabled=NO;
    [[self.editEntryScrollView layer] setCornerRadius:20.0f];
    [[self.editEntryScrollView layer] setBorderWidth:8.0f];
    [self.editEntryScrollView.layer setBorderColor:[LifeHeader getBackgroundColor].CGColor];
    [self.editEntryScrollView.layer setBackgroundColor:[UIColor clearColor].CGColor];
    /**Adding EntryView*/
    
    self.entryView = [[UIView alloc] initWithFrame:CGRectMake(8, 8, rect.size.width-14-16, 100)];
    
    self.note = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.entryView.frame.size.width -IMAGE_WIDTH, IMAGE_HEIGHT+30)];
    [[self.note layer] setMasksToBounds:YES];
    [[self.note layer] setCornerRadius:12.0f];
    //[[self.note layer] setBorderWidth:4.0f];
    //[self.note.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    self.note.font = [UIFont fontWithName:@"ArialMT" size:20];
    
    
    /***Adding dateButton *************/
    UIButton *dateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dateButton.frame = CGRectMake(8, self.note.frame.size.height + 2 + 8, self.editEntryScrollView.frame.size.width -16, 40);
    [dateButton setFont:[UIFont fontWithName:@"ArialMT" size:18]];
    [[dateButton layer] setCornerRadius:12.0f];
    [[dateButton layer] setBorderWidth:2.0f];
    [[dateButton layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    [dateButton setBackgroundColor:[LifeHeader getBorderColor]];
    dateButton.showsTouchWhenHighlighted = YES;
    
    //self.entryDate = nil;
    
    /******Adding locationButton ****/
    
    self.locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.locationButton.frame = CGRectMake(8, dateButton.frame.origin.y + dateButton.frame.size.height, self.editEntryScrollView.frame.size.width -16, 40);
    [self.locationButton setFont:[UIFont fontWithName:@"ArialMT" size:18]];
    [[self.locationButton layer] setCornerRadius:12.0f];
    [[self.locationButton layer] setBorderWidth:2.0f];
    [[self.locationButton layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.locationButton setBackgroundColor:[LifeHeader getBorderColor]];
    
    if(self.networkAvailable == @"YES"){
        [self.locationButton addTarget:self action:@selector(selectLocation) forControlEvents:UIControlEventTouchUpInside];
    }
    self.locationButton.showsTouchWhenHighlighted = YES;
    NSString *entryLocation = nil;
    
    /*****Adding Friends Button ****/
    
    self.friendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.friendsButton.frame = CGRectMake(8, self.locationButton.frame.origin.y + self.locationButton.frame.size.height, self.editEntryScrollView.frame.size.width -16, 40);
    [self.friendsButton setFont:[UIFont fontWithName:@"ArialMT" size:18]];
    [[self.friendsButton layer] setCornerRadius:12.0f];
    [[self.friendsButton layer] setBorderWidth:2.0f];
    [[self.friendsButton layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.friendsButton setBackgroundColor:[LifeHeader getBorderColor]];
    [self.friendsButton addTarget:self action:@selector(selectFriends) forControlEvents:UIControlEventTouchUpInside];
    self.friendsButton.showsTouchWhenHighlighted = YES;
    //NSString *entryLocation = nil;
    NSLog(@"EntryOperation: %@", self.entryOperation);
    Location *locationFromEntry = nil;
    if (self.entryOperation == @"edit") {
    if ([self.entryEditObject isKindOfClass:[Media class]]) {
        Media *mediaObj = (Media *)self.entryEditObject;
        locationFromEntry  = mediaObj.whichLocation;
        
        //([entryFromLocation.latitude floatValue],[entryFromLocation.longitude floatValue]);
        //CGFloat *latitude = (CGFloat)[entryFromLocation.latitude floatValue];
        //CGFloat *longitude = (CGFloat)(entryFromLocation.longitude);
        
        NSString *type = mediaObj.type;
        NSURL *url = [NSURL fileURLWithPath:mediaObj.source];
        if([type isEqualToString:VIDEO]) {
            self.entryType = VIDEO;
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
            AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            NSError *err = NULL;
            CMTime time = CMTimeMake(1, 10);
            CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
            UIImage *currentImg = [[UIImage alloc] initWithCGImage:imgRef];
            UIImageView* topImageView = [[UIImageView alloc] initWithImage:currentImg];
            topImageView.frame = CGRectMake(self.entryView.frame.size.width -IMAGE_WIDTH, 0, IMAGE_WIDTH, IMAGE_HEIGHT+30);
            [[topImageView layer] setCornerRadius:20.0f];
            topImageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.entryView addSubview:topImageView];
            
        } else if([type isEqualToString:PHOTO]) {
            self.entryType = PHOTO;
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            UIImage *currentImg = [UIImage imageWithData:imageData];
            UIImageView* topImageView = [[UIImageView alloc] initWithImage:currentImg];
            topImageView.frame = CGRectMake(self.entryView.frame.size.width -IMAGE_WIDTH, 0, IMAGE_WIDTH, IMAGE_HEIGHT+30);
            [[topImageView layer] setCornerRadius:20.0f];
            topImageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.entryView addSubview:topImageView];
        } else if([type isEqualToString:AUDIO]) {
            self.entryType = AUDIO;
        }
        
        if([LifeHeader stringIsEmpty:mediaObj.note]) {
            self.note.text = @"Write about it!";
            self.note.textColor = [UIColor lightGrayColor];
            self.firstTimeTyping = @"YES";
           /* if (self.note.editable) {
                self.note.textColor = [UIColor blackColor];
                self.note.text = @"";
            }*/
        } else {
            self.note.text = mediaObj.note;
        }
        
        
        self.entryDate = mediaObj.datewithtime;
       // entryLocation = locationFromEntry.name;
    } else if ([self.entryEditObject isKindOfClass:[Note class]]) {
        Note *noteObj = (Note *)self.entryEditObject;
        self.note.frame = CGRectMake(0, 0, self.entryView.frame.size.width, IMAGE_HEIGHT+30);

        if([LifeHeader stringIsEmpty:noteObj.note]) {
            self.note.text = @"Write about it!";
            self.note.textColor = [UIColor lightGrayColor];
            self.firstTimeTyping = @"YES";
            /*if (self.note.editable) {
                self.note.textColor = [UIColor blackColor];
                self.note.text = @"";
            }*/
        } else {
            self.note.text = noteObj.note;
        }
        self.entryType = NOTE;
        self.entryDate = noteObj.datewithtime;
       // entryLocation = locationFromEntry.name;
        locationFromEntry  = noteObj.whichLocation;
        
        } else if ([self.entryEditObject isKindOfClass:[CheckIn class]]) {
        CheckIn *checkInObj = (CheckIn *)self.entryEditObject;
            self.entryType = CHECKIN;
        /************
         Must add note for checkIn
         **************/
        self.note.frame = CGRectMake(0, 0, self.entryView.frame.size.width, IMAGE_HEIGHT+30);
            if([LifeHeader stringIsEmpty:checkInObj.note]) {
                NSLog(@"Note is empty for checkin");
                self.note.text = @"Write about it!";
                self.note.textColor = [UIColor lightGrayColor];
                self.firstTimeTyping = @"YES";
                /*if (self.note.editable) {
                    self.note.textColor = [UIColor blackColor];
                    self.note.text = @"";
                }*/
            } else {
                self.note.text = checkInObj.note;
            }
            
        self.entryDate = checkInObj.datewithtime;
       // entryLocation = locationFromEntry.name;
            locationFromEntry  = checkInObj.whichLocation;
    }
        if (locationFromEntry) {   
             entryLocation = locationFromEntry.name;
            self.userLocation = [[CLLocation alloc] initWithLatitude:[locationFromEntry.latitude floatValue] longitude:[locationFromEntry.longitude floatValue]];
            if(self.networkAvailable == @"YES"){
                NSLog(@"trying to find address");
                [self findAddress];
            }
        }
    } else if (self.entryOperation == @"save") {
        if (self.entryType == VIDEO) {
            //NSData *imageData = self.entryData;
            
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.entryURL options:nil];
            AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            NSError *err = NULL;
            CMTime time = CMTimeMake(1, 10);
            CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
            UIImage *currentImg = [[UIImage alloc] initWithCGImage:imgRef];

            
            //UIImage *currentImg = [UIImage imageWithData:imageData];
            UIImageView* topImageView = [[UIImageView alloc] initWithImage:currentImg];
            topImageView.frame = CGRectMake(self.entryView.frame.size.width -IMAGE_WIDTH, 0, IMAGE_WIDTH, IMAGE_HEIGHT+30);
            [[topImageView layer] setCornerRadius:20.0f];
            topImageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.entryView addSubview:topImageView];
            
            
        } else if(self.entryType == PHOTO) {
            NSLog(@"trying to show image thumbnail without passing image");
            UIImage *currentImg = [[UIImage alloc] initWithData:self.entryData];

            UIImageView* topImageView = [[UIImageView alloc] initWithImage:currentImg];
            topImageView.frame = CGRectMake(self.entryView.frame.size.width -IMAGE_WIDTH, 0, IMAGE_WIDTH, IMAGE_HEIGHT+30);
            [[topImageView layer] setCornerRadius:20.0f];
            topImageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.entryView addSubview:topImageView];
        
        } else if (self.entryType == NOTE || self.entryType == CHECKIN || self.entryType == AUDIO) {
            self.note.frame = CGRectMake(0, 0, self.entryView.frame.size.width, IMAGE_HEIGHT+30);
        }
        self.note.text = @"Write about it!";
        self.note.textColor = [UIColor lightGrayColor];
        self.firstTimeTyping = @"YES";
        if(self.places!=nil) {
            NSDictionary *topplace = (NSDictionary *)[self.places objectAtIndex:0];
            if(topplace !=nil) {
                NSLog(@"topplace is not nil");
                entryLocation = (NSString *)[topplace objectForKey:@"name"];
                NSLog(@"EntryLocation in save: %@",entryLocation);
            }
        }
    }
    // [self.view addSubview:entryView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification object:nil];
    [self.entryView addSubview:self.note];
    
    //setting up date
    
    if(self.entryOperation == @"save") {
        if(self.entryType == AUDIO) {
        } else {
            self.entryDate = [NSDate date];
        }
    }
    NSString *dateString = @"Time: ";
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSLog(@"Printing Entry Date %@",self.entryDate);
    dateString = [dateString stringByAppendingString:[dateFormatter stringFromDate:self.entryDate]];
    dateString = [dateString stringByAppendingString:@" "];
    [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"hh:mm a" options:0 locale:[NSLocale currentLocale]]];
    dateString = [dateString stringByAppendingString:[dateFormatter stringFromDate:self.entryDate]];
    [dateButton setTitle:dateString forState:UIControlStateNormal];
    
    //setting up location
    NSLog(@"EntryLocation: %@",entryLocation);
    if ([LifeHeader stringIsEmpty:entryLocation]) {
        entryLocation = @"Add location for your moment";
    } else {
        NSString *tmp = @"At ";
        //        NSLog(@"printing tmp: %@ and entryLocation = %@",tmp,entryLocation);
        entryLocation = [tmp stringByAppendingString:entryLocation];
    }
    [self.locationButton setTitle:entryLocation forState:UIControlStateNormal];
    [self.friendsButton setTitle:@"With: " forState:UIControlStateNormal];
    
    [self.editEntryScrollView addSubview:dateButton];
    [self.editEntryScrollView addSubview:self.locationButton];
    [self.editEntryScrollView addSubview:self.friendsButton];
    
    //Adding location Scroll View
    
    //[self.locationScrollView.layer setBackgroundColor:[UIColor clearColor].CGColor];
    
    
    [self.editEntryScrollView addSubview:self.entryView];
    [self.topScrollView addSubview:self.editEntryScrollView];
    //self.topScrollView.scrollsToTop = YES;
    [self.view addSubview:self.topScrollView];
    [self.view addSubview:self.doneButton];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveEntry
{
    if (self.entryOperation == @"edit") {
        BOOL updatingEntry = [self updateEntry];
        if(updatingEntry) {
            NSLog(@"Updating New Entry with type %@",self.entryType);
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            NSLog(@"Unable to save moment");
        }
        
    } else if (self.entryOperation == @"save") {
        BOOL savingNewEntry = [self saveNewEntry];
        if(savingNewEntry) {
            NSLog(@"saving New Entry with type %@",self.entryType);
            [self performSegueWithIdentifier:@"Show Life" sender:self];
            //[self.navigationController popViewControllerAnimated:YES];
        } else {
            NSLog(@"Unable to save moment");
        }
    }
    //[self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)keyboardWillShow:(NSNotification *)notification
{
    NSLog(@"In KEYBOARDWILL SHOW");
    
    [UIView beginAnimations:@"Resize" context:nil];
    [UIView setAnimationDuration:0.4];
    if (self.firstTimeTyping == @"YES") {
        self.note.text = @"";
        self.note.textColor = [UIColor blackColor];
        self.firstTimeTyping = @"NO";
    }
    self.doneButton.hidden = NO;
    self.topScrollView.scrollEnabled = NO;
    self.note.frame = CGRectMake(0, 0, self.entryView.frame.size.width, IMAGE_HEIGHT*2);
    [UIView commitAnimations];
}

-(void)hideKeyboard
{
    [UIView beginAnimations:@"Resize" context:nil];
    [UIView setAnimationDuration:0.4];
    if(self.note.text.length == 0) {
        self.firstTimeTyping = @"YES";
        self.note.textColor = [UIColor lightGrayColor]; 
        self.note.text = @"Write about it!";
    }
    
    self.doneButton.hidden = YES;
    self.topScrollView.scrollEnabled = YES;
    if (self.entryType==PHOTO || self.entryType==VIDEO) {
        self.note.frame = CGRectMake(0, 0, self.entryView.frame.size.width - IMAGE_WIDTH, IMAGE_HEIGHT+30);
    } else {
        self.note.frame = CGRectMake(0, 0, self.entryView.frame.size.width, IMAGE_HEIGHT+30);
    }
    [self.note resignFirstResponder];
    [UIView commitAnimations];
}

-(void)selectFriends
{
    
}

-(void)placeSelected:(id)sender
{
    
    int buttonNumber = [sender tag];
    self.locationChanged = @"YES";
    self.placeSelectedIndex = [[NSNumber alloc] initWithInt:buttonNumber];
    if (self.places) {
        self.place = (NSDictionary *)[self.places objectAtIndex:buttonNumber];
    }
    NSString * tmp = @"At ";
    if(self.place !=nil) {
        //NSLog(@"topplace is not nil");
        [self.locationButton setTitle:[tmp stringByAppendingString:(NSString *)[self.place objectForKey:@"name"]] forState:UIControlStateNormal];
    } else {
        [self.locationButton setTitle:@"Location Not Available" forState:UIControlStateNormal];
    }
    /*
    [UIView beginAnimations:@"Resize" context:nil];
    [UIView setAnimationDuration:1.0];
    CGRect landFrame = self.editEntryScrollView.frame;
    landFrame.size.width = self.editEntryScrollView.frame.size.width;
    landFrame.size.height = self.editEntryScrollView.frame.size.height - self.locationScrollView.frame.size.height;
    self.editEntryScrollView.frame = landFrame;
    [self.locationScrollView removeFromSuperview];
    self.locationScrollView = nil;
    [UIView commitAnimations];
    self.locationButtonState = @"CLOSE"; */
    
}

-(void)selectLocation
{
    if(self.networkAvailable == @"YES") {
        if(self.places == nil){
            
            if ([CLLocationManager locationServicesEnabled]) {
                self.myLocationManager = [[CLLocationManager alloc] init];
                self.myLocationManager.delegate = self;
                self.myLocationManager.purpose = @"To provide functionality based on user's current location.";
                [self.myLocationManager startUpdatingLocation]; 
                self.userLocation = self.myLocationManager.location;
            } else {
                // if()
                //NSString *latitude = 
                /* Location services are not enabled. Take appropriate action: for instance, prompt the user to enable the location services */
                NSLog(@"Location services are not enabled");
                
            }
            NSLog(@"Trying to find address");
            [self findAddress];
        }
        
    if(self.locationButtonState == @"CLOSE") {
        self.locationScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(8, self.locationButton.frame.origin.y + self.locationButton.frame.size.height, self.editEntryScrollView.frame.size.width -16, 40*4)];
        self.locationScrollView.pagingEnabled=NO;
        [[self.locationScrollView layer] setCornerRadius:20.0f];
        [[self.locationScrollView layer] setBorderWidth:2.0f];
        [self.locationScrollView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    self.locationScrollView.contentSize = CGSizeMake(self.locationScrollView.frame.size.width, 40*([self.places count]));
    
    [UIView beginAnimations:@"Resize" context:nil];
    [UIView setAnimationDuration:0.4];
    CGRect landFrame = self.editEntryScrollView.frame;
    landFrame.size.width = self.editEntryScrollView.frame.size.width;
    landFrame.size.height = self.editEntryScrollView.frame.size.height + self.locationScrollView.frame.size.height;
    self.editEntryScrollView.frame = landFrame;
        
        self.friendsButton.frame = CGRectMake(8, self.locationScrollView.frame.origin.y + self.locationScrollView.frame.size.height, self.locationScrollView.frame.size.width, 40);
    
    for (int i = 0; i < [self.places count]; i++) {
        UIButton *placeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        placeButton.frame = CGRectMake(0, i*40, self.locationScrollView.frame.size.width, 40);
        [placeButton setFont:[UIFont fontWithName:@"ArialMT" size:18]];
        [placeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [[placeButton layer] setCornerRadius:12.0f];
        [[placeButton layer] setBorderWidth:2.0f];
        [[placeButton layer] setBorderColor:[UIColor lightGrayColor].CGColor];
        [placeButton setBackgroundColor:[LifeHeader getMintColor]];
        NSString *buttonString = [((NSDictionary *)[self.places objectAtIndex:i]) objectForKey:@"name"];
        [placeButton setTitle:buttonString forState:UIControlStateNormal];
        placeButton.showsTouchWhenHighlighted = YES;
        placeButton.tag = i;
        [placeButton addTarget:self action:@selector(placeSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self.locationScrollView addSubview:placeButton];
    }
    
    
    //self.editEntryScrollView.frame.size.height = self.editEntryScrollView.frame.size.height + self.locationScrollView.frame.size.height;
    [self.editEntryScrollView addSubview:self.locationScrollView];
    [UIView commitAnimations];
    self.locationButtonState = @"OPEN";    
    } else if(self.locationButtonState == @"OPEN") {
        [UIView beginAnimations:@"Resize" context:nil];
        [UIView setAnimationDuration:0.4];
        CGRect landFrame = self.editEntryScrollView.frame;
        landFrame.size.width = self.editEntryScrollView.frame.size.width;
        landFrame.size.height = self.editEntryScrollView.frame.size.height - self.locationScrollView.frame.size.height;
        self.editEntryScrollView.frame = landFrame;
        [self.locationScrollView removeFromSuperview];
        self.locationScrollView = nil;
        [UIView commitAnimations];
        self.locationButtonState = @"CLOSE";
        self.friendsButton.frame = CGRectMake(8, self.locationButton.frame.origin.y + self.locationButton.frame.size.height, self.editEntryScrollView.frame.size.width -16, 40);
    }
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @""
                              message: @"Network Unavailable"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

-(Location *)saveNewLocation
{
    Location *newLocation = nil;
    CLLocation *location = [self userLocation];
    NSString *latitude = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
   // NSLog(@"UserLocation %@", location);
    
    if(self.place) {
        NSLog(@"%@",self.place);
        NSDictionary *locationInfo = [NSDictionary dictionaryWithObjectsAndKeys:[self.place objectForKey:@"name"], @"LOCATION_INFO_NAME",[self.place objectForKey:@"vicinity"], @"LOCATION_INFO_ADDRESS",latitude, @"LOCATION_INFO_LATITUDE", longitude, @"LOCATION_INFO_LONGITUDE", nil];
        
        NSLog(@"Location Info %@",locationInfo);
        
        newLocation = [Location locationWithInfo:locationInfo inManagedObjectContext:self.lifeDatabase.managedObjectContext];
    }
    return newLocation;
}

/**
 Saving Media files in the database
 */
-(BOOL)saveNewEntry
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSDate *dateWithTime = [NSDate date];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DATE_FORMAT_FOR_MEDIA_FILES];
    NSString *dateString = [dateFormatter stringFromDate:self.entryDate];
    NSString *savedMediaPath = nil;
    savedMediaPath = [documentsDirectory stringByAppendingString:@"/"];
    savedMediaPath = [savedMediaPath stringByAppendingString:dateString];
    NSDate *date = [[NSDate alloc] init];
    NSDictionary *entryInfo = nil;
    [dateFormatter setDateFormat:DATE_FORMAT];
    NSString *strDate = [dateFormatter stringFromDate:self.entryDate];
    // voila!
    date = [dateFormatter dateFromString:strDate];
    
    Location *locationForNewEntry = nil;
    NSString *noteData = @"";
    
    if(self.note.textColor == [UIColor blackColor]) {
        noteData = self.note.text;
    }
    
    if([self.entryType isEqualToString:PHOTO]) {
        savedMediaPath = [savedMediaPath stringByAppendingPathExtension:PHOTO_EXTENSION];
        [self.entryData writeToFile:savedMediaPath atomically:NO];
        if(self.networkAvailable == @"YES"){
            locationForNewEntry = [self saveNewLocation];
        }
        NSLog(@"Saving Location New Entry %@", locationForNewEntry);
        
        entryInfo = [NSDictionary dictionaryWithObjectsAndKeys: self.entryDate, @"MEDIA_INFO_DATEWITHTIME", date, @"MEDIA_INFO_DATE", noteData, @"MEDIA_INFO_NOTE", savedMediaPath, @"MEDIA_INFO_SOURCE", PHOTO, @"MEDIA_INFO_TYPE", self.user, @"MEDIA_INFO_WHOADDED", locationForNewEntry,@"MEDIA_INFO_LOCATION" ,nil];
        
        NSLog(@"entryInfo while saving Photo %@", entryInfo);
        
    } else if([self.entryType isEqualToString:VIDEO]) {
        savedMediaPath = [savedMediaPath stringByAppendingPathExtension:VIDEO_EXTENSION];
        NSError *dataReadingError = nil;
        self.entryData = [NSData dataWithContentsOfURL:self.entryURL options:NSDataReadingMapped error:&dataReadingError];
        [self.entryData writeToFile:savedMediaPath atomically:NO];
        if(self.networkAvailable == @"YES"){
            locationForNewEntry = [self saveNewLocation];
        }
        entryInfo = [NSDictionary dictionaryWithObjectsAndKeys: self.entryDate, @"MEDIA_INFO_DATEWITHTIME", date, @"MEDIA_INFO_DATE", noteData, @"MEDIA_INFO_NOTE", savedMediaPath, @"MEDIA_INFO_SOURCE", VIDEO, @"MEDIA_INFO_TYPE", self.user, @"MEDIA_INFO_WHOADDED", locationForNewEntry,@"MEDIA_INFO_LOCATION", nil];
    } else if([self.entryType isEqualToString:AUDIO]) {
        savedMediaPath = [self.entryURL absoluteString];
       // NSLog(@"saving audio... %@",self.entryData);
        NSError *dataReadingError = nil;
        self.entryData = [NSData dataWithContentsOfURL:self.entryURL options:NSDataReadingMapped error:&dataReadingError];
        [self.entryData writeToFile:savedMediaPath atomically:NO];
        if(self.networkAvailable == @"YES"){
            locationForNewEntry = [self saveNewLocation];
        }
        entryInfo = [NSDictionary dictionaryWithObjectsAndKeys: self.entryDate, @"MEDIA_INFO_DATEWITHTIME", date, @"MEDIA_INFO_DATE", noteData, @"MEDIA_INFO_NOTE", savedMediaPath, @"MEDIA_INFO_SOURCE", AUDIO, @"MEDIA_INFO_TYPE", self.user, @"MEDIA_INFO_WHOADDED",locationForNewEntry,@"MEDIA_INFO_LOCATION", nil];
    } else if ([self.entryType isEqualToString:NOTE]) {
        if(self.networkAvailable == @"YES"){
            locationForNewEntry = [self saveNewLocation];
        }
        NSLog(@"Location Object returned after saving %@",locationForNewEntry);
        entryInfo = [NSDictionary dictionaryWithObjectsAndKeys:noteData, @"NOTE_INFO_NOTE", self.entryDate, @"NOTE_INFO_DATEWITHTIME", date, @"NOTE_INFO_DATE", self.user, @"NOTE_INFO_WHOADDED", locationForNewEntry,@"NOTE_INFO_LOCATION",nil];
        Note *note =  [Note noteWithInfo:entryInfo inManagedObjectContext:self.lifeDatabase.managedObjectContext];
        if(note) {
            //note.whichLocation = locationForNewEntry;
            return YES;
        } else {
            return NO;
        }
    } else if ([self.entryType isEqualToString:CHECKIN]) {
        if(self.networkAvailable == @"YES"){
            locationForNewEntry = [self saveNewLocation];
        }
        NSLog(@"Location Object returned after saving %@",locationForNewEntry);

        entryInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys: self.user, @"CHECKIN_INFO_WHOADDED", date, @"CHECKIN_INFO_DATE", self.entryDate, @"CHECKIN_INFO_DATEWITHTIME",noteData, @"CHECKIN_INFO_NOTE",locationForNewEntry,@"CHECKIN_INFO_LOCATION",nil];
        CheckIn *checkin = [CheckIn checkInWithInfo:entryInfo inManagedObjectContext:self.lifeDatabase.managedObjectContext];
        
        NSLog(@"Checkin object saved: %@",checkin);
        if(checkin) {
            //checkin.whichLocation = locationForNewEntry;
            return YES;
        } else {
            return NO;
        }
    }
    NSLog(@"saving with URL %@",savedMediaPath);
    NSLog(@"Location Object returned after saving %@",locationForNewEntry);
    Media *media = [Media mediaWithInfo:entryInfo inManagedObjectContext:self.lifeDatabase.managedObjectContext];
    
    if(media) {
        NSLog(@"Media Saved %@", media);
       // locationForNewEntry.media  media;
        //media.whichLocation = locationForNewEntry;
        return YES;
    }
    return NO;
    
    
}

-(BOOL)updateEntry {
    if (self.entryType == PHOTO || self.entryType == VIDEO || self.entryType == AUDIO) {
        Media *mediaObj = (Media *)[self entryEditObject];
        NSLog(@"note = %@",self.note.text);
        if(self.note.textColor == [UIColor blackColor]) {
            mediaObj.note = self.note.text;
        } else {
            mediaObj.note = nil;
        }
        if(self.locationChanged == @"YES") {
            //Location *locationForNewEntry = [self saveNewLocation];
            mediaObj.whichLocation = [self saveNewLocation];
        }//mediaObj.date = self.entryDate;
    
    } else if(self.entryType == CHECKIN) {
        CheckIn *checkinObj = (CheckIn *)[self entryEditObject];
        if(self.note.textColor == [UIColor blackColor]) {
            checkinObj.note = self.note.text;
        } else {
            checkinObj.note = nil;
        }
        if(self.locationChanged == @"YES") {
            checkinObj.whichLocation = [self saveNewLocation];
            //checkinObj.whichLocation.address = [self.place objectForKey:@"vicinity"];
        }
    } else if(self.entryType == NOTE) {
        Note *noteObj = (Note *)[self entryEditObject];
        if(self.note.textColor == [UIColor blackColor]) {
            noteObj.note = self.note.text;
        } else {
            noteObj.note = nil;
        }
        if(self.locationChanged == @"YES") {
            noteObj.whichLocation  = [self saveNewLocation];
            //noteObj.whichLocation.address = [self.place objectForKey:@"vicinity"];
        }
    } 
    return  YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Show Life"]) {
        [segue.destinationViewController setUser:self.user];
        [segue.destinationViewController setLifeDatabase:self.lifeDatabase];
    }
}

@end
