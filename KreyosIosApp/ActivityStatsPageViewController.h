//
//  ActivityStatsPageViewController.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/20/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosUIViewBaseViewController.h"
#import "CustomUILabelBebas.h"
#import "KreyosUtility.h"

@interface ActivityStatsPageViewController : KreyosUIViewBaseViewController
{
    IBOutlet UIView *headerTotalActivity;
    IBOutlet UIView *headerDayDate;
    IBOutlet UITableView *activityStatsContent;
    
    IBOutlet UIView *preloaderView;
    
    //-- Data passed to this cell for stats
    NSArray *activityStatsData;
    __weak IBOutlet CustomUILabelBebas *mStepsTotal;
    
    __weak IBOutlet CustomUILabelBebas *mDate;
    __weak IBOutlet CustomUILabelBebas *mDay;
    __weak IBOutlet CustomUILabelBebas *mDistanceTotal;
    
    __weak IBOutlet CustomUILabelBebas *mCaloriesTotal;
}


+ (ActivityStatsPageViewController *)sharedInstance;
- (void) reloadActivityData;
- (void) refreshPage;
- (void) addHomeActivities:(NSDictionary*)p_activities;

@property (weak, nonatomic) IBOutlet UIButton *dataBlocker;
@property (nonatomic, readwrite) UIProgressView *dataProgressBar;
@end
