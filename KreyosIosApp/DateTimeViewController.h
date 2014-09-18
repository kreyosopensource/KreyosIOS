//
//  DateTimeViewController.h
//  KreyosIosApp
//
//  Created by Kreyos on 4/15/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosUIViewBaseViewController.h"
#import "CustomUILabelBebas.h"

@interface DateTimeViewController : KreyosUIViewBaseViewController
@property (weak, nonatomic) IBOutlet UIDatePicker *mDatePicker;
@property (weak, nonatomic) IBOutlet CustomUILabelBebas *mTime;
@property (weak, nonatomic) IBOutlet CustomUILabelBebas *mDate;
@property (weak, nonatomic) IBOutlet UISwitch *mSwitch;
@property (weak, nonatomic) IBOutlet UIButton *mCellButton;
@property (weak, nonatomic) IBOutlet UIView* mCellDate;

- (void) updateToday;

@end
