//
//  FriendsTableViewController.m
//  Fuse
//
//  Created by Mac Liu on 5/18/14.
//  Copyright (c) 2014 Mac Liu. All rights reserved.
//

#import "FriendsTableViewController.h"
#import "EditFriendsTableViewController.h"

@interface FriendsTableViewController ()

@end

@implementation FriendsTableViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    PFUser *currentUser = [PFUser currentUser];
    self.friendsRelations = [currentUser objectForKey:@"friendRelation"];
    PFQuery *query = [self.friendsRelations query];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"%@ %@", error, [error userInfo]);
        } else {
            self.friends = objects;
            [self.tableView reloadData];
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[EditFriendsTableViewController class]]) {
        EditFriendsTableViewController *TargetVC = segue.destinationViewController;
        TargetVC.currentUsersFriends = [NSMutableArray arrayWithArray:self.friends];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.friends count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    
    // Determines if the user is the current user
    if ([user.objectId isEqualToString:[[PFUser currentUser] objectId]]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (Me)", user.username];
    } else {
        cell.textLabel.text = user.username;
    }
    
    // Determines whether the user is free or not
    cell.detailTextLabel.text = [user objectForKey:@"status"];
    
    if ([self userIsBusy:user]) {
        [self havePlans:cell];
    } else {
        cell.backgroundColor = [UIColor cyanColor];
        cell.textLabel.textColor = [UIColor blueColor];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    
    // Determine whether selected friend is busy or not
    if ([self userIsBusy:user]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Do not disturb!" message:@"The person you are trying to call is is not FREE at the moment. Please try again later." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    } else {
        //Make phone call to selected user
        NSString *phoneCallNum = [NSString stringWithFormat:@"tel://%@",[user objectForKey:@"phoneNumber"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneCallNum]];
    }
}

#pragma mark - Helper Methods

// Determines whether the friend is busy by checking their status in the server
-(BOOL)userIsBusy:(PFUser *)user
{
    return ([[user objectForKey:@"status"] length] > 0);
}

// Setting the cell if the user is busy
-(void)havePlans: (UITableViewCell *)cell
{
    cell.backgroundColor = [UIColor redColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
}
@end
