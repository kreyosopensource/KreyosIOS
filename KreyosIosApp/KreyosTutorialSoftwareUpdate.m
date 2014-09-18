//
//  KreyosTutorialSoftwareUpdate.m
//  KreyosIosApp
//
//  Created by Kreyos on 8/26/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosTutorialSoftwareUpdate.h"
#import "KreyosUtility.h"
#import "KreyosDataManager.h"
#import "BluetoothDelegate.h"


@interface KreyosTutorialSoftwareUpdate ()
{
    NSTimer* m_refreshTimer;
}

@end

@implementation KreyosTutorialSoftwareUpdate

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self SetUpFetchTimer];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(checkIfLatestVersion:)
     name:@"firmwareVersion"
     object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [m_refreshTimer invalidate];
    m_refreshTimer = nil;
}

-(void)SetUpFetchTimer
{
    if (!m_refreshTimer)
    {
        m_refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                          target:self
                                                        selector:@selector(readVersion)
                                                        userInfo:nil
                                                         repeats:YES];

    }
}

-(void)readVersion
{
    [[BluetoothDelegate instance].currentlyDisplayingService readVersion];
}

#pragma mark CHECK FOR LATET FIRMWARE
- (void) checkIfLatestVersion:(id)sender
{
    [KreyosDataManager RequestforFirmwareUpdate:self selector:@selector(firmwareRequest:)];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void) firmwareRequest:(NSData*)pData
{
    NSString *dataParsed = [[NSString alloc] initWithData:pData encoding:NSUTF8StringEncoding];
    NSLog(@"REQUEST FIRMWARE DATA RECEIVED %@", dataParsed);
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:pData
                          
                          options:kNilOptions
                          error:&error];
    NSString *version = [json objectForKey:@"version_number"];
    NSString *pathToDownload = [json objectForKey:@"attachment"];
    
    double delayInSeconds   = 4.0;
    BOOL IS_EQUAL           = NO;
    if ( [version isEqualToString: [KreyosDataManager sharedInstance].FirmwareVersion])
    {
        [self.mLoadingIndicator setHidden:YES];
        [self.mLabelUpdate setText:@"Your Software is up to date."];
        
        IS_EQUAL = YES;
    }
    else
    {
        [BluetoothDelegate instance].firmwareURL = [NSString stringWithFormat:@"https:%@", pathToDownload];
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
        const char* NEXT_SCENE[] = { "goToUpdatingScene" ,"goToMain" };
       [self performSegueWithIdentifier:[NSString stringWithUTF8String:NEXT_SCENE[IS_EQUAL]] sender:self];
    });
    
    [[BluetoothDelegate instance].currentlyDisplayingService writeTest:(int8_t)1];
}

@end
