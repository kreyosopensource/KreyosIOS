//
//  KreyosHomeViewController.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/6/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosUIViewBaseViewController.h"
#import "AMSlideMenuMainViewController.h"
#import "iCarousel.h"
#import "FDTakeController.h"
#import "PICircularProgressView.h"
#import <UIKit/UIKit.h>

@interface KreyosHomeViewController : KreyosUIViewBaseViewController<iCarouselDataSource, iCarouselDelegate> 
{
    IBOutlet UIView *goalView;
    
    IBOutlet UIButton *pickBtn;
    IBOutlet UILabel *badgeDescription;
    IBOutlet iCarousel *statsPanel;

    IBOutlet UILabel *totalSecActive;
    IBOutlet UILabel *totalMinActive;
    IBOutlet UILabel *totalHrsActive;
    IBOutlet UILabel *totalSteps;
    
    IBOutlet UILabel *totalCalories;
    IBOutlet UILabel *totalDistance;
    
    IBOutlet UILabel *activeStatus;
    
    __weak IBOutlet UIView *m_indicatorView;
}

@property (weak, nonatomic) IBOutlet PICircularProgressView *progressView;

//PHOTO GETTER
@property FDTakeController *takeController;

@property (nonatomic) IBOutlet UISegmentedControl *GoalTab;
@property (nonatomic) IBOutlet UIView *goalView;

- (IBAction) segmentedControlCallback:(UISegmentedControl*)sender;
//+ (KreyosHomeViewController *)sharedInstance;
//photo
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UIView *mPickADailyTargetView;


//Badge View
@property (weak, nonatomic) IBOutlet UILabel *badgeTitle;
@property (weak, nonatomic) IBOutlet UILabel *badgeDescription;
@property (weak, nonatomic) IBOutlet UIImageView *badgeImageHolder;
@property (weak, nonatomic) IBOutlet iCarousel *carouselView;

//First PanelView
@property (weak, nonatomic) IBOutlet UILabel *activeOrInativeLabel;

//Second PanelView
@property (weak, nonatomic) IBOutlet UILabel *hrsLabel;
@property (weak, nonatomic) IBOutlet UILabel *minLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;

//ALertView
//@property (nonatomic, readwrite) UITableView *bluetoothTable;

//Dictionary of Views
@property (nonatomic, readwrite) NSMutableDictionary *_viewDictionary;

@property (nonatomic, assign) IBOutlet UIButton* btnDailyTarget;


//Container
@property (strong, nonatomic) IBOutlet UIView *statsContainer;

- (void) initFetchTimer;
- (void) sessionExpiredLogout;
- (void) tryReconnect;
- (void) reloadHomeActivities;
-(IBAction)btnDailyTargetCallback:(id)p_btn;

@end
