//
//  SignUpViewController.m
//  Fuse
//
//  Created by Mac Liu on 5/16/14.
//  Copyright (c) 2014 Mac Liu. All rights reserved.
//

#import "SignUpViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor cyanColor];
}

- (IBAction)signUpButtonPressed:(UIButton *)sender {
    NSString *username = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *name = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *passwordConfirm = [self.confirmPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *phoneNumber = [[NSString stringWithFormat:@"%@",self.number.text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([password isEqualToString:passwordConfirm]) {
        if ([username length] == 0 || [password length] == 0 || [phoneNumber length] == 0 || [name length] == 0) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Could not sign up!" message:@"Please make sure all fields are valid" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        } else {
            PFUser *newUser = [PFUser user];
            newUser.username = username;
            newUser.password = password;
            newUser[@"name"] = name;
            newUser[@"phoneNumber"] = phoneNumber;
            
            [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"Try again" otherButtonTitles: nil];
                    [alert show];
                } else {
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Password did not match. Please try again! " delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
    
}

- (IBAction)xButtonPressed:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
