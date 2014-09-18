//
//  KreyosDataManager.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/18/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosDataManager.h"
#import "KreyosUtility.h"
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "RequestManager.h"
#import "DBManager.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AMSlideMenuMainViewController.h"
#import "KreyosFacebookController.h"
#import "LoginViewController.h"
#import "KreyosHomeViewController.h"
#import "BluetoothDelegate.h"

@interface KreyosDataManager () <UIAlertViewDelegate>

@end

@implementation KreyosDataManager
{
    UIViewController*       mActiveView;
    UINavigationController* m_delegateNavCon;
    int                     m_timerState;
}
@synthesize g_isFromSlideBar;

// -- SINGLETON INITIALIZER
static KreyosDataManager *sharedInstance = nil;

+ (KreyosDataManager *)sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

//Synthesize Variables
@synthesize FirmwareVersion;
@synthesize WorkOutStatusDict;
@synthesize StatsObjectArray;
@synthesize PointOfActivity;
@synthesize BasicStatsArray;
@synthesize ActivityReadDataProgress;
@synthesize totalData_Calories;
@synthesize totalData_DistanceInMeter;
@synthesize totalData_Steps;
@synthesize IsWorkoutMode                       = m_bIsWorkOutMode;
@synthesize TimerState                          = m_timerState;
@synthesize DisplayingService;
@synthesize BaseChildViews;

@synthesize IsMainBluetoothSearchShown;
@synthesize IsFromTutorial;
@synthesize IsFromSetupWatch;

- (id) init
{
    if ( self = [super init] )
    {
        [self initStatsObjectArray];
        [self initWorkStatusDict];
        [self initActivityDataHolder];
        [self initDataValues];
    }
    return self;
}

- (void) viewDidLoad
{
    
}

- (void)initDataValues
{
    sharedInstance = self;
    
    //Set Default Version of Firmware to 1
    FirmwareVersion = kUNKNOWN_VERSION ;
}

- (void) initStatsObjectArray
{
    StatsObjectArray = [[NSArray alloc] initWithObjects:@"Steps", @"Cadence", @"Heart", @"AvgHeart", @"MaxHeart", @"Calories", @"Distance", @"Altitude", @"Elevation", @"Totd", @"Speed", @"AvgSpeed", @"TopSpeed", @"Pace", @"AvgPace", @"CurrentLap", @"AvgLap", @"BestLap", nil];
    
    BasicStatsArray = [[NSArray alloc] initWithObjects:@"Steps", @"Distance", @"Calories", @"Cadence", @"Heart Rate", nil];
}

- (void) initActivityDataHolder
{
    //1:Header -- 2:Mode -- 3:Meta -- 4:Data
    PointOfActivity = [[NSMutableArray alloc] init];
}

- (void) feedActivityData :(NSArray*)pArray
{
    [PointOfActivity addObject:pArray];
}

-(NSUserDefaults*) getUserDefaults
{
    self.UserDefaults = [NSUserDefaults standardUserDefaults];
    
    return self.UserDefaults;
}

-(void) setIsWorkoutMode:(BOOL)IsWorkoutMode
{
    m_bIsWorkOutMode = IsWorkoutMode;
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

- (void) initWorkStatusDict
{
    WorkOutStatusDict = [[NSMutableDictionary alloc] init];
    /*
     Dictionary Contains :
     - Name
     - Icon
     - Unit of measurement
     */
    
    //Heart Rate
    [WorkOutStatusDict setObject:@"Heart Rate"              forKey:@"Heart"];
    [WorkOutStatusDict setObject:@"icon_sports_heart_rate"  forKey:@"HeartIcon"];
    [WorkOutStatusDict setObject:@"BPM"                     forKey:@"HeartMeasure"];
    
    //Avg Heart Rate
    [WorkOutStatusDict setObject:@"Avg Heart Rate"          forKey:@"AvgHeart"];
    [WorkOutStatusDict setObject:@"icon_sports_heart_rate"  forKey:@"AvgHeartIcon"];
    [WorkOutStatusDict setObject:@"BPM"                     forKey:@"AvgHeartMeasure"];
    
    //Max Heart Rate
    [WorkOutStatusDict setObject:@"Max Heart Rate"                  forKey:@"MaxHeart"];
    [WorkOutStatusDict setObject:@"icon_sports_heart_rate_max"      forKey:@"MaxHeartIcon"];
    [WorkOutStatusDict setObject:@"BPM"                             forKey:@"MaxHeartMeasure"];
    
    //Pace
    [WorkOutStatusDict setObject:@"Pace"                    forKey:@"Pace"];
    [WorkOutStatusDict setObject:@"icon_sports_pace"        forKey:@"PaceIcon"];
    [WorkOutStatusDict setObject:@"PER MILE"                forKey:@"PaceMeasure"];
    
    //Avg Pace
    [WorkOutStatusDict setObject:@"Avg Pace"                forKey:@"AvgPace"];
    [WorkOutStatusDict setObject:@"icon_sports_pace"        forKey:@"AvgPaceIcon"];
    [WorkOutStatusDict setObject:@"PER MILE"                forKey:@"AvgPaceMeasure"];
    
    //Current Lap
    [WorkOutStatusDict setObject:@"Current Lap"                   forKey:@"CurrentLap"];
    [WorkOutStatusDict setObject:@"icon_sports_lap_current"       forKey:@"CurrentLapIcon"];
    [WorkOutStatusDict setObject:@"PER MILE"                      forKey:@"CurrentLapMeasure"];
    
    //Avg Lap
    [WorkOutStatusDict setObject:@"Avg Lap"                     forKey:@"AvgLap"];
    [WorkOutStatusDict setObject:@"icon_sports_lap_average"     forKey:@"AvgLapIcon"];
    [WorkOutStatusDict setObject:@"PER MILE"                    forKey:@"AvgLapMeasure"];
    
    //BestLap
    [WorkOutStatusDict setObject:@"Best Lap"                    forKey:@"BestLap"];
    [WorkOutStatusDict setObject:@"icon_sports_lap_best"        forKey:@"BestLapIcon"];
    [WorkOutStatusDict setObject:@"MPH"                         forKey:@"BestLapMeasure"];
    
    //Time of the Day
    [WorkOutStatusDict setObject:@"Time of the day"                 forKey:@"Totd"];
    [WorkOutStatusDict setObject:@"icon_sports_time_of_the_day"     forKey:@"TotdIcon"];
    [WorkOutStatusDict setObject:@""                                forKey:@"TotdMeasure"];
    
    //Speed
    [WorkOutStatusDict setObject:@"Speed"                       forKey:@"Speed"];
    [WorkOutStatusDict setObject:@"icon_sports_speed"           forKey:@"SpeedIcon"];
    [WorkOutStatusDict setObject:@"KPH"                         forKey:@"SpeedMeasure"];
    
    //Avg speed
    [WorkOutStatusDict setObject:@"AvgSpeed"                    forKey:@"AvgSpeed"];
    [WorkOutStatusDict setObject:@"icon_sports_speed_average"   forKey:@"AvgSpeedIcon"];
    [WorkOutStatusDict setObject:@"KPH"                         forKey:@"AvgSpeedMeasure"];
    //Top speed
    [WorkOutStatusDict setObject:@"Top Speed"                   forKey:@"TopSpeed"];
    [WorkOutStatusDict setObject:@"icon_sports_speed_top"       forKey:@"AvgSpeedIcon"];
    [WorkOutStatusDict setObject:@"KPH"                         forKey:@"AvgSpeedMeasure"];
    
    //Calories
    [WorkOutStatusDict setObject:@"Calories"                        forKey:@"Calories"];
    [WorkOutStatusDict setObject:@"icon_sports_calories"            forKey:@"CaloriesIcon"];
    [WorkOutStatusDict setObject:@"CAL"                             forKey:@"CaloriesMeasure"];
    
    //Distance
    [WorkOutStatusDict setObject:@"Distance"                    forKey:@"Distance"];
    [WorkOutStatusDict setObject:@"icon_sports_distance"        forKey:@"DistanceIcon"];
    [WorkOutStatusDict setObject:@"MTR"                         forKey:@"DistanceMeasure"];
    
    
    //Altitude
    [WorkOutStatusDict setObject:@"Altitude"                    forKey:@"Altitude"];
    [WorkOutStatusDict setObject:@"icon_sports_altitude"        forKey:@"AltitudeIcon"];
    [WorkOutStatusDict setObject:@"FT"                          forKey:@"AltitudeMeasure"];
    
    //Elevation
    [WorkOutStatusDict setObject:@"Elevation"                   forKey:@"Elevation"];
    [WorkOutStatusDict setObject:@"icon_sports_elevation"       forKey:@"ElevationIcon"];
    [WorkOutStatusDict setObject:@"FT"                          forKey:@"ElevationMeasure"];
    
    //Steps
    [WorkOutStatusDict setObject:@"Steps"                       forKey:@"Steps"];
    [WorkOutStatusDict setObject:@"icon_sports_elevation"       forKey:@"StepsIcon"];
    [WorkOutStatusDict setObject:@""                            forKey:@"StepsMeasure"];
}

#pragma mark FOR TESTING
+ (void) RequestforFirmwareUpdate : (id)p_id  selector:(SEL) p_sel
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
#ifndef OFFLINE_BUILD
        NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc] init];
        [userDictionary setObject:[KreyosDataManager getUserDefaultEmail] forKey:@"email"];
        [userDictionary setObject:[KreyosDataManager getUserDefaultOath]  forKey:@"auth_token"];
        
        NSError * err;
        NSData * jsonData       = [NSJSONSerialization dataWithJSONObject:userDictionary options:0 error:&err];
        NSString * dataString   = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

        [[RequestManager rm] sendRequestPostMethod:kServerFirmwareURL withPostData:nil target:p_id selector:p_sel];
        
#else
        [[RequestManager rm]sendRequest:kServerFirmwareURL target:p_id selector:p_sel];
#endif
      
        
    });
}

#pragma mark GETUSERDATA
- (void) getSportsDataFromWeb:(id)sender
{
    NSString *email = [KreyosDataManager getUserDefaultEmail];
    NSString *oath = [KreyosDataManager getUserDefaultOath];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //~~~Remove synchronous request this will cause lag in the app instead use async request in Request manager
        //        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:kServerUserActivitiesURL@"?email=%@&auth_token=%@&metric=monthly", email, oath ]]];
        //        [self performSelectorInBackground:@selector(fetchedData:) withObject:data];
        
        [[RequestManager rm] sendRequest:[NSString stringWithFormat:@"%@?email=%@&auth_token=%@&metric=monthly", kServerUserActivitiesURL, email, oath ] target:self selector:@selector(fetchedData:)];
    });

}

-(void)fetchedData:(NSData*)responseData {
    
    if([[BluetoothDelegate instance]getDidLogout])return;
    
    NSArray *userData;
    NSMutableArray *userDataArray;
    NSDictionary *userActivity;
    
    userDataArray   = [[NSMutableArray alloc] init];
    userActivity    = [[NSDictionary alloc] init];
    
    if (responseData) {
        
        NSError *error     = nil;
        NSDictionary *json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:kNilOptions
                              error:&error];

#ifdef ENABLE_WEB_DATA_PRINT
        NSLog(@"DATA GATHERED [KreyosDataManager::fetchedData] %@",json);
#endif
        
        //INSERT 0 VALUES TO USERDATAARRAY
        for(int x=0; x < 30; x++ )
        {
            [userDataArray addObject:[NSNumber numberWithInt:0]];
        }
        
        //SAVE DATA TO LOCAL DB
        userData = [json objectForKey:@"user"];
        
        if (![userData count]) {
            return;
        }
        
#ifdef ENABLE_WEB_DATA_PRINT
        NSLog(@"+AA --------------------------------------------------------");
#endif
        for (NSDictionary *dictData in userData[0]) {
            NSDictionary *data = [userData[0] objectForKey:dictData];
            
            [userDataArray replaceObjectAtIndex:(int)ACTIVITY_CALORIES      withObject:[data objectForKey:@"calories"]];
            [userDataArray replaceObjectAtIndex:(int)ACTIVITY_STEPS         withObject:[data objectForKey:@"num_steps"]];
            [userDataArray replaceObjectAtIndex:(int)ACTIVITY_DISTANCE      withObject:[data objectForKey:@"distance"]];
            [userDataArray replaceObjectAtIndex:(int)ACTIVITY_CREATED_TIME  withObject:[data objectForKey:@"time"]];
            
#ifdef ENABLE_WEB_DATA_PRINT
            NSLog(@"KreyosDataManager::fetchedData Inserting dat from web: data:%@",data);
#endif
            
            [[DBManager getSharedInstance] recordActivity:userDataArray];
        }
#ifdef ENABLE_WEB_DATA_PRINT
        NSLog(@"-AA --------------------------------------------------------");
#endif
        
#ifdef ENABLE_WEB_DATA_PRINT
        NSLog(@"+BB --------------------------------------------------------");
        [[DBManager getSharedInstance] printUserActivities];
        NSLog(@"-BB --------------------------------------------------------");
#endif
        
        // +AS:07102014 refresh db data
        [[DBManager getSharedInstance] getActivitiesForUser];
    }
    
    // +AS:07232014 Reload Overall Activity Screen
    [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_OVERALL_ACTIVITIES
                                                        object:nil];
    
}

- (BOOL) isSessionExpired : (NSDictionary*) jsonDic navCont:(UINavigationController*)navCon
{
    if ([jsonDic objectForKey:@"success"] == NULL) {
        return false;
    }
    
    BOOL returnVal = false;
    int intval = [[jsonDic objectForKey:@"success"] intValue];
    m_delegateNavCon = navCon;
    
    if (intval == 0) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"User Alert" message:[jsonDic objectForKey:@"message"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
//        [alert show];
//
//        [[NSNotificationCenter defaultCenter]postNotificationName:USER_DID_LOG_OUT object:nil];
        
        returnVal = true;
    }
    
    return returnVal;
}

- (void) clearDataOnLogOut
{
    if ( [KreyosDataManager sharedInstance].isConnectedToWifi )
    {
        if ([KreyosDataManager sharedInstance].IsConnectedUsingFB )
        {
            [FBSession.activeSession closeAndClearTokenInformation];
            [FBSession.activeSession close];
            [FBSession setActiveSession:nil];
            
            UIAlertView *alert;
            alert = [[UIAlertView alloc]
                     initWithTitle:LOGOUT_SUCCESSFUL
                     message:@""
                     delegate: nil
                     cancelButtonTitle:nil
                     otherButtonTitles:@"OK", nil];
            alert.tag = 200;
            alert.delegate = self;
            [alert show];
            
            //SET NO FOR CONNECTEDUSINGFB
            [KreyosDataManager sharedInstance].IsConnectedUsingFB = NO;
        }
        
        //DELETE LOCAL DATA
        [[DBManager getSharedInstance] deleteAccountInDevice];
    }
}

#pragma mark SETTER
+ (void) setUserDefaultEmail:(NSString*)email
{
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:kUserEmail];
}

+ (void) setUserDefaultPass:(NSString*)pass
{
    [[NSUserDefaults standardUserDefaults] setObject:pass forKey:kUserPass];
}

+ (void) setUserDefaultOath:(NSString*)token
{
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:kUserToken];
}

+ (void) setUserUID:(NSString*)p_uid
{
    [[NSUserDefaults standardUserDefaults] setObject:p_uid forKey:kUserUID];
}

#pragma mark ExistingView
- (void) setActiveView : (UIViewController*) pView
{
    mActiveView = pView;
}

- (UIViewController*) getActiveView
{
    return mActiveView;
}

#pragma mark GETTER
+ (NSString*) getUserDefaultEmail
{
    NSString* string = [[NSUserDefaults standardUserDefaults] objectForKey:kUserEmail];
    return string;
}

+ (NSString*) getUserDefaultPassword
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUserPass];
}

+ (NSString*) getUserDefaultOath
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUserToken];
}

+ (NSString*) getUserUID
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUserUID];
}

@end
