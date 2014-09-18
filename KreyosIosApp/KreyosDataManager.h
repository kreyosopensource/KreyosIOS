//
//  KreyosDataManager.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/18/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosUIViewBaseViewController.h"
#import "LKreyosService.h"

@interface KreyosDataManager : NSObject
{
    BOOL m_bIsWorkOutMode;
}


//SINGLETON
+ (KreyosDataManager *)sharedInstance;


@property (nonatomic, assign) BOOL IsConnectedUsingFB;
@property (nonatomic, assign) BOOL HasConnectedDevice;
@property (retain, nonatomic) LKreyosService *DisplayingService;


@property (nonatomic, readwrite) NSMutableArray *BaseChildViews;
//RECONNECT DATA ARRAY
@property (nonatomic, readwrite) NSArray *PreviouslyConnectedDevices;

//FIRMWARE VERSION
@property (nonatomic, readwrite) NSString* FirmwareVersion;

//FROM TUTORIAL
@property (nonatomic, readwrite) BOOL IsFromTutorial;

//CONNECTED TO APP
@property (nonatomic, readwrite) BOOL IsMainBluetoothSearchShown;

//TO SPORTS
@property (nonatomic, readwrite) BOOL IsWorkoutMode;
@property (nonatomic, readwrite) int  TimerState;

//SPORTS MODE
@property (nonatomic, readwrite) short WorkModeType; //0 - running 1 - cycling

//GETTER SETTER
@property (nonatomic, readwrite) float totalData_Steps;
@property (nonatomic, readwrite) float totalData_DistanceInMeter;
@property (nonatomic, readwrite) float totalData_Calories;
@property (nonatomic, readwrite) float totalData_Cadence;
@property (nonatomic, readwrite) float totalData_HeartRate;
@property (nonatomic, readwrite) float totalData_Hours;
@property (nonatomic, readwrite) float totalData_Minutes;
@property (nonatomic, readwrite) float totalData_Seconds;

@property (nonatomic, readwrite) float Data_WeightInKg;
@property (nonatomic, readwrite) float Data_HeightInCm;
@property (nonatomic, readwrite) float Data_Circumference;

@property (strong, nonatomic) NSString* World_Clock0;
@property (strong, nonatomic) NSString* World_Clock2;
@property (strong, nonatomic) NSString* World_Clock3;
@property (strong, nonatomic) NSString* World_Clock4;
@property (strong, nonatomic) NSString* World_Clock5;
@property (strong, nonatomic) NSString* World_Clock6;

@property (nonatomic, readwrite) Byte Gesture0;
@property (nonatomic, readwrite) Byte Gesture1;
@property (nonatomic, readwrite) Byte Gesture2;
@property (nonatomic, readwrite) Byte Gesture3;
@property (nonatomic, readwrite) Byte Gesture4;

//SETUP WATCH VARIABLES
@property (nonatomic, readwrite) BOOL IsFromSetupWatch;


//USERDEFAULT
@property (nonatomic, readwrite) NSUserDefaults *UserDefaults;

//Trackable Items
@property (nonatomic, readonly) NSMutableDictionary *WorkOutStatusDict;
@property (nonatomic, readonly) NSArray *StatsObjectArray;
@property (nonatomic, readonly) NSArray *BasicStatsArray;

//Sports Timer Page Trigger Type
@property (nonatomic, readwrite) BOOL g_isFromSlideBar;
@property (nonatomic, readwrite) BOOL g_debugHeader;

//Activity Data Tracking
@property (strong, nonatomic) NSMutableArray *PointOfActivity;
@property (nonatomic, readwrite) float ActivityReadDataProgress;

//-- FUNCTIONS
- (void) feedActivityData:(NSArray*)pArray;
- (NSUserDefaults*) getUserDefaults;
- (BOOL)isConnectedToWifi;

//GETTER SETTERS

+ (void) setUserDefaultEmail:(NSString*)email;
+ (void) setUserDefaultPass:(NSString*)pass;
+ (void) setUserDefaultOath:(NSString*)token;
+ (void) setUserUID:(NSString*)p_uid;
+ (NSString*) getUserDefaultEmail;
+ (NSString*) getUserDefaultPassword;
+ (NSString*) getUserDefaultOath;
+ (NSString*) getUserUID;

+ (void) RequestforFirmwareUpdate : (id)p_id  selector:(SEL) p_sel;

- (void) setActiveView : (UIViewController*) pView;
- (UIViewController*) getActiveView;
- (void) getSportsDataFromWeb:(id)sender;
- (void) logOutUser;
- (BOOL) isSessionExpired : (NSDictionary*) jsonDic navCont:(UINavigationController*)navCon;
- (void) clearDataOnLogOut;

@end