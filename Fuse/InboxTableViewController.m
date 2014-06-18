//
//  InboxTableViewController.m
//  Fuse
//
//  Created by Mac Liu on 5/16/14.
//  Copyright (c) 2014 Mac Liu. All rights reserved.
//

#import "InboxTableViewController.h"
#import "ViewController.h"
#import "PictureViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MSCellAccessory.h"

@interface InboxTableViewController () <UIAlertViewDelegate, UITextFieldDelegate>

@property (strong,nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *statusButton;

@end

@implementation InboxTableViewController

-(MPMoviePlayerController *)moviePlayer
{
    if (!_moviePlayer) {
        _moviePlayer = [[MPMoviePlayerController alloc] init];
    }
    return _moviePlayer;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getMessages];

    [self.navigationController.navigationBar setHidden:NO];
    
    // Set the status button accordingly to previous status
    if ([[[PFUser currentUser] objectForKey:@"status"] length] > 0) {
        self.statusButton.title = @"Plans";
    } else {
        self.statusButton.title = @"Free";
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor blackColor];
    
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        NSLog(@" %@ %@",currentUser.username, currentUser.email);
    } else {
        [self performSegueWithIdentifier:@"toLogin" sender:self];
    }
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(getMessages) forControlEvents:UIControlEventValueChanged];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.destinationViewController isKindOfClass:[ViewController class]]) {
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
    } else if ([segue.destinationViewController isKindOfClass:[PictureViewController class]]){
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES];
        PictureViewController *targetVC = segue.destinationViewController;
        targetVC.message = self.selectedMessage;
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
    return [self.messages count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFObject *message = [self.messages objectAtIndex:indexPath.row];
    cell.textLabel.text = [message objectForKey:@"senderUsername"];
    cell.textLabel.textColor = [UIColor blueColor];
    cell.detailTextLabel.text = [message objectForKey:@"messageStatus"];
    cell.detailTextLabel.textColor = [UIColor blueColor];
    
    // Gets the messages file type and determine whether it is a image or video file
    if ([[message objectForKey:@"fileType"] isEqualToString:@"image"]) {
        cell.imageView.image = [UIImage imageNamed:@"icon_image"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"icon_video"];
    }
    
    cell.backgroundColor = [UIColor cyanColor];
    
    // Cell Accessory View
    cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DISCLOSURE_INDICATOR color:[UIColor blueColor]];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedMessage = [self.messages objectAtIndex:indexPath.row];
    
    // Determines whether the filetype is an image or video
    if ([[self.selectedMessage objectForKey:@"fileType"] isEqualToString:@"image"]) {
        [self performSegueWithIdentifier:@"toPicture" sender:self];
    } else {
        PFFile *file = [self.selectedMessage objectForKey:@"file"];
        NSURL *url = [NSURL URLWithString:file.url];
        self.moviePlayer.contentURL = url;
        [self.moviePlayer prepareToPlay];
        [self.moviePlayer requestThumbnailImagesAtTimes:0 timeOption:MPMovieTimeOptionNearestKeyFrame];

        [self.view addSubview:self.moviePlayer.view];
        [self.moviePlayer setFullscreen:YES animated:YES];
    }
    
    [self.selectedMessage setObject:@"Opened" forKey:@"messageStatus"];
    [self.selectedMessage saveInBackground];
    [self.tableView reloadData];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PFObject *message = [self.messages objectAtIndex:indexPath.row];
        [self.messages removeObjectAtIndex:indexPath.row];
        [message deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message could not be deleted" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];
            } else {
               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message successfully deleted" message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];
            }
        }];
        [self.tableView reloadData];
    }
}

- (IBAction)LogOutButtonPressed:(UIBarButtonItem *)sender
{
    [PFUser logOut];
    [self performSegueWithIdentifier:@"toLogin" sender:sender];
}

- (IBAction)statusButtonPressed:(UIBarButtonItem *)sender {
    PFUser *currentUser = [PFUser currentUser];
    
    if ([self.statusButton.title isEqualToString:@"Free"]) {

        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Update Status" message:@"" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Update", nil];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField* textfield = [alert textFieldAtIndex:0];
        textfield.placeholder = @"What are your plans?";
        textfield.delegate = self;
        [alert show];
    } else {
        self.statusButton.title = @"Free";
        currentUser[@"status"] = @"";
        
        
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"%@", error);
            }
        }];
    }
}

#pragma mark - TextField Deleagte

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return (range.location < 40);
}

#pragma mark - AlertView Delegates

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    PFUser *currentUser = [PFUser currentUser];
    if (buttonIndex == 1){
        NSLog(@"%@", [[alertView textFieldAtIndex:0] text]);
        
        self.statusButton.title = @"Plans";
        currentUser[@"status"] = [[alertView textFieldAtIndex:0] text];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"%@", error);
            }
        }];
    }
}

#pragma mark - Helper Methods


- (void)getMessages
{
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query whereKey:@"recieverIds" equalTo:[[PFUser currentUser] objectId]];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.messages = [objects mutableCopy];
            [self.tableView reloadData];
        }
        if ([self.refreshControl isRefreshing]) {
            [self.refreshControl endRefreshing];
        }
    }];
}
         
@end
