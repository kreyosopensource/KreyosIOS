//
//  ActivityStatsPageViewController.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/20/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "ActivityStatsPageViewController.h"
#import "KreyosActivityCell.h"
#import "KreyosDataManager.h"
#import "KreyosBluetoothViewController.h"
#import "DBManager.h"
#import "AccountManager.h"
#import "DatabaseStruct.h"
#import "CustomHeaderTableViewCell.h"
#import "UIViewController+AMSlideMenu.h"
#import "BluetoothDelegate.h"
#import <objc/objc-sync.h>

#include <vector>
#include <map>



namespace ActivitySorting
{
    typedef struct
    {
        ActivityObject  object;
        int             time;
    }RawValues;
    
    typedef struct
    {
        RawValues rawVal;
        const char* keys;
    }ExractedValues;

    class RawMapContainer : public  std::map<const char*, RawValues>
    {
    public:
        typedef std::map<const char*, RawValues> ::iterator mapIT;
        bool haskey(const char* p_key)
        {
            for (mapIT it = begin(); it != end(); it++)
            {
                const char* key = it->first;
                if (!strcmp(key, p_key))
                {
                    return true;
                }
            }
            
            return false;
        }
        
        void UpdateObject( const char * p_key, ActivityObject structv )
        {
            for (mapIT it = begin(); it != end(); it++)
            {
                const char* key = it->first;
                if (!strcmp(key, p_key))
                {
                    it->second.object.bestLap       += structv.bestLap;
                    it->second.object.avgLap        += structv.avgLap;
                    it->second.object.currentLap    += structv.currentLap;
                    it->second.object.avgPace       += structv.avgPace;
                    it->second.object.pace          += structv.pace;
                    it->second.object.topSpeed      += structv.topSpeed;
                    it->second.object.avgSpeed      += structv.avgSpeed;
                    it->second.object.speed         += structv.speed;
                    it->second.object.elevation     += structv.elevation;
                    it->second.object.altitude      += structv.altitude;
                    it->second.object.maxHeart      += structv.maxHeart;
                    it->second.object.avgHeart      += structv.avgHeart;
                    it->second.object.heart         += structv.heart;
                    it->second.object.calories      += structv.calories;
                    it->second.object.distance      += structv.distance;
                    it->second.object.steps         += structv.steps;
                    it->second.object.sportID       = structv.sportID;
                    break;
                }
            }
        }
    };
    
};

@interface ActivityStatsPageViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    KreyosDataManager *dataManager;
    NSMutableArray *cellHolder;
    NSMutableArray *headerHolder;
    NSMutableArray *_dateHolder;
    NSMutableArray *_activitiesForUser;
    
    NSArray *monthList;
    
    BOOL bIsHeader;
    
    NSArray *dayList;
    
    ActivityObject structValue;
}
@end

@implementation ActivityStatsPageViewController

static ActivityStatsPageViewController *sharedInstance = nil;

+ (ActivityStatsPageViewController *)sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        NSNotificationCenter* notifCenter = [NSNotificationCenter defaultCenter];
        
        [notifCenter addObserver:self
                        selector:@selector(refreshPage)
                            name:RELOAD_OVERALL_ACTIVITIES
                          object:nil];
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    //~~~Fetch Overall Activity Data
    [[BluetoothDelegate instance] readActivityData];
    
    [[BluetoothDelegate instance] setIsUpdating:NO];
    
    sharedInstance = self;
    //Initialize Activity Data
    
    cellHolder          = [[NSMutableArray alloc] init];
    headerHolder        = [[NSMutableArray alloc] init];
    _dateHolder         = [[NSMutableArray alloc] init];
    _activitiesForUser  = [[NSMutableArray alloc] init];
    
    dayList     = [[NSArray alloc] initWithObjects:@"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat", nil];
    monthList   = [[NSArray alloc] initWithObjects:@"January", @"February", @"March", @"April", @"May", @"Jun", @"July",
                                                   @"August", @"September", @"October", @"November", @"December",nil];

    
    //Add ProgressBar
    self.dataProgressBar = [[UIProgressView alloc] initWithFrame:CGRectMake(
                                                                                   self.view.frame.size.width/2 - 50,
                                                                                   activityStatsContent.frame.size.height/2 - 15,
                                                                                   100,
                                                                                   30)];
    
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 3.0f);
    self.dataProgressBar.transform = transform;
    
    [self.dataProgressBar setProgress:0.5];
    
    //GET ALL THE DATA FROM ARRAYOFACTIVITIES
    [[DBManager getSharedInstance] getActivitiesForUser];
    
    // get activities for user
    _activitiesForUser = [[NSMutableArray alloc] init];
    
    //~~~Push the existing overall activities
    //~~~Push the home activities
    [self refreshPage];
    
    //GET THE SINGLE INSTANCE OF KREYOSDATAMANAAGER
    dataManager = [KreyosDataManager sharedInstance];
    
    //GET DATA FOR HEADER VALUES
    
    AMSlideMenuMainViewController *mainVC = [AMSlideMenuMainViewController getInstanceForVC:self];
    if(mainVC.rightMenu)
    {
        [self addRightMenuButton];
        [self addLeftMenuButton];
    }
    
    // set the current view on BluetoothDelegate
    [[BluetoothDelegate instance] setCurrentView:self];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSNotificationCenter* notifCenter = [NSNotificationCenter defaultCenter];
    
    //[notifCenter removeObserver:self name:RELOAD_OVERALL_ACTIVITIES object:nil];
    [notifCenter removeObserver:self];
    
    //SET ALL UITABLEVIEW DELEGATES AND DATASOURCE TO NIL TO AVOID NASTY MESSAGES
    activityStatsContent.delegate = nil;
    activityStatsContent.dataSource = nil;
}

- (void) dealloc
{
//    NSNotificationCenter* notifCenter = [NSNotificationCenter defaultCenter];
//    
//    //[notifCenter removeObserver:self name:RELOAD_OVERALL_ACTIVITIES object:nil];
//    [notifCenter removeObserver:self];
//    
//    //SET ALL UITABLEVIEW DELEGATES AND DATASOURCE TO NIL TO AVOID NASTY MESSAGES
//    activityStatsContent.delegate = nil;
//    activityStatsContent.dataSource = nil;
}

- (void) addHomeActivities:(NSDictionary*)p_activities
{
    //~~~Note: the checking of time is for not duplicating of data resulting
    //         to false Activity object
    for ( NSString* key in p_activities )
    {
        ActivityObject object;
        NSValue* value  = (NSValue*)[p_activities objectForKey:key];
        BOOL isExisting = NO;
        [value getValue:&object];
        
        for (NSValue* existing in _activitiesForUser)
        {
            ActivityObject object2;
            [existing getValue:&object2];
            
            if (object.time == object2.time && object.sportID == object2.sportID)
            {
                isExisting = YES;
                break;
            }
        }
        
        if (!isExisting)
        {
            [_activitiesForUser addObject:value];
        }
    }
}

- (void) getOverallData
{
    objc_sync_enter(self);
    
    ActivityObject structv;
    ActivitySorting::RawMapContainer rawDataHolder;
    
    int activityCount = [_activitiesForUser count];
    for ( int activityIndex = 0; activityIndex < activityCount; activityIndex++ )
    {
        //~~~Reset struct
        memset(&structv, 0, sizeof(ActivityObject));
        
        //~~~Get value and update in struct
        NSValue* value;
        value = (NSValue*)[_activitiesForUser objectAtIndex:activityIndex];
        [value getValue:&structv];
        
        if (structv.sportID < kActivity_Walking || structv.sportID > kActivity_Biking)
        {
            NSLog(@"INNVALID DATA SPORTS ID %i", structValue.sportID);
            continue;
        }
        
        //~~~Get time data
        unsigned int dateOfActivity = structv.time;

        //~~~Get date
        NSDateFormatter* format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"EEE, d MMM yyyy"];
        [format setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

        NSDate* date            = [[NSDate alloc] initWithTimeIntervalSince1970:(double)dateOfActivity];
        NSCalendar* calendar    = [NSCalendar currentCalendar];
        [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
        NSDateComponents* components    = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];         // Get necessary date components
        NSString *headerRef             = [NSString stringWithFormat:@"%i-%i-%i", [components year], [components month], [components day]];
        
        //~~~Hold the date and sports id
        NSString* mode = [NSString stringWithFormat:@"%@_%i",headerRef,structv.sportID];
        
        const char* modeKey = [mode UTF8String];
        if (rawDataHolder.haskey(modeKey))
        {
            //~~~Update existing data
            rawDataHolder.UpdateObject(modeKey, structv);
        }
        else
        {
            //~~~Create new Data
            ActivitySorting::RawValues obj;
            memset(&obj, 0, sizeof(ActivitySorting::RawValues));
            obj.object  = structv;
            obj.time    = dateOfActivity;
            rawDataHolder.insert(std::pair<const char*, ActivitySorting::RawValues>(modeKey, obj));
        }
    }
    
    //~~~Add to vector array to sort
    std::vector<ActivitySorting::ExractedValues> sorted;
    for (std::map<const char*, ActivitySorting::RawValues>::iterator it = rawDataHolder.begin(); it != rawDataHolder.end(); it++)
    {
        ActivitySorting::ExractedValues values;
        values.keys         = it->first;
        values.rawVal       = it->second;
        
        sorted.push_back(values);
    }
    
    //~~~Check if valid
    if (sorted.size())
    {
        //~~~Do Bubble Sorting here descending order
        bool isSorted   = false;
        while (!isSorted)
        {
            isSorted = true;
            
            for (int i = 0; i < sorted.size() -1; i++)
            {
                int fromExchange = sorted[i].rawVal.time;
                int toExchange   = sorted[i + 1].rawVal.time;
                //~~~Note:
                //      < descending
                //      > ascending
                if (fromExchange < toExchange)
                {
                    ActivitySorting::ExractedValues from = sorted[i];
                    ActivitySorting::ExractedValues to   = sorted[ i + 1 ];
                    
                    sorted[i]       = to;
                    sorted[i + 1]   = from;
                    isSorted        = false;
                }
            }
        }
    }
    else
    {
        return;
    }
    
    
    [_activitiesForUser removeAllObjects];
    _activitiesForUser = [[NSMutableArray alloc] init];
    
    //~~~Add to the array that is going to be used in table
    while (sorted.size())
    {
        ActivitySorting::ExractedValues values       = sorted[0];
        const char* timeWithmode    = values.keys;
        ActivityObject obj          = values.rawVal.object;
        
        NSString* stringkey     = [NSString stringWithUTF8String:timeWithmode];
        NSRange dateRefRange    = NSMakeRange(0, stringkey.length-2);
        NSString* dateRef       = [stringkey substringWithRange:dateRefRange];
        
        NSValue* filteredData = [NSValue valueWithBytes:&obj objCType:@encode(ActivityObject)];
        [_activitiesForUser addObject:filteredData];
        
        if ( ![_dateHolder containsObject:dateRef] )
        {
            [_activitiesForUser addObject:filteredData];
            [_dateHolder addObject:dateRef];
        }
        
        sorted.erase(sorted.begin());
    }
    
    [_dateHolder removeAllObjects];
}
- (void) reloadActivityData
{
    [[DBManager getSharedInstance] getActivitiesForUser];
    [activityStatsContent reloadData];
}

#pragma mark TABLEVIEW DELEGATES
- (UITableViewCell *) tableView:(UITableView *)tableView
          cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //** HIDE PRELOADER VIEW
    preloaderView.hidden    = true;
    self.dataBlocker.hidden = true;
    
    //** TYPE OF CELL THAT CAN BE GENERATE
    KreyosActivityCell *result          = nil;
    CustomHeaderTableViewCell *header   = nil;
    
    NSLog(@"ROW %i", indexPath.row);
    NSValue *objVal = (NSValue*)[_activitiesForUser objectAtIndex:indexPath.row];
    
    //** GET STRUCT VALUES FOR STEPS, DISTANCE CALORIES ETC
    
    memset(&structValue, 0, sizeof(ActivityObject));
    
    NSValue* value;
    value = objVal;
    [value getValue:&structValue];


    //** DATA THAT WILL BE VIEWED ON OVERALL ACTIVITY

    //** X SPACING BETWEEN STATS DATA
    float statSpacing = 100;
    
    //** GET TIME DATA
    unsigned int dateOfActivity = structValue.time;

    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"EEE, d MMM yyyy"];
    [format setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSDate* date            = [[NSDate alloc] initWithTimeIntervalSince1970:(double)dateOfActivity];
    NSCalendar* calendar    = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSDateComponents* components    = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date]; // Get necessary date components
    NSString *headerRef             = [NSString stringWithFormat:@"%i-%i-%i", [components year], [components month], [components day]];
    
    if ([cellHolder count] > indexPath.row)
        result = [cellHolder objectAtIndex:indexPath.row];
    
    if ( ![_dateHolder containsObject:headerRef] )
    {
        [_dateHolder addObject:headerRef];
        bIsHeader = YES;
        
        if( !header)
        {
            [tableView registerNib:[UINib nibWithNibName:@"HeaderCell" bundle:nil] forCellReuseIdentifier:@"header"];
            header = [tableView dequeueReusableCellWithIdentifier:@"header"];
        }
        
        //NSString *monthStr = [monthList objectAtIndex:([components month] - 1)];
        NSString* dayByDate     = [NSString stringWithFormat:@"%i-%i-%i", [components day], [components month], [components year]];
        NSString* dayOfWeek     = [self getDayByDate:dayByDate];
        NSString* dateString    = [NSString stringWithFormat:@"%@ %i, %i", GetMonthStringByIndex([components month]), [components day], [components  year]];
        
        header.mDay.text        = dayOfWeek;
        header.mDate.text       = dateString;
        header.mHeaderID        = headerRef;
        
        //NSLog(@"HEADER LIST %@ --> DATE %@", headerRef, dayByDate);
        [activityStatsContent reloadData];
        [cellHolder addObject:header];
    }
    
    if (bIsHeader)
    {
        bIsHeader = NO;
        return [cellHolder objectAtIndex:[indexPath row]];
    }
    
    if (result == nil)
    {
        result = [[KreyosActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil withData:structValue];
        result.selectionStyle = UITableViewCellSelectionStyleNone;

        [cellHolder addObject:result];
        
        UIScrollView *dataStatsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(130, 20, SCREEN_SIZE.width / 1.7f, 100)];
        
        //~~~Number and cell type need to show
        enum CellData
        {
            CELL_STEPS,
            CELL_DISTANCE,
            CELL_CALORIES,
            CELL_SPEED,
            CELL_AVGSPEED,
            CELL_TOPSPEED,
            CELL_MAX
        };
        
        //~~~Pre-defined Title and measurements Label
        struct
        {
            NSString* title;
            NSString* msr;
        }const LabelString[CELL_MAX] =
        {
            {.title = @"STEPS"          , .msr = @""},
            {.title = @"DISTANCE"       , .msr = @"km"},
            {.title = @"CALORIES"       , .msr = @"cal"},
            {.title = @"SPEED m/s"      , .msr = @"m/s"},
            {.title = @"AVG SPEED m/s"  , .msr = @"m/s"},
            {.title = @"TOP SPEED m/s"  , .msr = @"m/s"},
        };
        
        //~~~Data that needed to store
        struct
        {
            union
            {
                int     dataInt;
                float   dataFloat;
            }Data;
        }const LabelData[CELL_MAX] =
        {
            {.Data.dataInt      = structValue.steps},
            {.Data.dataFloat    = HOME_DISTANCE(structValue.distance) },
            {.Data.dataFloat    = HOME_CALORIES(structValue.calories) },
            {.Data.dataInt      = structValue.speed },
            {.Data.dataInt      = structValue.avgSpeed },
            {.Data.dataInt      = structValue.topSpeed },
        };

        for (int i = 0 ; i < CELL_MAX ; i++)
        {
            UILabel *stat = [[UILabel alloc] initWithFrame:CGRectMake(statSpacing * i, 10, 50, 50)];
            [stat setFont:FONT_BEBAS(13)];
            [stat setTextColor:BLUE];
            [stat setText:LabelString[i].title];
            
            UILabel *msr = [[UILabel alloc] initWithFrame:CGRectMake(statSpacing * i, 40, 30, 50)];
            [msr setTextAlignment:NSTextAlignmentCenter];
            [msr setFont:FONT_BEBAS(13)];
            [msr setTextColor:BLUE];
            [msr setText:LabelString[i].msr];
            
            CGRect valueLbelFrme        = stat.frame;
            valueLbelFrme.origin.y      = stat.frame.origin.y + 15;
            valueLbelFrme.size.width    = 100;
            valueLbelFrme.size.height   = 50;
            
            UILabel *statVal = [[UILabel alloc] initWithFrame:valueLbelFrme];
            [statVal setFont:FONT_BEBAS(20)];
            [statVal setTextColor:[UIColor blackColor]];
            
            if ( 1<<i & (1<<CELL_DISTANCE | 1<<CELL_CALORIES) )
            {
                if (i == CELL_DISTANCE )
                {
                    NSString* string = HOME_DIST_STR_2(LabelData[i].Data.dataFloat);
                    [statVal setText:string];
                }
                else if ( i == CELL_CALORIES )
                {
                    NSString* string = HOME_CAL_STR_2(LabelData[i].Data.dataFloat);
                    [statVal setText:string];
                }
            }
            else
            {
                [statVal setText:[NSString stringWithFormat:@"%i", LabelData[i].Data.dataInt]];
            }

            dataStatsScrollView.contentSize = CGSizeMake(statSpacing * i + 80, 75);

            [dataStatsScrollView addSubview:stat];
            [dataStatsScrollView addSubview:statVal];
            [dataStatsScrollView addSubview:msr];
        }
        
        mDay.text   = [result getDay];
        mDate.text  = [result getDate];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM dd yyyy"];
        
        
        for (CustomHeaderTableViewCell *header in cellHolder)
        {
            if ( [header isKindOfClass:[CustomHeaderTableViewCell class]] &&
                [header.mHeaderID isEqualToString:headerRef] )
            {
                [header setStepsTotal:structValue.steps];
                [header setDistanceTotal:structValue.distance];
                [header setCaloriesTotal:structValue.calories];
            }
        }
        
        float steps            = dataManager.totalData_Steps;
        float computedDistance = HOME_DISTANCE( dataManager.totalData_DistanceInMeter );
        float computedCalories = HOME_CALORIES( dataManager.totalData_Calories );
        
        mStepsTotal.text     = HOME_STEPS_STR(steps);
        mDistanceTotal.text  = HOME_DIST_STR(computedDistance);
        mCaloriesTotal.text  = HOME_CAL_STR(computedCalories);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"panelUpdate" object:nil userInfo:nil];
        
        [[result contentView] addSubview:dataStatsScrollView];
        
    }

    [self reloadActivityData];
    return result;
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
    return [_activitiesForUser count];
}

- (void)refreshPage
{
    // reload data
    [_activitiesForUser removeAllObjects];
    [_activitiesForUser addObjectsFromArray:[AccountManager getSharedAccountManager].activityObjects];
    
    [self addHomeActivities:[[DBManager getSharedInstance] getHomeActivities]];
    [self getOverallData];
    
    // refresh page
    [activityStatsContent reloadData];
}

#pragma mark GET DATA
- (NSString*) getDayByDate : (NSString*)p_date
{
    // format --- NSString* string=@"26-01-2014";
    if( p_date == nil) return @"";

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"Asia/Kolkata"];
    [dateFormatter setTimeZone:gmt];
    
    NSDate *mydate = [dateFormatter dateFromString:p_date];
    
    NSCalendar* calender = [NSCalendar currentCalendar];
    NSDateComponents* component = [calender components:NSWeekdayCalendarUnit fromDate:mydate];
    [component weekday];
    
    return [dayList objectAtIndex:([component weekday] - 1)];
}


#pragma mark TOUCH DELEGATES
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    BOOL hasConnectedDevice = [[KreyosDataManager sharedInstance] HasConnectedDevice];
    
    if ( [[touch view] isEqual:self.dataBlocker])
    {
        if ( hasConnectedDevice )
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Device not found" message:@"Please connect your Kreyos watch" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
            return;
        }
        else {
            [activityStatsContent reloadData];
        }
    }
}

-(IBAction)refresherOrb:(id)sender
{
    if (![[KreyosDataManager sharedInstance] HasConnectedDevice] )
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Device not found" message:@"Please connect your Kreyos watch" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        return;
    }
    else {
        [activityStatsContent reloadData];
    }
}

-(float) randomFloat:(float)Min  andMax:(float) Max{
    return ((arc4random()%RAND_MAX)/(RAND_MAX*1.0))*(Max-Min)+Min;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

NSString* GetMonthStringByIndex(u_int p_index)
{
    p_index--;
    static const char* data[] =
    {
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sept",
        "Oct.",
        "Nov",
        "Dec",
    };
    
    return [NSString stringWithUTF8String:data[p_index]];
}


@end
