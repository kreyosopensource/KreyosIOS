//
//  SetAlarmViewController.m
//  KreyosIosApp
//
//  Created by Kreyos on 4/2/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "SetAlarmViewController.h"
#import "WatchAlarmTableViewController.h"

@interface SetAlarmViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@end

@implementation SetAlarmViewController

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
    
    [self.alarmPicker addTarget:self action:@selector(pickerChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void) setThisDelegate:(id)sender
{
    delegate = sender;
}

- (void) pickerChanged:(id)sender
{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"h:mm a"];
    
    self.timeLabel.text = [outputFormatter stringFromDate:self.alarmPicker.date];
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"h:mm a"];
    
    self.timeLabel.text = [outputFormatter stringFromDate:self.alarmPicker.date];
    
}

- (IBAction) saveChanges : (id) sender
{
    [delegate returnTimeData:self.alarmPicker.date];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction) cancel:(id)sender
{
    [delegate cancelSetAlarm];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
