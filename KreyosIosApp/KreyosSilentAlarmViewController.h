//
//  KreyosSilentAlarmViewController.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/31/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosUIViewBaseViewController.h"

@interface KreyosSilentAlarmViewController : KreyosUIViewBaseViewController

@property (strong, nonatomic) IBOutlet UIView *settingsHolder;
@property (strong, nonatomic) IBOutlet UIButton *updateButton;

-(void)returnTimeData:(NSString*)pTime;

@end
