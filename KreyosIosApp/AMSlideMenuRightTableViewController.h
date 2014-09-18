//
//  AMSlideMenuRightTableViewController.h
//  AMSlideMenu
//
//  Created by Artur Mkrtchyan on 12/24/13.
//  Copyright (c) 2013 SocialObjects Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomUILabelBebas.h"

@class AMSlideMenuMainViewController;

@interface AMSlideMenuRightTableViewController : UITableViewController

@property (strong, nonatomic) AMSlideMenuMainViewController *mainVC;

- (void)openContentNavigationController:(UINavigationController *)nvc;

//SET CONNECTED OR DISCONNECTED
@property (weak, nonatomic) IBOutlet CustomUILabelBebas *m_connectStatusLbl;

@end
