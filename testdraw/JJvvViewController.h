//
//  JJvvViewController.h
//  testdraw
//
//  Created by jesse on 8/4/14.
//  Copyright (c) 2014 pptv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJvvArcsectorControl.h"

@interface JJvvViewController : UIViewController
@property (weak, nonatomic) IBOutlet JJvvArcsectorControl *arcsectorControl;
@property (weak, nonatomic) IBOutlet UIImageView *OutputImage;

@end
