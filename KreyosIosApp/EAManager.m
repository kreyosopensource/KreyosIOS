//
//  EAManager.m
//  BluetoothTest
//
//  Created by Michael Dautermann on 1/2/14.
//  Copyright (c) 2014 Michael Dautermann. All rights reserved.
//

#import "EAManager.h"

@implementation EAManager

+ (EAManager *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _eaMGR = nil;
    
    dispatch_once(&pred, ^{
        _eaMGR = [[EAManager alloc] init];
    });
    
    return _eaMGR;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        self.actualMgr = [EAAccessoryManager sharedAccessoryManager];

        [self.actualMgr registerForLocalNotifications];
    }
    return self;
}

// this awakeFromNib would hit.... if I instantiated this in a storyboard of XIB file

- (void)awakeFromNib
{
    if(!self.actualMgr)
    {
        self.actualMgr = [EAAccessoryManager sharedAccessoryManager];
        
        [self.actualMgr registerForLocalNotifications];
    }
}

- (IBAction)checkDevicesNow:(id)sender
{
    NSArray * connectedDevices = [self.actualMgr connectedAccessories];
    if([connectedDevices count] > 0)
    {
        NSLog(@"connected devices include %@", connectedDevices);
    } else {
        NSLog(@"no External Accessory framework compatible devices connected");
    }
}

@end
