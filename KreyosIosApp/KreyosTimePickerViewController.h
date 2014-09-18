//
//  KreyosTimePickerViewController.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/29/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosUIViewBaseViewController.h"

@interface KreyosTimePickerViewController : KreyosUIViewBaseViewController
{
    IBOutlet UIDatePicker *alarmPicker;
    IBOutlet UIButton *setAlarmBtn;
}
- (void) setThisDelegate : (id) pDelegate;

@property (nonatomic, assign) id delegate;

@end
