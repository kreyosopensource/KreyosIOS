//
//  KreyosTutorialTableViewController.m
//  KreyosIosApp
//
//  Created by Kreyos on 8/26/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosTutorialTableViewController.h"
#import "BluetoothDelegate.h"
#import "KreyosUtility.h"

//#define DEBUG_CONTINUE

#define RELOAD_TABLE_INTERVAL 3.0F

@interface KreyosTutorialTableViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSTimer* m_refreshTimer;
}

@property (retain, nonatomic) UILabel*                  currentlyConnectedSensor;
@property (retain, nonatomic) LKreyosService*           currentlyDisplayingService;
@property (retain, nonatomic) CBPeripheral*             connectedperipheral;

@end


@implementation KreyosTutorialTableViewController

@synthesize currentlyDisplayingService;
@synthesize connectedperipheral;
@synthesize currentlyConnectedSensor;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //Initialize DataManager
    [KreyosDataManager sharedInstance].IsFromTutorial = YES;

    [self SetUpTable];
    [self setUpBluetoothConnection];
    [self SetUpReloadTimer];
    [[BluetoothDelegate instance] setCurrentView:self];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [m_refreshTimer invalidate];
    m_refreshTimer = nil;
}

-(void) setUpBluetoothConnection
{
    self.externalAccessoryMgr = [EAManager sharedInstance];
    [self.externalAccessoryMgr checkDevicesNow:self];
}

-(void)SetUpTable
{
    self.mTBluetoothTable.delegate = self;
    self.mTBluetoothTable.dataSource = self;
    
    if([KreyosDataManager sharedInstance].HasConnectedDevice)
    {
        [self hideTable: YES];
    }
    else
    {
#ifdef DEBUG_CONTINUE
        [self hideTable: YES];
#else
        [self hideTable: NO];
#endif
    }
}

-(void)hideTable:(BOOL)p_bool
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self.bluetoothTableHolder setHidden:p_bool];
        
        if (p_bool)
            [self.mNextButton setHidden:NO];
        else
            [self.mNextButton setHidden:YES];
    });
}

//============================================================
#pragma mark UITABLEVIEW DELEGATES
//============================================================
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell	*cell;
	CBPeripheral	*peripheral;
	NSArray			*devices;
	NSInteger		row	= [indexPath row];
    NSString        *peripheralSerial;
    static NSString *cellID = @"DeviceList";
    
	cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if (!cell)
    {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor clearColor];
    }
    
	if ([indexPath section] == 0)
    {
		devices = [[LkDiscovery sharedInstance] connectedServices];
        peripheral = [(LKreyosService*)[devices objectAtIndex:row] peripheral];
        
	}
    else
    {
		devices = [[LkDiscovery sharedInstance] foundPeripherals];
        peripheral = (CBPeripheral*)[devices objectAtIndex:row];
	}
    
    if ([[[LkDiscovery sharedInstance] peripheralSerial] count]  > 0)
    {
        peripheralSerial = [[[LkDiscovery sharedInstance] peripheralSerial] objectAtIndex:row];
    }
    
    if ([peripheralSerial length])
        [[cell textLabel] setText:peripheralSerial];
    else
        [[cell textLabel] setText:@"Peripheral"];
    
	return cell;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;//[[self.blueMgr btListDevices] count];
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
    
	if ( ![peripheral isConnected] ) //~~~Not Connected
    {

        [[LkDiscovery sharedInstance] connectPeripheral:peripheral];
        [currentlyConnectedSensor setText:[NSString stringWithFormat: @"{%@}",[peripheral name]]];
        
        //Add Notification for connected device
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(hideTable:)
         name:@"connectedToKreyos"
         object:nil];
        
        NSString *uuidString = [NSString stringWithFormat:@"%@", [[peripheral identifier] UUIDString]];
        [[NSUserDefaults standardUserDefaults] setObject:uuidString forKey:USERDEF_LASTDEVICE];
    }
	else
    {
        currentlyDisplayingService  = nil;
        currentlyDisplayingService  = [[BluetoothDelegate instance] serviceForPeripheral:peripheral];
        connectedperipheral         = peripheral;
        
        //UPDATE TIME
        [[BluetoothDelegate instance] updateTime];
        
        [currentlyConnectedSensor setText:[NSString stringWithFormat: @"{%@}",[peripheral name]]];

    }
}

//============================================================
#pragma mark TIMER
//============================================================
- (void) SetUpReloadTimer
{
    if (!m_refreshTimer)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
           m_refreshTimer = [NSTimer scheduledTimerWithTimeInterval:RELOAD_TABLE_INTERVAL
                                                             target:self
                                                           selector:@selector(tableDataReload:)
                                                           userInfo:connectedperipheral
                                                            repeats:YES];
       });
    }
}

- (void) tableDataReload : (id) sender
{
    [self.mTBluetoothTable reloadData];
}


@end
