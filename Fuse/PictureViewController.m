//
//  PictureViewController.m
//  Fuse
//
//  Created by Mac Liu on 5/30/14.
//  Copyright (c) 2014 Mac Liu. All rights reserved.
//

#import "PictureViewController.h"

@interface PictureViewController ()

@end

@implementation PictureViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = [NSString stringWithFormat:@"Sent from %@",[self.message objectForKey:@"senderUsername"]];
    
    // Get the image file and set it to the imageView
    PFFile *file = [self.message objectForKey:@"file"];
    NSURL *url = [[NSURL alloc] initWithString:file.url];
    NSData *data = [NSData dataWithContentsOfURL:url];
    self.imageView.image = [UIImage imageWithData:data];
}

// Saves image to users photo album when button is pressed
- (IBAction)saveButtonPressed:(id)sender {
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, nil,nil, nil);
}

@end
