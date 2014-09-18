//
//  EAManager.h
//  BluetoothTest
//
//  Created by Michael Dautermann on 1/2/14.
//  Copyright (c) 2014 Michael Dautermann. All rights reserved.
//

#import <ExternalAccessory/ExternalAccessory.h>

@interface EAManager : NSObject

@property (strong) EAAccessoryManager *actualMgr;

+ (EAManager *)sharedInstance;

- (IBAction)checkDevicesNow:(id)sender;

@end
