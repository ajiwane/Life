//
//  SignUpViewController.m
//  JournalDatabase
//
//  Created by karthik jagadeesh on 6/29/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import "SignUpViewController.h"

#define BORDER 15
#define TEXTVIEWBORDER 10
#define TEXTHEIGHT 30
#define FROMTOP 80
#define kOFFSET_FOR_KEYBOARD 80.0

@implementation SignUpViewController

@synthesize lifeDatabase = _lifeDatabase;
@synthesize fetchedLoginResultsController = _fetchedLoginResultsController;
@synthesize user = _user;
@synthesize dateOfBirthPicker = _dateOfBirthPicker;
@synthesize dobBox = _dobBox;
@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize email = _email;
@synthesize confirmEmail = _confirmEmail;
@synthesize password = _password;
@synthesize confirmPassword = _confirmPassword;
@synthesize dateOfBirthButton = _dateOfBirthButton;
@synthesize maleButton = _maleButton;
@synthesize femaleButton = _femaleButton;
@synthesize dob = _dob;
@synthesize faceButton = _faceButton;
@synthesize gender = _gender;


- (void)viewDidUnload {
    [self setFirstName:nil];
    [self setLastName:nil];
    [self setEmail:nil];
    [self setPassword:nil];
    [self setConfirmEmail:nil];
    [self setConfirmPassword:nil];
    [self setDob:nil];
    [self setGender:nil];
    [super viewDidUnload];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}


//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard 
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}
/*
-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}
*/
-(void)keyboardWillHide {
    if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    if ([sender isEqual:self.confirmPassword]||[sender isEqual:self.password])
    {
        NSLog(@"This is the sender %@", sender);
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y >= 0)
        {
            [self setViewMovedUp:YES];
        }
    }
}


- (void)viewWillAppear:(BOOL)animated
{
/*
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:self.view.window];
  */  
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:self.view.window];
}

- (void)viewWillDisappear:(BOOL)animated
{
    /*
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
        name:UIKeyboardWillShowNotification object:nil];
    */
    [[NSNotificationCenter defaultCenter] removeObserver:self
        name:UIKeyboardWillHideNotification object:nil];
}

- (void) hideKeyboard {
    [self.firstName resignFirstResponder];
    [self.lastName resignFirstResponder];
    [self.email resignFirstResponder];
    [self.confirmEmail resignFirstResponder];
    [self.password resignFirstResponder];
    [self.confirmPassword resignFirstResponder];
    [self.dateOfBirthButton resignFirstResponder];
    [self.maleButton resignFirstResponder];
    [self.femaleButton resignFirstResponder];
}

- (void)setupLoginFetchedResultsController
{
    
    //********************** must check that email is unique
    BOOL emailExit = [Login doesEmailExit:self.email.text inManangedObjectContext:self.lifeDatabase.managedObjectContext];
    
    if(emailExit == YES) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @""
                              message: @"Email already in use"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        //alert
        NSLog(@"User already exists.");
    } else {
        
        NSDictionary *loginInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.email.text, @"LOGIN_INFO_EMAIL", self.password.text, @"LOGIN_INFO_PASSWORD", nil];
        Login *login = [Login loginWithInfo:loginInfo inManagedObjectContext:self.lifeDatabase.managedObjectContext];
        
        //****************calculate age
        //figure out how to get a date fro DOB, string won't work
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.firstName.text, @"USER_INFO_FIRSTNAME", self.lastName.text, @"USER_INFO_LASTNAME", self.gender, @"USER_INFO_GENDER", login, @"USER_INFO_LOGIN", nil];
        User *user = [User userWithInfo:userInfo inManagedObjectContext:self.lifeDatabase.managedObjectContext];
        login.user = user;
        
        if([LifeHeader stringIsEmpty:self.firstName.text]) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @""
                                  message: @"Enter First Name!"
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            
            //******************* make field red or alert
            
        }
        else if(![self.email.text isEqualToString:self.confirmEmail.text] || ([LifeHeader stringIsEmpty:self.email.text]) || ([LifeHeader stringIsEmpty:self.confirmEmail.text])) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @""
                                  message: @"Emails do not match!"
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            //throw error , make red
        } else if (![self.password.text isEqualToString:self.confirmPassword.text] || ([LifeHeader stringIsEmpty:self.password.text]) || ([LifeHeader stringIsEmpty:self.confirmPassword.text])) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle: @""
                                  message: @"Passwords do not match!"
                                  delegate: nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            //throw error, make red
        } else {
            
            NSDictionary *loginInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.email.text, @"LOGIN_INFO_EMAIL", self.password.text, @"LOGIN_INFO_PASSWORD", nil];
            
            NSLog(@"Login Info: %@", loginInfo);
            Login *login = [Login loginWithInfo:loginInfo inManagedObjectContext:self.lifeDatabase.managedObjectContext];
            
            if(login==nil) {
                NSLog(@"Unable to create login object");
            }
            
            //****************calculate age
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.firstName.text, @"USER_INFO_FIRSTNAME", self.lastName.text, @"USER_INFO_LASTNAME", login, @"USER_INFO_LOGIN", self.dob, @"USER_INFO_DOB", self.gender, @"USER_INFO_GENDER",  nil];
            NSLog(@"User_INFO %@", userInfo);
            
            self.user = [User userWithInfo:userInfo inManagedObjectContext:self.lifeDatabase.managedObjectContext];
            if(self.user != nil) {
                login.user = self.user;
                NSLog(@"I am performing the segue in signup with user %@", self.user);
                [self performSegueWithIdentifier:@"Show Life" sender:self];
            } else {
                NSLog(@"Unable to create new User");
            }
        }
    }
}

- (void)useDocument
{
    NSLog(@"In useDocument");
    if(![[NSFileManager defaultManager] fileExistsAtPath:[self.lifeDatabase.fileURL path]]) {
        [self.lifeDatabase saveToURL:self.lifeDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [self setupLoginFetchedResultsController];
            //[self fetchFlickerDataIntoDocument:self.photoDatabase];
        }];
    } else if (self.lifeDatabase.documentState == UIDocumentStateClosed) {
        [self.lifeDatabase openWithCompletionHandler:^(BOOL success) {
            [self setupLoginFetchedResultsController];
        }];
    } else if (self.lifeDatabase.documentState == UIDocumentStateNormal) {
        [self setupLoginFetchedResultsController];
    }
}

-(void)newSignUp
{
    NSLog(@"calling useDocument now in newSignUp");
    [self useDocument];
    /*
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Login"];
    //request.predicate = [NSPredicate predicateWithFormat:@"email = %@", self.email];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"email" ascending:NO]];
    self.fetchedLoginResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.lifeDatabase.managedObjectContext sectionNameKeyPath:nil cacheName:nil];*/
}



- (void)setLifeDatabase:(UIManagedDocument *)lifeDatabase
{
    NSLog(@"I'm in setlifeDatabase- SIgnUpView");
    if(_lifeDatabase != lifeDatabase) {
        NSLog(@"Inside the if in setlifedatabase");
        _lifeDatabase = lifeDatabase;
    }
    
    //[self useDocument];
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"I'm in the Segue of SignUp");
    if([segue.identifier isEqualToString:@"Show Life"]) {
        [segue.destinationViewController setUser:self.user];
        NSLog(@"settingup LifeDatabase in SignUPView");
        [segue.destinationViewController setLifeDatabase:self.lifeDatabase];
    }
}

- (void) pickDate
{
    self.dobBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    self.dobBox.backgroundColor = [LifeHeader getBorderColor];

    UIImage *currentImg = [UIImage imageNamed:@"paper32.jpg"];
    UIImageView* topImageView = [[UIImageView alloc] initWithImage:currentImg];
    CGRect rect = [[UIScreen mainScreen] bounds];
    topImageView.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    [self.dobBox addSubview:topImageView];
    
    self.dateOfBirthPicker = [[UIDatePicker alloc] init];
    self.dateOfBirthPicker.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height/8, 0, 0);

    UIView *dateOfBirthPickerView = [[UIView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height/8, self.dateOfBirthPicker.frame.size.width, self.dateOfBirthPicker.frame.size.height)];
    
    dateOfBirthPickerView.transform = CGAffineTransformMakeScale(0.75f, 0.75f);
    
    [self.dateOfBirthPicker setDatePickerMode:UIDatePickerModeDate];
    NSCalendar *startCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:1990];
    [components setMonth:1];
    [components setDay:1];
    [self.dateOfBirthPicker setDate:[startCalendar dateFromComponents:components] animated:NO];
    
    [dateOfBirthPickerView addSubview:self.dateOfBirthPicker];
    [self.dobBox addSubview:dateOfBirthPickerView];
    
    UIButton *cancelDOB = [LifeHeader getButton];
    cancelDOB.frame = CGRectMake(90, 300, 60, 30);
    [cancelDOB setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelDOB addTarget:self action:@selector(cancelDOB) forControlEvents:UIControlEventTouchUpInside];
    [self.dobBox addSubview:cancelDOB];
    
    UIButton *doneDOB = [LifeHeader getButton];
    doneDOB.frame = CGRectMake(170, 300, 60, 30);
    [doneDOB setTitle:@"Done" forState:UIControlStateNormal];
    [doneDOB addTarget:self action:@selector(saveDOB) forControlEvents:UIControlEventTouchUpInside];
    // make the dateviewpicker pop up
    [self.dobBox addSubview:doneDOB];

    [self.view addSubview:self.dobBox];
}

- (void) cancelDOB
{
    [self.dobBox removeFromSuperview];
}

- (void) saveDOB
{
    self.dob = [self.dateOfBirthPicker date];
    NSString *dateString = [LifeHeader stringFromDate:self.dob];
    [self.dateOfBirthButton setTitle:dateString forState:UIControlStateNormal];
    self.dateOfBirthButton.titleLabel.font = [UIFont systemFontOfSize:10];
    [self.dobBox removeFromSuperview];
}

- (void) takePhoto
{
    // take a picture of the users face
}

- (void) genderPushed: (id) sender
{
    if ([sender tag]==0) {
        self.femaleButton.backgroundColor = [UIColor grayColor];
        self.maleButton.backgroundColor = [UIColor colorWithRed:.125 green:.125 blue:.125 alpha:.8];
        self.gender = @"Male";
    } else {
        self.maleButton.backgroundColor = [UIColor grayColor];
        self.femaleButton.backgroundColor = [UIColor colorWithRed:.125 green:.125 blue:.125 alpha:.8];
        self.gender = @"Female";
    }
    
}

- (void) backToLogin
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.lifeDatabase) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:DATABASE];
        
        NSLog(@"Println url: %@", url);
        self.lifeDatabase = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    
    UIImage *currentImg = [UIImage imageNamed:@"paper32.jpg"];
    UIImageView* topImageView = [[UIImageView alloc] initWithImage:currentImg];
    CGRect rect = [[UIScreen mainScreen] bounds];
    topImageView.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    [self.view addSubview:topImageView];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.faceButton = [UIButton buttonWithType:UIButtonTypeCustom];   
    self.faceButton.frame = CGRectMake(rect.size.width/2-25, 10, 50, 50);
    self.faceButton.backgroundColor = [UIColor colorWithRed:.125 green:.125 blue:.125 alpha:.5];
    [self.faceButton addTarget:self action:@selector(takePhoto) forControlEvents:UIControlStateNormal];
    
    //first name
    self.firstName = [[UITextField alloc] initWithFrame:CGRectMake(BORDER, FROMTOP, rect.size.width/2-2*BORDER, TEXTHEIGHT)];
    self.firstName.borderStyle = UITextBorderStyleLine;
    self.firstName.placeholder = @"First Name";     
    [self.firstName setDelegate:self];
    
    //last name
    self.lastName = [[UITextField alloc] initWithFrame:CGRectMake(rect.size.width/2 + BORDER, FROMTOP, rect.size.width/2-2*BORDER, TEXTHEIGHT)];
    self.lastName.borderStyle = UITextBorderStyleLine;
    self.lastName.placeholder = @"Last Name";
    [self.lastName setDelegate:self];


    //email
    self.email = [[UITextField alloc] initWithFrame:CGRectMake(BORDER, FROMTOP+TEXTHEIGHT+TEXTVIEWBORDER, rect.size.width - 2*BORDER, TEXTHEIGHT)];
    self.email.borderStyle = UITextBorderStyleLine;
    self.email.placeholder = @"Email";
    [self.email setDelegate:self];


    //confirm email
    self.confirmEmail = [[UITextField alloc] initWithFrame:CGRectMake(BORDER, FROMTOP+2*TEXTHEIGHT+TEXTVIEWBORDER, rect.size.width-2*BORDER, TEXTHEIGHT)];
    self.confirmEmail.borderStyle = UITextBorderStyleLine;
    self.confirmEmail.placeholder = @"Confirm Email";
    [self.confirmEmail setDelegate:self];


    //password
    self.password = [[UITextField alloc] initWithFrame:CGRectMake(BORDER, FROMTOP+3*TEXTHEIGHT+2*TEXTVIEWBORDER, rect.size.width-2*BORDER, TEXTHEIGHT)];
    self.password.borderStyle = UITextBorderStyleLine;
    self.password.placeholder = @"Password";
    self.password.secureTextEntry = YES;
    [self.password setDelegate:self];


    //confirm password
    self.confirmPassword = [[UITextField alloc] initWithFrame:CGRectMake(BORDER, FROMTOP+4*TEXTHEIGHT+2*TEXTVIEWBORDER, rect.size.width-2*BORDER, TEXTHEIGHT)];
    self.confirmPassword.borderStyle = UITextBorderStyleLine;
    self.confirmPassword.placeholder = @"Confirm Password";
    self.confirmPassword.secureTextEntry = YES;
    [self.confirmPassword setDelegate:self];

    
    //date of birth
    self.dateOfBirthButton = [LifeHeader getButton];
    self.dateOfBirthButton.frame = CGRectMake(BORDER, FROMTOP+5*TEXTHEIGHT+3*TEXTVIEWBORDER, 80, 40);
    [self.dateOfBirthButton setTitle:@"DOB" forState:UIControlStateNormal];
    [self.dateOfBirthButton addTarget:self action:@selector(pickDate) forControlEvents:UIControlEventTouchUpInside];
    
    //pick a gender
    self.maleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.maleButton.frame = CGRectMake(rect.size.width - BORDER - 105, 280, 50, TEXTHEIGHT);
    self.gender = 0;
    self.maleButton.backgroundColor = [UIColor colorWithRed:.125 green:.125 blue:.125 alpha:.8];
    [self.maleButton setTitle:@"Male" forState:UIControlStateNormal];
    [self.maleButton addTarget:self action:@selector(genderPushed:) forControlEvents:UIControlEventTouchUpInside];
    self.maleButton.titleLabel.font = [UIFont systemFontOfSize:10];
    self.maleButton.tag = 0;

    
    self.femaleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.femaleButton.frame = CGRectMake(rect.size.width-BORDER-50, 280, 50, TEXTHEIGHT);
    self.femaleButton.backgroundColor = [UIColor grayColor];
    [self.femaleButton setTitle:@"Female" forState:UIControlStateNormal];
    [self.femaleButton addTarget:self action:@selector(genderPushed:) forControlEvents:UIControlEventTouchUpInside];
    self.femaleButton.titleLabel.font = [UIFont systemFontOfSize:10];
    self.femaleButton.tag = 1;
    
    // submit all data to front end
    UIButton *submitUserButton = [LifeHeader getButton];
    submitUserButton.frame = CGRectMake(200, rect.size.height -120, 100, 40);
    [submitUserButton setTitle:@"Enter Life" forState:UIControlStateNormal];
    [submitUserButton addTarget:self action:@selector(newSignUp) forControlEvents:UIControlEventTouchUpInside];
    
    
    // submit all data to front end
    UIButton *backToLogin = [LifeHeader getButton];
    backToLogin.frame = CGRectMake(50, rect.size.height -120, 100, 40);
    [backToLogin setTitle:@"Back" forState:UIControlStateNormal];
    [backToLogin addTarget:self action:@selector(backToLogin) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.faceButton];
    [self.view addSubview:self.firstName];
    [self.view addSubview:self.lastName];
    [self.view addSubview:self.email];
    [self.view addSubview:self.confirmEmail];
    [self.view addSubview:self.password];
    [self.view addSubview:self.confirmPassword];
    [self.view addSubview:self.dateOfBirthButton];
    [self.view addSubview:self.maleButton];
    [self.view addSubview:self.femaleButton];
    [self.view addSubview:submitUserButton];
    [self.view addSubview:backToLogin];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
}

@end
