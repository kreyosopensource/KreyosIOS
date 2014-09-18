//
//  MainVC.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/6/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "MainVC.h"
#import "KreyosUtility.h"
#import <FacebookSDK/FacebookSDK.h>
#import "KreyosFacebookController.h"
#import "LoginViewController.h"
#import "KreyosDataManager.h"
#import "DBManager.h"
#import "RequestManager.h"
#import "BluetoothDelegate.h"
#import "DeviceManager.h"

@interface MainVC ()
{
    
}
@end

@implementation MainVC
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UINavigationBar appearance] setBarTintColor:LOGIN_BLUE];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
	// Do any additional setup after loading the view.
    
}


/*----------------------------------------------------*/
#pragma mark - Overriden Methods -
/*----------------------------------------------------*/

- (NSString *)segueIdentifierForIndexPathInLeftMenu:(NSIndexPath *)indexPath
{
    NSString *identifier = @"";
    switch (indexPath.row) {
        case 0:
            
            identifier = @"home";
            
        break;
        case 1:
            
            identifier = @"activity";
        
        break;
        case 2:
            
            identifier = @"sports";
        
            [KreyosDataManager sharedInstance].g_isFromSlideBar = YES;
            
        break;
        case 3:
            
            identifier = @"dailytarget";
            
        break;
        case 7:
            
            identifier = @"firmware";
            
        break;
    }
    
    return identifier;
}

- (NSString *)segueIdentifierForIndexPathInRightMenu:(NSIndexPath *)indexPath
{
    NSString *identifier = @"";
    switch (indexPath.row) {
        case 0:
            identifier = @"bluetooth";
            break;
        case 1:
            identifier = @"datetime";
            break;
        case 2:
            identifier = @"alarm";
            break;
        case 3:
            identifier = @"firmware";
            break;
        case 4:
            identifier = @"personal";
            break;
        case 5:
            identifier = @"tutorial";
            [KreyosDataManager sharedInstance].IsFromSetupWatch = YES;
            break;
        case 6:
            //Log out on app
            [self logoutCheck];
            
            break;
    }
    
    return identifier;
}

- (CGFloat)leftMenuWidth
{
    return 250;
}

- (CGFloat)rightMenuWidth
{
    return 250;
}

- (void)configureLeftMenuButton:(UIButton *)button
{
    CGRect frame = button.frame;
    frame = CGRectMake(0, 0, 37.5f, 40);
    button.frame = frame;
    button.backgroundColor = [UIColor clearColor];
    [button setImage:[UIImage imageNamed:@"menuicon"] forState:UIControlStateNormal];
}

- (void)configureRightMenuButton:(UIButton *)button
{
    CGRect frame = button.frame;
    frame = CGRectMake(0, 0, 37.5f, 40);
    button.frame = frame;
    
    button.backgroundColor = [UIColor clearColor];
    [button setImage:[UIImage imageNamed:@"watchicon"] forState:UIControlStateNormal];
}

- (void) configureSlideLayer:(CALayer *)layer
{
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 1;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 5;
    layer.masksToBounds = NO;
    layer.shadowPath =[UIBezierPath bezierPathWithRect:self.view.layer.bounds].CGPath;
}

- (AMPrimaryMenu)primaryMenu
{
    return AMPrimaryMenuLeft;
}


// Enabling Deepnes on left menu
- (BOOL)deepnessForLeftMenu
{
    return YES;
}

// Enabling Deepnes on left menu
- (BOOL)deepnessForRightMenu
{
    return YES;
}

// Enabling darkness while left menu is opening
- (CGFloat)maxDarknessWhileLeftMenu
{
    return 0.5;
}

// Enabling darkness while right menu is opening
- (CGFloat)maxDarknessWhileRightMenu
{
    return 0.5;
}

#pragma mark ALERT VIEW SHOW ON LOGOUT
- (void) logoutCheck
{
    if ( [KreyosDataManager sharedInstance].isConnectedToWifi )
    {
        if ([KreyosDataManager sharedInstance].IsConnectedUsingFB )
        {
            [FBSession.activeSession closeAndClearTokenInformation];
            [FBSession.activeSession close];
            [FBSession setActiveSession:nil];
            
            /*
            UIAlertView *alert;
            alert = [[UIAlertView alloc]
                     initWithTitle:@"Logout Succesful"
                     message:@""
                     delegate: nil
                     cancelButtonTitle:nil
                     otherButtonTitles:@"OK", nil];
            alert.tag = 200;
            alert.delegate = self;
            [alert show];
            */
            
            //SET NO FOR CONNECTEDUSINGFB
            [KreyosDataManager sharedInstance].IsConnectedUsingFB = NO;
            
            NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc] init];
            assert([KreyosDataManager getUserDefaultEmail]);
            
            [userDictionary setObject:[KreyosDataManager getUserDefaultEmail] forKey:@"email"];
            [userDictionary setObject:[KreyosDataManager getUserDefaultOath]  forKey:@"auth_token"];
            [userDictionary setObject:[KreyosFacebookController sharedInstance].getUserID forKey:@"uid"];
            
            NSError * err;
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:userDictionary options:0 error:&err];
            NSString * dataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            [[RequestManager rm] sendRequestPostMethod:kServerSessionLogoutURL withPostData:dataString target:self selector:@selector(tryLogOut:)];
        }
        else
        {
            NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc] init];
            assert([KreyosDataManager getUserDefaultEmail]);
            [userDictionary setObject:[KreyosDataManager getUserDefaultEmail] forKey:@"email"];
            [userDictionary setObject:[KreyosDataManager getUserDefaultOath]  forKey:@"auth_token"];
            
            NSError * err;
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:userDictionary options:0 error:&err];
            NSString * dataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            [[RequestManager rm] sendRequestPostMethod:kServerSessionLogoutURL withPostData:dataString target:self selector:@selector(tryLogOut:)];
        }
        
        //DELETE LOCAL DATA
        [[NSNotificationCenter defaultCenter]postNotificationName:USER_DID_LOG_OUT object:nil];
        [[BluetoothDelegate instance]setDidLogOut:YES];
    }
    
}

- (void) tryLogOut:(NSData*)responseData
{
    NSString *dataParsed = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"LOGOUT DATA RECEIVED %@", dataParsed);
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    UIAlertView *alert;
    
    [[DBManager getSharedInstance] deleteAccountInDevice];
    
    if ( [[json objectForKey:@"status"] intValue] == kLoginSuccess)
    {
        //DELETE LOCAL DATA
        //[[DBManager getSharedInstance] deleteAccountInDevice];
        alert = [[UIAlertView alloc]
                          initWithTitle:LOGOUT_SUCCESSFUL
                          message:@""
                          delegate: nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil];
        alert.tag = 200;
    }
    else
    {
        //This is when session expired, need to add message later
        alert = [[UIAlertView alloc]
                 initWithTitle:LOGOUT_SUCCESSFUL
                 message:@""
                 delegate: nil
                 cancelButtonTitle:@"OK"
                 otherButtonTitles:nil, nil];
        
        alert.tag = 200;
    }
    
    alert.delegate = self;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    //0 is cancel
    if(alertView.tag == 200)
    {
        // If the session state is any of the two "open" states when the button is clicked
        if (   FBSession.activeSession.state == FBSessionStateOpen
            || FBSession.activeSession.state == FBSessionStateOpenTokenExtended)
        {
            
            // Close the session and remove the access token from the cache
            // The session state handler (in the app delegate) will be called automatically
            [FBSession.activeSession closeAndClearTokenInformation];
            
            
            [[KreyosFacebookController sharedInstance] releaseData];
            // If the session state is not any of the two "open" states when the button is clicked
        }
    }
    
    LoginViewController *login =  [self.storyboard instantiateViewControllerWithIdentifier:LOGIN_STORYBOARD];
    [self.navigationController pushViewController:login animated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[DeviceManager GetStoryboard] bundle:nil];
    
    LoginViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:LOGIN_STORYBOARD];
    
    [self presentViewController:ivc animated:YES completion:nil];
}

@end
