//
//  InboxTableViewController.h
//  Fuse
//
//  Created by Mac Liu on 5/16/14.
//  Copyright (c) 2014 Mac Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InboxTableViewController : UITableViewController

@property(strong,nonatomic) NSMutableArray *messages;
@property(strong,nonatomic) PFObject *selectedMessage;
@property (strong,nonatomic) UIRefreshControl *refreshControl;

//IBActions
- (IBAction)LogOutButtonPressed:(UIBarButtonItem *)sender;

@end
