//
//  ViewController.h
//  Fuse
//
//  Created by Mac Liu on 5/15/14.
//  Copyright (c) 2014 Mac Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

//IBOutlets
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

//IBAction
- (IBAction)loginButtonPressed:(UIButton *)sender;


@end
