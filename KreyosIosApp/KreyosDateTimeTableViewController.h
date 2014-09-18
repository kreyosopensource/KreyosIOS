//
//  KreyosDateTimeTableViewController.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/29/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KreyosDateTimeTableViewController : UITableViewController
{
    IBOutlet UILabel *timeZon;
    IBOutlet UISwitch *setSwitchToggle;
    IBOutlet UILabel *currentDate;
    IBOutlet UILabel *currentTime;
}

-(void)sendDataToA:(NSString *)timeZoneData;
@end
