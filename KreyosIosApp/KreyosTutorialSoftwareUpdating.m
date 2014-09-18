//
//  KreyosTutorialSoftwareUpdating.m
//  KreyosIosApp
//
//  Created by Kreyos on 8/27/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosTutorialSoftwareUpdating.h"
#import "BluetoothDelegate.h"

@implementation KreyosTutorialSoftwareUpdating

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    dispatch_async(dispatch_get_main_queue(),^
    {
       [[BluetoothDelegate instance]initializeUpdateFirmWare];
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(continueTutorial)
                                                 name:@"firmwareUpdate"
                                               object:nil];
}

-(void)continueTutorial
{
    [self performSegueWithIdentifier:@"goToUpdateComplete" sender:self];
}

@end
