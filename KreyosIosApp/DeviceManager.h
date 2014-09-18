//
//  DeviceManager.h
//  KreyosIosApp
//
//  Created by Kreyos on 8/19/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface DeviceManager : NSObject
+(void)LoadStoryBoard:(AppDelegate*)p_app;
+(BOOL)IS_IPhone4S;
+(NSString*)GetStoryboard;
@end
