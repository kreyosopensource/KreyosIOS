//
//  KreyosUIViewBaseViewController.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/6/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVGKImage.h"
#import "SVGKImageView.h"
#import "SVGKFastImageView.h"
#import "SVGKLayeredImageView.h"

@interface KreyosUIViewBaseViewController : UIViewController

- (void)animateTextField:(UITextField*)textField up:(BOOL)up;
- (void) hideNavigationItem:(UIViewController*)p_vc;
- (void) unlockScreen : (id) sender;
- (void) lockScreen : (id) sender;
@end
