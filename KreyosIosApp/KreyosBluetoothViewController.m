//
//  KreyosBluetoothViewController.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/7/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosBluetoothViewController.h"
#import "KreyosHomeViewController.h"
#import "LkDiscovery.h"
#import "LKreyosService.h"
#import "KreyosUtility.h"
#import "KreyosDataManager.h"
#import "SportsPageViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "KreyosUtility.h"
#import "UIViewController+AMSlideMenu.h"
#import "AMSlideMenuMainViewController.h"
#import "DBManager.h"
#import "DatabaseStruct.h"
#import "ActivityStatsPageViewController.h"
#import "AMSlideMenuMainViewController.h"
#import "Scheduler.h"
#import "GenericOverlay.h"
#import "BluetoothDelegate.h"

@interface KreyosBluetoothViewController ()<KreyosDiscoveryDelegate, KreyosProtocol, UITableViewDataSource, UITableViewDelegate>

@property (retain, nonatomic) UILabel                   *currentlyConnectedSensor;
@end

@implementation KreyosBluetoothViewController
{
    UIBackgroundTaskIdentifier  backgroundTaskID;
    CBPeripheral*               m_activatedPeripheral;
}

@synthesize currentlyConnectedSensor;
@synthesize sensorsTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if ( self )
    {
    
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ( (self = [super initWithCoder:aDecoder]) )
    {

    }
    
    return self;
}

#pragma mark - LOAD - UNLOAD - INITIALIZE - DEALLOC
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    m_activatedPeripheral = nil;
    
    [[BluetoothDelegate instance] setIsUpdating:NO];
    
    // +AS:07152015 Setup Listeners
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openContentViewControllerForSports)
                                                 name:OPEN_VC_FOR_SPORTS
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateWatchFirmware)
                                                 name:UPDATE_FIRMWARE
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateConnectedPeripheral:)
                                                 name:UPDATE_CONNECTED_PERIPHERAL
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(discoveryDidRefresh)
                                                 name:REFRESH_DEVICE_DISCOVERIES
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(discoveryStatePoweredOff)
                                                 name:BLUETOOTH_POWER_WARNING
                                               object:nil];
    
    [self initialize];
    
    // set the current view on BluetoothDelegate
    [[BluetoothDelegate instance] setCurrentView:self];
}

- (void) viewDidUnload
{
    [self setCurrentlyConnectedSensor:nil];
    [super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) initialize
{
    mKreyosDataMangr    = [KreyosDataManager sharedInstance];
    slideMenuMainView   = [AMSlideMenuMainViewController getInstanceForVC:self];
    
    if ( slideMenuMainView.rightMenu )
    {
        [self addRightMenuButton];
        [self addLeftMenuButton];
    }
    
    UIColor *fontClr = [UIColor grayColor];
    
    //Currently connected label
    currentlyConnectedSensor = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 300, 35)];
    currentlyConnectedSensor.font = REGULAR_FONT_WITH_SIZE(35);
    currentlyConnectedSensor.textColor = fontClr;
    currentlyConnectedSensor.text = @"";
    currentlyConnectedSensor.textAlignment = UITextAlignmentCenter;
    
    //Add found devices list table
    sensorsTable.backgroundColor = [UIColor clearColor];
    sensorsTable.layer.opacity = 0.5f;
    sensorsTable.dataSource = self;
    sensorsTable.delegate = self;
}


- (void) dealloc
{
#ifdef STOP_BLUETOOTH
    //[[LkDiscovery sharedInstance] stopScanning];
    [[BluetoothDelegate instance] stopScan];
#endif
    
    //SET ALL UITABLEVIEW DELEGATES AND DATASOURCE TO NIL TO AVOID NASTY MESSAGES
    sensorsTable.delegate = nil;
    sensorsTable.dataSource = nil;
}

#pragma mark - BUTTON CALLBACKS
-(IBAction)Toggle:(id)sender
{
    
}

-(IBAction)disconnectToDevice:(id)sender
{
    [[BluetoothDelegate instance] disconnect];
}

-(void)SetThisButton:(UIButton*)p_btn setTruFalse:(BOOL)p_b
{
    p_btn.enabled = p_b;
    p_btn.alpha = p_b == true ? 1.0f : 0.5f;
}

// +AS:07152014 Callbacks
- (void) openContentViewControllerForSports
{
    [slideMenuMainView openContentViewControllerForSports:self];
}

- (void) updateWatchFirmware
{
    backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void){
        
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskID];
        backgroundTaskID = UIBackgroundTaskInvalid;
        
    }];
}

- (void) updateConnectedPeripheral:(NSNotification*)p_userInfo
{
    NSString* peripheralName = p_userInfo.userInfo[PERIPHERAL_KEY];
    [currentlyConnectedSensor setText:peripheralName];
    [currentlyConnectedSensor setEnabled:NO];
}

- (void) startTestSportsData
{
    //sportsWatchStatus = WS_IDLE;
    [[BluetoothDelegate instance].currentlyDisplayingService writeSportsGrids:1 value1:4 value2:17 value3:0xff];
    [[BluetoothDelegate instance].currentlyDisplayingService readSportsDesc];
}

/** Central Manager reset */
- (void) kreyosServiceDidReset
{
    [[BluetoothDelegate instance].connectedServices removeAllObjects];
}

#pragma mark -
#pragma mark TableView Delegates
/****************************************************************************/
/*							TableView Delegates								*/
/****************************************************************************/
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell	*cell;
	CBPeripheral	*peripheral;
	NSArray			*devices;
	NSInteger		row	= [indexPath row];
    static NSString *cellID = @"DeviceList";
    
	cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
	if (!cell)
    {
		cell                    = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        cell.backgroundColor    = [UIColor clearColor];
    }
	if ([indexPath section] == 0) {
		devices     = [[LkDiscovery sharedInstance] connectedServices];
        peripheral  = [(LKreyosService*)[devices objectAtIndex:row] peripheral];
        
	}
    else
    {
		devices     = [[LkDiscovery sharedInstance] foundPeripherals];
        peripheral  = (CBPeripheral*)[devices objectAtIndex:row];
	}
    
    if ([[peripheral name] length])
        [[cell textLabel] setText:[peripheral name]];
    else
        [[cell textLabel] setText:@"Peripheral"];
    
    [[cell detailTextLabel] setText: [peripheral isConnected] ? @"Connected" : @"Not connected"];
    
	return cell;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger	res = 0;
    
	if (section == 0)
		res = [[[LkDiscovery sharedInstance] connectedServices] count];
	else
		res = [[[LkDiscovery sharedInstance] foundPeripherals] count];
    
	return res;
}

- (void)          tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[LkDiscovery sharedInstance] isDeviceConnecting])
    {
        NSLog(@"CONNECTING BLOCK CHOOSING OF DEVICE ");
        
        UIAlertView* alert  = [GenericOverlay createOverlayWarningDeviceIsConnecting:self selectors1:@selector(CallbackConectingDisconnect) selector1:nil];
        [alert show];
        return;
    }
        
    BOOL bisConected        = [KreyosDataManager sharedInstance].HasConnectedDevice;
    m_activatedPeripheral   = nil;

	CBPeripheral* peripheral    = nil;
	NSArray* devices            = nil;
	NSInteger row               = [indexPath row];
	
	if ([indexPath section] == 0)
    {
		devices         = [[LkDiscovery sharedInstance] connectedServices];
        peripheral      = [(LKreyosService*)[devices objectAtIndex:row] peripheral];
	}
    else
    {
		devices         = [[LkDiscovery sharedInstance] foundPeripherals];
    	peripheral      = (CBPeripheral*)[devices objectAtIndex:row];
	}
    
	if (![peripheral isConnected]) //~~~Not Connected
    {
        //~~~Check if it has a current device connected in the phone
        //   if true show warning message
        //   else connect
        if (bisConected)
        {
            m_activatedPeripheral       = peripheral;
            NSArray* connectedDevices   = [[LkDiscovery sharedInstance] connectedServices];
            CBPeripheral* conectedfrom  = [(LKreyosService*)[connectedDevices objectAtIndex:0] peripheral];
            
            UIAlertView* Generic  = [GenericOverlay createOverlayWarningDeviceIsConnected:self
                                                                               selectors1:@selector(CallbackYes)
                                                                                selector1:@selector(CallbackNo)
                                                                               deviceFrom:(const char*)[[conectedfrom name]UTF8String]
                                                                                 deviceTo:(const char*)[[peripheral name]UTF8String]];
            [Generic show];
        }
        else
        {
            [self ConnectToPeripheral:peripheral];
        }
    }
	else
    {
        [BluetoothDelegate instance].currentlyDisplayingService  = nil;
        [BluetoothDelegate instance].currentlyDisplayingService  = [[BluetoothDelegate instance] serviceForPeripheral:peripheral];
        [BluetoothDelegate instance].connectedperipheral         = peripheral;
        [currentlyConnectedSensor setText:[NSString stringWithFormat: @"{%@}",[peripheral name]]];
    }
}

-(void)CallbackConectingDisconnect
{
    if (reconnectionTimer)
    {
        [reconnectionTimer invalidate];
        reconnectionTimer = nil;
    }
    
    [[LkDiscovery sharedInstance]cleanAllDevicesConnected];
}

-(void)CallbackYes
{
    if (reconnectionTimer)
    {
        [reconnectionTimer invalidate];
        reconnectionTimer = nil;
    }
    
    [[LkDiscovery sharedInstance]disconectCurrentPeriperal];
    
    //~~~TODO: TOBE CLEANED AND OPTIMIZED
    //~~~Save the latest connected device will connect after disconnectingn
    //   Recon in reconnection timer
    NSString *uuidString = [NSString stringWithFormat:@"%@", [[m_activatedPeripheral identifier] UUIDString]];
    [[NSUserDefaults standardUserDefaults] setObject:uuidString forKey:USERDEF_LASTDEVICE];
    
    [currentlyConnectedSensor setText:[NSString stringWithFormat: @"{%@}",[m_activatedPeripheral name]]];
}

-(void)CallbackNo
{
    m_activatedPeripheral = nil;
}

-(void)ConnectToPeripheral:(CBPeripheral*)p_peripheral
{
    //~~~Save the latest connected device
    NSString *uuidString = [NSString stringWithFormat:@"%@", [[p_peripheral identifier] UUIDString]];
    [[NSUserDefaults standardUserDefaults] setObject:uuidString forKey:USERDEF_LASTDEVICE];
    
    //~~~update peripherals
    [BluetoothDelegate instance].connectedperipheral        = nil;
    [KreyosDataManager sharedInstance].DisplayingService    = nil;
    [[BluetoothDelegate instance] conenctPeripheral:p_peripheral];
    
    //~~~update connected sensor
    [currentlyConnectedSensor setText:[NSString stringWithFormat: @"{%@}",[p_peripheral name]]];
}

#pragma mark -
#pragma mark KreyosDiscoveryDelegate
// +AS:07152014 Please remove this
/****************************************************************************/
/*                       KreyosDiscoveryDelegate Methods                    */
/****************************************************************************/
- (void) discoveryDidRefresh
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [sensorsTable reloadData];
    });
}

- (void) discoveryStatePoweredOff
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:BLUETOOTH_ERROR_POWER_OFF_TITLE
                                                        message:BLUETOOTH_ERROR_POWER_OFF_MESSAGE
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

#pragma mark -
#pragma mark App IO
/****************************************************************************/
/*                              App IO Methods                              */
/****************************************************************************/
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    /*if (![_hour isExclusiveTouch]) {
        [_hour resignFirstResponder];
    }*/
}

- (IBAction)disconnect:(id)sender
{
    [[BluetoothDelegate instance] disconnect];
}

// +AS:07152014 Please remove this
- (IBAction)scan:(id)sender
{
    [[BluetoothDelegate instance] startScan];
}

-(BOOL)isDeviceConnectedToBT
{
    return [BluetoothDelegate instance].connectedperipheral.state == CBPeripheralStateConnected ? TRUE : FALSE;
}

@end
