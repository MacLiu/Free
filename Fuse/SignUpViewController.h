//
//  SignUpViewController.h
//  Fuse
//
//  Created by Mac Liu on 5/16/14.
//  Copyright (c) 2014 Mac Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController 

//IBOutlets
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (strong, nonatomic) IBOutlet UITextField *number;

//IBAction
- (IBAction)signUpButtonPressed:(UIButton *)sender;
- (IBAction)xButtonPressed:(UIButton *)sender;
@end
