//
//  SplashPage.m
//  KreyosIosApp
//
//  Created by Kreyos on 9/8/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "SplashPage.h"
#import "BluetoothDelegate.h"
#import "KreyosDataManager.h"
#import "KreyosUtility.h"
#import "AccountManager.h"
#import "Profile.h"

@interface SplashPage ()

@end

@implementation SplashPage

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
    
    NSLog(@"%@", (NSString*)[[NSUserDefaults standardUserDefaults]objectForKey:@"info_0"]);
    
    //~~~Boot bluetooth manager
    [[BluetoothDelegate instance]initialize];
    [[BluetoothDelegate instance] setIsUpdating:NO];
    
    //~~~SetUpAccount Default account
    [AccountManager getSharedAccountManager].userID = 1;
    static NSString* email  = @"user";
    static NSString* auth   = @"123123qweasd123qwesd123qwe123";
    
    [KreyosDataManager setUserDefaultOath:auth];
    [KreyosDataManager setUserDefaultEmail:email];
    
    Profile* profile        = [[Profile alloc] init];
    [profile clear];
    profile.email           = email;
    profile.kreyosToken     = auth;
    [profile saveProfile];
    
    //~~~Boot kreyos manager
    [[DBManager getSharedInstance]initDB];
    
    BOOL IS_TUTORIAL_DONE = [[USERDATA objectForKey:@"isUserLogB4"]boolValue];
    const char* transitionKey[] =
    {
        "splashToTutorial",
        "goToMain",
    };
    
#ifdef ENABLE_SHOW_TUTORIAL
    [self performSegueWithIdentifier:[NSString stringWithUTF8String:transitionKey[1]] sender:self];
#else
    [self performSegueWithIdentifier:[NSString stringWithUTF8String:transitionKey[IS_TUTORIAL_DONE]] sender:self];
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
