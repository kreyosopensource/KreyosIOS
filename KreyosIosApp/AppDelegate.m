//
//  AppDelegate.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/6/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "Reachability.h"
#import <GoogleMaps/GoogleMaps.h>
#import "KreyosUtility.h"
#import "DBManager.h"
#import "LkDiscovery.h"
#import "DeviceManager.h"

@implementation AppDelegate
{
    id services_;
}

@synthesize g_bHasAlreadyLaunchOnce;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [DeviceManager LoadStoryBoard:self];
    [self setupAPIKeyForGPS];
    
    return YES;
}

-(void)setupAPIKeyForGPS
{
    if ([kAPIKey length] == 0)
    {
        // Blow up if APIKey has not yet been set.
        NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
        NSString *format = @"Configure APIKey inside SDKDemoAPIKey.h for your "
        @"bundle `%@`, see README.GoogleMapsSDKDemos for more information";
        @throw [NSException exceptionWithName:@"SDKDemoAppDelegate"
                                       reason:[NSString stringWithFormat:format, bundleId]
                                     userInfo:nil];
    }
    
    [GMSServices provideAPIKey:kAPIKey];
    services_ = [GMSServices sharedServices];
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    //--- > RUN UPDATE EVEN ON ENTERBACKGROUND
    UIApplication *app = [UIApplication sharedApplication];
    UIBackgroundTaskIdentifier bgTask = UIBackgroundTaskInvalid;
    
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
    }];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[NSNotificationCenter defaultCenter]postNotificationName:CHANGE_TOPBAR_COLOR object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:RELOAD_BLUETOOTH_TABLE object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

-(BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

- (BOOL)isConnectedToWifi
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStats = [reachability currentReachabilityStatus];
    
    if ( networkStats == NotReachable )
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Connection Problem"
                              message:@"This device is not connected to internet"
                              delegate: nil
                              cancelButtonTitle:NSLocalizedString(@"OK", @"InAppSettingsKit")
                              otherButtonTitles:nil];
        [alert show];
    }
    
    return networkStats != NotReachable;
}


@end
