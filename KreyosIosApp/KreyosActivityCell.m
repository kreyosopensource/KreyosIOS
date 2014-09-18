//
//  KreyosActivityCell.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/20/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosActivityCell.h"
#import "KreyosDataManager.h"
#import "KreyosUtility.h"
#import "KreyosDataManager.h"
#import "AccountManager.h"

NSString *const kMODE_NORMAL    = @"stats-activity";
NSString *const kMODE_WALKING   = @"stats-activity";
NSString *const kMODE_RUNNING   = @"stats-running";
NSString *const kMODE_BIKING    = @"stats-cycling";

#define mDescriptionTitle  [NSArray arrayWithObjects: @"Congratulations! ", @"Awesome!",    @"Great!",  @"That's fantastic!",   nil]

@implementation KreyosActivityCell
{
    KreyosDataManager *dataMngr;
    
    BOOL dragging;
    NSArray *dayList;
    NSArray *monthList;
    
    unsigned short version;
    unsigned short year;
    unsigned short month;
    unsigned short day;
    
    unsigned short mode;
    unsigned int mHour;
    unsigned int mMinutes;
    unsigned short slots;
    
    unsigned int steps;
    unsigned int distance;
    unsigned int calories;
}
@synthesize stepsValue;
@synthesize dstValue;
@synthesize calValue;

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withData:(ActivityObject)pStructVal
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        steps       = pStructVal.steps;
        distance    = pStructVal.distance;
        calories    = pStructVal.calories;
        
        //GET TIME DATA
        unsigned int dateOfActivity = pStructVal.time;

        NSDate* date            = [[NSDate alloc] initWithTimeIntervalSince1970:(double)dateOfActivity];
        NSCalendar* calendar    = [NSCalendar currentCalendar];
        [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
        NSDateComponents* components    = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:date]; // Get necessary date components
        NSString *headerRef             = [NSString stringWithFormat:@"%i-%i-%i", [components year], [components month], [components day]];
        
        dayList     = [[NSArray alloc] initWithObjects:@"MON", @"TUE", @"WED", @"THU", @"FRI", @"SAT", @"SUN",  nil];
        monthList   = [[NSArray alloc] initWithObjects:@"January", @"February", @"March", @"April", @"May", @"Jun", @"July",
                                                     @"August", @"September", @"October", @"November", @"December",nil];
        
        version = 0;
        year    = [components year];
        month   = [components month];
        day     = [components day];
        
        mHour   = [components hour];
        mMinutes= [components minute];
        mode    = pStructVal.sportID;
        slots   = 0;
        
        [self updateHeaderValues];
        [self setUpDataCell];
        
    }
    return self;
}

- (void) setUpDataCell
{
    float paddingX = 10;
    float paddingY = 10;
    
    dragging = true;

    unsigned int randDesc = (arc4random() % [mDescriptionTitle count] );
    NSString *activityStr = @"";
    NSString *activityMsr = @"";
    
    activityType = [[UILabel alloc] initWithFrame:CGRectMake(paddingX + 120, paddingY, 150, 20)];
    [activityType setText:mDescriptionTitle[randDesc]];
    [activityType setFont:FONT_BEBAS(15)];
    [activityType setTextColor:ORANGE];
    
    activityDesc = [[UILabel alloc] initWithFrame:CGRectMake(paddingX + 120, paddingY + 15, 170, 30)];
    [activityDesc setFont:FONT_LATOREG(11)];
    
    //Time Label
    
    UILabel *timelbl = [[UILabel alloc] initWithFrame:CGRectMake(paddingX, self.frame.size.height/2, 150, 20)];
    
    KLog(@"DISPLAYS %d:%d", mHour, mMinutes);
    
    //~~~Format time check if minutes is 0 - 9
    char buf[10];
    if (mMinutes < 10)
    {
        sprintf(buf, "0%i", mMinutes);
        NSString* string = [NSString stringWithUTF8String:buf];
        [timelbl setText:[NSString stringWithFormat:@"%d:%@", [self get12HourFormat:mHour], string]];
    }
    else
    {
        [timelbl setText:[NSString stringWithFormat:@"%d:%d", [self get12HourFormat:mHour], mMinutes]];
    }
    
    [timelbl setFont:FONT_LATOREG(11)];
    [self addSubview:timelbl];
    
    UIImage *iconImage = [UIImage imageNamed:kMODE_NORMAL];
    
    switch (mode) {
        case 0:
            activityStr = @"Walking";
            activityMsr = @"steps";
            break;
        case 1:
            iconImage = [UIImage imageNamed:kMODE_RUNNING];
            activityStr = @"Walking";
            activityMsr = @"steps";
            break;
        case 2:
            iconImage = [UIImage imageNamed:kMODE_BIKING];
            activityStr = @"Walking";
            activityMsr = @"steps";
            break;
        case 3:
            iconImage = [UIImage imageNamed:kMODE_RUNNING];
            activityStr = @"Running";
            activityMsr = @"kph";
            break;
        case 4:
            iconImage = [UIImage imageNamed:kMODE_BIKING];
            activityStr = @"Biking";
            activityMsr = @"kph";
            break;
            
        default:
            break;
    }
     
    //SET DESCRIPTION DEPENDS ON ACTIVITY
    //[activityDesc setText:[NSString stringWithFormat:@"You've reached your goal of %@ %d %@!", activityStr, steps, activityMsr ]];
    activityDesc.numberOfLines = 0;
    
    activityIcon = [[UIImageView alloc] initWithFrame:CGRectMake(paddingX + 30, paddingY, 74, 70)];    [activityIcon setImage:iconImage];
    activityIcon.backgroundColor = [UIColor clearColor];
    
    [self addSubview:activityIcon];
    [self addSubview:activityType];
    //[self addSubview:activityDesc];
    
}

#pragma mark GETDAY DATe
- (void) updateHeaderValues
{
    NSString* dayByDate = [NSString stringWithFormat:@"%i-%i-%i", day, month, year];
    dayLabel.text = [self getDayByDate:dayByDate];
}


- (NSString*) getDayByDate : (NSString*)p_date
{
    // format --- NSString* string=@"26-01-2014";
    if( p_date == nil) return @"";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-mm-yyyy"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:[[NSTimeZone localTimeZone]name]];
    [dateFormatter setTimeZone:gmt];
    
    NSDate *mydate = [dateFormatter dateFromString:p_date];
    
    NSCalendar* calender = [NSCalendar currentCalendar];
    NSDateComponents* component = [calender components:NSWeekdayCalendarUnit fromDate:mydate];
    [component weekday];
    
    return [dayList objectAtIndex:[component weekday] -1 ];
}

- (NSString*) getDay
{
    NSString* dayByDate = [NSString stringWithFormat:@"%i-%i-%i", day, month, year];
    return [self getDayByDate:dayByDate];
}

- (NSString*) getDate
{
    NSString *monthStr = [monthList objectAtIndex:(month - 1)];
    NSString *date = [NSString stringWithFormat:@"%@ %i, 20%i", monthStr, day, year];
    
    return date;
}

/* +AS:07282014 No need to use this. please delete
- (NSArray*) getTotalData
{
    NSNumber* steps = [NSNumber numberWithFloat:[dataMngr totalData_Steps]];
    NSNumber* dists = [NSNumber numberWithFloat:PrecomputeData( dataMngr.totalData_DistanceInMeter / 1000.0f )];
    NSNumber* calor = [NSNumber numberWithFloat:PrecomputeData( dataMngr.totalData_Calories / 1000.0f )];
    
    NSArray* totalValues = [NSArray arrayWithObjects:steps, dists, calor, nil];
     
    return totalValues;
}
//*/

- (int) get12HourFormat:(int)p24
{
    if ( p24 < 12 )
        return p24;
    else{
        return p24 - 12;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
