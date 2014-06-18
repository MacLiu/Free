//
//  PictureViewController.h
//  Fuse
//
//  Created by Mac Liu on 5/30/14.
//  Copyright (c) 2014 Mac Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PictureViewController : UIViewController

@property(strong,nonatomic) PFObject *message;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end
