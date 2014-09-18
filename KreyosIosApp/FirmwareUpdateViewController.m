//
//  FirmwareUpdateViewController.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/14/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "FirmwareUpdateViewController.h"
#import "KreyosBluetoothViewController.h"
#import "LKreyosService.h"
#import "AMSlideMenuMainViewController.h"
#import "UIViewController+AMSlideMenu.h"
#import "KreyosDataManager.h"
#import "LoginViewController.h"
#import "KreyosUtility.h"
#import "BluetoothDelegate.h"

@interface FirmwareUpdateViewController ()
{
    AMSlideMenuMainViewController *mainVC;
    LKreyosService  *displayingService;
    NSTimer         *m_updateAgaintimer;
    NSString        *m_pathToDownload;
}
@end

@implementation FirmwareUpdateViewController
@synthesize firmwareUpdateBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        if ([KreyosDataManager sharedInstance].DisplayingService)
        {
            [[KreyosDataManager sharedInstance].DisplayingService readVersion];
        }
    }
    return self;
}

-(IBAction)updateWatchFirmware:(id)sender
{
    //uncomments the following 2 lines to test read today's activity data
    //[[KreyosBluetoothViewController sharedInstance] initializeFileTransistor];
    //[[KreyosBluetoothViewController sharedInstance] readActivityData];
    
    //uncomments the following 2 lines to test firmware upgrade
    //[[BluetoothDelegate instance] initializeFileTransistor];
    [[BluetoothDelegate instance] updateWatchFirmware];
    
    //uncomments the following line to test sports data sync
    //[[KreyosBluetoothViewController sharedInstance] startTestSportsData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //add button on top
    mainVC              = [AMSlideMenuMainViewController getInstanceForVC:self];
    displayingService   = [KreyosDataManager sharedInstance].DisplayingService;
    [[BluetoothDelegate instance] initializeFileTransistor];
    
    if(mainVC.rightMenu)
    {
        [self addRightMenuButton];
        [self addLeftMenuButton];//Disable swipes
        
        [self disableSlidePanGestureForRightMenu];
        [self disableSlidePanGestureForLeftMenu];
    }
    
    if  ( displayingService )
    {
        self.updateLabel.text = [NSString stringWithFormat:@"Current Version : %@", [KreyosDataManager sharedInstance].FirmwareVersion ];
        
        //READ WATCH PROTOCOL TO GET WATCH VERSION
        [[BluetoothDelegate instance].currentlyDisplayingService readVersion];
        
        //FIRE AN OBSERVER TO CHECK WATCH VERSION
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(checkIfLatestVersion:)
         name:@"firmwareVersion"
         object:nil];
    }
    else
    {
        self.updateLabel.text = @"No Device Connected";
    }
    
    //HIDE indicator
    [self.activityIndicator setHidden:YES];
    
    // set the current view on BluetoothDelegate
    [[BluetoothDelegate instance] setCurrentView:self];
}

- (void) checkIfLatestVersion:(id)sender
{
    //Remove observer after getting the watch version
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"firmwareVersion" object:nil];
   
    [self.activityIndicator setHidden:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.updateLabel.text = [NSString stringWithFormat:@"Current Version : %@", [KreyosDataManager sharedInstance].FirmwareVersion ];
    });
}

- (IBAction)checkForVersion:(UIButton*)sender
{
    if ([sender.titleLabel.text isEqualToString:@"DONE UPDATING"]) {
        return;
    }
    
    if ( displayingService )
    {
        [self.activityIndicator setHidden:NO];
        self.updateLabel.text = @"Firmware is updating, Please wait...";
        [self.firmwareUpdateBtn setEnabled:NO];
        [self.firmwareUpdateBtn setTitle:@"Please wait..." forState:UIControlStateNormal];
        
            //Check for version
        [displayingService readVersion];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(updateCheck:)
         name:@"firmwareVersion"
         object:nil];
        
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Device not found" message:@"Please connect your Kreyos watch" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (void) updateCheck:(id)sender
{
    [KreyosDataManager RequestforFirmwareUpdate:self selector:@selector(checkLatestVersion:)];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self name:@"firmwareVersion" object:nil];
}

- (void) checkLatestVersion : (NSData*) pResponse
{
    NSString *dataParsed = [[NSString alloc] initWithData:pResponse encoding:NSUTF8StringEncoding];
    NSLog(@"REQUEST FIRMWARE DATA RECEIVED %@", dataParsed);
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:pResponse
                          
                          options:kNilOptions
                          error:&error];

    NSString *version   = [json objectForKey:@"version_number"];
    m_pathToDownload    = [json objectForKey:@"attachment"];
    
#ifndef OFFLINE_BUILD
    if ([[KreyosDataManager sharedInstance] isSessionExpired:json navCont:self.navigationController]) {

        [[KreyosDataManager sharedInstance] clearDataOnLogOut];
        LoginViewController *login =  [self.storyboard instantiateViewControllerWithIdentifier:LOGIN_STORYBOARD];
        [self.navigationController pushViewController:login animated:YES];
        return;
    }
    
#endif
    
    if ( [[KreyosDataManager sharedInstance].FirmwareVersion isEqualToString: version])
    {
        [self.activityIndicator setHidden:YES];
        [self.firmwareUpdateBtn setEnabled:YES];
        [self.firmwareUpdateBtn setTitle:@"Check for Updates" forState:UIControlStateNormal];
        [self.updateLabel setText:@"Your Software is up to date."];
    }
    else
    {
        //NOTIFICATION IF UPDATE IS DONE
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(doneUpdating:)
         name:@"firmwareUpdate"
         object:nil];
        
        //NOTIFICATION IF CALLING UPDATE TO WATCH HAS FAILED
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(removeTimer:)
         name:@"tryUpdateAgain"
         object:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [BluetoothDelegate instance].firmwareURL    = [NSString stringWithFormat:@"https:%@", m_pathToDownload];
            [[BluetoothDelegate instance]initializeUpdateFirmWare];
        });
    }
}

- (void) removeTimer:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"tryUpdateAgain" object:nil];
    [self.firmwareUpdateBtn setTitle:@"Please wait..." forState:UIControlStateNormal];
    [m_updateAgaintimer invalidate];
    
    //REMOVE MENUNS
    [self removeLeftMenuButton];
    [self removeRightMenuButton];
    
}
                                     
- (void) tryUpdateAgain:(id)sender
{
//    [[BluetoothDelegate instance] updateWatchFirmware:[NSString stringWithFormat:@"https:%@", m_pathToDownload]];
}

- (void) doneUpdating:(id)sender
{
    [self addRightMenuButton];
    [self addLeftMenuButton];
    
    NSLog(@"DONE UPDATING");    [self.activityIndicator setHidden:YES];
    [self.updateLabel setText:@"Your software is now up to date"];
    [self.firmwareUpdateBtn setEnabled:YES];
    [self.firmwareUpdateBtn setTitle:@"DONE UPDATING" forState:UIControlStateNormal];
    [self.firmwareUpdateBtn addTarget:self action:@selector(goToMain:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) goToMain:(id)sender
{
    [self performSegueWithIdentifier:@"doneUpdating" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
