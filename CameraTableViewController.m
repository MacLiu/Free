//
//  CameraTableViewController.m
//  Fuse
//
//  Created by Mac Liu on 5/20/14.
//  Copyright (c) 2014 Mac Liu. All rights reserved.
//
#import <MobileCoreServices/UTCoreTypes.h>
#import "CameraTableViewController.h"
#import "MSCellAccessory.h"

@interface CameraTableViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@end

@implementation CameraTableViewController

-(NSMutableArray *)messageReceivers
{
    if (!_messageReceivers) {
        _messageReceivers = [[NSMutableArray alloc] init];
    }
    return _messageReceivers;
}

-(PFRelation *)friendsRelations{
    if (!_friendsRelations) {
        _friendsRelations = [[PFUser currentUser] objectForKey:@"friendRelation"];
    }
    return _friendsRelations;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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

 
    if (self.image == nil && [self.video length] == 0) {
        self.camera = [[UIImagePickerController alloc] init];
        self.camera.delegate = self;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ) {
            self.camera.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            self.camera.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        self.camera.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.camera.sourceType];
        self.camera.allowsEditing = NO;
        self.camera.videoMaximumDuration = 15;
        
        [self presentViewController:self.camera animated:NO completion:nil];
    }
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

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tabBarController setSelectedIndex:0];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage]) {
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    } else {
        self.video = (NSString *)[[info objectForKey:UIImagePickerControllerMediaURL] path];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
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
    cell.textLabel.text = user.username;
    
    if ([self.messageReceivers containsObject:user.objectId]) {
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:[UIColor blueColor]];
    } else {
        cell.accessoryView = nil;
    }
    
    // Determines if the user is the current user
    if ([user.objectId isEqualToString:[[PFUser currentUser] objectId]]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (Me)", user.username];
    } else {
        cell.textLabel.text = user.username;
    }
    
    
    // Determines whether the user is free or not
    cell.detailTextLabel.text = [user objectForKey:@"status"];
    
    if ([cell.detailTextLabel.text length] > 0) {
        [self havePlans:cell];
    } else {
        cell.backgroundColor = [UIColor cyanColor];
        cell.textLabel.textColor = [UIColor blueColor];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    PFUser *user = [self.friends objectAtIndex:indexPath.row];

    if ([[user objectForKey:@"status"] length] == 0) {
        if (cell.accessoryView == nil) {
            cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:[UIColor blueColor]];
            [self.messageReceivers addObject:user.objectId];
        } else {
            cell.accessoryView = nil;
            [self.messageReceivers removeObject:user.objectId];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Do not disturb!" message:@"The person you are trying to message is not FREE at the moment. Please try again later." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
}


#pragma mark - IBActions

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender {
    [self clearData];
    [self.tabBarController setSelectedIndex:0];
}

- (IBAction)sendButtonPressed:(id)sender {
    if (self.image == nil && [self.video length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please make sure a photo or video is selected" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [self presentViewController:self.camera animated:NO completion:nil];
    } else {
        [self sendMessage];
        [self.tabBarController setSelectedIndex:0];
    }
    
}

#pragma mark - Helper Methods

-(void)clearData
{
    [self.messageReceivers removeAllObjects];
    self.image = nil;
    self.video = nil;
}

-(void)sendMessage
{
    NSString *fileName;
    NSString *fileType;
    NSData *fileData;
    
    if (self.image != nil) {
        UIImage *newImage = [self resizeImageWithWidth:320.0 Height:480.0];
        fileData = UIImagePNGRepresentation(newImage);
        fileName = @"image.png";
        fileType = @"image";
    } else {
        fileData = [NSData dataWithContentsOfFile:self.video];
        fileName= @"video.mov";
        fileType = @"video";
    }
    
    PFFile *file = [PFFile fileWithName:fileName data:fileData];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message Failed" message:@"Please try resending the message" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        } else {
            PFObject *message = [PFObject objectWithClassName:@"Message"];
            [message setObject:file forKey:@"file"];
            [message setObject:fileType forKey:@"fileType"];
            [message setObject:self.messageReceivers forKey:@"recieverIds"];
            [message setObject:[[PFUser currentUser] username] forKey:@"senderUsername"];
            [message setObject:[[PFUser currentUser] objectId] forKey:@"senderId"];
            [message setObject:@"Unopened" forKey:@"messageStatus"];
            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message Failed" message:@"Please try resending the message" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message Sent!" message:@"Message was succesfully sent" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    [self clearData];
                }
            }];
        }
    }];
}

-(UIImage *)resizeImageWithWidth:(float)width Height:(float)height
{
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [self.image drawInRect:CGRectMake(0, 0, width, height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(void)havePlans: (UITableViewCell *)cell
{
    cell.backgroundColor = [UIColor redColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
}

@end
