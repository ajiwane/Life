//
//  EntriesViewController.m
//  JournalDatabase
//
//  Created by karthik jagadeesh on 7/8/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import "EntriesViewController.h"
#import <Twitter/Twitter.h>

@implementation EntriesViewController

@synthesize lifeDatabase = _lifeDatabase;
@synthesize scrollViewEntries = _scrollViewEntries;
@synthesize user = _user;
@synthesize selectedEntryNumber = _selectedEntryNumber;
@synthesize topBarView = _topBarView;
@synthesize mapview = _mapview;
@synthesize userLocation = _userLocation;
@synthesize scrollView = _scrollView;
@synthesize entryEditNumber = _entryEditNumber;
@synthesize entryEditObject = _entryEditObject;
@synthesize entryOperation = _entryOperation;
@synthesize videoButton = _videoButton;
@synthesize swipeRecognizer = _swipeRecognizer;
@synthesize tapRec = _tapRec;
@synthesize audioPlayer = _audioPlayer;
@synthesize currentAudioButton = _currentAudioButton;

- (void)setLifeDatabase:(UIManagedDocument *)lifeDatabase
{
    if(_lifeDatabase != lifeDatabase) {
        _lifeDatabase = lifeDatabase;
    }
}

-(void) setUser:(User *)user
{
   _user = user;
}

-(void) setSelectedEntryNumber:(NSNumber *)selectedEntryNumber
{
    _selectedEntryNumber = selectedEntryNumber;
}

-(void) setScrollViewEntries:(NSMutableArray *)scrollViewEntries
{
    _scrollViewEntries = scrollViewEntries;
}
/*
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.lifeDatabase) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:DATABASE];
        self.lifeDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    //self.fullScreen=@"NO";
}*/

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.topBarView.alpha = 0;
    if(self.audioPlayer.playing) {
        [self.audioPlayer stop];
    }
    self.currentAudioButton = nil;
}

- (void)viewWillAppear:(BOOL)animated
{    
    [super viewWillAppear:animated];
    
    if (!self.lifeDatabase) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:DATABASE];
        self.lifeDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    
    UIView *editedView = [self.scrollView.subviews objectAtIndex:[self.entryEditNumber intValue]];
    NSObject *object = [self.scrollViewEntries objectAtIndex:[self.entryEditNumber intValue]];
    
    if([object isKindOfClass:[Note class]]) {
        UIView *editedTopView = [editedView.subviews objectAtIndex:0];
        UITextView *editedTextView = [editedTopView.subviews objectAtIndex:0];
        editedTextView.text = ((Note *)object).note;
        
        UIView *editedBottomView = [editedView.subviews objectAtIndex:1];
        UITextView *editedLocationView = [editedBottomView.subviews objectAtIndex:1];
        if(((Note *)object).whichLocation) {
            editedLocationView.text = [@"At: " stringByAppendingString: ((Note *)object).whichLocation.name];
        }
    } else if ([object isKindOfClass:[Media class]]) {
        UIView *editedBottomView = [editedView.subviews objectAtIndex:1];
        UITextView *editedTextView = [editedBottomView.subviews objectAtIndex:0];
        UITextView *editedLocationView = [editedBottomView.subviews objectAtIndex:2];
        editedTextView.text = ((Media *) object).note;
        if(((Media *)object).whichLocation) {
            editedLocationView.text = [@"At: " stringByAppendingString: ((Media *)object).whichLocation.name];
        }    
    } else if ([object isKindOfClass:[CheckIn class]]) {
        UIView *editedBottomView = [editedView.subviews objectAtIndex:1];
        UITextView *editedTextView = [editedBottomView.subviews objectAtIndex:0];
        UITextView *editedLocationView = [editedBottomView.subviews objectAtIndex:2];
        editedTextView.text = ((CheckIn *) object).note;
        if(((CheckIn *)object).whichLocation) {
            editedLocationView.text = [@"At: " stringByAppendingString: ((CheckIn *)object).whichLocation.name];
        }
    }
    
}

- (void)socialPushed:(id)sender
{
    NSObject *obj = [self.scrollViewEntries objectAtIndex:[sender tag]];
    NSLog(@"Post will be sent to social sharing site: %@", obj);
    /*
    NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/user_timeline.json"];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:@"karthikj89" forKey:@"screen_name"];
    [parameters setObject:@"50" forKey:@"count"];
    [parameters setObject:@"1" forKey:@"include_entities"];
    TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:parameters requestMethod:TWRequestMethodGET];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData != nil) {
            NSError *error = nil;
            NSJSONSerialization *dataSource = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
            
            if (dataSource != nil) {
                NSLog(@"The json response: %@", dataSource);
            } else {
                NSLog(@"Error serializing response data %@ with user info %@.", error, error.userInfo);
            }
        } else {
            NSLog(@"Error requesting timeline %@ with user info %@.", error, error.userInfo);
        }
    }];
     */
}


- (void)viewDidLoad
{    
    [super viewDidLoad];

    
    self.entryOperation = @"edit";
    self.navigationController.navigationBarHidden = YES;
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    self.scrollView.contentSize = CGSizeMake(rect.size.width*[self.scrollViewEntries count], rect.size.height);
    self.scrollView.delegate = self;
    self.scrollView.autoresizesSubviews = YES;
    
    //[self.scrollView addGestureRecognizer:scrollRecognizer];
    
    for (int i=0; i < [self.scrollViewEntries count]; i++) {
        UIView *entryView = [[UIView alloc] initWithFrame:CGRectMake(i*rect.size.width, 0, rect.size.width, rect.size.height)];
        
        //self.swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
        //[self.swipeRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft)];
        //self.swipeRecognizer.delegate = self;
       // self.swipeRecognizer.delaysTouchesBegan = YES;
        //[entryView addGestureRecognizer:self.swipeRecognizer];
        
        self.tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        self.tapRec.delegate = self;
        [entryView addGestureRecognizer:self.tapRec];
        /*
        UISwipeGestureRecognizer *scrollRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom)];
        [scrollRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft)];
        scrollRecognizer.delegate = self;
        [entryView addGestureRecognizer:scrollRecognizer]; */
        UIView *entryTopView = entryTopView = [[UIView alloc] initWithFrame:CGRectMake(8, 8, rect.size.width-16, rect.size.height*0.6-8)];;
        
        
       // UIView *entryTopView = [[UIView alloc] initWithFrame:CGRectMake(8, 8, rect.size.width-16, rect.size.height*0.6-8)];
        UIView *entryBottomView = [[UIView alloc] initWithFrame:CGRectMake(8, rect.size.height*0.6 +8, rect.size.width-16, rect.size.height*0.4 -36)];
        entryBottomView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"finewhite.jpg"]];
        UITextView *captionView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, entryBottomView.frame.size.width, (entryBottomView.frame.size.height)*0.4)];
        captionView.editable = NO;
        captionView.textColor = [UIColor blackColor];
        [captionView setFont:[UIFont fontWithName:@"ArialMT" size:18]];
        captionView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255 blue:0/255 alpha:0.2];
        
        UITextView *timeView = [[UITextView alloc] initWithFrame:CGRectMake(0, (entryBottomView.frame.size.height)*0.4 +1, entryBottomView.frame.size.width, (entryBottomView.frame.size.height)*0.20 -1)];
        timeView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255 blue:0/255 alpha:0.2];
        timeView.editable = NO;
        timeView.textColor = [UIColor blackColor];
        [timeView  setFont:[UIFont fontWithName:@"ArialMT" size:18]];
        timeView.scrollEnabled = NO;
        //timeView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255 blue:0/255 alpha:0.2];
        
        UITextView *locationView = [[UITextView alloc] initWithFrame:CGRectMake(0, (entryBottomView.frame.size.height)*0.6 +1, entryBottomView.frame.size.width, (entryBottomView.frame.size.height)*0.20 -1)];
        locationView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255 blue:0/255 alpha:0.2];
        locationView.editable = NO;
        locationView.textColor = [UIColor blackColor];
        [locationView  setFont:[UIFont fontWithName:@"ArialMT" size:18]];
        
        /*
        UITextView *friendsView = [[UITextView alloc] initWithFrame:CGRectMake(0, (entryBottomView.frame.size.height)*0.8 +1, entryBottomView.frame.size.width, (entryBottomView.frame.size.height)*0.20 -1)];
        friendsView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255 blue:0/255 alpha:0.2];
        friendsView.editable = NO;*/
        //UILabel *timeAndLocationTextView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, timeAndLocationScrollView.frame.size.width, timeAndLocationScrollView.frame.size.height)];
       // UILabel *timeAndLocationTextView = [[UILabel alloc] init];
       // timeAndLocationTextView.backgroundColor = [UIColor clearColor];
        //timeAndLocationTextView.editable = NO;
        
        UIScrollView *friendsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, (entryBottomView.frame.size.height)*0.8 +1, entryBottomView.frame.size.width, (entryBottomView.frame.size.height)*0.20 -1)];
        friendsScrollView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255 blue:0/255 alpha:0.2];
        
        UIButton *pushTwitter = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        pushTwitter.frame = CGRectMake(2, 2, friendsScrollView.frame.size.height-4, friendsScrollView.frame.size.height-4);
        [pushTwitter setBackgroundImage:[UIImage imageNamed:@"twitter.png"] forState:UIControlStateNormal];
        [pushTwitter addTarget:self action:@selector(socialPushed:) forControlEvents:UIControlEventTouchUpInside];
        pushTwitter.tag = i;
        [friendsScrollView addSubview:pushTwitter];
        
        UIButton *pushFacebook = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        pushFacebook.frame = CGRectMake(friendsScrollView.frame.size.height, 2, friendsScrollView.frame.size.height-4, friendsScrollView.frame.size.height-4);
        [pushFacebook setBackgroundImage:[UIImage imageNamed:@"facebook.png"] forState:UIControlStateNormal];
        [pushFacebook addTarget:self action:@selector(socialPushed:) forControlEvents:UIControlEventTouchUpInside];
        pushFacebook.tag = i;
        [friendsScrollView addSubview:pushFacebook];
        
        UIButton *pushPinterest = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        pushPinterest.frame = CGRectMake(2*friendsScrollView.frame.size.height-2, 2, friendsScrollView.frame.size.height-4, friendsScrollView.frame.size.height-4);
        [pushPinterest setBackgroundImage:[UIImage imageNamed:@"pinterest.png"] forState:UIControlStateNormal];
        [pushPinterest addTarget:self action:@selector(socialPushed:) forControlEvents:UIControlEventTouchUpInside];
        pushPinterest.tag = i;
        [friendsScrollView addSubview:pushPinterest];
        
        UIButton *pushTumblr = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        pushTumblr.frame = CGRectMake(3*friendsScrollView.frame.size.height-4, 2, friendsScrollView.frame.size.height-4, friendsScrollView.frame.size.height-4);
        [pushTumblr setBackgroundImage:[UIImage imageNamed:@"tumblr.png"] forState:UIControlStateNormal];
        [pushTumblr addTarget:self action:@selector(socialPushed:) forControlEvents:UIControlEventTouchUpInside];
        pushTumblr.tag = i;
        [friendsScrollView addSubview:pushTumblr];
        
        NSObject *entryObj = [self.scrollViewEntries objectAtIndex:i]; 
        if ([entryObj isKindOfClass:[Media class]]) {
            Media *mediaObj = (Media *)entryObj;
            NSString *type = mediaObj.type;
            NSURL *url = [NSURL fileURLWithPath:mediaObj.source];
            if([type isEqualToString:VIDEO]) {
                AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
                AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                NSError *err = NULL;
                CMTime time = CMTimeMake(1, 10);
                CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
                UIImage *currentImg = [[UIImage alloc] initWithCGImage:imgRef];
                UIImageView* topImageView = [[UIImageView alloc] initWithImage:currentImg];
                topImageView.frame = CGRectMake(0, 0, entryTopView.frame.size.width, entryTopView.frame.size.height);
                
                 UIButton *videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
                //[[backButton layer] setCornerRadius:4.0f];
                videoButton.frame = CGRectMake(entryTopView.frame.size.width*0.5 - 30, entryTopView.frame.size.height*0.5-20, 60, 40);
                [videoButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
                [[videoButton layer] setMasksToBounds:YES];
                [[videoButton layer] setCornerRadius:2.f];
                [[videoButton layer] setBorderWidth:1.0f];
                [[videoButton layer] setBorderColor:[UIColor whiteColor].CGColor];
                [videoButton setImage:[UIImage imageNamed:@"playButton.jpg"]  forState:UIControlStateNormal];
                videoButton.tag = i;
                
                //[backButton setBackgroundColor:[UIColor blackColor]];
                //[backButton setTitle:@"Back" forState:UIControlStateNormal];
                //[backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                //[self.topBarView addSubview:backButton];
                [entryTopView addSubview:topImageView];
                [entryTopView addSubview:videoButton];
                
                
                /*************add 40% text*/
                
            } else if([type isEqualToString:PHOTO]) {
                NSData *imageData = [NSData dataWithContentsOfURL:url];
                UIImage *currentImg = [UIImage imageWithData:imageData];
                UIImageView* topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, entryTopView.frame.size.width, entryTopView.frame.size.height)];
                //UIImageView* topImageView = [[UIImageView alloc] initWithImage:currentImg];
                //topImageView.frame = CGRectMake(0, 0, entryTopView.frame.size.width, entryTopView.frame.size.height);
                [topImageView setImage:currentImg];
                
                //topImageView.contentMode = UIViewContentModeScaleAspectFit;

                [entryTopView addSubview:topImageView];

                topImageView.userInteractionEnabled = YES;
               // entryBottomView.userInteractionEnabled = YES;
               // [topImageView addGestureRecognizer:scrollRecognizer];
                //[entryBottomView addGestureRecognizer:scrollRecognizer];
                
                /*************add 40% text*/
            } else if([type isEqualToString:AUDIO]) {
              //  NSDATA *audioData = [NSData dataWithContentsOfURL:url];
                UIImage *currentImg = [UIImage imageNamed:AUDIO_IMAGE];
                UIImageView* topImageView = [[UIImageView alloc] initWithImage:currentImg];
                topImageView.frame = CGRectMake(0, 0, entryTopView.frame.size.width, entryTopView.frame.size.height);
                UIButton *audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
                //[[backButton layer] setCornerRadius:4.0f];
                audioButton.frame = CGRectMake(entryTopView.frame.size.width*0.5 - 30, entryTopView.frame.size.height*0.5-20, 60, 40);
                [audioButton addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
                [[audioButton layer] setMasksToBounds:YES];
                [[audioButton layer] setCornerRadius:2.f];
                [[audioButton layer] setBorderWidth:1.0f];
                [[audioButton layer] setBorderColor:[UIColor whiteColor].CGColor];
               // self.audioButton setBackgroundImage:<#(UIImage *)#> forState:<#(UIControlState)#>
                [audioButton setBackgroundImage:[UIImage imageNamed:PLAY_AUDIO_IMAGE]  forState:UIControlStateNormal];
                audioButton.tag = i;
                
                //[backButton setBackgroundColor:[UIColor blackColor]];
                //[backButton setTitle:@"Back" forState:UIControlStateNormal];
                //[backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                //[self.topBarView addSubview:backButton];
                
                //[entryTopView addSubview:topImageView];
                [entryTopView addSubview:topImageView];
                [entryTopView  addSubview:audioButton];
             //   topImageView.userInteractionEnabled = YES;
                
            }
            captionView.text = mediaObj.note;
            //[captionView textAlignment] = 
            
            NSString *dateString = @"Time: ";
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            dateString = [dateString stringByAppendingString:[dateFormatter stringFromDate:mediaObj.datewithtime]];
            dateString = [dateString stringByAppendingString:@" "];
            [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"hh:mm a" options:0 locale:[NSLocale currentLocale]]];
            dateString = [dateString stringByAppendingString:[dateFormatter stringFromDate:mediaObj.datewithtime]];
            //[dateButton setTitle:dateString forState:UIControlStateNormal];
            timeView.text = dateString;
            
            NSString *locationString = @"At: ";
            if(mediaObj.whichLocation) {
                locationString = [locationString stringByAppendingString:mediaObj.whichLocation.name];
                locationView.text = locationString;
            } else {
                locationString = @"";
            }
            [entryBottomView addSubview:captionView];
            [entryBottomView addSubview:timeView];
            [entryBottomView addSubview:locationView];
            [entryBottomView addSubview:friendsScrollView];
            
        } else if ([entryObj isKindOfClass:[Note class]]) {
            entryTopView.frame = CGRectMake(8, 8, rect.size.width-16, rect.size.height*0.76 -14.4);// + (entryBottomView.frame.size.height)*0.4);
           // entryTopView.backgroundColor = [LifeHeader getBackgroundColor];
            entryBottomView.frame = CGRectMake(8, 8+entryTopView.frame.size.height, rect.size.width-16, rect.size.height*0.24 -21.6);
            
            captionView.frame = CGRectMake(0, 0, entryTopView.frame.size.width, entryTopView.frame.size.height-8);
        
            timeView.frame = CGRectMake(0, 1, entryBottomView.frame.size.width, timeView.frame.size.height);
            locationView.frame = CGRectMake(0, timeView.frame.size.height + 2, entryBottomView.frame.size.width, timeView.frame.size.height);
            friendsScrollView.frame = CGRectMake(0, timeView.frame.size.height*2 +3, entryBottomView.frame.size.width, timeView.frame.size.height);
            
            Note *noteObj = (Note *)entryObj;
            captionView.text = noteObj.note;
            
            captionView.backgroundColor = [LifeHeader getBackgroundColor];
            NSString *dateString = @"Time: ";
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            dateString = [dateString stringByAppendingString:[dateFormatter stringFromDate:noteObj.datewithtime]];
            dateString = [dateString stringByAppendingString:@" "];
            [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"hh:mm a" options:0 locale:[NSLocale currentLocale]]];
            dateString = [dateString stringByAppendingString:[dateFormatter stringFromDate:noteObj.datewithtime]];
            //[dateButton setTitle:dateString forState:UIControlStateNormal];
            timeView.text = dateString;
            
            NSString *locationString = @"At: ";
            if(noteObj.whichLocation) {
                locationString = [locationString stringByAppendingString:noteObj.whichLocation.name];
                locationView.text = locationString;
            } else {
                locationString = @"";
            }
            captionView.textAlignment = UITextAlignmentCenter;
            
            [entryTopView addSubview:captionView];
            CGFloat topCorrect = (captionView.frame.size.height - [captionView contentSize].height)  / 2.0;
            NSLog(@"captionView frame %f", captionView.frame.size.height);
            NSLog(@"captionvuew content %f", captionView.contentSize.height);
            topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
            captionView.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
            
            [entryBottomView addSubview:timeView];
            [entryBottomView addSubview:locationView];
            [entryBottomView addSubview:friendsScrollView];
            
        } else if ([entryObj isKindOfClass:[CheckIn class]]) {
            CheckIn *checkInObj = (CheckIn *)entryObj;
            self.mapview = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, entryTopView.frame.size.width, entryTopView.frame.size.height)];
            self.userLocation = [[CLLocation alloc] initWithLatitude:[checkInObj.whichLocation.latitude floatValue] longitude:[checkInObj.whichLocation.longitude floatValue]];
            //self.userLocation = [[CLLocation alloc] initWithLatitude:37 longitude:-122];
            CLLocationCoordinate2D coordinate = self.userLocation.coordinate;
            MKCoordinateSpan span = MKCoordinateSpanMake(.01, .01);
            MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
            [self.mapview setRegion:region];
            [self.mapview regionThatFits:region];
           // NSString *checkedIn = @"Checked in at ";
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            [point setCoordinate:coordinate];
            [point setTitle:checkInObj.whichLocation.name];
            [point setSubtitle:checkInObj.whichLocation.address];
            [self.mapview addAnnotation:point];
            [self.mapview selectAnnotation:point animated:NO];
            self.mapview.scrollEnabled = NO;
            self.mapview.zoomEnabled = NO;
            UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc] 
                                              initWithTarget:self action:@selector(tap:)];
         //   tapRec.delegate = self;
            self.mapview.tag = i;
            [self.mapview addGestureRecognizer:tapRec];
            [entryTopView addSubview:self.mapview];
            
            
            captionView.text = checkInObj.note;
            //[captionView textAlignment] = 
            
            NSString *dateString = @"Time: ";
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            dateString = [dateString stringByAppendingString:[dateFormatter stringFromDate:checkInObj.datewithtime]];
            dateString = [dateString stringByAppendingString:@" "];
            [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"hh:mm a" options:0 locale:[NSLocale currentLocale]]];
            dateString = [dateString stringByAppendingString:[dateFormatter stringFromDate:checkInObj.datewithtime]];
            //[dateButton setTitle:dateString forState:UIControlStateNormal];
            timeView.text = dateString;
            
            NSString *locationString = @"At: ";
            if(checkInObj.whichLocation) {
                locationString = [locationString stringByAppendingString:checkInObj.whichLocation.name];
                locationView.text = locationString;
            } else {
                locationString = @"";
            }
            
            [entryBottomView addSubview:captionView];
            [entryBottomView addSubview:timeView];
            [entryBottomView addSubview:locationView];
            [entryBottomView addSubview:friendsScrollView];

            
            //[checkedIn stringByAppendingString:checkInObj.place];
            
           // UIImageView* bottomLabelImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"finewhite.jpg"]];
            //bottomLabelImage.frame = CGRectMake(0, 0, entryBottomView.frame.size.width, entryBottomView.frame.size.height);
          //  [entryBottomView addSubview:bottomLabelImage];
            /*
            UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, entryBottomView.frame.size.width, entryBottomView.frame.size.height)];
            bottomLabel.text = checkedIn;
            //bottomLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"finewhite.jpg"]];
            //bottomLabel.backgroundColor = [LifeHeader getBorderColor];
            bottomLabel.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255 blue:0/255 alpha:0.2];
            [bottomLabel setTextColor:[UIColor blackColor]];
            [bottomLabel setTextAlignment:UITextAlignmentCenter];
            [entryBottomView addSubview:bottomLabel];
            NSLog(@"bottom label view height %g, screen height %g",bottomLabel.frame.size.height,rect.size.height);*/
            
        }
        entryView.tag = i;      
        
        [entryView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)]];
     //   entryBottomView.tag = i;
      //  [entryBottomView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
        //[entryBottomView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)]];

        
        UIButton *fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //[[backButton layer] setCornerRadius:4.0f];
        fullScreenButton.frame = CGRectMake(entryTopView.frame.size.width - 40, entryTopView.frame.size.height-40, 30, 30);
        [fullScreenButton addTarget:self action:@selector(fullScreen:) forControlEvents:UIControlEventTouchUpInside];
        [[fullScreenButton layer] setMasksToBounds:YES];
        [[fullScreenButton layer] setCornerRadius:2.f];
        [[fullScreenButton layer] setBorderWidth:1.0f];
        [[fullScreenButton layer] setBorderColor:[LifeHeader getBorderColor].CGColor];
        fullScreenButton.backgroundColor = [UIColor whiteColor];
        [fullScreenButton setImage:[UIImage imageNamed:@"view_full_screen_alt.png"]  forState:UIControlStateNormal];
        fullScreenButton.tag = i;
        
        //[backButton setBackgroundColor:[UIColor blackColor]];
        //[backButton setTitle:@"Back" forState:UIControlStateNormal];
        //[backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //[self.topBarView addSubview:backButton];
        [entryTopView addSubview:fullScreenButton];
        
        [entryView addSubview:entryTopView];
        [entryView addSubview:entryBottomView];
        [self.scrollView addSubview:entryView];
    }
    self.scrollView.pagingEnabled = YES;
    [self.scrollView setContentOffset:CGPointMake([self.selectedEntryNumber floatValue]*rect.size.width, 0) animated:NO];
    
    
    // when you tap on a cell it should make the navigation view at the top show up
    // change value 
    
    [self.view addSubview:self.scrollView];
    
    self.topBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 50)];
    self.topBarView.backgroundColor = [LifeHeader getBackgroundColor];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [[backButton layer] setCornerRadius:4.0f];
    backButton.frame = CGRectMake(10, 10, 50, 30);
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [backButton setBackgroundColor:[UIColor colorWithRed:.125 green:.125 blue:.125 alpha:.8]];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backButton.layer.borderWidth = 1;
    [self.topBarView addSubview:backButton];
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [[editButton layer] setCornerRadius:4.0f];
    editButton.frame = CGRectMake(rect.size.width-60, 10, 50, 30);
    [editButton addTarget:self action:@selector(editEntry) forControlEvents:UIControlEventTouchUpInside];
    [editButton setBackgroundColor:[UIColor colorWithRed:.125 green:.125 blue:.125 alpha:.8]];
    [editButton setTitle:@"Edit" forState:UIControlStateNormal];
    editButton.layer.borderWidth = 1;
    [editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    [self.topBarView addSubview:editButton];
    
    [self.view addSubview:self.topBarView];
    
    self.topBarView.alpha = 0;
}

-(void)fullScreen:(id)sender
{
    NSLog(@"fullscreen button clicked");
    CGRect rect = [[UIScreen mainScreen] bounds];
    
   // self.fullScreen = @"YES";
    [UIView beginAnimations:@"Resize" context:nil];
    [UIView setAnimationDuration:0.4];
    
   // UIButton *aButton = (UIButton *)sender;
   // [aButton.subviews objectAtIndex:0];
    UIView *entryView = [[self.scrollView subviews] objectAtIndex:[sender tag]];
    //NSLog(@"superview of button %f", entryTopView.frame.size.height);
   // NSLog(@"rect.heingt %f", rect.size.height);
    UIView *entryTopView = [[entryView subviews] objectAtIndex:0];
    /*
    UIImageView *fullScreenImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, entryView.frame.size.width - 16, entryView.frame.size.height-36)];
    fullScreenImageView.backgroundColor = [UIColor whiteColor];
    [fullScreenImageView setImage:[UIImage imageNamed:AUDIO_IMAGE]];
    fullScreenImageView.contentMode = UIViewContentModeCenter;
   // fullScreenImageView.image = [UIImage imageNamed:PLAY_IMAGE];
    [entryView addSubview:fullScreenImageView];*/
    
    
    UIView *entryBottomView = [[entryView subviews] objectAtIndex:1];
    entryBottomView.hidden = YES;
    
    UIView *objectInsideView = [[entryTopView subviews] objectAtIndex:0];
    entryTopView.frame = CGRectMake(8, 8, rect.size.width-16, rect.size.height-36);
    objectInsideView.frame = CGRectMake(0, 0, entryTopView.frame.size.width, entryTopView.frame.size.height);
    objectInsideView.contentMode = UIViewContentModeScaleAspectFit;
    NSObject *ithObj = [self.scrollViewEntries objectAtIndex:[sender tag]];
    if([ithObj isKindOfClass:[Media class]]) {
        NSString *type = ((Media *)(ithObj)).type;
        if([type isEqualToString:AUDIO] || [type isEqualToString:VIDEO]) {
            UIView *pButton = [[entryTopView subviews] objectAtIndex:1];
            pButton.frame = CGRectMake(entryTopView.frame.size.width*0.5 - 30, entryTopView.frame.size.height*0.5-20, 60, 40);
        }
    }
    //[entryTopView removeFromSuperview];
    
    
    UIButton *zoomButton = [[entryTopView subviews] lastObject];
    [zoomButton setImage:[UIImage imageNamed:@"fullscreen_exit.png"] forState:UIControlStateNormal];
    [zoomButton addTarget:self action:@selector(exitFullScreen:) forControlEvents:UIControlEventTouchUpInside];
    zoomButton.frame = CGRectMake(entryTopView.frame.size.width - 40, entryTopView.frame.size.height-40, 30, 30); 
    zoomButton.tag = [sender tag];
    [UIView commitAnimations];
   // [entryView setNeedsDisplay];
   // [entryTopView setNeedsDisplay];
    //[entryTopView.superview addSubview:entryTopView];
   // [self.scrollView setNeedsDisplay];
     
    //[entryTopView reloadInputViews];
    //[self.view setNeedsDisplay];
}

-(void)exitFullScreen:(id)sender
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    [UIView beginAnimations:@"Resize" context:nil];
    [UIView setAnimationDuration:0.4];
    UIView *entryView = [[self.scrollView subviews] objectAtIndex:[sender tag]];
    UIView *entryTopView = [[entryView subviews] objectAtIndex:0];

    UIView *entryBottomView = [[entryView subviews] objectAtIndex:1];
    entryBottomView.hidden = NO;

    UIView *objectInsideView = [[entryTopView subviews] objectAtIndex:0];
    NSObject *ithObj = [self.scrollViewEntries objectAtIndex:[sender tag]];
    if([ithObj isKindOfClass:[Note class]]) {
        entryTopView.frame = CGRectMake(8, 8, rect.size.width-16, rect.size.height*0.76 -14.4);
    } else {
        entryTopView.frame = CGRectMake(8, 8, rect.size.width-16, rect.size.height*0.6-8);
    }
    
    objectInsideView.frame = CGRectMake(0, 0, entryTopView.frame.size.width, entryTopView.frame.size.height);
    objectInsideView.contentMode = UIViewContentModeScaleToFill;
    
    if([ithObj isKindOfClass:[Media class]]) {
        NSString *type = ((Media *)(ithObj)).type;
        if([type isEqualToString:AUDIO] || [type isEqualToString:VIDEO]) {
            UIView *pButton = [[entryTopView subviews] objectAtIndex:1];
            pButton.frame = CGRectMake(entryTopView.frame.size.width*0.5 - 30, entryTopView.frame.size.height*0.5-20, 60, 40);
        }
    }  
    
    UIButton *zoomButton = [[entryTopView subviews] lastObject];
    zoomButton.backgroundColor = [UIColor whiteColor];
    [zoomButton setImage:[UIImage imageNamed:@"view_full_screen_alt.png"] forState:UIControlStateNormal];
    [zoomButton addTarget:self action:@selector(fullScreen:) forControlEvents:UIControlEventTouchUpInside];
    zoomButton.frame = CGRectMake(entryTopView.frame.size.width - 40, entryTopView.frame.size.height-40, 30, 30); 
    zoomButton.tag = [sender tag];
    [UIView commitAnimations];
    
    [UIView commitAnimations];
}

- (void)drawRect:(CGRect)rect
{
    NSLog(@"in draw rect");
}

-(void)playVideo:(id)sender
{
    NSLog(@"PlayButton Clicked with %i", [sender tag]);
    
    Media *mediObj = (Media *)[self.scrollViewEntries objectAtIndex:[sender tag]];
    NSURL *url = [NSURL fileURLWithPath:mediObj.source];
    //NSLog(@"Video URL %@",mediObj);
    MPMoviePlayerViewController *mp = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [[mp moviePlayer] prepareToPlay];
    [[mp moviePlayer] setShouldAutoplay:YES];
    [[mp moviePlayer] setControlStyle:2];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [self presentMoviePlayerViewControllerAnimated:mp];
    
}

-(void)pauseAudio:(id)sender
{
    UIButton *aButton = (UIButton *)sender;
    [aButton setBackgroundImage:[UIImage imageNamed:PLAY_AUDIO_IMAGE] forState:UIControlStateNormal];
    [aButton addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
    self.audioPlayer = nil;
}

-(void)playAudio:(id)sender
{
    UIButton *pauseButton = (UIButton *)sender;
    self.currentAudioButton = (UIButton *)sender; 
   // [pauseButton removeFromSuperview];
    [pauseButton setBackgroundImage:[UIImage imageNamed:PAUSE_IMAGE] forState:UIControlStateNormal];
    [pauseButton addTarget:self action:@selector(pauseAudio:) forControlEvents:UIControlEventTouchUpInside];

    
    Media *mediObj = (Media *)[self.scrollViewEntries objectAtIndex:[sender tag]];
    NSString *filename = mediObj.source;
   // NSLog(@"filename: %@", filename);
    NSURL *fileURL = [NSURL URLWithString:filename];
    NSLog(@"Audio URL %@",fileURL);
    
    NSLog(@"Playaudio button pressed");
    NSError *audioPlayerError = nil;
    NSError *audioSessionError = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance]; 
    if ([audioSession setCategory:AVAudioSessionCategoryAmbient error:&audioSessionError]){
        NSLog(@"Successfully set the audio session.");
    } else {
        NSLog(@"Could not set the audio session");
    }
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&audioPlayerError];
    if (self.audioPlayer != nil){
        self.audioPlayer.delegate = self;
        if ([self.audioPlayer prepareToPlay] ){
            [self.audioPlayer play];
            NSLog(@"Successfully started playing.");
        } else {
            NSLog(@"Failed to play the audio file.");
            self.audioPlayer = nil;
        }
    } else { 
        NSLog(@"Could not instantiate the audio player with error %@.", audioPlayerError);
    }
    
}


- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
}
/* The audio session has been deactivated here */
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags
{
    if (flags == AVAudioSessionInterruptionFlags_ShouldResume){ 
        [player play];
    }
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"did finsh plying..");
    [self.currentAudioButton setBackgroundImage:[UIImage imageNamed:PLAY_AUDIO_IMAGE] forState:UIControlStateNormal];
    [self.currentAudioButton addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
    
    //UIView *topView = self.audioButton.superview;
    //CGRect frame = self.audioButton.frame;
    //self.audioButton.hidden = YES;
    //[self.audioButton removeFromSuperview];
    /*
    self.audioButton = nil;
    self.audioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.audioButton.frame = frame;
    [self.audioButton setImage:[UIImage imageNamed:PLAY_AUDIO_IMAGE] forState:UIControlStateNormal];
    [self.audioButton addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [topView addSubview:self.audioButton];
    // [self.audioButton setNeedsDisplayInRect:self.audioButton.frame];
    //[self.audioButton reloadInputViews];
                                            */
    self.audioPlayer = nil;
    //self.audioButton.hidden = NO;
}

-(void)videoPlayBackDidFinish:(NSNotification*)notification
{       
    [self dismissMoviePlayerViewControllerAnimated];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // Disallow recognition of tap gestures in the segmented control.
    if ([touch.view isKindOfClass:[UIButton class]]) {//change it to your condition
        NSLog(@"Button Clicked");
        return NO;
    }
    NSLog(@"Printing gesture %@",gestureRecognizer);
    
    if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        
        //gestureRecognizer.enabled = NO;
    }
    else { 
        if([gestureRecognizer isKindOfClass:[UISwipeGestureRecognizer class]]) {
        NSLog(@"finding swipe");
        if (self.topBarView.alpha ==1) {
            self.topBarView.alpha = 0;

        }   
       // return NO;
        }
    }
    return YES;
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)editEntry
{
   // self.scrollView 
    NSLog(@"printing entry number for the scroll %i", self.entryEditNumber);
    
    self.entryEditObject = [self.scrollViewEntries objectAtIndex:[self.entryEditNumber integerValue]];
    [self performSegueWithIdentifier:@"Show Edit Entry" sender:self];
}

- (void)tap:(UITapGestureRecognizer *)recognizer
{
    int i = [[recognizer view] tag];
    NSLog(@"inside the gesture recognizer %i",i);
    NSLog(@"Number version of int: %@",[NSNumber numberWithInt:i]);
    self.entryEditNumber = [NSNumber numberWithInt:i];
    // make the uiview topbar appear for 5 seconds and then disappear again
    if(self.topBarView.alpha == 0) {
        self.topBarView.alpha = 1;
        [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(disappear) userInfo:nil repeats:FALSE];
        self.tapRec.enabled = NO;
    }
}

- (void)disappear
{
    self.tapRec.enabled = YES;
    self.topBarView.alpha = 0;
}

- (void)pinch:(UIPinchGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)handleSwipeFrom
{
    NSLog(@"Scroll view swipped");
    //if (recognizer.state == UIGestureRecognizerStateRecognized) {
      //  self.topBarView.alpha = 0;
       // [self.navigationController popViewControllerAnimated:YES];
    //}
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Show Edit Entry"]) {
        [segue.destinationViewController setUser:self.user];
        [segue.destinationViewController setLifeDatabase:self.lifeDatabase];
        [segue.destinationViewController setEntryEditObject:self.entryEditObject];
        [segue.destinationViewController setEntryOperation:self.entryOperation];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
