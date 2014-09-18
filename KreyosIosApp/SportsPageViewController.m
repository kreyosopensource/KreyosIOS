//
//  SportsPageViewController.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/7/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//
#define CELL_TRASH      5
#define CELL_REFRESH    6
#define CELL_METRIC     7
#define CELL_VALUE      8
#define CELL_TITLE      9   

#define GRID_1x2        3
#define GRID_1x3        4
#define GRID_2x2        5

#define METERS_PER_MILE 1609.344
#define RUNNING_ON      @"running_active"
#define RUNNING_OFF     @"running_inactive"
#define CYCLING_ON      @"cycling_active"
#define CYCLING_OFF     @"cycling_inactive"

#import "SportsPageViewController.h"
#import "KreyosUtility.h"
#import "KreyosBluetoothViewController.h"
#import "SVGFactoryManager.h"
#import "SVGKImage.h"
#import "SVGButton.h"
#import "LKreyosService.h"
#import "LkDiscovery.h"
#import "KreyosGPSMapViewController.h"
#import "KreyosHomeViewController.h"
#import "AMSlideMenuMainViewController.h"
#import "UIViewController+AMSlideMenu.h"
#import "KreyosDataManager.h"
#import "PSLocationManager.h"
#import "BluetoothDelegate.h"
#import "DeviceManager.h"
#import "Scheduler.h"

#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>

enum WORKSTATUS
{
    RUNNING = 1,
    CYCLING = 2
};

@interface SportsPageViewController () <GMSMapViewDelegate, CLLocationManagerDelegate, PSLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    
    int _workStatus;
    int updateCount;
    
    //SPORTS DATA
    
    float distance;
    float currentSpeed;
    float maxSpeed;
    float sportDistance;
    float sportSpeed;
    float sportAltitude;
    
    float accumulatedDistance;
    float accumulatedAltitude;
    
    BOOL bIsTimerSynced;
    BOOL m_bIsSportStarts;
}
@end

@implementation SportsPageViewController
{
    
    __weak IBOutlet UILabel *previousDistance;
    __weak IBOutlet UILabel *totalDistance;
    
    IBOutlet GMSMapView *mapView_;
    
    BOOL firstLocationUpdate_;
    
    GMSMutablePath *routePath;
    GMSPolyline *routeLne;
    
    NSDate* eventDate;
    NSTimeInterval howRecent;
    
    float totalDistanceTravelled;
    float prevDistanceTravelled;
    
    NSMutableDictionary *workoutStatus;
    NSMutableArray* m_cellValueStorage;
    
    NSArray *m_trackableObjects;
    NSArray *m_cellArray;
    int currentNumberOfTiles;
    
    NSTimer* watchTimer;

    //Timer
    int m_timeCounter;
    int m_recordedTime;
    int m_seconds;
    int m_minutes;
    int m_hours;
    
    //CLLOCATION
    CLLocation *stampedLocation;
    CLLocation *newLocation;
    
    //INDEX
    
    int cellStatusIndex ;
    
    BOOL bIsRunning;
    

}

TimerStates timerState;

@synthesize dataHolder;
@synthesize sportsTimer;
@synthesize activeOrInactiveLabel;
@synthesize cell_1;
@synthesize cell_2;
@synthesize cell_3;
@synthesize cell_4;
@synthesize pauseBtn;
@synthesize startBtn;
@synthesize resumeBtn;
@synthesize stopBtn;
@synthesize addBtn;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [[BluetoothDelegate instance] setSportViewController:self];
    }
    return self;
}

#pragma mark VIEW DID LOAD
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[BluetoothDelegate instance] setIsUpdating:NO];
    
    // +AS:07082014 Initial Value
    m_cellValueStorage = [[NSMutableArray alloc] init];
    [m_cellValueStorage addObject:@"Steps"];
    [m_cellValueStorage addObject:@"Distance"];
    [m_cellValueStorage addObject:@"Speed"];
    [m_cellValueStorage addObject:@"Calories"];
    
    [[KreyosDataManager sharedInstance] setActiveView:self];
    
    _workStatus = RUNNING;
    bIsTimerSynced = NO;
    
//    NSMutableDictionary *dict = [[KreyosHomeViewController sharedInstance] _viewDictionary];
    
    //POPULATE WORKOUT STATUS
    workoutStatus = [KreyosDataManager sharedInstance].WorkOutStatusDict;
    
    //POPULATE TRACKABLE OBJECTS
    m_trackableObjects = [[NSArray alloc] initWithObjects:@"Steps", @"Heart", @"AvgHeart", @"MaxHeart", @"Calories", @"Distance", @"Altitude", @"Elevation", @"Totd", @"Speed", @"AvgSpeed", @"TopSpeed", @"Pace", @"AvgPace", @"CurrentLap", @"AvgLap", @"BestLap", nil];

    
    //add button on top
    AMSlideMenuMainViewController *mainVC = [AMSlideMenuMainViewController getInstanceForVC:self];
    
    if(mainVC.rightMenu)
    {
        [self addRightMenuButton];
        [self addLeftMenuButton];//Disable swipes
        
        [self disableSlidePanGestureForRightMenu];
        [self disableSlidePanGestureForLeftMenu];
    }
    
    
    dataHolder.layer.cornerRadius = 10;
    timerState = TimeStop;
    
    m_cellArray = [NSArray arrayWithObjects:cell_1, cell_2, cell_3, cell_4, nil];
    
    //[self resetTimer];
    
    [self setUpSportsButtons];
    [self setTimerPanel];
    
    for (UIView *cell in m_cellArray)
    {
        [self setUpCellButtons:cell];
    }
    //PS LOCATION
    [PSLocationManager sharedLocationManager].delegate = self;
    [[PSLocationManager sharedLocationManager] prepLocationUpdates];
    [[PSLocationManager sharedLocationManager] startLocationUpdates];
    
    //SET UP GPS
    geocoder                                = [[CLGeocoder alloc] init];
    self.locationManager                    = [[CLLocationManager alloc] init];
    self.locationManager.delegate           = self;
    self.locationManager.distanceFilter     = 1000.0f;
    self.locationManager.desiredAccuracy    = kCLLocationAccuracyBest;
    
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    mapView_.settings.compassButton = YES;
    mapView_.settings.myLocationButton = YES;
    mapView_.delegate = self;

    routePath = [GMSMutablePath path];
    
    [locationManager startUpdatingLocation];
    [self startLocation];
    
    //Change Grid on Load
    [self changeIcon];
    [self updateColor];
    
    [self initCell];
    
    // set the current view on BluetoothDelegate
    [[BluetoothDelegate instance] setCurrentView:self];
    
    //~~~App Loop
    [Scheduler createTimer:self selector:@selector(updateSportsTile) interval:0.05f];
    timerPanelView.backgroundColor = KREYOS_GRAY;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [watchTimer invalidate];
    watchTimer = nil;
    
    [[BluetoothDelegate instance] setSportViewController:nil];
    
    [[KreyosDataManager sharedInstance] setActiveView:nil];
}

- (void)updateGridByType
{
    if (m_bIsSportStarts)
    {
        //ADD VALUES FOR MCELLSTORAGE BEFORE CHANGING ONE OF ITS VALUES
        if ( m_cellValueStorage == nil)
        {
            m_cellValueStorage = [[NSMutableArray alloc] init];
            
            [m_cellValueStorage addObject:@"Steps"];
            [m_cellValueStorage addObject:@"Speed"];
            [m_cellValueStorage addObject:@"Calories"];
            [m_cellValueStorage addObject:@"Distance"];
        }
        
        [self changeIcon];
    }
}

-(void)changeIcon
{
    switch ([KreyosDataManager sharedInstance].WorkModeType)
    {
        case RUNNING:
        {
            [mCyclingWorkout setBackgroundImage:[UIImage imageNamed:CYCLING_OFF]    forState:UIControlStateNormal];
            [mRunningWorkout setBackgroundImage:[UIImage imageNamed:RUNNING_ON]     forState:UIControlStateNormal];
            
            bIsRunning = YES;
        }
            break;
        case CYCLING:
        {
            [mCyclingWorkout setBackgroundImage:[UIImage imageNamed:CYCLING_ON]     forState:UIControlStateNormal];
            [mRunningWorkout setBackgroundImage:[UIImage imageNamed:RUNNING_OFF]    forState:UIControlStateNormal];
            
            bIsRunning = NO;
        }
            break;
        default:
            break;
    }
}

-(void)updateColor
{
    //~~~TODO: Tobe Optimize
    UIColor* colorTable[] =
    {
        TIMER_YELLOW,   //~~~Start
        KREYOS_GRAY,    //~~~Pause
        TIMER_YELLOW,   //~~~Resume
        KREYOS_GRAY,    //~~~TimeStop
    };
    
    timerPanelView.backgroundColor = colorTable[[KreyosDataManager sharedInstance].TimerState];
}

-(void) initCell
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([KreyosDataManager sharedInstance].WorkModeType == RUNNING)
        {
            [self updateStatus:@"Steps"     cellNum:cell_1 isForced:YES];
            [self updateStatus:@"Speed"     cellNum:cell_3 isForced:YES];
        }
        else
        {
            [self updateStatus:@"Speed"     cellNum:cell_1 isForced:YES];
            [self updateStatus:@"Altitude"  cellNum:cell_3 isForced:YES];
        }
        
        [self setTileCountTo:currentNumberOfTiles];
        [self changeIcon];
    });
}

- (void) setUpSportsButtons
{
    currentNumberOfTiles    = 4;
    pauseBtn.hidden         = TRUE;
    resumeBtn.hidden        = TRUE;
    stopBtn.hidden          = TRUE;
}

- (void) setUpCellButtons:(UIView*)cellView
{
    cellView.layer.borderColor = [UIColor grayColor].CGColor;
    cellView.layer.borderWidth = 0.5f;
}

#pragma mark TIMER
- (void) setTimerPanel
{
    BOOL isSelectedFromSlideMenu = [KreyosDataManager sharedInstance].g_isFromSlideBar;
    activitySelection.layer.cornerRadius = 10;
    activitySelection.layer.shadowOffset = CGSizeMake(5, 10);
    activitySelection.layer.shadowRadius = 10;
    
    if( isSelectedFromSlideMenu )
    {
        timerPanelView.backgroundColor = KREYOS_GRAY;
        activitySelection.hidden = YES;
        
        [(KreyosSVGButton*)badgeActivityBtn addSVGOnThisButton:@"walking"];
        [badgeActivityBtn addTarget:self action:@selector(showHideActivitySelection:) forControlEvents:UIControlEventTouchUpInside];
        
        /* REMOVE FOR NOW
        //Add Callback Function for all button inside selection
        for (UIButton *selectionBtn in [activitySelection subviews]) {
            [selectionBtn addTarget:self action:@selector(changeActivity:) forControlEvents:UIControlEventTouchUpInside];
        }
         */
    }
    
    else
    {
        timerPanelView.backgroundColor = TIMER_YELLOW;
        activitySelection.hidden = YES;
        
    }
}

-(IBAction) updateTimerWithButton:(UIButton*) sender
{
    [self updateTimer:(long)[sender tag]];
}

-(void)updateTimer:(int)p_timerState
{
    [KreyosDataManager sharedInstance].TimerState = p_timerState;
    
    switch(p_timerState)
    {
        case TimeStart: //Timer start
        {
            if (timerState == TimeStart) return;

            timerState          = TimeStart;
            m_bIsSportStarts    = YES;
        
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if( watchTimer )
                {
                    [watchTimer invalidate];
                    watchTimer = nil;
                }
                
                watchTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(fireTimer:) userInfo:nil repeats:YES];
                [self initCell];
                [self updateGridByType];
                [self updateColor];
            });
        }
        break;
        case TimePause: //Timer pause
        
            timerState                      = TimePause;
            timerPanelView.backgroundColor  = KREYOS_GRAY;
           
        break;
        case TimeResume: //Timer resume
            
            timerState = TimeResume;
            timerPanelView.backgroundColor = TIMER_YELLOW;

        break;
        case TimeStop: //Timer stop
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                m_timeCounter                   = 0;
                timerPanelView.backgroundColor  = KREYOS_GRAY;
                m_bIsSportStarts    = NO;
                timerState          = TimeStop;
                
                [watchTimer invalidate];
                watchTimer = nil;
       
                [mCyclingWorkout setBackgroundImage:[UIImage imageNamed:CYCLING_OFF] forState:UIControlStateNormal];
                [mRunningWorkout setBackgroundImage:[UIImage imageNamed:RUNNING_OFF] forState:UIControlStateNormal];

            });
            
        break;
    }
}

-(void)fireTimer:(NSTimer *)timer {
    
    //~~~Update UI Grid
    [self setTileCountTo:currentNumberOfTiles reUpdate:YES];
    
    if(timerState == TimePause) return;
    
    m_timeCounter++;
    
    [self populateLabelwithTime:m_timeCounter];
    
    //SEND GSPS INFO TO WATCH
    /*
    Int32[0] : Speed in meter * 100/second
    Int32[1] : Altitude in meter
    Int32[2] : Distance in meter * 10
    */
    
#pragma mark COMPUTATION TO GPS INFO
    //Write GPS info to watch
    int32_t gpsSpeed        = sportSpeed;
    int32_t gpsAltitude     = sportAltitude - accumulatedAltitude;
    int32_t gpsDistance     = (sportDistance - accumulatedDistance) * 10;
    int32_t reserved = 0;
    
    accumulatedDistance     =  sportDistance;
    accumulatedAltitude     =  sportAltitude;
    
    [[BluetoothDelegate instance].currentlyDisplayingService writeGpsInfo:gpsSpeed altitude:gpsAltitude distance:gpsDistance reserved:reserved];
}

-(void) populateLabelwithTime:(int)seconds
{
    
    NSString *time_string;
    
    m_seconds = seconds ;
    m_minutes = (m_seconds / 60);
    m_hours = m_minutes / 60;
    
    m_seconds -= m_minutes * 60;
    m_minutes -= m_hours * 60;
    
    time_string = [NSString stringWithFormat:@"%02d:%02d:%02d", m_hours, m_minutes, m_seconds];
    
    if ( sportsTimer )
        sportsTimer.text = time_string;
    
    /*
    if(viewMapGps)
    {
        KreyosGPSMapViewController *mapView = (KreyosGPSMapViewController*)viewMapGps;
        [mapView setTime:time_string];
    }
     */
}


#pragma mark BUTTON CALLBACKS
// +AS:07092014 Trash Button Callback
// Cell Tags: ( Grid Info Index )
//  0   - Plus Button
//  1   |   2
//  3   |   4
//  -
//  1
//  2
//  3
//  -
//  1
//  2
-(IBAction)changeGridNum:(UIButton*)sender
{
    UIView* cell = sender.superview;
    BOOL bIsTrash = ( sender.tag == CELL_TRASH );
    BOOL bIsCell1 = ( cell_1 == sender.superview );
    BOOL bIsCell2 = ( cell_2 == sender.superview );
    BOOL bIsCell3 = ( cell_3 == sender.superview );
    BOOL bIsCell4 = ( cell_4 == sender.superview );
    NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    NSLog(@"SportsPageViewController::changeGridNum IsTrash:%i CelLTag:%i Cells:%i%i%i%i",bIsTrash,cell.tag,bIsCell1,bIsCell2,bIsCell3,bIsCell4);
    NSLog(@"------------------------------------");
    
    if( currentNumberOfTiles > 3 && sender.tag == CELL_TRASH )
    {
        // +AS:07092014 Arrange the indices on the ValueStorage
        int indexOnArray = cell.tag-1;
        NSString* tobeRemoved = m_cellValueStorage[ indexOnArray ];
        [m_cellValueStorage removeObjectAtIndex: indexOnArray];
        [m_cellValueStorage addObject:tobeRemoved];
        [self setTileCountTo:--currentNumberOfTiles];
        
        // +AS:07092014 Added Refresh of Grid
        ((UILabel*)[cell_1 viewWithTag:CELL_TITLE]).text =  [[workoutStatus valueForKey:m_cellValueStorage[0]] uppercaseString];
        ((UILabel*)[cell_1 viewWithTag:CELL_METRIC]).text = [[workoutStatus valueForKey:[m_cellValueStorage[0] stringByAppendingString:@"Measure"]] uppercaseString];
        
        ((UILabel*)[cell_2 viewWithTag:CELL_TITLE]).text =  [[workoutStatus valueForKey:m_cellValueStorage[1]] uppercaseString];
        ((UILabel*)[cell_2 viewWithTag:CELL_METRIC]).text = [[workoutStatus valueForKey:[m_cellValueStorage[1] stringByAppendingString:@"Measure"]] uppercaseString];
        
        ((UILabel*)[cell_3 viewWithTag:CELL_TITLE]).text =  [[workoutStatus valueForKey:m_cellValueStorage[2]] uppercaseString];
        ((UILabel*)[cell_3 viewWithTag:CELL_METRIC]).text = [[workoutStatus valueForKey:[m_cellValueStorage[2] stringByAppendingString:@"Measure"]] uppercaseString];
        
        ((UILabel*)[cell_4 viewWithTag:CELL_TITLE]).text =  [[workoutStatus valueForKey:m_cellValueStorage[3]] uppercaseString];
        ((UILabel*)[cell_4 viewWithTag:CELL_METRIC]).text = [[workoutStatus valueForKey:[m_cellValueStorage[3] stringByAppendingString:@"Measure"]] uppercaseString];
    }
    else if ( currentNumberOfTiles < 5 && sender.tag == 2)
    {
        [self setTileCountTo:++currentNumberOfTiles];
    }
}

-(IBAction)changeWorkOutStatus:(id)sender
{
    
}

// +AS:07092014 Refresh Button Callback
#pragma mark Refresh Button Callback
- (IBAction)changeGridValue:(UIButton*)tappedBtn
{
    [self updateStatus:@"Speed" cellNum:tappedBtn.superview isForced:NO];
    //~~~Note: During the update status, title count must also be called to update the grid display on watch.
    [self setTileCountTo:currentNumberOfTiles];
}

#pragma mark SET TILES
- (void) updateSportsTile
{
    [self setTileCountTo:currentNumberOfTiles reUpdate:YES];
}

- (void) setTileCountTo:(int)count
{
    //~~~set current tile num
    currentNumberOfTiles = count;
    [self changeAndUpdateGrid:currentNumberOfTiles];
}

- (void) setTileCountTo:(int)count
               reUpdate:(BOOL)p_reUpdate
{
    float yPos          = 215;
    float xPos          = 0;
    
    CGSize fiveGridSize;
    CGSize fourGridSize;
    CGSize threeGridSize;
    
    //~~~Row X Col
    //~~~3.5" Devices
    //~~~100h, 265 base y
    BOOL isIPhone4S = [DeviceManager IS_IPhone4S];
    if (isIPhone4S)
    {
        float gridHeight = 205.0f;
        fiveGridSize     = CGSizeMake(160, gridHeight * 0.50f); // 2x2  index 5
        fourGridSize     = CGSizeMake(320, gridHeight * 0.33f); // 1x3  index 4
        threeGridSize    = CGSizeMake(320, gridHeight * 0.50f); // 1x2  index 3
    }
    //~~~4" Devices
    //~~~114h
    else
    {
        fiveGridSize     = CGSizeMake(160, 114);    // 2x2
        fourGridSize     = CGSizeMake(320, 76);     // 1x3
        threeGridSize    = CGSizeMake(320, 114);    // 1x2
    }
    
    addBtn.hidden = NO;
    //Set status to 0;
    cellStatusIndex = 0;
    
    float trashYPos = 20;
    float swapYPos = 60;
    float textPos;
    float metricPos = 80;
    float categoryPos = 11;
    float buttonScale = 1.0f;
    
    switch (count)
    {
        case GRID_1x2:
        {
            cell_3.transform = CGAffineTransformMakeScale(0, 0);
            cell_4.transform = CGAffineTransformMakeScale(0, 0);
            
            cell_1.frame = CGRectMake(xPos,
                                      yPos,
                                      threeGridSize.width,
                                      threeGridSize.height);
            
            cell_2.frame = CGRectMake(xPos,
                                      yPos + cell_1.frame.size.height,
                                      threeGridSize.width,
                                      threeGridSize.height);
            
            textPos = 100;
            buttonScale = 1.0f;
        }
        break;
        case GRID_1x3:
        {
            cell_3.transform = CGAffineTransformMakeScale(1, 1);
            cell_4.transform = CGAffineTransformMakeScale(0, 0);
            
            cell_1.frame = CGRectMake(xPos,
                                      yPos,
                                      fourGridSize.width,
                                      fourGridSize.height);
            
            cell_2.frame = CGRectMake(xPos,
                                      yPos + cell_1.frame.size.height,
                                      fourGridSize.width,
                                      fourGridSize.height);
            
            cell_3.frame = CGRectMake(xPos,
                                      cell_2.frame.origin.y + cell_2.frame.size.height,
                                      fourGridSize.width,
                                      fourGridSize.height);
            
            textPos = 75;
            trashYPos = 12;
            swapYPos = 39;
            metricPos = 55;
            categoryPos = 5;
            buttonScale = 1.2f;
        }
        break;
        case GRID_2x2:
        {
            cell_3.transform = CGAffineTransformMakeScale(1, 1);
            cell_4.transform = CGAffineTransformMakeScale(1, 1);
            
            
            cell_1.frame = CGRectMake(xPos,
                                      yPos,
                                      fiveGridSize.width,
                                      fiveGridSize.height);
            
            cell_2.frame = CGRectMake(fiveGridSize.width ,
                                      yPos,
                                      fiveGridSize.width,
                                      fiveGridSize.height);
            
            cell_3.frame = CGRectMake(xPos,
                                      cell_2.frame.origin.y + cell_2.frame.size.height,
                                      fiveGridSize.width,
                                      fiveGridSize.height);
            
            //NSLog(@"WIDTH : %f", fiveGridSize.width);
            cell_4.frame = CGRectMake(fiveGridSize.width ,
                                      yPos + cell_1.frame.size.height,
                                      fiveGridSize.width,
                                      fiveGridSize.height);
            
            textPos = 100;
            buttonScale = 1.0f;
            addBtn.hidden = YES;
        }
        break;
    }
    
    for (UIView *cell in m_cellArray )
    {
        NSArray* cellSubVies = [cell subviews];
        
        for (UILabel *valueLbl in cellSubVies)
        {
            CGRect rect = valueLbl.frame;
            
            if ([valueLbl tag] == CELL_VALUE)
            {
                //~~~Refresh button positions
                //  1x3 of 4S
                //      57, 12
                //  non 1x3
                //      39, 12.
                //~~~Value label position
                //  1x3 of 4S
                //      72, -7.349f
                //  non 1x3
                //      52, -7.349f
                if (count == GRID_1x3 && isIPhone4S)
                {
                    rect.origin.y = cell.frame.size.height - textPos;
                    rect.origin.x = 85;
                    [[valueLbl layer] setAnchorPoint:CGPointMake(0.0f, 0.5f)];
                }
                else if (isIPhone4S)
                {
                    rect.origin.y = 20;
                    rect.origin.x = 52;
                    [[valueLbl layer] setAnchorPoint:CGPointMake(0.0f, 0.5f)];
                }
                else
                {
                    rect.origin.y = cell.frame.size.height - textPos;
                    rect.origin.x = 52;
                    [[valueLbl layer] setAnchorPoint:CGPointMake(0.5f, 0.5f)];
                }
            }
            
            if ([valueLbl tag] == CELL_METRIC)
            {
                rect.origin.y = metricPos;
                
                if (count == GRID_1x3 && isIPhone4S)
                {
                    rect.origin.y = metricPos-5;
                    rect.origin.x = 105;
                    [[valueLbl layer] setAnchorPoint:CGPointMake(0.0f, 0.5f)];
                }
                else
                {
                    rect.origin.x = 53;
                    [[valueLbl layer] setAnchorPoint:CGPointMake(0.5f, 0.5f)];
                }
            }
            
            if ([valueLbl tag] == CELL_TITLE)
            {
                rect.origin.y = categoryPos;
                
                if (count == GRID_1x3 && isIPhone4S)
                {
                    rect.origin.y = categoryPos-5;
                    rect.origin.x = 105;
                    [[valueLbl layer] setAnchorPoint:CGPointMake(0.0f, 0.5f)];
                }
                else
                {
                    rect.origin.x = 53;
                    [[valueLbl layer] setAnchorPoint:CGPointMake(0.5f, 0.5f)];
                }
            }
            
            valueLbl.frame = rect;
        }
        
        for (UIView *button in cellSubVies)
        {
            CGRect rect = button.frame;
            
            if ([button tag] == CELL_TRASH)
            {
                button.transform = CGAffineTransformMakeScale(buttonScale, buttonScale);
                
                if (count == GRID_1x3 && !isIPhone4S)
                {
                    rect.origin.y = trashYPos - 8.0f;
                }
                else
                {
                    rect.origin.y = trashYPos;
                }
            }
            else if ([button tag] == CELL_REFRESH)
            {
                button.transform = CGAffineTransformMakeScale(buttonScale, buttonScale);
                
                //~~~Refresh button positions
                //  1x3 of 4S
                //      57, 12
                //  non 1x3
                //      39, 12.
                //~~~Value label position
                //  1x3 of 4S
                //      72, -7.349f
                //  non 1x3
                //      52, -7.349f
                if (count == GRID_1x3 && isIPhone4S)
                {
                    rect.origin.y = 12;
                    rect.origin.x = 57;
                }
                else
                {
                    rect.origin.y = swapYPos;
                    rect.origin.x = 12; //~~~Default x position on all grid
                }
            }
            
            button.frame = rect;
        }
    }

    //~~~Refresh scales
    switch (count)
    {
        case GRID_1x2:
        {
            cell_1.transform = CGAffineTransformMakeScale(1, 1);
            cell_2.transform = CGAffineTransformMakeScale(1, 1);
            cell_3.transform = CGAffineTransformMakeScale(0, 0);
            cell_4.transform = CGAffineTransformMakeScale(0, 0);
        }
        break;
        case GRID_1x3:
        {
            cell_1.transform = CGAffineTransformMakeScale(1, 1);
            cell_2.transform = CGAffineTransformMakeScale(1, 1);
            cell_3.transform = CGAffineTransformMakeScale(1, 1);
            cell_4.transform = CGAffineTransformMakeScale(0, 0);
        }
        break;
        case GRID_2x2:
        {
            cell_1.transform = CGAffineTransformMakeScale(1, 1);
            cell_2.transform = CGAffineTransformMakeScale(1, 1);
            cell_3.transform = CGAffineTransformMakeScale(1, 1);
            cell_4.transform = CGAffineTransformMakeScale(1, 1);
        }
        break;
            
        default:
        break;
    }
}


#pragma mark SET STATUS
-(void) updateWorkOutData:(int32_t[5])p_data
{
    
    NSLog(@"---%i timer now equal %i---", m_timeCounter, p_data[0]);
    if ( !NSLocationInRange(m_timeCounter, NSMakeRange(p_data[0] - 2, p_data[0] + 2)))
    {
        bIsTimerSynced = NO;
    }
    
    if ( p_data[0] != m_timeCounter && !bIsTimerSynced)
    {
        bIsTimerSynced = true;
        m_timeCounter += ( p_data[0] - m_timeCounter);
        
    }

    NSLog(@"------------------------------------------------");
    for (int i = 0; i < 5; i++)
    {
        NSLog(@"PARSER P_DATA %i", p_data[i]);
    }
    NSLog(@"------------------------------------------------");
    
    dispatch_async(dispatch_get_main_queue(),
    ^{
        for (UIView *cell in m_cellArray) {
            for (UILabel *dataLbl in [cell subviews]) {
                // 8 - Value Label
                if ( dataLbl.tag == CELL_VALUE )
                {
                    dataLbl.text = [self getConvertedDataFromThis:p_data[[m_cellArray indexOfObject:cell] + 1]
                                                          indexOF:[m_cellArray indexOfObject:cell]];
                    
                }
            }
        }
    });
}

- (NSString*) getConvertedDataFromThis:(int)pData indexOF:(short)pIndex
{
    
    //IF PDATA == 0 return so we wll not convert it
    if ( pData == 0 )   { return [NSString stringWithFormat:@"%d",  pData ]; }
    float returnData = pData;
    
    //GET ACTIVITY DATA FROM INDEX pIndex
    if( [m_cellValueStorage[pIndex] isEqualToString:@"Distance"] )
    {
        returnData = pData / 10;
        return [NSString stringWithFormat:@"%.0f", returnData];
    }
    else if ( [m_cellValueStorage[pIndex] isEqualToString:@"Speed"] )
    {
        float speedValue = (double)pData * 36 / 1000;
        returnData = speedValue;
    }
    
    return [NSString stringWithFormat:@"%.2f", returnData];
}

// +AS:07092014 Note on arranging the values on *m_cellValueStorage
-(void) updateStatus:(NSString*)p_key cellNum: (UIView*) p_cell isForced:(BOOL)bIsForced
{
    //CHECK MODE IF CYCLING, DISABLE STEP PARAM
    BOOL exemptSteps = NO;
    if ([KreyosDataManager sharedInstance].WorkModeType == CYCLING) {
            exemptSteps = YES;
    }
    
    // IF CELL VALUE EXISTS ON CELLS
    if(!bIsForced) {
        do {
            p_key = m_trackableObjects[cellStatusIndex++];
            
            if ( cellStatusIndex >= [m_trackableObjects count])
                cellStatusIndex = 0;
            
        } while ( [m_cellValueStorage containsObject:p_key] || ( exemptSteps && [p_key isEqualToString:@"Steps"]) );
    }
    
    // REPLACE VALUE ON INDEX
    // Note:
    //  tag is it's grid index. ( tag - 1 )
    //  1 = index 0
    //  2 = index 1
    //  3 = index 2
    //  4 = index 3
    if( p_cell.tag > 0 )
    {
        [m_cellValueStorage replaceObjectAtIndex:p_cell.tag - 1 withObject:p_key];
    }
    else
    {
        [m_cellValueStorage replaceObjectAtIndex:p_cell.tag withObject:p_key];
    }
    
    if (p_cell != nil) {
        ((UILabel*)[p_cell viewWithTag:CELL_TITLE]).text =  [[workoutStatus valueForKey:p_key] uppercaseString];
        ((UILabel*)[p_cell viewWithTag:CELL_METRIC]).text = [[workoutStatus valueForKey:[p_key stringByAppendingString:@"Measure"]] uppercaseString];
    }
}

-(void) initializeCellWithValues
{
    
}

int8_t passedVal[4];

-(void) changeAndUpdateGrid:(int)p_count
{
    // +AS: Reset the Values
    passedVal[0] = -1;
    passedVal[1] = -1;
    passedVal[2] = -1;
    passedVal[3] = -1;
    
    // +AS: Data on m_cellValueStorage is already sorted,
    //  so.. all you need to do is fill the data in the passedVal on the following arrangement
    //  Count == 3
    //      0, 1
    //  Count == 4;
    //      0, 1, 2
    //  Count == 5
    //      0, 1, 2, 3
    int countToAdd = p_count-1;
    
    for ( int i = 0; i < countToAdd; i++ )
    {
        passedVal[i] = [self getByteValue:m_cellValueStorage[i]];
    }
    
    NSData *valueToPass = [NSData dataWithBytes:&passedVal length:sizeof(passedVal)];
    [[BluetoothDelegate instance] doWrite:valueToPass forCharacteristics:BLE_HANDLE_SPORTS_GRID];
    
}
#pragma mark PSLocationManagerDelegate

- (void)locationManager:(PSLocationManager *)locationManager signalStrengthChanged:(PSLocationManagerGPSSignalStrength)signalStrength {
    NSString *strengthText;
    if (signalStrength == PSLocationManagerGPSSignalStrengthWeak) {
        strengthText = NSLocalizedString(@"Weak", @"");
    } else if (signalStrength == PSLocationManagerGPSSignalStrengthStrong) {
        strengthText = NSLocalizedString(@"Strong", @"");
    } else {
        strengthText = NSLocalizedString(@"...", @"");
    }
    
    //self.strengthLabel.text = strengthText;
}

- (void)locationManagerSignalConsistentlyWeak:(PSLocationManager *)locationManager {
   // self.strengthLabel.text = NSLocalizedString(@"Consistently Weak", @"");
}

- (void)locationManager:(PSLocationManager *)theLocationManager distanceUpdated:(CLLocationDistance)theDistance {
    self.distanceLabel.text = [NSString stringWithFormat:@"%.2f %@", theDistance, NSLocalizedString(@"meters", @"")];
    self.speedLabel.text = [NSString stringWithFormat:@"%.2f", theLocationManager.currentSpeed];
    
    sportDistance = theDistance;
    sportSpeed = theLocationManager.currentSpeed;
}

- (void)locationManager:(PSLocationManager *)locationManager error:(NSError *)error {
    // location services is probably not enabled for the app
//    self.strengthLabel.text = NSLocalizedString(@"Unable to determine location", @"");
}


#pragma mark GPS DELEGATES
- (void)startLocation
{
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 1;
    
    NSString *theerror;
    if (![CLLocationManager locationServicesEnabled]) {
        theerror = @"Error message";
    }
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusRestricted ||
        status == kCLAuthorizationStatusDenied) {
        theerror = @"Error message";
    }
    
    if (theerror) {
        NSLog(@"%@",theerror);
    }
    else
    {
        status = [CLLocationManager authorizationStatus];
        
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
        
        [self.locationManager startUpdatingLocation];
        
        status = [CLLocationManager authorizationStatus];
        
        NSLog(@"CLLocationManager is %@", self.locationManager);
        NSLog(@"Location is %@", self.locationManager.location);
        
        //[self updateUI];
    }
}

- (void)locationManager:(CLLocationManager *)p_manager
    didUpdateToLocation:(CLLocation *)p_newLocation
           fromLocation:(CLLocation *)p_oldLocation
{
	if (updateCount < 2) {
		[self locationUpdate:p_newLocation];
		updateCount++;
	}
	else {
		[self locationChange:p_newLocation :p_oldLocation];
	}
}

- (void)locationChange:(CLLocation *)p_newLocation
                      :(CLLocation *)p_oldLocation
{
	NSTimeInterval difference = [[p_newLocation timestamp] timeIntervalSinceDate:[p_oldLocation timestamp]];
    
	double temp_distance = [p_newLocation getDistanceFrom:p_oldLocation];
	
	distance += temp_distance;
	self.altitudeLabel.text = [NSString stringWithFormat:@"ALTITUDE %.2f",p_newLocation.altitude];
	
    //Save Altitude to send to watch
    sportAltitude = p_newLocation.altitude;
	
	currentSpeed = (temp_distance/difference) * (18.0/5.0);
	if (currentSpeed > maxSpeed) {
		maxSpeed = currentSpeed;
		//self.speedLabel.text = [NSString stringWithFormat:@"%.2f",maxSpeed];
	}
}


-(void)locationUpdate:(CLLocation *)location {
	NSLog(@"locationUpdate");
}

- (void)locationError:(NSError *)error {
	NSLog(@"locationError");
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError");
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"Change in authorization status");
}
/*
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLLocation *recentLocation = [locations lastObject];
    CLLocation *oldLocation = [locations objectAtIndex:locations.count-1];
    
    
    self.speedLabel.text = [NSString stringWithFormat:@"SPEED : %f", [newLocation speed]];
    self.distanceLabel.text = [NSString stringWithFormat:@"DISTANCE : %f", [newLocation distanceFromLocation:oldLocation]];
    self.altitudeLabel.text = [NSString stringWithFormat:@"ALTITUDE : %f", [newLocation altitude]];
    
    
    totalDistance.text = [NSString stringWithFormat:@"%f", [oldLocation distanceFromLocation:recentLocation] ];
    previousDistance.text = [NSString stringWithFormat:@"%i", [locations count]];
    
    //mapView_.camera = [GMSCameraPosition cameraWithTarget:recentLocation.coordinate zoom:14 ];
    mapView_.camera = [GMSCameraPosition cameraWithTarget:recentLocation.coordinate zoom:18];
    [routePath addCoordinate:recentLocation.coordinate];
    
    //routeLne = [GMSPolyline polylineWithPath:routePath];
    //routeLne.map = mapView_;
    
    NSLog(@"count %i", [locations count]);
    NSLog(@"Found location %f", [locations[0] distanceFromLocation:recentLocation]);
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
                                                         zoom:17];
        prevDistanceTravelled = 0;
        totalDistanceTravelled = 0;
        
        eventDate = location.timestamp;
        stampedLocation = location;
        
    }else{
        
        
        NSLog(@"DISTANCE %f", totalDistanceTravelled);
        NSLog(@"SPEED %f", [location speed]);
        NSLog(@"ALTITUDE %f", [location altitude]);
        
        self.speedLabel.text = [NSString stringWithFormat:@"SPEED %f", [location speed]];
        self.distanceLabel.text = [NSString stringWithFormat:@"DISTANCE %f", totalDistanceTravelled];
        self.altitudeLabel.text = [NSString stringWithFormat:@"ALTITUDE %f", [location altitude]];
        
        //if( totalDistanceTravelled  >= (prevDistanceTravelled + 3))
        //{
            previousDistance.text = [NSString stringWithFormat:@"%2f", prevDistanceTravelled];
            totalDistance.text = [NSString stringWithFormat:@"%2f", totalDistanceTravelled];
            
            [self.view bringSubviewToFront:previousDistance];
            [self.view bringSubviewToFront:totalDistance];
            
            prevDistanceTravelled = totalDistanceTravelled;
            //[mapView_ animateToCameraPosition:[GMSCameraPosition cameraWithTarget:location.coordinate zoom:14]];
            
            [routePath addCoordinate:location.coordinate];
            [self updateDistance];
            
            routeLne = [GMSPolyline polylineWithPath:routePath];
            routeLne.map = mapView_;
      // }
    }
}

- (void)mapView:(GMSMapView *)mapVieww
didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    
    [routePath addCoordinate:coordinate];
     routeLne = [GMSPolyline polylineWithPath:routePath];
     //Set Routline proprerties
     routeLne.strokeColor = [UIColor orangeColor];
     routeLne.strokeWidth = 3;
     
     routeLne.map = mapView_;
     
     [self updateDistance];
}

-(void) updateDistance
{
    if ( [routePath count] >= 3 )
    {
        CLLocation *startPos = [[CLLocation alloc] initWithLatitude:[routePath coordinateAtIndex:[routePath count] - 1].latitude
                                                            longitude:[routePath coordinateAtIndex:[routePath count] - 1].longitude];
        
        CLLocation *finalPos = [[CLLocation alloc] initWithLatitude:[routePath coordinateAtIndex:[routePath count] - 2].latitude
                                                            longitude:[routePath coordinateAtIndex:[routePath count] - 2].longitude];
        
        if ( [startPos distanceFromLocation:finalPos] > 0 )
        {
            totalDistanceTravelled += kMeterPerMile / [startPos distanceFromLocation:finalPos];
        
        
            //NSLog(@"startPos %f, : : %f", [routePath coordinateAtIndex: [routePath count] - 1].latitude, [routePath coordinateAtIndex:[routePath count] - 1].longitude);
            // NSLog(@"COUNT %i", [routePath count]);
            NSLog(@"DISTANCE %f", totalDistanceTravelled);
        }
    }
    
}*/

-(IBAction) startRunning:(id)sender
{
    
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

-(NSMutableArray *)decodePolyLine: (NSMutableString *)encoded {
    
    [encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, [encoded length])];
    
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    
    while (index < len) {
     
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5] ;
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }
    return array;
}

#pragma mark TIMER

-(void) resetTimer
{
    sportsTimer.text = [NSString stringWithFormat:@"00:00:00"];
}

-(void) resetSportsPage
{
    dispatch_async(dispatch_get_main_queue(),
   ^{
       if(watchTimer)
       {
           [watchTimer invalidate];
           watchTimer = nil;
       }
       
       [self updateTimer:TimeStop];
       [self resetTimer];
   });
}

#pragma mark UTILITY FUNCTIONS


-(int8_t)getByteValue:(NSString*)p_key
{
    if ( [p_key isEqualToString:@"---"] )           return (int8_t)0;
    else if ( [p_key isEqualToString:@"Speed"] )    return (int8_t)1;
    else if ( [p_key isEqualToString:@"Heart"] )    return (int8_t)2;
    else if ( [p_key isEqualToString:@"Calories"] ) return (int8_t)3;
    else if ( [p_key isEqualToString:@"Distance"] ) return (int8_t)4;
    else if ( [p_key isEqualToString:@"AvgSpeed"] ) return (int8_t)5;
    else if ( [p_key isEqualToString:@"Altitude"] ) return (int8_t)6;
    else if ( [p_key isEqualToString:@"Totd"] )     return (int8_t)7;
    else if ( [p_key isEqualToString:@"Top Speed"] ) return (int8_t)8;
    else if ( [p_key isEqualToString:@"Cadence"] )  return (int8_t)9;
    else if ( [p_key isEqualToString:@"Pace"] )     return (int8_t)10;
    else if ( [p_key isEqualToString:@"AvgHeart"] ) return (int8_t)11;
    else if ( [p_key isEqualToString:@"MaxHeart"] ) return (int8_t)12;
    else if ( [p_key isEqualToString:@"Elevation"] ) return (int8_t)13;
    else if ( [p_key isEqualToString:@"CurrentLap"] ) return (int8_t)14;
    else if ( [p_key isEqualToString:@"BestLap"] )  return (int8_t)15;
    else if ( [p_key isEqualToString:@"Floor"] )    return (int8_t)16;
    else if ( [p_key isEqualToString:@"Steps"] )    return (int8_t)17;
    else if ( [p_key isEqualToString:@"AvgPace"] )  return (int8_t)18;
    else if ( [p_key isEqualToString:@"AvgLap"] )   return (int8_t)19;
    else  return (int8_t)1;
}

- (UIImage *)imageNamed:(NSString *)p_name withColor:(UIColor *)p_color
{
    
    // load the image
    NSString *name = p_name;
    UIImage *img = [UIImage imageNamed:name];
    
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContext(img.size);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [p_color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}

#pragma mark TOUCH SECTION
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //Iterate through your subviews, or some other custom array of view
    
    UITouch *touch = [touches anyObject];
    
    if ( [touch.view isKindOfClass:[SVGKFastImageView class]])
    {
        SVGKFastImageView *tappedBtn = (SVGKFastImageView*)touch.view;
        
        switch ([tappedBtn.superview tag]) {
            case CELL_TRASH:
                //TRASHBTN
                [self setTileCountTo:currentNumberOfTiles <= 3 ? 3 : --currentNumberOfTiles];
                
                break;
            case CELL_REFRESH:
                //REFRESHBTN
                [self updateStatus:@"Speed" cellNum:tappedBtn.superview.superview isForced:NO];
                
                break;
            case 3:
                //ADDBTN
                [self setTileCountTo:currentNumberOfTiles >= 5 ? 5 : ++currentNumberOfTiles];
                break;
            default:
                break;
        }
    }
    
    for (UIView *view in self.view.subviews)
        [view resignFirstResponder];
}

- (void) showHideActivitySelection : (id) sender
{
    activitySelection.hidden = !activitySelection.hidden;
}


- (void) changeActivity:(int)pActType
{
    UIImage *biking     = [UIImage imageNamed:@"bikingicon.png"];
    UIImage *running    = [UIImage imageNamed:@"runningicon.png"];
    
    switch (pActType) {
        case 1:
            
            [badgeActivityBtn setBackgroundImage:running forState:UIControlStateNormal];
            break;
        case 2:
            
            [badgeActivityBtn setBackgroundImage:biking forState:UIControlStateNormal];
            
            break;
        default:
            break;
    }
    
    activitySelection.hidden = YES;
}

- (void) dealloc
{
    [[KreyosDataManager sharedInstance] setActiveView:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
