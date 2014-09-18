//
//  AMSlideMenuRightTableViewController.m
//  AMSlideMenu
//
//  Created by Artur Mkrtchyan on 12/24/13.
//  Copyright (c) 2013 SocialObjects Software. All rights reserved.
//

#import "AMSlideMenuRightTableViewController.h"
#import "AMSlideMenuMainViewController.h"
#import "AMSlideMenuContentSegue.h"
#import "KreyosDataManager.h"
#import "KreyosUtility.h"

@interface AMSlideMenuRightTableViewController ()

@end

@implementation AMSlideMenuRightTableViewController

/*----------------------------------------------------*/
#pragma mark - Lifecycle -
/*----------------------------------------------------*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionUpdate:) name:CHANGE_TOPBAR_COLOR object:nil];
    [self connectionUpdate:nil];
}

- (void)openContentNavigationController:(UINavigationController *)nvc
{
#ifdef AMSlideMenuWithoutStoryboards
    AMSlideMenuContentSegue *contentSegue = [[AMSlideMenuContentSegue alloc] initWithIdentifier:@"contentSegue" source:self destination:nvc];
    [contentSegue perform];
#else
    NSLog(@"This methos is only for NON storyboard use! You must define AMSlideMenuWithoutStoryboards \n (e.g. #define AMSlideMenuWithoutStoryboards)");
#endif
}

/*----------------------------------------------------*/
#pragma mark - TableView delegate -
/*----------------------------------------------------*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *segueIdentifier = [self.mainVC segueIdentifierForIndexPathInRightMenu:indexPath];
    if (segueIdentifier && segueIdentifier.length > 0)
    {
        [self performSegueWithIdentifier:segueIdentifier sender:self];
    }
}

/*---------------*/
#pragma mark Connection Update
/*---------------*/
- (void) connectionUpdate : (id)sender
{
    if ([KreyosDataManager sharedInstance].HasConnectedDevice)
        [self.m_connectStatusLbl setText:@"WATCH CONNECTED"];
    else
        [self.m_connectStatusLbl setText:@"WATCH DISCONNECTED"];
}

@end
