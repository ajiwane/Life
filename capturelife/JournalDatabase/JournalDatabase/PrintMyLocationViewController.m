//
//  PrintMyLocationViewController.m
//  JournalDatabase
//
//  Created by karthik jagadeesh on 7/2/12.
//  Copyright (c) 2012 uc berkeley. All rights reserved.
//

#import "PrintMyLocationViewController.h"

@implementation PrintMyLocationViewController
@synthesize myLocationManager = _myLocationManager;
@synthesize myGeocoder = _myGeocoder;
@synthesize user = _user;
@synthesize lifeDatabase = _lifeDatabase;
@synthesize places = _places;
@synthesize place = _place;
@synthesize currentXMLProperty = _currentXMLProperty;


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{ /* We received the new location */
   // NSLog(@"Latitude = %f", newLocation.coordinate.latitude);
   // NSLog(@"Longitude = %f", newLocation.coordinate.longitude);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    /* Failed to receive user's location */
}

#pragma mark - View lifecycle

- (void) setLifeDatabase:(UIManagedDocument *)lifeDatabase
{
    _lifeDatabase = lifeDatabase;
}

- (void) setUser:(User *) user
{
    _user = user;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([CLLocationManager locationServicesEnabled]) {
        self.myLocationManager = [[CLLocationManager alloc] init];
        self.myLocationManager.delegate = self;
        self.myLocationManager.purpose = @"To provide functionality based on user's current location.";
        [self.myLocationManager startUpdatingLocation]; 
    } else {
        /* Location services are not enabled. Take appropriate action: for instance, prompt the user to enable the location services */
        NSLog(@"Location services are not enabled");
        
    }
}


-(void)saveLocationHelper:(NSDictionary *)checkInInfo
{
    CheckIn *checkin = [CheckIn checkInWithInfo:checkInInfo inManagedObjectContext:self.lifeDatabase.managedObjectContext];
    [self.navigationController popViewControllerAnimated:YES];   
}


- (void) findAddress: (CLLocation *) location
{
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/xml?key=AIzaSyBO2EGTRqmXh2vtd7aJcxygS6hpKj5xsUY&radius=500&sensor=false&location=%f,%f", 37.785, -122.406];
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

- (IBAction)saveLocation:(id)sender {
    CLLocation *location = self.myLocationManager.location;
    [self findAddress:location];
    
    NSLog(@"places: %@",self.places);
    self.myGeocoder = [[CLGeocoder alloc] init];
    
    NSDate *todaysDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSString * justDate = [dateFormatter stringFromDate:todaysDate];
    NSDate * date = [dateFormatter dateFromString:justDate];
    NSMutableDictionary *checkInInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys: self.user, @"CHECKIN_INFO_WHOADDED", date, @"CHECKIN_INFO_DATE", todaysDate, @"CHECKIN_INFO_DATEWITHTIME", nil];
    
    [self.myGeocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error){
        if (error == nil && [placemarks count] > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            [checkInInfo setValue:placemark.country forKey:@"CHECKIN_INFO_PLACE"];
            [checkInInfo setValue:placemark.postalCode forKey:@"CHECKIN_INFO_LOCATION"];
            [self saveLocationHelper:checkInInfo];
        } else if (error==nil && [placemarks count] == 0) {
            NSLog(@"No results found");
        } else if (error != nil) {
            NSLog(@"error occurred");
        }
    }];
    // This is currently adding nil
    // we will need to create a view for user to pick location and add to db based on that
    

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    
    [self.myLocationManager stopUpdatingLocation]; 
    self.myLocationManager = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
