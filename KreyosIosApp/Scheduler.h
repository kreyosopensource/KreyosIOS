//
//  Scheduler.h
//  KreyosIosApp
//
//  Created by Kreyos on 7/9/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RECONECTION_INTERVAL            3.0f
#define FETCH_INTERVAL                  2.0f
#define INITIAL_FETCH_INTERVAL          2.9f // Based on Steve's email. Initial Fetch Value would be 1.0f on the first run, while the timer reaches 30sec, reset the timer to 20.0f
#define DEFAULT_FETCH_INTERVAL          20.0f
#define RESET_TIMER_CAP                 30

#define HOME_FETCH_INTERVAL             20

@interface Scheduler : NSObject
+(NSTimer*)createReconnectionTimer:(id)p_target selector:(SEL)p_selector userInfo:(id)p_info;
+(NSTimer*)createFetchTimer:(id)p_target selector:(SEL)p_selector;
+(NSTimer*)createTimer:(id)p_target selector:(SEL)p_selector interval:(float)p_interval;
@end
