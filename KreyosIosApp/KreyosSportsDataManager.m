//
//  KreyosSportsDataManager.m
//  KreyosIosApp
//
//  Created by Kreyos on 5/8/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosSportsDataManager.h"

@interface KreyosSportsDataManager ()
{
    int mTopSpeed;
}
@end

@implementation KreyosSportsDataManager

static KreyosSportsDataManager *_sharedInstance;

+(KreyosSportsDataManager*) sharedInstance
{
    if (_sharedInstance) {
        _sharedInstance = [[self alloc] init];
    }
    
    return _sharedInstance;
}


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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*) GetTimeOfTheDay {
    NSDate *now = [[NSDate alloc] init];;
    NSDateComponents *components = [[NSCalendar currentCalendar] components: NSSecondCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:now];
    
    int year = [components year];
    int month = [components month];
    int day = [components day];
    int hour = [components hour];
    int min = [components minute];
    int sec = [components second];
    
    return [NSString stringWithFormat:@"%i:%i", hour, min];
}

- (void) GetAverageSpeed
{
    
}

- (int) GetTopSpeed : (int) pSpeed
{
    if(pSpeed > mTopSpeed){
        mTopSpeed = pSpeed;
    }
    
    return mTopSpeed;
}

- (void) GetPace
{
    
}

- (void) GetAveragePace
{
    
}

#pragma mark GPS
- (void) GetLapTime
{
    
}

- (void) GetAverageLapTime
{
    
}

- (void) GetBestLapTime
{
    
}


#pragma mark ANT+ DEPENDENT
- (void) GetHeartRate
{
    
}

- (void) GetAverageHeartRate
{
    
}

- (void) GetMaxHeartRate
{
    
}





@end
