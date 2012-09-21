//
//  journalViewController.m
//  JournalDatabase
//
//  Created by karthik jagadeesh on 6/25/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import "journalViewController.h"


@implementation journalViewController
@synthesize loginEmail = _loginEmail;
@synthesize loginPassword = _loginPassword;
@synthesize lifeDatabase = _lifeDatabase;
@synthesize user= _user;

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}

- (void) hideKeyboard {
    [self.loginPassword resignFirstResponder];
    [self.loginEmail resignFirstResponder];
}

-(void)setupFetchedResultsController 
{
    NSDictionary *loginInfo = [NSDictionary dictionaryWithObjectsAndKeys: self.loginEmail.text, @"LOGIN_INFO_EMAIL", self.loginPassword.text, @"LOGIN_INFO_PASSWORD", nil];
    
    BOOL userExist = [Login checkUser:loginInfo inManangedObjectContext:self.lifeDatabase.managedObjectContext];
    
    if(userExist == NO) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @""
                              message: @"Wrong email or password!"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        
    } else {
        
        Login *login = [Login loginWithInfo:loginInfo inManagedObjectContext:self.lifeDatabase.managedObjectContext];
        self.user = login.user;
        /*
         NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys: @"Bob", @"USER_INFO_FIRSTNAME", @"Jones", @"USER_INFO_LASTNAME", [[NSNumber alloc] initWithInt:10], @"USER_INFO_ID", login, @"USER_INFO_LOGIN", nil];
    */
        //self.user = [User userWithInfo:userInfo inManagedObjectContext:self.lifeDatabase.managedObjectContext];
        //login.user = self.user;
        if ([login.password isEqualToString:self.loginPassword.text]) {
            [self performSegueWithIdentifier:@"Show Life" sender:self];
        }
    }
}

- (void)useDocument
{
    if(![[NSFileManager defaultManager] fileExistsAtPath:[self.lifeDatabase.fileURL path]]) {
        NSLog(@"Creating database file");
        [self.lifeDatabase saveToURL:self.lifeDatabase.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            [self setupFetchedResultsController];
            //[self fetchFlickerDataIntoDocument:self.lifeDatabase];
        }];
    } else if (self.lifeDatabase.documentState == UIDocumentStateClosed) {
        NSLog(@"Opeing the database file");
       // NSLog(@"at %@", self.lifeDatabase.fileURL);
        [self.lifeDatabase openWithCompletionHandler:^(BOOL success) {
            [self setupFetchedResultsController];
            // pass 
        }];
    } else if (self.lifeDatabase.documentState == UIDocumentStateNormal) {
        NSLog(@"database file is open");
        [self setupFetchedResultsController];
        // pass
    }
}

- (void)signInPressed
{
    [self useDocument];
}

- (void) signUp
{
    [self performSegueWithIdentifier:@"Show SignUp" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"Show Life"]) {
        [segue.destinationViewController setUser:self.user];
        [segue.destinationViewController setLifeDatabase:self.lifeDatabase];
    }
    else if([segue.identifier isEqualToString:@"Show SignUp"]) {
       // [segue.destinationViewController setLifeDatabase:self.lifeDatabase];
        //NoOpp
    }
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
    
    self.navigationController.navigationBarHidden = YES;
    
    UIImage *currentImg = [UIImage imageNamed:@"paper32.jpg"];
    UIImageView* topImageView = [[UIImageView alloc] initWithImage:currentImg];
    CGRect rect1 = [[UIScreen mainScreen] bounds];
    topImageView.frame = CGRectMake(0, 0, rect1.size.width, rect1.size.height);
    [self.view addSubview:topImageView];
    
    //first name
    self.loginEmail = [[UITextField alloc] initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width-40, 30)];
    self.loginEmail.borderStyle = UITextBorderStyleLine;
    self.loginEmail.placeholder = @"Login";     
    
    //first name
    self.loginPassword = [[UITextField alloc] initWithFrame:CGRectMake(20, 135, self.view.bounds.size.width-40, 30)];
    self.loginPassword.borderStyle = UITextBorderStyleLine;
    self.loginPassword.placeholder = @"Password";
    self.loginPassword.secureTextEntry = YES;
    
    UIButton *login = [LifeHeader getButton];
    login.frame = CGRectMake(200, 200, 80, 30);
    [login addTarget:self action:@selector(signInPressed) forControlEvents:UIControlEventTouchUpInside];
    [login setTitle:@"Login" forState:UIControlStateNormal];
    
    UIButton *signUp = [LifeHeader getButton];
    signUp.frame = CGRectMake(200, 30, 80, 30);
    [signUp addTarget:self action:@selector(signUp) forControlEvents:UIControlEventTouchUpInside];
    [signUp setTitle:@"Sign Up" forState:UIControlStateNormal];
    
    [self.view addSubview:login];
    [self.view addSubview:self.loginEmail];
    [self.view addSubview:self.loginPassword];
    [self.view addSubview:signUp];
    
    
    [self.loginEmail setDelegate:(id)self];
    [self textFieldShouldReturn:self.loginEmail];
    [self.loginPassword setDelegate:(id)self];
    [self textFieldShouldReturn:self.loginPassword];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
    gestureRecognizer.cancelsTouchesInView = NO;
}

@end
