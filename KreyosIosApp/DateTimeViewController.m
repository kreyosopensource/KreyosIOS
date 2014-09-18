//
//  DateTimeViewController.m
//  KreyosIosApp
//
//  Created by Kreyos on 4/15/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosBluetoothViewController.h"
#import "LKreyosService.h"
#import "DateTimeViewController.h"

@interface DateTimeViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
{
    BOOL bIsAutomaticallyOn;
    
    LKreyosService *currentDisplayedService;
}
@end

@implementation DateTimeViewController

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
    
    [self.mDatePicker   addTarget:self action:@selector(pickerChanged:) forControlEvents:UIControlEventValueChanged];
    [self.mSwitch       addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    currentDisplayedService = [ KreyosDataManager sharedInstance].DisplayingService;
    
    [self isCellButtonEnable:self.mSwitch.isOn];
}

- (void) updateToday
{
    NSDate *now = [[NSDate alloc] init];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"h:mm a"];
    
    self.mTime.text = [outputFormatter stringFromDate:now];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MMM d, yyyy"];
    
    self.mDate.text = [dateFormatter stringFromDate:now];
}

-(void)isCellButtonEnable:(BOOL)p_bool
{
    if (p_bool)
    {
        self.mCellButton.enabled    = NO;
        self.mCellButton.hidden     = YES;
        self.mCellDate.hidden       = YES;
        [self updateToday];
    }
    else
    {
        self.mCellButton.enabled    = YES;
        self.mCellButton.hidden     = NO;
        self.mCellDate.hidden       = NO;
    }
}

- (IBAction)showPicker:(id)sender
{
    if (bIsAutomaticallyOn) {
        return;
    }
    
    [self.mDatePicker setHidden:NO];
}

- (void) switchChanged : (UISwitch*) pswitch
{
    [self isCellButtonEnable:pswitch.isOn];
    if ( pswitch.isOn )
    {
        [self updateToday];
        [self updateWatchAutomatically];
        [self setAutomaticToLocalData:YES];
        [self.mDatePicker setHidden:YES];
        
        bIsAutomaticallyOn = YES;
    }
    else
    {
        bIsAutomaticallyOn = NO;
        [self setAutomaticToLocalData:NO];
    }
}

- (void) pickerChanged:(id)sender
{

    if ( self.mSwitch.isOn ) return;
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"h:mm a"];
    
    self.mTime.text = [outputFormatter stringFromDate:self.mDatePicker.date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MMM d, yyyy"];
    
    self.mDate.text = [dateFormatter stringFromDate:self.mDatePicker.date];
    
    
}

- (IBAction) updateWatch:(id) sender
{
    BOOL hasConnectedDevice                 = [[KreyosDataManager sharedInstance] HasConnectedDevice];
    
    if ( !hasConnectedDevice )
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Device not found" message:@"Please connect your Kreyos watch" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        return;
    }
    
    BOOL isAutomaticSet = [[NSUserDefaults standardUserDefaults] boolForKey:@"set_automatic"];
    
    if ( isAutomaticSet )
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Date and Time" message:@"Date and Time is set automatically" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        return;
    }
    
    [self.mDatePicker setHidden:YES];  
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components: NSSecondCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:self.mDatePicker.date];
    
    int year = [components year];
    int month = [components month];
    int day = [components day];
    int hour = [components hour];
    int min = [components minute];
    int sec = [components second];
    
    [currentDisplayedService writeDateTime:(int8_t)(year - 2000)
                                        month:(int8_t)month - 1
                                          day:(int8_t)day
                                         hour:(int8_t)hour
                                      minutes:(int8_t)min
                                      seconds:(int8_t)sec];
}

- (void) updateWatchAutomatically
{
    if ( !currentDisplayedService )
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Device not found" message:@"Please connect your Kreyos watch" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
    
    NSDate *now = [[NSDate alloc] init];;
    NSDateComponents *components = [[NSCalendar currentCalendar] components: NSSecondCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:now];
    
    int year = [components year];
    int month = [components month];
    int day = [components day];
    int hour = [components hour];
    int min = [components minute];
    int sec = [components second];
    
    [currentDisplayedService writeDateTime:(int8_t)(year - 2000)
                                     month:(int8_t)month - 1
                                       day:(int8_t)day
                                      hour:(int8_t)hour
                                   minutes:(int8_t)min
                                   seconds:(int8_t)sec];
}

- (void) setAutomaticToLocalData : (BOOL) pb
{
    [[NSUserDefaults standardUserDefaults] setBool:pb forKey:@"set_automatic"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
