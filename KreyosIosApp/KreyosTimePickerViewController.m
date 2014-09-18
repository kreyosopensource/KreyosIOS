//
//  KreyosTimePickerViewController.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/29/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosTimePickerViewController.h"
#import "WatchAlarmTableViewController.h"

@interface KreyosTimePickerViewController ()

@end

@implementation KreyosTimePickerViewController

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

- (void) setThisDelegate : (id) pDelegate
{
    self.delegate = pDelegate;
}

- (IBAction)setThisTime:(id)sender
{
    
     [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    WatchAlarmTableViewController *deleg = (WatchAlarmTableViewController*)self.delegate;
    
    NSDateFormatter *hour = [[NSDateFormatter alloc] init];
    NSDateFormatter *min = [[NSDateFormatter alloc] init];
    
    [hour setDateFormat:@"hh"];
    [min setDateFormat:@"mma"];
    
    NSString *hourStr = [hour stringFromDate:[alarmPicker date]];
    NSString *minStr = [min stringFromDate:[alarmPicker date]];

    [deleg returnTimeData:[NSString stringWithFormat:@"%@:%@",hourStr, minStr]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
