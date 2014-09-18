//
//  KreyosSilentAlarmViewController.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/31/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosSilentAlarmViewController.h"
#import "KreyosTimePickerViewController.h"
#import "KreyosUtility.h"
#import "KreyosDataManager.h"
#import "KreyosBluetoothViewController.h"
#import "BluetoothDelegate.h"

@interface KreyosSilentAlarmViewController ()
{
    LKreyosService *displayingService;
    
}
@end

@implementation KreyosSilentAlarmViewController

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
    
    [[BluetoothDelegate instance] setIsUpdating:NO];
    
    displayingService = [KreyosDataManager sharedInstance].DisplayingService;
    
    self.settingsHolder.layer.cornerRadius  = 15;
    self.settingsHolder.layer.borderWidth   = 0.5;
    self.settingsHolder.layer.borderColor   = KREYOS_GRAY.CGColor;
    self.settingsHolder.layer.masksToBounds = YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)setAlarmToWatch:(id)sender
{
    BOOL hasConnectedDevice                 = [[KreyosDataManager sharedInstance] HasConnectedDevice];
    
    if ( !hasConnectedDevice )
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Device not found" message:@"Please connect your Kreyos watch" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        return;
    }
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    
    //Write to watch
    if ( [userDef objectForKey:@"alarm_1"])
    {
        NSDate *date = (NSDate*)[userDef objectForKey:@"alarm_1"];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
        int8_t hour = [components hour];
        int8_t minute = [components minute];
        
        NSLog(@"WRITE ALARM 1 HOUR=>%i ::: MINUTE=>%i", hour, minute);
        [displayingService writeAlarm0:(int8_t)1 hour:hour minutes:minute];
    }
    else
    {
        [displayingService writeAlarm0:(int8_t)0 hour:(int8_t)0 minutes:(int8_t)0];
    }
    
    if ( [userDef objectForKey:@"alarm_2"])
    {
        NSDate *date = (NSDate*)[userDef objectForKey:@"alarm_2"];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
        int8_t hour = [components hour];
        int8_t minute = [components minute];
        
        NSLog(@"WRITE ALARM 2 HOUR=>%i ::: MINUTE=>%i", hour, minute);
        [displayingService writeAlarm1:(int8_t)1 hour:hour minutes:minute];
    }else
    {
        [displayingService writeAlarm1:(int8_t)0 hour:(int8_t)0 minutes:(int8_t)0];
    }
    
    if ( [userDef objectForKey:@"alarm_3"])
    {
        NSDate *date = (NSDate*)[userDef objectForKey:@"alarm_3"];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
        int8_t hour = [components hour];
        int8_t minute = [components minute];
        
        NSLog(@"WRITE ALARM 3 HOUR=>%i ::: MINUTE=>%i", hour, minute);
        [displayingService writeAlarm2:(int8_t)1 hour:hour minutes:minute];
    }else
    {
        [displayingService writeAlarm2:(int8_t)0 hour:(int8_t)0 minutes:(int8_t)0];
    }
    
    //Show alertView that update is succesful
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Set Alarm" message:@"Alarm is set succesfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
