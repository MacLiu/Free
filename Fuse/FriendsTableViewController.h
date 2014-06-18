//
//  FriendsTableViewController.h
//  Fuse
//
//  Created by Mac Liu on 5/18/14.
//  Copyright (c) 2014 Mac Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendsTableViewController : UITableViewController

@property (strong, nonatomic) PFRelation *friendsRelations;
@property (strong, nonatomic) NSArray *friends;
@property (strong, nonatomic) PFUser *selectedFriend;
@end
