//
//  DeviceManager.m
//  KreyosIosApp
//
//  Created by Kreyos on 8/19/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "DeviceManager.h"
#import <sys/utsname.h>
#import "UIDevice+Hardware.h"
#import "KreyosUtility.h"

@implementation DeviceManager

typedef unsigned long long int UL_INT;

#define STORYBOARD_4SRES                @"Main4thGen"
#define STORYBOARD_5SRES                @"Main"

#define OFFLINE_STORYBOARD_5SRES        @"OfflineMain"
#define OFFLINE_STORYBOARD_4SRES        @"OfflineMain4thGen"

static BOOL IS_IPhone4S                 = NO;
static const UL_INT  g_supportedDevice  =
{
    (UL_INT)1<<IPHONE_4S                    |
    (UL_INT)1<<IPHONE_5                     |
    (UL_INT)1<<IPHONE_5_CDMA_GSM            |
    (UL_INT)1<<IPHONE_5C                    |
    (UL_INT)1<<IPHONE_5C_CDMA_GSM           |
    (UL_INT)1<<IPHONE_5S                    |
    (UL_INT)1<<IPHONE_5S_CDMA_GSM           |
    (UL_INT)1<<IPOD_TOUCH_5G                |
    (UL_INT)1<<IPAD_2_WIFI                  |
    (UL_INT)1<<IPAD_2                       |
    (UL_INT)1<<IPAD_2_CDMA                  |
    (UL_INT)1<<IPAD_2                       |
    (UL_INT)1<<IPAD_MINI_WIFI               |
    (UL_INT)1<<IPAD_MINI                    |
    (UL_INT)1<<IPAD_MINI_WIFI_CDMA          |
    (UL_INT)1<<IPAD_3_WIFI                  |
    (UL_INT)1<<IPAD_3_WIFI_CDMA             |
    (UL_INT)1<<IPAD_3                       |
    (UL_INT)1<<IPAD_4_WIFI                  |
    (UL_INT)1<<IPAD_4                       |
    (UL_INT)1<<IPAD_4_GSM_CDMA              |
    (UL_INT)1<<IPAD_AIR_WIFI                |
    (UL_INT)1<<IPAD_AIR_WIFI_GSM            |
    (UL_INT)1<<IPAD_AIR_WIFI_CDMA           |
    (UL_INT)1<<IPAD_MINI_RETINA_WIFI        |
    (UL_INT)1<<IPAD_MINI_RETINA_WIFI_CDMA
};

static const UL_INT  g_IPAD4S_RES           =
{
    (UL_INT)1<<IPHONE_4S                    |
    (UL_INT)1<<IPAD_2_WIFI                  |
    (UL_INT)1<<IPAD_2                       |
    (UL_INT)1<<IPAD_2_CDMA                  |
    (UL_INT)1<<IPAD_2                       |
    (UL_INT)1<<IPAD_MINI_WIFI               |
    (UL_INT)1<<IPAD_MINI                    |
    (UL_INT)1<<IPAD_MINI_WIFI_CDMA          |
    (UL_INT)1<<IPAD_3_WIFI                  |
    (UL_INT)1<<IPAD_3_WIFI_CDMA             |
    (UL_INT)1<<IPAD_3                       |
    (UL_INT)1<<IPAD_4_WIFI                  |
    (UL_INT)1<<IPAD_4                       |
    (UL_INT)1<<IPAD_4_GSM_CDMA              |
    (UL_INT)1<<IPAD_AIR_WIFI                |
    (UL_INT)1<<IPAD_AIR_WIFI_GSM            |
    (UL_INT)1<<IPAD_AIR_WIFI_CDMA           |
    (UL_INT)1<<IPAD_MINI_RETINA_WIFI        |
    (UL_INT)1<<IPAD_MINI_RETINA_WIFI_CDMA
};

+(void)LoadStoryBoard:(AppDelegate*)p_app
{
    Hardware hardware       = [[UIDevice currentDevice]hardware];
    UL_INT  hardwareFlag    = ((UL_INT)1<<hardware);
    NSString* storyBoard    = nil;
    if (hardwareFlag & g_supportedDevice)
    {
        if(hardwareFlag & g_IPAD4S_RES)
        {
#ifdef OFFLINE_BUILD
            storyBoard  = OFFLINE_STORYBOARD_4SRES;
#else
            storyBoard  = STORYBOARD_4SRES;
#endif
            IS_IPhone4S = YES;
        }
        else
        {
#ifdef OFFLINE_BUILD
            storyBoard  = OFFLINE_STORYBOARD_5SRES;
#else
            storyBoard  = STORYBOARD_5SRES;
#endif
        }
    }
    else
    {
        //~~~HANDLE ERROR HERE
    }
    
#ifdef STORY_IPHONE_4S
    #ifdef OFFLINE_BUILD
        storyBoard  = OFFLINE_STORYBOARD_4SRES;
    #else
        storyBoard  = STORYBOARD_4SRES;
    #endif
#endif
    
#ifdef STORY_IPHONE_5S
    #ifdef OFFLINE_BUILD
        storyBoard  = OFFLINE_STORYBOARD_5SRES;
    #else
        storyBoard  = STORYBOARD_5SRES;
    #endif
#endif
    
    if (storyBoard)
    {
        UIStoryboard *mainStoryboard    = [UIStoryboard storyboardWithName:storyBoard bundle:nil];
        p_app.window                    = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        p_app.window.rootViewController = [mainStoryboard instantiateInitialViewController];
        [p_app.window makeKeyAndVisible];
    }
}

+(BOOL)IS_IPhone4S
{
#ifdef STORY_IPHONE_4S
    return YES;
#endif
    return IS_IPhone4S;
}


+(NSString*)GetStoryboard
{
#ifdef STORY_IPHONE_4S
    return STORYBOARD_4SRES;
#endif
    
#ifdef OFFLINE_BUILD
    return IS_IPhone4S ? OFFLINE_STORYBOARD_4SRES : OFFLINE_STORYBOARD_5SRES;
#else
    return IS_IPhone4S ? STORYBOARD_4SRES : STORYBOARD_5SRES;
#endif
}



@end
