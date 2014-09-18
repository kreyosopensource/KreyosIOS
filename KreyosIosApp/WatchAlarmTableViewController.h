//
//  WatchAlarmTableViewController.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/29/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WatchAlarmTableViewController : UITableViewController
{
    
}
@property (nonatomic, assign) UILabel *selectedCellAlarm;
@property (strong, nonatomic) NSMutableDictionary *mAlarmDict;

//CELLS
@property (strong, nonatomic) IBOutlet UILabel *mAlarm1CellLbl;
@property (strong, nonatomic) IBOutlet UILabel *mAlarm2CellLbl;
@property (strong, nonatomic) IBOutlet UILabel *mAlarm3Celllbl;

@property (weak, nonatomic) IBOutlet UISwitch *switch_1;
@property (weak, nonatomic) IBOutlet UISwitch *switch_2;
@property (weak, nonatomic) IBOutlet UISwitch *switch_3;

-(void)returnTimeData:(NSDate*)pTime;
- (void) cancelSetAlarm;

@end
