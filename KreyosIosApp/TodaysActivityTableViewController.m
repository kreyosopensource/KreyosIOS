//
//  TodaysActivityTableViewController.m
//  KreyosIosApp
//
//  Created by Kreyos on 6/11/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "TodaysActivityTableViewController.h"
#import "KreyosDataManager.h"
#import "KreyosBluetoothViewController.h"
#import "DBManager.h"
#import "KreyosActivityCell.h"
#import "AccountManager.h"
#import "KreyosUtility.h"
#import "BluetoothDelegate.h"

@interface TodaysActivityTableViewController ()
{
    NSMutableArray *todaysActivities;
    NSMutableArray *cellHolder;
    NSMutableArray *headerHolder;
    NSMutableArray *_dateHolder;
    NSMutableArray *_todaysData;
    
    KreyosDataManager *dataManager;
    ActivityObject structValue;
    
    float m_steps;
    float m_distance;
    float m_calories;
    float m_speed;
    float m_avgspeed;
}
@end

@implementation TodaysActivityTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[BluetoothDelegate instance] setIsUpdating:NO];
    
    todaysActivities = [[NSMutableArray alloc] init];
    
    cellHolder      = [[NSMutableArray alloc] init];
    _dateHolder     = [[NSMutableArray alloc] init];
    _todaysData     = [[NSMutableArray alloc] init];
    
    //[[BluetoothDelegate instance] initializeFileTransistor];
    //~~~Please remove the unnecessary readActivityData calls
    //[[BluetoothDelegate instance] readActivityData];
    
    //GET THE SINGLE INSTANCE OF KREYOSDATAMANAAGER
    dataManager = [KreyosDataManager sharedInstance];
    
    //GET ALL THE DATA FROM ARRAYOFACTIVITIES
    [[DBManager getSharedInstance] getActivitiesForUser];
    
    //JUST FILTER FOR TODAY'S DATA
    [self filterDataForToday];
    
    // set the current view on BluetoothDelegate
    [[BluetoothDelegate instance] setCurrentView:self];
}

- (void) filterDataForToday
{
    NSArray* todaysData = DictToArray([[DBManager getSharedInstance] getHomeActivities]);
    NSArray* overallData = [AccountManager getSharedAccountManager].activityObjects;
   
    [self fillDataWithActivities:todaysData];
    [self fillDataWithActivities:overallData];
    
    //GET DATA FOR HEADER VALUES
    [self collectDataForHeader];
}

- (void) fillDataWithActivities:(NSArray*)p_list
{
    if ( p_list == nil || [p_list count] <= 0 ) { return; }
    
    int overallCount = [p_list count];
    
    for (int indx = 0; indx < overallCount; indx++) {
        
        //** GET TIME DATA
        NSValue* value;
        value = (NSValue*)[p_list objectAtIndex:indx];
        [value getValue:&structValue];
        
        unsigned int dateOfActivity     = structValue.time;
        NSString *epoctime              = [NSString stringWithFormat:@"%i", dateOfActivity];
        NSTimeInterval seconds          = [epoctime doubleValue];
        NSDate *date                    = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
        NSCalendar* calendar            = [NSCalendar currentCalendar];
        
        NSDateComponents* components    = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                                      fromDate:date];
        
        NSString *headerRef = [NSString stringWithFormat:@"%i-%i-%i", [components year], [components month], [components day]];
        
        NSDate *today = [NSDate date];
        components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                 fromDate:today];
        
        NSString *todayStr = [NSString stringWithFormat:@"%i-%i-%i", [components year], [components month], [components day]];
        
        if ([headerRef isEqualToString:todayStr]) {
            [_todaysData addObject:[p_list objectAtIndex:indx]];
        }
    }
}

#pragma mark TABLEVIEW DELEGATES
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //** TYPE OF CELL THAT CAN BE GENERATE
    KreyosActivityCell *result = nil;
    
    //** GET STRUCT VALUES FOR STEPS, DISTANCE CALORIES ETC
    NSValue* value;
    value = (NSValue*)[_todaysData objectAtIndex:indexPath.row];
    [value getValue:&structValue];
    
    NSMutableArray* _str = [NSMutableArray array];
    [_str addObject:@"STEPS"];
    [_str addObject:@"DISTANCE"];
    [_str addObject:@"CALORIES"];
    [_str addObject:@"SPEED m/s"];
    [_str addObject:@"AVG SPEED m/s"];
    [_str addObject:@"TOP SPEED m/s"];
    
    NSMutableArray* _msr = [NSMutableArray array];
    [_msr addObject:@""];
    [_msr addObject:@"m"];
    [_msr addObject:@"cal"];
    [_msr addObject:@"m/s"];
    [_msr addObject:@"m/s"];
    [_msr addObject:@"m/s"];
    
    //** DATA THAT WILL BE VIEWED ON OVERALL ACTIVITY
    int _struct[6]={structValue.steps,structValue.distance,structValue.calories, structValue.speed, structValue.avgSpeed, structValue.topSpeed};
    
    //** X SPACING BETWEEN STATS DATA
    float statSpacing = 100;
    
    
    //** GET TIME DATA
    unsigned int dateOfActivity = structValue.time;
    NSString *epoctime = [NSString stringWithFormat:@"%i", dateOfActivity];
    NSTimeInterval seconds = [epoctime doubleValue];
    NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date]; // Get necessary date components
    NSString *headerRef = [NSString stringWithFormat:@"%i-%i-%i", [components year], [components month], [components day]];
    
    NSDate *today = [NSDate date];
    components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:today];
    NSString *todayStr = [NSString stringWithFormat:@"%i-%i-%i", [components year], [components month], [components day]];
    
    if ([cellHolder count] > indexPath.row)
        result = [cellHolder objectAtIndex:indexPath.row];
    
    if (result == nil)
    {
        result = [[KreyosActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil withData:structValue];
        result.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cellHolder addObject:result];
        
        UIScrollView *dataStatsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(130, 20, SCREEN_SIZE.width / 1.7f, 100)];
        
        float avg_speed;
        float top_speed;
        float f_time;
        
        float min;
        float max;
        
        for (int i = 0 ; i < [_str count] ; i++)
        {
            UILabel *stat = [[UILabel alloc] initWithFrame:CGRectMake(statSpacing * i, 10, 50, 50)];
            [stat setFont:FONT_BEBAS(13)];
            [stat setTextColor:BLUE];
            [stat setText:[_str objectAtIndex:i ]];
            
            UILabel *msr = [[UILabel alloc] initWithFrame:CGRectMake(statSpacing * i, 40, 30, 50)];
            [msr setTextAlignment:NSTextAlignmentCenter];
            [msr setFont:FONT_BEBAS(13)];
            [msr setTextColor:BLUE];
            [msr setText:[_msr objectAtIndex:i ]];
            
            CGRect valueLbelFrme = stat.frame;
            valueLbelFrme.origin.y = stat.frame.origin.y + 15;
            valueLbelFrme.size.width = 100;
            valueLbelFrme.size.height = 50;
            UILabel *statVal = [[UILabel alloc] initWithFrame:valueLbelFrme];
            [statVal setFont:FONT_BEBAS(20)];
            [statVal setTextColor:[UIColor blackColor]];
            
            switch (i) {
                case 1u:
                    
                    m_distance = _struct[i] * 0.01f;
                    [statVal setText:[NSString stringWithFormat:@"%.2f", m_distance]];
                    break;
                    
                case 3u:
                    
                    m_steps         = _struct[0];
                    f_time          = m_steps * 0.5f;
                    m_speed         = m_distance / f_time;
                    
                    [statVal setText:[NSString stringWithFormat:@"%.2f", m_speed]];
                    
                    break;
                    
                case 4u:
                    
                    avg_speed = m_speed * 0.7f;
                    [statVal setText:[NSString stringWithFormat:@"%.2f", avg_speed]];
                    break;
                    
                case 5u:
                    
                    top_speed = m_speed * 1.1f;
                    [statVal setText:[NSString stringWithFormat:@"%.2f", top_speed]];
                    
                    break;
                    
                default:
                    [statVal setText:[NSString stringWithFormat:@"%i",_struct[i]]];
                    break;
            }
            
            dataStatsScrollView.contentSize = CGSizeMake(statSpacing * i + 80, 75);
            
            [dataStatsScrollView addSubview:stat];
            [dataStatsScrollView addSubview:statVal];
            [dataStatsScrollView addSubview:msr];
            
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"panelUpdate" object:nil userInfo:nil];
        
        [[result contentView] addSubview:dataStatsScrollView];
        
    }
    
    return result;
}

- (void) collectDataForHeader
{
    ActivityObject structv;
    
#ifdef DEBUG_WEIRD_DATE
    float todayCalories             = 0.0f;
    float todayDistanceInMeter      = 0.0f;
    float todaySteps                = 0.0f;
#endif
    
    for (int x = 0; x < [_todaysData count]; x++) {
        
        NSValue* value;
        value = (NSValue*)[_todaysData objectAtIndex:x];
        [value getValue:&structv];
        
#ifdef DEBUG_WEIRD_DATE
        todayCalories        += [self getComputedCalories:structv.calories];
        todayDistanceInMeter += structv.distance;
        todaySteps           += structv.steps;
#endif
    }
    
#ifdef DEBUG_WEIRD_DATE
    NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    NSLog(@"TodaysActivityTableViewController::collectDataForHeader");
    NSLog(@"    Todays Values: (Calories,distanceMeter,steps)");
    NSLog(@"       (%f,%f,%f)",todayCalories,todayDistanceInMeter,todaySteps);
    NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
#endif
}

- (float) getComputedCalories : (int) val
{
    val = abs(val);
    
    float calVal;
    calVal = val % 100;
    calVal /= 100.0;
    calVal += val / 100;
    
    return calVal;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPHONE_5)
    {
        return 100;
    }
    return 99;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_todaysData count];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
