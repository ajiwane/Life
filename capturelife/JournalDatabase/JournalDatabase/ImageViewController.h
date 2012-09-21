//
//  ImageViewController.h
//
//  Created by CS193p Instructor.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"
@interface ImageViewController : UIViewController

@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) Photo *photo;

@end
