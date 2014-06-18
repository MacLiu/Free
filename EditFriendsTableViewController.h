//
//  EditFriendsTableViewController.h
//  Fuse
//
//  Created by Mac Liu on 5/17/14.
//  Copyright (c) 2014 Mac Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditFriendsTableViewController : UITableViewController

@property (strong,nonatomic) NSArray *users; //of PFUsers
@property (strong, nonatomic) NSMutableArray *searchedFriends; // of PFUsers
@property (strong,nonatomic) NSMutableArray *currentUsersFriends; //of PFUsers
@property (strong,nonatomic) PFUser *currentUser;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBat;
@property (nonatomic) BOOL isFiltered;

@end
