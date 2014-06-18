//
//  CameraTableViewController.h
//  Fuse
//
//  Created by Mac Liu on 5/20/14.
//  Copyright (c) 2014 Mac Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraTableViewController : UITableViewController

@property (strong, nonatomic) UIImagePickerController *camera;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *video;

@property (strong, nonatomic) NSArray *friends;
@property (strong, nonatomic) PFRelation *friendsRelations;
@property (strong, nonatomic) NSMutableArray *messageReceivers;

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)sendButtonPressed:(id)sender;
@end
