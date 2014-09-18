//
//  KreyosUtility.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/6/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "KreyosTools.h"


//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Build
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#define BUILD_LOCAL                     0
#define BUILD_WEB                       1
#define BUILD_RELEASE                   2
#define IOS_BUILD                       BUILD_WEB


//~~~DEBUG SWITCHES GUIDE :)
//   SYMBOL: ((╯°□°)╯︵ ┻━┻)   - Do not use this switches in release build. This debug switches is build for development only.
//         : ( ¯\_(ツ)_/¯ )    - Can be use in development and release build depending to the build requirments

#if IOS_BUILD == BUILD_LOCAL || IOS_BUILD == BUILD_WEB
//#define EMULATOR_BUILD                //~~~PREVENT CRASHING OF CENTRAL MANAGER IN EMULATOR MODE ((╯°□°)╯︵ ┻━┻)
//#define STORY_IPHONE_5S               //~~~ENABLE STORYBOARD IN 5S ((╯°□°)╯︵ ┻━┻)
//#define STORY_IPHONE_4S               //~~~ENABLE STORYBOARD IN 4S ((╯°□°)╯︵ ┻━┻)
//#define ENABLE_SHOW_TUTORIAL          //~~~ALWAYS SHOW TUTORIAL    ((╯°□°)╯︵ ┻━┻)
#define OFFLINE_BUILD                   //~~~LOAD OFFLINE STORY BOARD ( ¯\_(ツ)_/¯ )
#endif

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// LOCAL
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#if IOS_BUILD == BUILD_LOCAL

#define kSERVER_URL                     @"http://192.168.1.116:3000/api/"

//~~~DEBUG
//#define DEBUG_WEIRD_DATE
//#define ENABLE_WEB_DATA_PRINT
//#define ENABLE_DB_PRINT
//#define BYPASS_LOGIN
//#define WATCH_DATA
//#define DEBUG_HOME_DATA

//#define DEBUG_BYPASS_LOGIN
//#define ALWAYS_TUTORIAL

//IF LOCAL REGISTER
//#define LOCAL

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// WEB
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#elif IOS_BUILD == BUILD_WEB

#define kSERVER_URL                     @"https://kreyos-members.herokuapp.com/api/"

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// RELEASE
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#elif IOS_BUILD == BUILD_RELEASE //members.kreyos.com

#define kSERVER_URL                     @"https://members.kreyos.com/api/"

#endif

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Defines
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//~~~Server API Paths
#define kServerFirmwareURL                  [NSString stringWithFormat:@"%@%@", kSERVER_URL, @"firmwares/latest_firmware"]
#define kServerUserCheckMail                [NSString stringWithFormat:@"%@%@", kSERVER_URL, @"users/check_email"]
#define kServerUserLoginURL                 [NSString stringWithFormat:@"%@%@", kSERVER_URL, @"login"]
#define kServerSessionLogoutURL             [NSString stringWithFormat:@"%@%@", kSERVER_URL, @"logout"]
#define kServerUserRegisterURL              [NSString stringWithFormat:@"%@%@", kSERVER_URL, @"users"]
#define kServerSessionKeyURL                [NSString stringWithFormat:@"%@%@", kSERVER_URL, @"persistence"]
#define kServerUserActivitiesURL            [NSString stringWithFormat:@"%@%@", kSERVER_URL, @"activities"]
#define kServerFacebookLogin                [NSString stringWithFormat:@"%@%@", kSERVER_URL, @"login_via_facebook"]
#define kServerUpdateUserProfile            [NSString stringWithFormat:@"%@%@", kSERVER_URL, @"users/update"]
#define kServerGetUserProfile               [NSString stringWithFormat:@"%@%@", kSERVER_URL, @"users/get"]

#define LOGIN_STORYBOARD                    @"sb_login"

//~~~RADUIS
#define PHOTO_RAD                           48.0f

//~~~Key User default
#define USERDEF_LASTDEVICE                  @"deviceConnected"
#define USERDEF_PHOTO                       @"user_photo"
#define KREYOS_HOME_ACTIVITIES              @"KreyosHomeActivities"

//~~~Photo Border
#define PHOTO_BORDER                        3.0f

//~~~ADD OBSERVER NAME HERE:
#define CHANGE_TOPBAR_COLOR                 @"ConnectionChange"
#define RELOAD_BLUETOOTH_TABLE              @"ReloadTable"
#define RELOAD_HOME_ACTIVITIES              @"ReloadHomeActivities"
#define RELOAD_OVERALL_ACTIVITIES           @"ReloadOverallActivities"
#define USER_DID_LOG_OUT                    @"LogoutUser"
#define SEGUE_LOADING_TO_MAINSCREEN         @"MainScreenSegue"
#define SEGUE_LOADING_TO_REGISTERUSER       @"RegisterUserSegue"
#define SEGUE_LOADING_TO_EMAILREG           @"FBEmailRegister"
#define SEGUE_REGISTER_TOLOGIN              @"RegisterBackSegue"
#define SEGUE_REGISTER_TO_REGISTER2         @"RegisterUser2Segue"
#define SEGUE_REGISTER2_TO_MAIN             @"register2tomainscreen"
#define SEGUE_REGISTER2_TO_LOGIN            @"register2toLogin"
#define SEGUE_LOGIN_TO_FIRSTTIME            @"loginToFirstTime"
#define SEGUE_BACK_TO_LOGIN                 @"backToLogin"
#define SEGUE_OVERALL_ACTIVITIES            @"sugue_overall_activities"
#define SEGUE_DAILY_TARGET                  @"sugue_daily_target"
#define FIRST_LAUNCH                        @"HasLaunchedOnce"

#define MAKE_RGB_UI_COLOR(rr,gg,bb) [UIColor colorWithRed:rr/255.0f green:gg/255.0f blue:bb/255.0f alpha:1.0f]
//#define MAKE_RGB_UI_COLOR(rr,gg,bb) [[[UIColor alloc] initWithRed:rr/255.0f green:gg/255.0f blue:bb/255.0f alpha:1.0f] autorelease]

#define MAKE_RGB_UI_COLOR_ALLOC(rr,gg,bb) [[UIColor alloc] initWithRed:rr/255.0f green:gg/255.0f blue:bb/255.0f alpha:1.0f]

#define FONT_BEBAS(ss)               [UIFont fontWithName:@"BebasNeue" size:ss]
#define FONT_LATOREG(ss)             [UIFont fontWithName:@"Lato-Regular" size:ss]
#define FONT_LEAGUE(ss)              [UIFont fontWithName:@"League_Gothic" size:ss]
#define REGULAR_FONT_WITH_SIZE(ss)   [UIFont fontWithName:@"ProximaNova-Regular" size:ss]
#define LIGHT_FONT_WITH_SIZE(ss)     [UIFont fontWithName:@"ProximaNova-Light" size:ss]ksi
#define BOLD_FONT_WITH_SIZE(ss)      [UIFont fontWithName:@"ProximaNova-Bold" size:ss]
#define SEMIBOLD_FONT_WITH_SIZE(ss)  [UIFont fontWithName:@"ProximaNova-Semibold" size:ss]
#define ITALIC_FONT_WITH_SIZE(ss)    [UIFont fontWithName:@"ProximaNova-RegularIt" size:ss]
//#define STOP_BLUETOOTH

// common used font
#define BOTTOM_TEXT_FONT             REGULAR_FONT_WITH_SIZE(10.15f)
#define NAVI_BAR_TITLE_FONT          SEMIBOLD_FONT_WITH_SIZE(15.69f)
#define NAVI_BAR_ITEM_FONT           LIGHT_FONT_WITH_SIZE(15.69f)
#define PRIMARY_BUTTON_FONT          REGULAR_FONT_WITH_SIZE(16.62f)
#define INNER_TAB_SEL_FONT           BOLD_FONT_WITH_SIZE(12.83f)
#define INNER_TAB_NORMAL_FONT        REGULAR_FONT_WITH_SIZE(12.83f)
#define TABLE_LIST_FONT              LIGHT_FONT_WITH_SIZE(14.77f)
#define TABLE_LIST_LEFT_FONT         SEMIBOLD_FONT_WITH_SIZE(12.0f)
#define TABLE_LIST_RIGHT_FONT        REGULAR_FONT_WITH_SIZE(10.15f)
#define SEGMENTED_NORMAL_FONT        REGULAR_FONT_WITH_SIZE(11.08f)
#define SEGMENTED_SEL_FONT           SEMIBOLD_FONT_WITH_SIZE(11.08f)

#define CGRectSetPos( r, x, y )     CGRectMake( x, y, r.size.width, r.size.height )
#define APP_DELEGATE                (AppDelegate*)[[UIApplication sharedApplication] delegate]
#define SCREEN_SIZE                 [[UIScreen mainScreen] bounds].size

#define CLEAR                       [UIColor clearColor]
#define WHITE                       [UIColor whiteColor]
#define BLACK                       [UIColor blackColor]
#define RED                         [UIColor redColor]
#define BLUE                        [UIColor colorWithRed:24/255.0f green:177/255.0f blue:233/255.0f alpha:1.0f]
#define LOGIN_BLUE                  [UIColor colorWithRed:0/255.0f green:190/255.0f blue:240/255.0f alpha:1.0f]
#define KREYOS_GRAY                 [UIColor colorWithRed:175/255.0f green:175/255.0f blue:175/255.0f alpha:1.0f]
#define TIMER_YELLOW                [UIColor colorWithRed:194/255.0f green:238/255.0f blue:21/255.0f alpha:1.0f]
#define ORANGE                      [UIColor colorWithRed:226/255.0f green:163/255.0f blue:0/255.0f alpha:1.0f]

#define IS_IPAD                     (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE                   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5                 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA                   ([[UIScreen mainScreen] scale] == 2.0f)
#define IS_IOS7                     ([[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue] >= 7)

#pragma mark TAGS
#define USERDATA                    [NSUserDefaults standardUserDefaults]

#define kLoginSessionFailed         401
#define kLoginSuccess               200
#define kLoginFailed
#define kRegisterSuccess            201
#define kRegisterFailed             422

/*
 int ftMin   = 1;    int ftMax   = 9;
 int inchMin = 0;    int inchMax = 11;
 int cmMin   = 60;   int cmMax   = 274;
 int lbMin   = 10;   int lbMax   = 420;
 int kgMin   = 5;    int kgMax   = 185;
//*/

#define MIN_FT                      1
#define MIN_INCH                    0
#define MIN_CM                      60
#define MIN_LBS                     10
#define MIN_KG                      5

#define MAX_FT                      9
#define MAX_INCH                    11
#define MAX_CM                      303
#define MAX_LBS                     420
#define MAX_KG                      185

#define DEFAULT_WEIGHT              @"22"   //~~~Lbs
#define DEFAULT_HEIGHT              @"3'0"  //~~~Ft'Inch

//VERSION OF FIRMWARE
#define kDEBUG_VERSION                 @"DEBUG"
#define kUNKNOWN_VERSION               @"------"

// used for customized navigation bar page, to support IOS7
#define ADD_TO_ROOT_VIEW(v) \
do { \
if (IS_IOS7) \
{ \
CGRect frame = v.frame; \
frame.origin.y += 20; \
v.frame = frame; \
} \
[self.view addSubview:v]; \
} while(0)

// used for standard navigation bar page, to support IOS7
#define ADD_TO_ROOT_VIEW2(v) \
do { \
if (IS_IOS7) \
{ \
CGRect frame = v.frame; \
frame.origin.y += 64; \
v.frame = frame; \
} \
[self.view addSubview:v]; \
} while(0)

#define DEFINE_AUTO_FIT_NAVI_BAR(nbar) \
CGRect navBound = CGRectMake(0, 0, self.view.bounds.size.width, 44); \
if (IS_IOS7) { \
navBound.size.height += 20; \
} \
UINavigationBar* nbar = [[UINavigationBar alloc] initWithFrame:navBound]; \
[nbar setBackgroundImage:[UIImage imageNamed:IS_IOS7?@"nav_bg_7":@"nav_bg"] forBarMetrics:UIBarMetricsDefault];

#define REGISTER_FOR_KEYBOARD_NOTIFICATIONS() \
            [[NSNotificationCenter defaultCenter] addObserver:self \
                                                     selector:@selector(keyboardWasShown:) \
                                                         name:UIKeyboardDidShowNotification object:nil]; \
            [[NSNotificationCenter defaultCenter] addObserver:self \
                                                     selector:@selector(keyboardWillBeHidden:) \
                                                         name:UIKeyboardWillHideNotification object:nil];


#define kUserEmail              @"user_email"
#define kUserPass               @"user_pass"
#define kUserToken              @"user_token"
#define kUserUID                @"user_uid"
//#define kEMAIL                @"user_email" // Unused. use the kUserEmail instead
#define kAUTH_KEY               @"auth_key"

enum Activities
{
    kActivity_Walking,
    kActivity_Running,
    kActivity_Biking
};
static NSString *const kAPIKey = @"AIzaSyCDR4NRfyhdSrGpKJ7BQal-n2rnW3BsTfs";

//CGPoint MultiplyVector( CGPoint pVec1, CGPoint pVec2 );
//CGPoint MultiplyVectorToScalar( CGPoint pVec1, CGFloat pScalar );
//CGPoint AddVector( CGPoint pVec1, CGPoint pVec2 );
//CGPoint AddVectorToScalar( CGPoint pVec1, CGFloat pScalar );
//CGPoint GetMidPoint( CGPoint pPosition, CGSize pSize );
//NSDate* DateFromEpoch( int p_epoch );
//NSDate* DateFromString( NSString* p_dd, NSString* p_mm, NSString* p_yyyy );
//NSString* DateStringFromEpoch( int p_epoch );
//NSString* DateStringFromDate( NSDate* p_date );
//NSString* DateStringFromNow();
//NSDateComponents* ComponentFromDate( NSDate* p_date );
//NSArray* DictToArray( NSDictionary* p_dict );
//float PrecomputeData( float p_value );
//NSString* GetMonthStringByIndex(u_int p_index);


//~~~Unit Values on Home Data
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Distance
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#define CM_TO_M(p_cm)           p_cm / 100.0f
#define CM_TO_KM(p_cm)          p_cm / 100.0f / 1000.0f
#define M_TO_CM(p_m)            p_m * 100.0f
#define M_TO_KM(p_m)            p_m / 1000.0f
#define KM_TO_CM(p_km)          p_km / 1000.0f / 100.0f
#define KM_TO_M(p_km)           p_km / 1000.0f
#define HOME_DISTANCE(dist)     CM_TO_KM(dist)
#define HOME_DIST_STR(dist)     [NSString stringWithFormat:@"%.3f",dist];
#define HOME_DIST_STR_2(dist)   [NSString stringWithFormat:@"%.2f",dist];
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Calories
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#define HOME_CALORIES(cal)      fabsf(cal / 100.0f / 1000.0f)
#define HOME_CAL_STR(cal)       [NSString stringWithFormat:@"%.3f",cal];
#define HOME_CAL_STR_2(cal)     [NSString stringWithFormat:@"%.2f",cal];
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  Steps
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#define HOME_STEPS_STR(stp)     [NSString stringWithFormat:@"%.0f",stp];
//void            DebugWatchSendData();
//NSString*       HexadecimalString(NSData* p_data);
//id              DataWithHexString(NSString * p_hex);

//~~~UIALERTVIEW MESSAGE AND TITLE
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  REGISTRATION
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#define REGISTRATION_EMAIL_ERROR_TITLE                  @"Whoops!"
#define REGISTRATION_EMAIL_ERROR_MESSAGE                @"You've entered an invalid email."

#define REGISTRATION_MISSING_FIELD_ERROR_TITLE          @"Oops!"
#define REGISTRATION_MISSING_FIELD_ERROR_MESSAGE        @"You've missed out on one or more fields. Recheck again."

#define REGISTRATION_PASS_CHARACTER_ERROR_TITLE         @"Whoa, there!"
#define REGISTRATION_PASS_CHARACTER_ERROR_MESSAGE       @"Your password must be 8 characters or more."

#define REGISTRATION_PASS_NOT_MATCH_ERROR_TITLE         @"Yikes!"
#define REGISTRATION_PASS_NOT_MATCH_ERROR_MESSAGE       @"Your passwords don't match."

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  BLUETOOTH
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#define BLUETOOTH_ERROR_POWER_OFF_TITLE                 @"Bluetooth Power"
#define BLUETOOTH_ERROR_POWER_OFF_MESSAGE               @"Turn on your phone's Bluetooth to use Low Energy"

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  LOGOUT
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#define LOGOUT_SUCCESSFUL                               @"You've successfully logged out."

