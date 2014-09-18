//
//  SportsPageViewController.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/7/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosUIViewBaseViewController.h"
#import <MapKit/MapKit.h>
#import "KreyosSVGButton.h"

typedef enum TimerState
{
    TimeStart = 0,
    TimeStop,
    TimePause,
    TimeResume,
    
} TimerStates;

@interface SportsPageViewController : KreyosUIViewBaseViewController
{
    IBOutlet UIView *dataHolder;
    IBOutlet MKMapView *gpsMapView;
    IBOutlet UIView *timerPanelView;
    IBOutlet UIView *activitySelection;
    IBOutlet KreyosSVGButton *badgeActivityBtn;
    
    __weak IBOutlet UIButton *mRunningWorkout;
    __weak IBOutlet UIButton *mCyclingWorkout;
    
}

@property (nonatomic) IBOutlet UIView *dataHolder;
@property (weak, nonatomic) IBOutlet UILabel *activeOrInactiveLabel;
@property (weak, nonatomic) IBOutlet UIView *cell_1;
@property (weak, nonatomic) IBOutlet UIView *cell_2;
@property (weak, nonatomic) IBOutlet UIView *cell_3;
@property (weak, nonatomic) IBOutlet UIView *cell_4;
@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *resumeBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIView *addBtn;
@property (weak, nonatomic) IBOutlet UIView *badgeChosen;
@property (strong, nonatomic) IBOutlet UILabel *sportsTimer;

//DEBUG SHITS
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *altitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;


-(void)updateTimer:(int)p_timerState;
-(IBAction) updateTimerWithButton:(UIButton*) sender;
-(IBAction)testing:(id)sender;
-(void) updateWorkOutData:(int32_t[5])p_data;
-(void) changeAndUpdateGrid:(int)p_count;
-(void) resetSportsPage;
-(void) initCell;

@property (nonatomic, retain) CLLocationManager *locationManager;

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error;

- (void) changeActivity:(int)pActType;
- (void) changeWorkOut:(int)pType;
@end
