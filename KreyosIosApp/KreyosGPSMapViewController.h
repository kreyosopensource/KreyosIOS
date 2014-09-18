//
//  KreyosGPSMapViewController.h
//  kreyos_watch
//
//  Created by KrisJulio on 2/21/14.
//  Copyright (c) 2014 kreyos. All rights reserved.
//
#define kMeterPerMile 1609.34f
#define kMeterPerKilometer 0.001f

#import "KreyosUIViewBaseViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface KreyosGPSMapViewController : KreyosUIViewBaseViewController <GMSMapViewDelegate>
{
    __weak IBOutlet UIView *gpsMapView;
    __weak IBOutlet UIView *ssView;
    
    __weak IBOutlet UIButton *backButton;
    
    __weak IBOutlet UIButton *runButton;
    __weak IBOutlet UILabel *timerLabel;
    __weak IBOutlet UILabel *distanceLabel;
}

@property (nonatomic, weak) IBOutlet UIView *gpsMapView;
@property (nonatomic, weak) IBOutlet UIView *ssView;
@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, weak) IBOutlet UIButton *runButton;
@property (nonatomic, weak) IBOutlet UILabel *timerLabel;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;

- (IBAction)backToSports:(id)sender;
- (void)setTime:(NSString*)p_time;
- (void)resetValues;

@end
