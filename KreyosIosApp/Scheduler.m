//
//  Scheduler.m
//  KreyosIosApp
//
//  Created by Kreyos on 7/9/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "Scheduler.h"


@implementation Scheduler


+(NSTimer*)createReconnectionTimer:(id)p_target selector:(SEL)p_selector userInfo:(id)p_info
{
    return [NSTimer scheduledTimerWithTimeInterval:RECONECTION_INTERVAL target:p_target selector:p_selector userInfo:p_info repeats:YES];
}

+(NSTimer*)createFetchTimer:(id)p_target selector:(SEL)p_selector
{
    return [NSTimer scheduledTimerWithTimeInterval:FETCH_INTERVAL target:p_target selector:p_selector userInfo:nil repeats:YES];
}

+(NSTimer*)createTimer:(id)p_target selector:(SEL)p_selector interval:(float)p_interval
{
    return [NSTimer scheduledTimerWithTimeInterval:p_interval target:p_target selector:p_selector userInfo:nil repeats:YES];
}

@end
