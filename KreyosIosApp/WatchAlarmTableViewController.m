//
//  WatchAlarmTableViewController.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/29/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "WatchAlarmTableViewController.h"
#import "KreyosTimePickerViewController.h"
#import "SetAlarmViewController.h"
#import "KreyosUtility.h"
#import "KreyosDataManager.h"
#import "BluetoothDelegate.h"
#import "DeviceManager.h"

@interface WatchAlarmTableViewController ()
{
    KreyosDataManager *dataManager;
    NSUserDefaults *mUserDefaults;
    
    UISwitch *selectedSwitch;
    
    BOOL bIsAlarm1Off;
    BOOL bIsAlarm2Off;
    BOOL bIsAlarm3Off;
}
@end

@implementation WatchAlarmTableViewController
@synthesize selectedCellAlarm;
@synthesize mAlarmDict;

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
    
    if ([DeviceManager IS_IPhone4S])
    {
        self.tableView.contentInset = UIEdgeInsetsMake(-60, 0, 70, 0);
    }
    else
    {
        self.tableView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0);
    }
    
    dataManager = [KreyosDataManager sharedInstance];
    
    //GET USERDEFAULTS FOR ALARMS
    mUserDefaults = [[KreyosDataManager sharedInstance] getUserDefaults];
    
    bIsAlarm1Off = bIsAlarm2Off = bIsAlarm3Off = YES;
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"h:mm a"];
    
    if ( [mUserDefaults objectForKey:@"alarm_1"]){
        self.mAlarm1CellLbl.text = [NSString stringWithFormat:@"%@" , [outputFormatter stringFromDate:[mUserDefaults objectForKey:@"alarm_1"]]];
        [self.switch_1 setOn:YES animated:NO];
        bIsAlarm1Off = false;
    }
    
    if ( [mUserDefaults objectForKey:@"alarm_2"]){
        self.mAlarm2CellLbl.text = [NSString stringWithFormat:@"%@" , [outputFormatter stringFromDate:[mUserDefaults objectForKey:@"alarm_2"]]];
        [self.switch_2 setOn:YES animated:NO];
        bIsAlarm1Off = false;
    }
    
    if ( [mUserDefaults objectForKey:@"alarm_3"]){
        self.mAlarm3Celllbl.text = [NSString stringWithFormat:@"%@" , [outputFormatter stringFromDate:[mUserDefaults objectForKey:@"alarm_3"]]];
        [self.switch_3 setOn:YES animated:NO];
        bIsAlarm1Off = false;
    }
    
    [mUserDefaults synchronize];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.row) {
        case 0:
            if ( bIsAlarm1Off ) return;
            break;
            
        case 2:
            if ( bIsAlarm2Off ) return;
            break;
            
        case 4:
            if ( bIsAlarm3Off ) return;
            break;
            
            
        default:
            break;
    }
    
    if ( indexPath.row % 2 == 0)
    {
        //TODO switch to set alarm view
        [self performSegueWithIdentifier:@"alarmSetSegue" sender:self];\
        
        selectedSwitch = nil;
        
        UITableViewCell *cellSelected = [tableView cellForRowAtIndexPath:indexPath];
        selectedCellAlarm = cellSelected.textLabel;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   [(SetAlarmViewController*)[segue destinationViewController] setThisDelegate:self];
}

/******************** RETURN DATA *******************/
#pragma mark RETURN DATA FROM TIME SELECTION
/******************** RETURN DATA *******************/

-(void)returnTimeData:(NSDate*)pTime
{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"h:mm a"];
    
    selectedCellAlarm.text = [NSString stringWithFormat:@"%@" , [outputFormatter stringFromDate:pTime]];
    
    [dataManager.UserDefaults setObject:pTime forKey:[NSString stringWithFormat:@"alarm_%i", selectedCellAlarm.tag]];
    
    //Set UISWITCH Toggle to ON when alarm is set
    switch (selectedCellAlarm.tag) {
        case 1:
            [self.switch_1 setOn:YES animated:YES];
            break;
        case 2:
            [self.switch_2 setOn:YES animated:YES];
            break;
        case 3:
            [self.switch_3 setOn:YES animated:YES];
            break;
            
        default:
            break;
    }
}

- (void) cancelSetAlarm
{
    if (selectedSwitch) {
         [selectedSwitch setOn:NO animated:YES];
    }
    selectedSwitch = nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (IBAction)enableDisableAlarm:(UISwitch*)sender {
    
    if ([sender isKindOfClass:[UISwitch class]] ) {
        
        selectedSwitch  = sender;
        
        switch ( [sender tag] ) {
            case 100:
                bIsAlarm1Off = !sender.isOn;
                if (!sender.isOn)   {
                    
                    [mUserDefaults removeObjectForKey:@"alarm_1"];
                    self.mAlarm1CellLbl.text = [NSString stringWithFormat:@"--:--"];
                }else{
                    [self performSegueWithIdentifier:@"alarmSetSegue" sender:self];
                    
                    selectedCellAlarm = self.mAlarm1CellLbl;
                }
                
                break;
                
            case 101:
                bIsAlarm2Off = !sender.isOn;
                if (!sender.isOn)   {
                    [mUserDefaults removeObjectForKey:@"alarm_2"];
                    self.mAlarm2CellLbl.text = [NSString stringWithFormat:@"--:--"];
                }else{
                    [self performSegueWithIdentifier:@"alarmSetSegue" sender:self];
                    
                    selectedCellAlarm = self.mAlarm2CellLbl;
                }
                
                break;
                
            case 102:
                bIsAlarm3Off = !sender.isOn;
                if (!sender.isOn)   {
                    [mUserDefaults removeObjectForKey:@"alarm_3"];
                    self.mAlarm3Celllbl.text = [NSString stringWithFormat:@"--:--"];
                }else{
                    [self performSegueWithIdentifier:@"alarmSetSegue" sender:self];
                    
                    selectedCellAlarm = self.mAlarm3Celllbl;
                }
                
                break;
                
            default:
                break;
        }
    }
}

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
