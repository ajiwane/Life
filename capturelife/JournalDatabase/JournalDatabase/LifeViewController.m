//
//  LifeViewController.m
//  JournalDatabase
//
//  Created by Karthik Jagadeesh on 7/7/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import "LifeViewController.h"

#define BUTTON_DIM 45
#define BAR_HEIGHT 50

#define CELL_HEIGHT 120
#define HEADER_HEIGHT 20
#define SCROLL_VIEW_HEIGHT 100
#define ITEM_WIDTH 101

@implementation LifeViewController

@synthesize lifeDatabase = _lifeDatabase;
@synthesize user = _user;
@synthesize entries = _entries;
@synthesize dates = _dates;
@synthesize tableView = _tableView;
@synthesize scrollViewEntries = _scrollViewEntries;
@synthesize selectedEntryNumber = _selectedEntryNumber;
@synthesize dateBox = _dateBox;
@synthesize datePicker = _datePicker;
@synthesize entryOperation = _entryOperation;
@synthesize entryType = _entryType;
@synthesize entryData = _entryData;
@synthesize entryDate = _entryDate;
@synthesize myLocationManager = _myLocationManager;
@synthesize audioView = _audioView;
@synthesize recorder = _recorder;
@synthesize entryURL = _entryURL;
@synthesize audioPlayer = _audioPlayer;
@synthesize networkAvailable = _networkAvailable;

-(void) setEntryDate:(NSDate *)entryDate
{
    if (_entryDate !=   entryDate) {
        _entryDate = entryDate;
    }

}


-(NSString *)getFilePath
{
    
}

/**
 Saving Media files in the database
 */
-(BOOL)saveMedia:(NSData *)mediaData withType:(NSString *)type
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSDate *dateWithTime = [NSDate date];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DATE_FORMAT_FOR_MEDIA_FILES];
    NSString *dateString = [dateFormatter stringFromDate:dateWithTime];
    NSString *savedMediaPath = nil;
    savedMediaPath = [documentsDirectory stringByAppendingString:@"/"];
    savedMediaPath = [savedMediaPath stringByAppendingString:dateString];
    NSDate *date = [[NSDate alloc] init];
    NSDictionary *mediaInfo = nil;
    
    if([type isEqualToString:PHOTO]) {
        savedMediaPath = [savedMediaPath stringByAppendingPathExtension:PHOTO_EXTENSION];
        [mediaData writeToFile:savedMediaPath atomically:NO];
        [dateFormatter setDateFormat:DATE_FORMAT];
        NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
        // voila!
        date = [dateFormatter dateFromString:strDate];
        
        mediaInfo = [NSDictionary dictionaryWithObjectsAndKeys: dateWithTime, @"MEDIA_INFO_DATEWITHTIME", date, @"MEDIA_INFO_DATE", @"1stphoto", @"MEDIA_INFO_SUMMARY", savedMediaPath, @"MEDIA_INFO_SOURCE", @"photo", @"MEDIA_INFO_TYPE", self.user, @"MEDIA_INFO_WHOADDED", nil];
    } else if([type isEqualToString:VIDEO]) {
        savedMediaPath = [savedMediaPath stringByAppendingPathExtension:VIDEO_EXTENSION];
        [mediaData writeToFile:savedMediaPath atomically:NO];
        [dateFormatter setDateFormat:DATE_FORMAT];
        NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
        
        // voila!
        date = [dateFormatter dateFromString:strDate];
        
        mediaInfo = [NSDictionary dictionaryWithObjectsAndKeys: dateWithTime, @"MEDIA_INFO_DATEWITHTIME", date, @"MEDIA_INFO_DATE", @"1stphoto", @"MEDIA_INFO_SUMMARY", savedMediaPath, @"MEDIA_INFO_SOURCE", @"video", @"MEDIA_INFO_TYPE", self.user, @"MEDIA_INFO_WHOADDED", nil];
    } else if([type isEqualToString:AUDIO]) {
        savedMediaPath = [savedMediaPath stringByAppendingPathExtension:AUDIO_EXTENSION];
        [mediaData writeToFile:savedMediaPath atomically:NO];
        [dateFormatter setDateFormat:DATE_FORMAT];
        NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
        
        // voila!
        date = [dateFormatter dateFromString:strDate];
        
        mediaInfo = [NSDictionary dictionaryWithObjectsAndKeys: dateWithTime, @"MEDIA_INFO_DATEWITHTIME", date, @"MEDIA_INFO_DATE", @"1stphoto", @"MEDIA_INFO_SUMMARY", savedMediaPath, @"MEDIA_INFO_SOURCE", @"audio", @"MEDIA_INFO_TYPE", self.user, @"MEDIA_INFO_WHOADDED", nil];
    }
    NSLog(@"saving with URL %@",savedMediaPath);
    Media *media = [Media mediaWithInfo:mediaInfo inManagedObjectContext:self.lifeDatabase.managedObjectContext];
    
    if(media) {
        return YES;
    }
    return NO;
}

/** Takes photo from camera
 */
- (void)capturePhoto 
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        
        if([mediaTypes containsObject:(NSString *)kUTTypeImage]){
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = (id)self;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
            picker.allowsEditing = YES;
            [self presentModalViewController:picker animated:YES];
        }
    }
}

/**Capture Video from camera*/
- (void)recordVideo 
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        if([mediaTypes containsObject:(NSString *)kUTTypeMovie]){
            NSLog(@"Camera is availble");
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = (id)self;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
            picker.allowsEditing = YES;
            [self presentModalViewController:picker animated:YES];
        } else {
            NSLog(@"Camera is not available");
        }
    }
}

-(BOOL) startRecording
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    self.audioView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    self.audioView.backgroundColor = [LifeHeader getBorderColor];
    [self.view addSubview:self.audioView];
    
    recordButton = [LifeHeader getButton];
    recordButton.frame = CGRectMake( 140, rect.size.height - 150, 70, 50);
    [[recordButton layer] setMasksToBounds:YES];
    [[recordButton layer] setCornerRadius:8.0f];
    [recordButton setTitle:@"Record" forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(captureAudio) forControlEvents:UIControlEventTouchUpInside];

    
    stopButton = [LifeHeader getButton];
    stopButton.frame = CGRectMake( 220, rect.size.height - 150, 50, 50);
    [[stopButton layer] setMasksToBounds:YES];
    [[stopButton layer] setCornerRadius:8.0f];
    [stopButton setTitle:@"Stop" forState:UIControlStateNormal];
    [stopButton addTarget:self action:@selector(stopCapturingAudio) forControlEvents:UIControlEventTouchUpInside];
    stopButton.enabled = NO;
    
    cacncelAudioButton = [LifeHeader getButton];
    cacncelAudioButton.frame = CGRectMake( 60, rect.size.height - 150, 70, 50);
    [[cacncelAudioButton layer] setMasksToBounds:YES];
    [[cacncelAudioButton layer] setCornerRadius:8.0f];
    [cacncelAudioButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cacncelAudioButton addTarget:self action:@selector(cancelAudio) forControlEvents:UIControlEventTouchUpInside];
    
    playAudioButton = [LifeHeader getButton];
    playAudioButton.frame = CGRectMake( 90, rect.size.height - 250, 70, 50);
    [[playAudioButton layer] setMasksToBounds:YES];
    [[playAudioButton layer] setCornerRadius:8.0f];
    [playAudioButton setTitle:@"Play" forState:UIControlStateNormal];
    [playAudioButton addTarget:self action:@selector(playAudio) forControlEvents:UIControlEventTouchUpInside];
    playAudioButton.hidden = YES;
    
    saveAudioButton = [LifeHeader getButton];
    saveAudioButton.frame = CGRectMake( 160, rect.size.height - 250, 70, 50);
    [[saveAudioButton layer] setMasksToBounds:YES];
    [[saveAudioButton layer] setCornerRadius:8.0f];
    [saveAudioButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveAudioButton addTarget:self action:@selector(saveAudio) forControlEvents:UIControlEventTouchUpInside];
    saveAudioButton.hidden = YES;
    
    [self.audioView addSubview:saveAudioButton];
    [self.audioView addSubview:playAudioButton];
    [self.audioView addSubview:cacncelAudioButton];
    [self.audioView addSubview:recordButton];
    [self.audioView addSubview:stopButton];
    
    recordingLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, rect.size.width - 50, 80)];
    stopWatchLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, rect.size.width - 50, 80)];
    recordingLabel.backgroundColor = [UIColor clearColor];
    stopWatchLabel.backgroundColor = [UIColor clearColor];
    recordingLabel.textColor = [UIColor whiteColor];
    stopWatchLabel.textColor = [UIColor whiteColor];
    recordingLabel.textAlignment = UITextAlignmentCenter;
    stopWatchLabel.textAlignment = UITextAlignmentCenter;
    recordingLabel.font = [UIFont systemFontOfSize:30];
    stopWatchLabel.font = [UIFont systemFontOfSize:30];
    
    recordingLabel.text = @"Recording...";
    recordingLabel.hidden = YES;
    [self.audioView addSubview:recordingLabel];
    [self.audioView addSubview:stopWatchLabel];
   
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSDate *entryDate = [NSDate date];
    self.entryDate = entryDate;
    self.entryType = AUDIO;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DATE_FORMAT_FOR_MEDIA_FILES];
    NSString *dateString = [dateFormatter stringFromDate:entryDate];
    recordingPath = [documentsDirectory stringByAppendingString:@"/"];
    recordingPath = [recordingPath stringByAppendingString:dateString];
    recordingPath = [recordingPath stringByAppendingString:@".caf"];
    NSError	*error = nil;
    self.entryURL  = [NSURL fileURLWithPath:recordingPath];
    
	return YES;
}


- (NSDictionary *) audioRecordingSettings{
    NSDictionary *result = nil;
    /* kAudioFileInvalidFileError Let's prepare the audio recorder options in the dictionary. Later we will use this dictionary to instantiate an audio recorder of type AVAudioRecorder */
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
   // [settings setValue:[NSNumber numberWithInteger:kAudioFormatAppleLossless] forKey:AVFormatIDKey];
    [settings setValue:[NSNumber numberWithFloat:44100.0f] forKey:AVSampleRateKey];
    [settings setValue:[NSNumber numberWithInteger:2] forKey:AVNumberOfChannelsKey];
    [settings setValue:[NSNumber numberWithInteger:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    result = [NSDictionary dictionaryWithDictionary:settings]; 
    return result;
}

-(void)playAudio
{
    NSLog(@"Playaudio button pressed");
    NSError *audioPlayerError = nil;
    NSError *audioSessionError = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance]; 
    if ([audioSession setCategory:AVAudioSessionCategoryAmbient error:&audioSessionError]){
        NSLog(@"Successfully set the audio session.");
    } else {
        NSLog(@"Could not set the audio session");
    }
   // NSData *fileData = [NSData dataWithContentsOfURL:self.entryURL];
  //  NSURL *fileURL = [NSURL fileURLWithPath:recordingPath];

    NSLog(@"printing url.. %@",self.entryURL);
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.entryURL error:&audioPlayerError];
    if (self.audioPlayer != nil){
        self.audioPlayer.delegate = self;
       // [self.audioPlayer play];
        if ([self.audioPlayer prepareToPlay] ){
            [self.audioPlayer play];
            recordButton.enabled = NO;
            saveAudioButton.enabled = NO;
            
            NSLog(@"Successfully started playing.");
        } else {
            NSLog(@"Failed to play the audio file.");
            self.audioPlayer = nil;
        }
    } else { 
        NSLog(@"Could not instantiate the audio player with error %@.", audioPlayerError);
    }
    
}

-(void)saveAudio
{
    NSLog(@"saving audio");
    if ([self.audioPlayer isPlaying]){ 
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    } 
    //self.entryData = [NSData dataWithContentsOfURL:self.entryURL];
    [self performSegueWithIdentifier:@"Show Edit Entry" sender:self];
}

-(void)cancelAudio
{
    if(self.recorder.recording) {
        [self.recorder stop];
    }
    if ([self.audioPlayer isPlaying]){ 
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    } 
    [stopWatchTimer invalidate];
    stopWatchTimer = nil;
    [self.audioView removeFromSuperview];
}

-(void)captureAudio
{
    NSError *error = nil;
    self.recorder = [[AVAudioRecorder alloc] initWithURL:self.entryURL settings:[self audioRecordingSettings] error:&error];

    if (self.recorder != nil){
        self.recorder.delegate = self; /* Prepare the recorder and then start the recording */
        if ([self.recorder prepareToRecord]){
            if([self.recorder record]) {
            NSLog(@"Successfully started to record.");
            stopButton.enabled = YES;
            startDate = [NSDate date];
                recordingLabel.hidden = NO;
                recordButton.enabled = NO;
                // Create the stop watch timer that fires every 10 ms
            stopWatchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/10.0
                                                                  target:self
                                                                selector:@selector(updateTimer)
                                                                userInfo:nil
                                                                 repeats:YES];    
                
                
            /* After 5 seconds, let's stop the recording process */ //[self performSelector:@selector(stopRecordingOnAudioRecorder:)
            //   withObject:self.recorder afterDelay:5.0f];
            } else {
                NSLog(@"failed to record");
            }
        } else { NSLog(@"Failed to prepare.");
            self.recorder = nil;
        }
    } else { NSLog(@"Failed to create an instance of the audio recorder with erros.%@", error);
    }
    /*
    NSLog(@"record button pushed");
    if(!recorder.recording) {
        if( [recorder prepareToRecord] == YES) {
            
            recorder.meteringEnabled = YES;
            
            NSLog(@"recording begins");
            [recorder record];
            stopButton.enabled = YES;
            recordButton.enabled = NO;
   
        } 
    }
    */
    
}

- (void)updateTimer
{
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:startDate];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    NSString *timeString=[dateFormatter stringFromDate:timerDate];
   // NSLog(@"In update timer with time %@",timeString);
    stopWatchLabel.text = timeString;
}

-(void)stopCapturingAudio
{
    if ([self.audioPlayer isPlaying]){ 
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    } 
    
    stopButton.enabled = NO;
    NSLog(@"stoping only once");
    [self.recorder stop];
    [stopWatchTimer invalidate];
    stopWatchTimer = nil;
    recordingLabel.hidden = YES;
    playAudioButton.hidden = NO;
    saveAudioButton.hidden = NO;
    recordButton.enabled = YES;
    //[self.audioView removeFromSuperview];
    
    /*
    if(recorder.recording) {
        NSLog(@"Stoping audio..");
        [recorder stop];
    }*/
    //add audio play button and discard button and save button
}
-(void)audioRecorderDidFinishRecording:
(AVAudioRecorder *)recorder 
                          successfully:(BOOL)flag
{
    self.recorder = nil;
    NSLog(@"Succesfully finsished recording");
}

-(void)audioPlayerDidFinishPlaying:
(AVAudioPlayer *)player successfully:(BOOL)flag
{
    self.recorder = nil;
    self.audioPlayer = nil;
    recordButton.enabled = YES;
    saveAudioButton.enabled = YES;
}

-(void)recordAudio
{
    BOOL recordingReturn = [self startRecording];
    if (recordingReturn) {
        NSLog(@"Finished recording");
        //call segue to saveentrypage
    } else {
        NSLog(@"Failed to capture Audio");
    }
}

-(void) setSelectedEntryNumber:(NSNumber *)selectedEntryNumber
{
    _selectedEntryNumber = selectedEntryNumber;
}

-(void) setEntries:(NSDictionary *)entries
{
    if (_entries != entries) {
        _entries = entries;
    }
}

-(void)setupFetchedResultsController
{
    // initializing the request for each table t891A679D-F78F-4D75-8404-555BD6D964E73
    NSFetchRequest *requestMedia = [[NSFetchRequest alloc] init];
    NSFetchRequest *requestNote = [[NSFetchRequest alloc] init];
    NSFetchRequest *requestCheckin = [[NSFetchRequest alloc] init];
    [NSFetchedResultsController deleteCacheWithName:nil];  
    
    // creating the entity description for each table
    NSEntityDescription *mediaEntity = [NSEntityDescription entityForName:MEDIA_ENTITY inManagedObjectContext:self.lifeDatabase.managedObjectContext];
    NSEntityDescription *noteEntity = [NSEntityDescription entityForName:NOTE_ENTITY inManagedObjectContext:self.lifeDatabase.managedObjectContext];
    NSEntityDescription *checkInEntity = [NSEntityDescription entityForName:CHECKIN_ENTITY inManagedObjectContext:self.lifeDatabase.managedObjectContext];
    NSLog(@"user before quering %@", self.user);
    
    requestMedia.predicate = [NSPredicate predicateWithFormat:@"whoAdded = %@", self.user];
    requestNote.predicate = [NSPredicate predicateWithFormat:@"whoAdded = %@", self.user];
    requestCheckin.predicate = [NSPredicate predicateWithFormat:@"whoAdded = %@", self.user];
    
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
    NSError *mediaError = nil;
    NSError *checkinError = nil;
    NSError *noteError = nil;
    NSArray *medias = [self.lifeDatabase.managedObjectContext executeFetchRequest:requestMedia error:&mediaError];
    NSArray *checkins = [self.lifeDatabase.managedObjectContext executeFetchRequest:requestCheckin error:&checkinError];
    NSArray *notes = [self.lifeDatabase.managedObjectContext executeFetchRequest:requestNote error:&noteError];
    if(mediaError!=nil) {
        NSLog(@"Error while retreiving media objects: %@", mediaError);
    }
    if(checkinError!=nil) {
        NSLog(@"Error while retreiving checkin objects: %@", checkinError);
    }
    if(noteError!=nil) {
        NSLog(@"Error while retreiving note objects: %@", noteError);
    }
    
    
    self.entries = [[NSMutableDictionary alloc] init];
    NSLog(@"count from media query %i", [medias count]);
    NSLog(@"count from checkin query %i", [checkins count]);
    NSLog(@"count from note query %i", [notes count]);
    
    //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    // Take the 4 separate arrays and merge in one array
    NSMutableSet *set = [NSMutableSet setWithArray:medias];
    [set addObjectsFromArray:notes];
    [set addObjectsFromArray:checkins];
    NSArray *allEntries = [set allObjects];
    //separate out the entries based on day
    for (int i =0 ; i< [allEntries count]; i++) {
        //NSString *dateString = nil;
        NSDate *date = nil;
        NSObject *ith = [allEntries objectAtIndex:i]; 
        if ([ith isKindOfClass:[Media class]]) {
            Photo *obj = (Photo *)ith;
            date = obj.date;
        } else if ([ith isKindOfClass:[Note class]]) {
            Note *obj = (Note *)ith;
            date = obj.date;
        } else if ([ith isKindOfClass:[CheckIn class]]) {
            CheckIn *obj = (CheckIn *)ith;        
            date = obj.date;
        }
        NSMutableArray *arrayOfEntry = [self.entries objectForKey:date];
        if (!arrayOfEntry) {
            arrayOfEntry = [[NSMutableArray alloc] init];
            [arrayOfEntry addObject:ith];
            [self.entries setObject:arrayOfEntry forKey:date];
        } else {
            [arrayOfEntry addObject:ith];
        }
    }
    
    self.dates = [self.entries allKeys];    
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:NO];
    NSArray *sorters = [[NSArray alloc] initWithObjects:sorter, nil];
    self.dates = [self.dates sortedArrayUsingDescriptors:sorters];
}

- (void)useDocument
{
    NSLog(@"In LifeViewCOntroller USeDOcument");
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
    if(_lifeDatabase != lifeDatabase) {
        NSLog(@"i am in the set life database if");
        _lifeDatabase = lifeDatabase;
    }
}

- (void) addEntry:(id)sender
{
    int buttonNumber = [sender tag];
    if(buttonNumber == 0) {
        self.entryType = CHECKIN;
        if (self.networkAvailable == @"YES") {
            [self performSegueWithIdentifier:@"Show Edit Entry" sender:self];
        } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @""
                              message: @"Network Unavailable"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        }
        
    } else if (buttonNumber == 1) {
        self.entryType = NOTE;
        [self performSegueWithIdentifier:@"Show Edit Entry" sender:self];
    } else if (buttonNumber == 2) {
        [self capturePhoto];
    } else if (buttonNumber == 3) {
        [self recordVideo];
    } else if (buttonNumber == 4) {
        [self recordAudio];
    }
}

- (void) entryAction:(id)sender
{
    int buttonNumber = [sender tag];
    int rowNumber = buttonNumber/5000 ;
    int entryNumber = buttonNumber - (rowNumber*5000) ;
    //NSLog(@"button tag %i with RowMuber=%i, and entryNUmber=%i",buttonNumber,rowNumber, entryNumber);
    NSDate *date = [self.dates objectAtIndex:rowNumber];
    NSArray *itemsForDate = [self.entries objectForKey:date];
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"datewithtime"
                                                 ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    itemsForDate = [itemsForDate sortedArrayUsingDescriptors:sortDescriptors];
    self.scrollViewEntries = [NSMutableArray arrayWithArray:itemsForDate];
    self.selectedEntryNumber = [[NSNumber alloc] initWithInt:entryNumber];
    [self performSegueWithIdentifier:@"Show Entries" sender:self];
}

-(void) setUser:(User *)user
{
    _user = user;
}

-(void) setEntryURL:(NSURL *)entryURL
{
    _entryURL = entryURL;
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

- (void)viewDidAppear:(BOOL)animated
{
    //[self useDocument];
   // [self viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self useDocument];
    
    if([LifeHeader connected]) {
        self.networkAvailable = @"YES";
    }
    
    if (!self.lifeDatabase) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:DATABASE];
        self.lifeDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    
    if ([CLLocationManager locationServicesEnabled]) {
        self.myLocationManager = [[CLLocationManager alloc] init];
        self.myLocationManager.delegate = self;
        self.myLocationManager.purpose = @"To provide functionality based on user's current location.";
        [self.myLocationManager startUpdatingLocation]; 
        [self.myLocationManager stopUpdatingLocation];
        //location = self.myLocationManager.location;
    } else {
        /* Location services are not enabled. Take appropriate action: for instance, prompt the user to enable the location services */
        NSLog(@"Location services are not enabled");
        
    }
  
    self.entryOperation = @"save";
    //self.entryData = nil;
    /***************/
    UIImage *currentImg = [UIImage imageNamed:@"paper32.jpg"];
    UIImageView* topImageView = [[UIImageView alloc] initWithImage:currentImg];
    CGRect rect1 = [[UIScreen mainScreen] bounds];
    topImageView.frame = CGRectMake(0, 0, rect1.size.width, rect1.size.height);
    [self.view addSubview:topImageView];
    /******************/
    self.navigationController.navigationBarHidden = YES;
    CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat statusNav = statusBarHeight;
    CGRect rect = [[UIScreen mainScreen] bounds];
    NSArray *imageFiles = [NSArray arrayWithObjects: CHECKIN_IMAGE, NOTE_IMAGE, CAMERA_IMAGE, VIDEO_IMAGE, AUDIO_IMAGE, nil];
    
    // start creating subviews to show the scroll and table view
    UIScrollView *topScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, BAR_HEIGHT)];
    topScrollView.contentSize = CGSizeMake((BUTTON_DIM+3)*[imageFiles count], BAR_HEIGHT);
    topScrollView.backgroundColor = [LifeHeader getBarBackgroundColor];
    topScrollView.alpha = 0.8;
    
    for (int i=0; i < [imageFiles count]; i++) {
        UIButton *lifeOptionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        lifeOptionButton.frame = CGRectMake((i+1)*3+(BUTTON_DIM)*i,2,BUTTON_DIM,BUTTON_DIM);
        NSString *filename = [imageFiles objectAtIndex:i];
        
        lifeOptionButton.backgroundColor = [LifeHeader getBackgroundColor];
        [[lifeOptionButton layer] setMasksToBounds:YES];
        [[lifeOptionButton layer] setCornerRadius:8.0f];
        //[[lifeOptionButton layer] setBorderWidth:4.0f];
        [lifeOptionButton.layer setBorderColor:[LifeHeader getBorderColor].CGColor];
        
        [lifeOptionButton setBackgroundImage:[UIImage imageNamed:filename] forState:UIControlStateNormal];
        [lifeOptionButton addTarget:self action:@selector(addEntry:) forControlEvents:UIControlEventTouchUpInside];
        lifeOptionButton.tag = i;
        [topScrollView addSubview:lifeOptionButton];
    }
    
    [self.view addSubview:topScrollView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,BAR_HEIGHT, rect.size.width, rect.size.height-2*BAR_HEIGHT-statusNav) style:UITableViewStylePlain];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    UIScrollView *bottomScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, rect.size.height - BAR_HEIGHT - statusNav, rect.size.width, BAR_HEIGHT)];
    bottomScrollView.contentSize = CGSizeMake(rect.size.width, BAR_HEIGHT);
    //bottomScrollView.backgroundColor = [UIColor clearColor];
    
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(5, 5, 60, 30);
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    backButton.backgroundColor = [LifeHeader getButtonBackgroundColor];
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    bottomScrollView.backgroundColor = [LifeHeader getBarBackgroundColor];
    
    //bottomScrollView.alpha = 0.8;
    //[bottomScrollView addSubview:backButton];
    
    UIButton *addDateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addDateButton.frame = CGRectMake(70, 5, 60, 30);
    [addDateButton setTitle:@"Add Entry" forState:UIControlStateNormal];
    addDateButton.backgroundColor = [LifeHeader getButtonBackgroundColor];
    [addDateButton addTarget:self action:@selector(addDateEntry) forControlEvents:UIControlEventTouchUpInside];
    //[bottomScrollView addSubview:addDateButton];
    
    [self.view addSubview:bottomScrollView];
    //[self useDocument];
    
}

-(void) addDateEntry
{
    NSLog(@"inside add date entry");
    self.dateBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 400, 400)];
    self.dateBox.backgroundColor = [LifeHeader getBackgroundColor];
    self.datePicker = [[UIDatePicker alloc] init];
    [self.dateBox addSubview:self.datePicker];
    
    UIButton *doneDate = [UIButton buttonWithType:UIButtonTypeCustom];
    doneDate.frame = CGRectMake(250, 250, 50, 50);
    doneDate.backgroundColor = [LifeHeader getBackgroundColor];
    [doneDate setTitle:@"Done" forState:UIControlStateNormal];
    [doneDate addTarget:self action:@selector(saveEntry) forControlEvents:UIControlEventTouchUpInside];
    [self.dateBox addSubview:doneDate];
    [self.view addSubview:self.dateBox];
}

-(void) saveEntry
{
    NSLog(@"trying to get date info");
    NSDate *addForDate = [self.datePicker date];
    NSLog(@"%@", addForDate);
    [self.dateBox removeFromSuperview];
}

- (void) goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Day Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    } else {
        return cell;
    }
    
    NSDate *cellDate = (NSDate *)[self.dates objectAtIndex:indexPath.row];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSArray *itemsForDate = [self.entries objectForKey:[self.dates objectAtIndex:indexPath.row]];
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"datewithtime"
                                                  ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    itemsForDate = [itemsForDate sortedArrayUsingDescriptors:sortDescriptors];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, CELL_HEIGHT)];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, HEADER_HEIGHT)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 1, rect.size.width-2, HEADER_HEIGHT-1)];
    [headerLabel setTextColor:[UIColor blackColor]];
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    headerLabel.text = [dateFormatter stringFromDate:cellDate];
    
    [headerView addSubview:headerLabel];
    [view   addSubview:headerView];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, HEADER_HEIGHT, rect.size.width, SCROLL_VIEW_HEIGHT)];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.contentSize = CGSizeMake((4+ITEM_WIDTH)*[itemsForDate count]+1,SCROLL_VIEW_HEIGHT);
    for (int i=0; i<[itemsForDate count]; i++)
    {
        //UIView *buttonBackground = [[UIView alloc] initWithFrame:CGRectMake(i*(ITEM_WIDTH+2), 0, ITEM_WIDTH, SCROLL_VIEW_HEIGHT)];
        //buttonBackground.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
        //buttonBackground.backgroundColor = [LifeHeader getBackgroundColor];
        UIButton *buttonForItem = [UIButton buttonWithType:UIButtonTypeCustom];
        
        
        //buttonForItem.frame = CGRectMake(7.5, 7.5, ITEM_WIDTH-15, SCROLL_VIEW_HEIGHT-15);
        
        if(i==0) {
            buttonForItem.frame = CGRectMake(3, 0, ITEM_WIDTH, SCROLL_VIEW_HEIGHT);
        } else {
            buttonForItem.frame = CGRectMake(i*(ITEM_WIDTH+4)+3, 0, ITEM_WIDTH, SCROLL_VIEW_HEIGHT);   
        }
        
        UILabel *textLayer = [[UILabel alloc] initWithFrame:CGRectMake(2, 3*ITEM_WIDTH/5, ITEM_WIDTH-4 , 2*ITEM_WIDTH/5)];
        textLayer.backgroundColor = [LifeHeader getButtonBackgroundColor];
        
        NSObject *obj = [itemsForDate objectAtIndex:i]; 
        if ([obj isKindOfClass:[Media class]]) {
            Media *mediaObj = (Media *)obj;
            NSString *type = mediaObj.type;
            NSURL *url = [NSURL fileURLWithPath:mediaObj.source];
            if([type isEqualToString:VIDEO]) {
                AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
                AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                NSError *err = NULL;
                CMTime time = CMTimeMake(1, 10);
                CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
                UIImage *currentImg = [[UIImage alloc] initWithCGImage:imgRef];
                
                [buttonForItem setBackgroundImage:currentImg forState:UIControlStateNormal];
                [buttonForItem setImage:[UIImage imageNamed:PLAY_IMAGE]  forState:UIControlStateNormal];
            } else if([type isEqualToString:PHOTO]) {
                NSData *imageData = [NSData dataWithContentsOfURL:url];
                [buttonForItem setBackgroundImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
            } else if ([type isEqualToString:AUDIO]) {
                [buttonForItem setBackgroundImage:[UIImage imageNamed:AUDIO_IMAGE] forState:UIControlStateNormal];
            }
            
            NSString *string = nil;
            if (mediaObj.note != nil) {
                string = mediaObj.note;
            } else if (mediaObj.whichLocation.name != nil) {
                string = mediaObj.whichLocation.name;
            } else {
                string = @"";
            }
            textLayer.text = string;
        } else if ([obj isKindOfClass:[Note class]]) {
            //NSData *imageData = [NSData dataWithContentsOfURL:NOTE_IMAGE];
            Note *noteObj = (Note *)obj;
            [buttonForItem setBackgroundImage:[UIImage imageNamed:NOTE_IMAGE] forState:UIControlStateNormal];
            textLayer.text = noteObj.note;
        } else if ([obj isKindOfClass:[CheckIn class]]) {
            [buttonForItem setBackgroundImage:[UIImage imageNamed:CHECKIN_IMAGE] forState:UIControlStateNormal];
            CheckIn *checkInObj = (CheckIn *)obj;
            textLayer.text = [@"In: " stringByAppendingString:checkInObj.whichLocation.name];
            //checkedIn = [checkedIn stringByAppendingString:checkInObj.place];
        }
        [buttonForItem addTarget:self action:@selector(entryAction:) forControlEvents:UIControlEventTouchUpInside];
        buttonForItem.tag = i + (5000* indexPath.row);
        
        buttonForItem.backgroundColor = [LifeHeader getBackgroundColor];
        [[buttonForItem layer] setMasksToBounds:YES];
        //[[buttonForItem layer] setCornerRadius:4.0f];
        [[buttonForItem layer] setBorderWidth:2.0f];
        
        textLayer.font = [UIFont systemFontOfSize:10];
        textLayer.textColor = [UIColor whiteColor];
        textLayer.numberOfLines = 0;
        textLayer.lineBreakMode = UILineBreakModeWordWrap;
        [buttonForItem addSubview:textLayer];
        [buttonForItem.layer setBorderColor:[UIColor whiteColor].CGColor];
        
        [scrollView addSubview:buttonForItem];
    }
    [view addSubview:scrollView];
    [view setBackgroundColor:[UIColor clearColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.contentView addSubview:view];
    return cell;
}

-(void)dismissImagePicker
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(__bridge NSString *)kUTTypeMovie]){
        NSURL *urlOfVideo = [info objectForKey:UIImagePickerControllerMediaURL];
        NSError *dataReadingError = nil;
        NSData *videoData = [NSData dataWithContentsOfURL:urlOfVideo options:NSDataReadingMapped error:&dataReadingError];
        if (videoData != nil){
            self.entryType = VIDEO;
            self.entryURL = urlOfVideo;
           // self.entryData = videoData;
            /*
            BOOL savingVideo = [self saveMedia:videoData withType:VIDEO];
            /* We were able to read the data */
            /*
            if(savingVideo) {
                NSLog(@"Succesfully saved the video.");
            } else {
                NSLog(@"Failed to save video.");
            }
            */
        } else { 
            /* We failed to read the data. Use the dataReadingError
             variable to determine what the error is */ 
            NSLog(@"Failed to load the data with error = %@", dataReadingError);
        }
    } else if ([mediaType isEqualToString:(__bridge NSString *)kUTTypeImage]){
        
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        if (!image) image = [info objectForKey:UIImagePickerControllerMediaURL];
        if(image) {
            NSLog(@"Picture Taken");
           // NSData *imageData = UIImagePNGRepresentation(image); NSURL *referenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
            self.entryType = PHOTO;
            self.entryURL = [info objectForKey:UIImagePickerControllerReferenceURL];
            NSLog(@"entryURL %@", self.entryURL);
            self.entryData = UIImagePNGRepresentation(image);
            /*
            BOOL savingPhoto = [self saveMedia:imageData withType:PHOTO];
            if(savingPhoto) {
                NSLog(@"Succesfully saved the photo.");
            } else {
                NSLog(@"Failed to save photo.");
            }*/
        }
    }
    [self performSegueWithIdentifier:@"Show Edit Entry" sender:self];
    [self dismissImagePicker];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissImagePicker];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Show Homepage"]) {
        [segue.destinationViewController setUser:self.user];
        [segue.destinationViewController setLifeDatabase:self.lifeDatabase];
    } else if([segue.identifier isEqualToString:@"Show Note"]) {
        NSLog(@"I am in Segue going to capture note with user: %@", self.user);
        [segue.destinationViewController setUser:self.user];
        [segue.destinationViewController setLifeDatabase:self.lifeDatabase];
    } else if ([segue.identifier isEqualToString:@"Show Location"]) {
        [segue.destinationViewController setUser:self.user];
        [segue.destinationViewController setLifeDatabase:self.lifeDatabase];
    } else if([segue.identifier isEqualToString:@"Show Life"]) {
        [segue.destinationViewController setUser:self.user];
        [segue.destinationViewController setLifeDatabase:self.lifeDatabase];
    } else if([segue.identifier isEqualToString:@"Show Entries"]) {
        [segue.destinationViewController setUser:self.user];
        [segue.destinationViewController setLifeDatabase:self.lifeDatabase];
        [segue.destinationViewController setSelectedEntryNumber:self.selectedEntryNumber];
        [segue.destinationViewController setScrollViewEntries:self.scrollViewEntries];
        
    } else if([segue.identifier isEqualToString:@"Show Edit Entry"]) {
        
        [segue.destinationViewController setUser:self.user];
        [segue.destinationViewController setLifeDatabase:self.lifeDatabase];
        [segue.destinationViewController setEntryOperation:self.entryOperation];
        [segue.destinationViewController setEntryDate:self.entryDate];
        [segue.destinationViewController setEntryType:self.entryType];
        [segue.destinationViewController setEntryURL:self.entryURL];
        [segue.destinationViewController setEntryData:self.entryData];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
