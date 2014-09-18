//
//  KreyosGPSMapViewController.m
//  kreyos_watch
//
//  Created by KrisJulio on 2/21/14.
//  Copyright (c) 2014 kreyos. All rights reserved.
//

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif


#import "KreyosGPSMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "AppDelegate.h"
#import "KreyosUtility.h"
#import "SportsPageViewController.h"

@interface KreyosGPSMapViewController ()

@end


@implementation KreyosGPSMapViewController
{
    GMSMapView *mapView_;
    GMSMutablePath *routePath;
    GMSPolyline *routeLne;
    
    NSDate* eventDate;
    NSTimeInterval howRecent;
    
    float totalDistanceTravelled;
    
    BOOL firstLocationUpdate_;
    
    CLLocationManager *locationManager;
}


@synthesize gpsMapView;
@synthesize backButton;
@synthesize runButton;
@synthesize timerLabel;
@synthesize distanceLabel;
@synthesize ssView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:38.8879
                                                            longitude:-77.0200
                                                                 zoom:15];
    
    mapView_ = [GMSMapView mapWithFrame:gpsMapView.bounds camera:camera];
    
    mapView_.settings.compassButton = YES;
    mapView_.settings.myLocationButton = YES;
    
    //Create routePath holder;
    routePath = [GMSMutablePath path];
    
    [gpsMapView addSubview:mapView_];
    
    mapView_.delegate = self;
    
    // Listen to the myLocation property of GMSMapView.
    [mapView_ addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView_.myLocationEnabled = YES;
    });
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    
    
    CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
    
    if (!firstLocationUpdate_) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        firstLocationUpdate_ = YES;
        mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate
                                                         zoom:14];
    
        totalDistanceTravelled = 0;
        
        eventDate = location.timestamp;

    }else{
        
        howRecent = [eventDate timeIntervalSinceNow];
        
        NSLog(@"%d", abs(howRecent));
        
        if( abs(howRecent) < 15.0 )
        {
            //[mapView_ animateToCameraPosition:[GMSCameraPosition cameraWithTarget:location.coordinate zoom:14]];
        
            [routePath addCoordinate:location.coordinate];
            [self updateDistance];
        
            routeLne = [GMSPolyline polylineWithPath:routePath];
            routeLne.map = mapView_;
        }
    }
}

- (void)mapView:(GMSMapView *)mapVieww
didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    
    /*[routePath addCoordinate:coordinate];
    routeLne = [GMSPolyline polylineWithPath:routePath];
    //Set Routline proprerties
    routeLne.strokeColor = [UIColor orangeColor];
    routeLne.strokeWidth = 3;
    
    routeLne.map = mapView_;
    
    [self updateDistance];*/
}

-(void) updateDistance
{
   if ( [routePath count] >= 3 )
   {
     
        CLLocation *startPos = [[CLLocation alloc] initWithLatitude:[routePath coordinateAtIndex:[routePath count] - 1].latitude
                                                      longitude:[routePath coordinateAtIndex:[routePath count] - 1].longitude];
    
        CLLocation *finalPos = [[CLLocation alloc] initWithLatitude:[routePath coordinateAtIndex:[routePath count] - 2].latitude
                                                      longitude:[routePath coordinateAtIndex:[routePath count] - 2].longitude];
    
    
        totalDistanceTravelled += [startPos distanceFromLocation:finalPos] / kMeterPerMile;
        distanceLabel.text = [NSString stringWithFormat:@"%.2f", totalDistanceTravelled ];

       
       NSLog(@"startPos %f, : : %f", [routePath coordinateAtIndex: [routePath count] - 1].latitude, [routePath coordinateAtIndex:[routePath count] - 1].longitude);
       NSLog(@"COUNT %i", [routePath count]);
       NSLog(@"DISTANCE %f", totalDistanceTravelled);
   }
    
}

- (void)setTime:(NSString*)p_time
{
    timerLabel.text = p_time;
}

- (void)resetValues
{
    timerLabel.text = @"00:00:00";
    distanceLabel.text = @"0.00";
}

-(IBAction) startRunning:(id)sender
{
    //[[KreyosSportsViewController sharedInstance] updateTimer:0];
    //[KreyosSportsViewController sharedInstance].screenShotImage = [self takeScreenshot];
}

- (IBAction)backToSports:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
   /* [self.navigationController transitionFromViewController:self toViewController:self.parentViewController duration:1 options:UIViewAnimationOptionAllowAnimatedContent animations:nil completion:nil];*/
}

- (UIImage *)takeScreenshot{
	CGRect rect = [self.view bounds];
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	[self.view.layer renderInContext:context];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

- (void)dealloc
{
    
    /*[mapView_ removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

