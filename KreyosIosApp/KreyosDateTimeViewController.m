//
//  KreyosDateTimeViewController.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/31/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosDateTimeViewController.h"
#import "TimezoneTableViewController.h"

@interface KreyosDateTimeViewController ()

@end

@implementation KreyosDateTimeViewController

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSString *Date;
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    Date = [dateFormatter stringFromDate:now];
    
    currentDate.text = Date;
    
    NSString *Time;
    NSDate *timeNow = [NSDate date];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm"];
    Time = [timeFormatter stringFromDate:timeNow];
    
    currentTime.text = Time;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [(TimezoneTableViewController*)[segue destinationViewController] setThisDelegate:self];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)sendDataToA:(NSString *)timeZoneData
{
    // data will come here inside of ViewControllerA
    timeZon.text = timeZoneData;
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
