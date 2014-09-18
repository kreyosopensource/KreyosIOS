//
//  AppDelegate.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/6/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (BOOL)isConnectedToWifi;

@property (nonatomic, readwrite) BOOL g_bHasAlreadyLaunchOnce;

@end
