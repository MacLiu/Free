//
//  EditFriendsTableViewController.m
//  Fuse
//
//  Created by Mac Liu on 5/17/14.
//  Copyright (c) 2014 Mac Liu. All rights reserved.
//

#import "EditFriendsTableViewController.h"
#import "MSCellAccessory.h"

@interface EditFriendsTableViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation EditFriendsTableViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
 
    PFQuery *query = [PFUser query];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"%@ %@",error, error.userInfo);
        } else {
            self.users = objects;
            [self.tableView reloadData];
        }
    }];
    
    self.currentUser = [PFUser currentUser];
}

- (void)viewDidLoad
{
   [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor blackColor];
    self.searchBat.barTintColor = [UIColor blackColor];
    
    self.searchedFriends = [[NSMutableArray alloc] init];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchBat.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (self.isFiltered) {
        return [self.searchedFriends count];
    }
    return [self.users count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor blackColor];
    
    // Configure the cell...
    PFUser *user;
    if (self.isFiltered) {
        user = [self.searchedFriends objectAtIndex:indexPath.row];
    } else {
        user = [self.users objectAtIndex:indexPath.row];
    }
    
    // Determines if the user is the current user
    if ([user.objectId isEqualToString:[[PFUser currentUser] objectId]]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (Me)", user.username];
    } else {
        cell.textLabel.text = user.username;
    }
    
    cell.textLabel.textColor = [UIColor whiteColor];
    
    if ([self isFriend:user]){
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:[UIColor blueColor]];
    } else {
        cell.accessoryView = nil;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBat resignFirstResponder];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    PFRelation *relationWithFriends = [self.currentUser relationForKey:@"friendRelation"];
    PFUser *user = [self.users objectAtIndex:indexPath.row];
    
    if ([self isFriend:user]) {
        cell.accessoryView = nil;
        
        for (PFUser *friend in self.currentUsersFriends) {
            if ([friend.objectId isEqualToString:user.objectId]){
                [self.currentUsersFriends removeObject:friend];
                break;
            }
        }
        
        [relationWithFriends removeObject:user];
    } else {
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:[UIColor blueColor]];
        [self.currentUsersFriends addObject:user];
        [relationWithFriends addObject:user];
    }
    
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"%@ %@",error,[error userInfo]);
        }
    }];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Search Bar Delegates

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.searchedFriends removeAllObjects];
    if ([searchText length] == 0) {
        self.isFiltered = NO;
    } else {
        self.isFiltered = YES;
        
        for (PFUser *user in self.users) {
            NSString *username = user.username;
            
            NSRange searchRange = [username rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (searchRange.location != NSNotFound) {
                [self.searchedFriends addObject:user];
            }
        }
        
    }
    [self.tableView reloadData];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.tableView resignFirstResponder];
    [self.searchBat resignFirstResponder];
}



#pragma mark - Helper Methods

-(BOOL)isFriend:(PFUser *)user
{
    for (PFUser *friend in self.currentUsersFriends) {
        if ([friend.objectId isEqualToString:user.objectId]) return YES;
    }
    return NO;
}



@end