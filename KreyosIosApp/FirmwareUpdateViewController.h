//
//  FirmwareUpdateViewController.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/14/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosUIViewBaseViewController.h"
#import "CustomUILabelProxi.h"

@interface FirmwareUpdateViewController : KreyosUIViewBaseViewController
@property (strong, nonatomic) IBOutlet UIButton *firmwareUpdateBtn;
@property (weak, nonatomic) IBOutlet CustomUILabelProxi *updateLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


-(IBAction)updateWatchFirmware:(id)sender;

@end
