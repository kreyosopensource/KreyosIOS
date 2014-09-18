//
//  SetAlarmViewController.h
//  KreyosIosApp
//
//  Created by Kreyos on 4/2/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosUIViewBaseViewController.h"
#import "WatchAlarmTableViewController.h"
#import "CustomUILabelBebas.h"

@interface SetAlarmViewController : KreyosUIViewBaseViewController
{
    WatchAlarmTableViewController *delegate;
}
@property (strong, nonatomic) IBOutlet CustomUILabelBebas   *timeLabel;
@property (strong, nonatomic) IBOutlet UIDatePicker         *alarmPicker;
@property (strong, nonatomic) IBOutlet UIButton             *saveAlarmBtn;

- (void) setThisDelegate:(id)sender;

@end
