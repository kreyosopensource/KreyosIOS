//
//  CustomHeaderTableViewCell.h
//  KreyosIosApp
//
//  Created by Kreyos on 4/25/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomUILabelBebas.h"

@interface CustomHeaderTableViewCell : UITableViewCell
@property (assign, nonatomic) NSString* mHeaderID;
@property (assign, readwrite) float mTotalSteps;
@property (assign, readwrite) float mTotalDistance;
@property (assign, readwrite) float mTotalCalories;

@property (weak, nonatomic) IBOutlet CustomUILabelBebas *mDay;
@property (weak, nonatomic) IBOutlet CustomUILabelBebas *mDate;
@property (weak, nonatomic) IBOutlet CustomUILabelBebas *mSteps;
@property (weak, nonatomic) IBOutlet CustomUILabelBebas *mDistance;
@property (weak, nonatomic) IBOutlet CustomUILabelBebas *mCalories;


- (void) setStepsTotal      : (int) val;
- (void) setDistanceTotal   : (int) val;
- (void) setCaloriesTotal   : (int) val;

@end
