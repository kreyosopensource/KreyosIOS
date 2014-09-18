//
//  CustomHeaderTableViewCell.m
//  KreyosIosApp
//
//  Created by Kreyos on 4/25/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "CustomHeaderTableViewCell.h"
#import "KreyosDataManager.h"
#import "KreyosHomeViewController.h"
#import "KreyosUtility.h"

@implementation CustomHeaderTableViewCell
{
    
}
@synthesize mHeaderID;
@synthesize mTotalSteps;
@synthesize mTotalDistance;
@synthesize mTotalCalories;

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setStepsTotal : (int) val
{
    self.mTotalSteps += val;
    self.mSteps.text = [NSString stringWithFormat:@"%.0f", mTotalSteps];
}

- (void) setDistanceTotal : (int) val
{
    self.mTotalDistance += val;
    //self.mDistance.text = [NSString stringWithFormat:@"%.0f", mTotalDistance/100];
    //~~~Precompute distance to KM
    self.mDistance.text  = HOME_DIST_STR_2(HOME_DISTANCE(self.mTotalDistance));
}

- (void) setCaloriesTotal : (int) val
{
    self.mTotalCalories += val;
    //self.mCalories.text = [NSString stringWithFormat:@"%.0f", mTotalCalories/100];
    //~~~Precompute calories same to home view
    self.mCalories.text = HOME_CAL_STR_2(HOME_CALORIES(self.mTotalCalories));
}

@end
