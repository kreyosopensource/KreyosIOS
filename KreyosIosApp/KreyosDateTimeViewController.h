//
//  KreyosDateTimeViewController.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/31/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosUIViewBaseViewController.h"

@interface KreyosDateTimeViewController : KreyosUIViewBaseViewController
{
    IBOutlet UILabel *timeZon;
    IBOutlet UISwitch *setSwitchToggle;
    IBOutlet UILabel *currentDate;
    IBOutlet UILabel *currentTime;
}

-(void)sendDataToA:(NSString *)timeZoneData;


@end
