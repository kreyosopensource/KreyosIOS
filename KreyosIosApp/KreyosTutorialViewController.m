//
//  KreyosTutorialViewController.m
//  KreyosIosApp
//
//  Created by Kreyos on 4/2/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import "KreyosTutorialViewController.h"
#import "KreyosBluetoothViewController.h"
#import "LkDiscovery.h"
#import "KreyosDataManager.h"
#import "KreyosUtility.h"
#import "KreyosHomeViewController.h"
#import "BluetoothDelegate.h"

@interface KreyosTutorialViewController () <UITableViewDataSource, UITableViewDelegate>
{
    NSTimer *refishTimer;
    
    NSMutableArray *mPageList;
    
    short mCurrentPage;
    NSString *mSavedUrl;
    
    NSTimer *readVersionTimer;
    BOOL    m_bIsFromSetupWatch;
}

enum TUTORIAL_PAGE
{
    TURN_ON_PAGE = 1,
    PAIR_WATCH_PAGE,
    PAIR_WATCHLE_Page,
};

@property (retain, nonatomic) NSMutableArray            *connectedServices;
@property (retain, nonatomic) CBPeripheral              *connectedperipheral;
@property (retain, nonatomic) UILabel                   *currentlyConnectedSensor;
@property (retain, nonatomic) LKreyosService            *currentlyDisplayingService;

@end

@implementation KreyosTutorialViewController

@synthesize currentlyDisplayingService;
@synthesize connectedServices;
@synthesize connectedperipheral;
@synthesize currentlyConnectedSensor;

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
    
    m_bIsFromSetupWatch = [KreyosDataManager sharedInstance].IsFromSetupWatch;
    
    //Initialize DataManager
    [KreyosDataManager sharedInstance].IsFromTutorial = YES;
    
    mPageList = [[NSMutableArray alloc] init];
    [mPageList addObject:self.mPFirstTutorialPage];
    [mPageList addObject:self.mPFirstIITutorialPage];
    [mPageList addObject:self.mPSecondTutorialPage];
    [mPageList addObject:self.mPThirdTutorialPage];
    [mPageList addObject:self.mPFourthTutorialPage];
    [mPageList addObject:self.mPFifthTutorialPage];
    [mPageList addObject:self.mPSixthTutorialPage];

    
    [self setUpPages];
    [self setUpRefishTimer];
    [self setUpComponents];
    [self setUpBluetoothConnection];
    
    // set the current view on BluetoothDelegate
    [[BluetoothDelegate instance] setCurrentView:self];
}

- (void) setUpBluetoothConnection
{
    self.externalAccessoryMgr = [EAManager sharedInstance];
    
    //self.blueMgr = [BluetoothManager sharedInstance];
    
    [self.externalAccessoryMgr checkDevicesNow:self];
}


-(void) setUpComponents
{
    self.mTBluetoothTableHolder.layer.cornerRadius = 5;
    if([KreyosDataManager sharedInstance].HasConnectedDevice)
    {
        [self hideTable:nil];
    }
}

- (void)setUpPages
{
    mCurrentPage = TURN_ON_PAGE;
    
    CGRect pageFrame = self.view.frame;
    
    for (short pIndex = 0; pIndex < [mPageList count]; pIndex++)
    {
        pageFrame.origin.x = self.view.frame.size.width * pIndex;
        
        [(UIView*)mPageList[pIndex] setFrame:pageFrame];
    }
}


#pragma mark BUTTON CALLBACKS
- (IBAction)continueTutorial:(id)sender
{
    CGRect pageFrame = self.view.frame;
    for (int pIndex = 0; pIndex < [mPageList count]; pIndex++)
    {
        pageFrame.origin.x = self.view.frame.size.width * (pIndex - (int)mCurrentPage) ;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        [(UIView*)mPageList[pIndex] setFrame:pageFrame];
        
        [UIView commitAnimations];
    }
    
    switch ((int)mCurrentPage)
    {
        case 2:
            if (m_bIsFromSetupWatch && [KreyosDataManager sharedInstance].HasConnectedDevice)
            {
                mCurrentPage += 1;
                [self continueTutorial:self];
                return;
            }
            
        break;
        case 4:
            
            readVersionTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(readVersion:) userInfo:nil repeats:YES];
            [readVersionTimer fire];
            
            [[NSNotificationCenter defaultCenter]
             addObserver:self
             selector:@selector(checkIfLatestVersion:)
             name:@"firmwareVersion"
             object:nil];
            
        break;
        case 5:
        {
            dispatch_async(dispatch_get_main_queue(),^
            {
                [[BluetoothDelegate instance]initializeUpdateFirmWare];
                [BluetoothDelegate instance].firmwareURL    = mSavedUrl;
            });
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(continueTutorial:)
                                                         name:@"firmwareUpdate"
                                                       object:nil];
        }
        break;
        case 6:
        {
            [self continueToMainPage:self];
        }
        break;
    }
    
    mCurrentPage ++;
}


#pragma mark READ VERSION
- (void) readVersion:(id) sender
{
    [[BluetoothDelegate instance].currentlyDisplayingService readVersion];

}

#pragma mark NOTIFICATION CALLBACKS
- (void) continueToMainPage:(id)sender
{
    double delayInSeconds = 2.0;
    dispatch_time_t popTime;

    [readVersionTimer invalidate];
    
    popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self performSegueWithIdentifier:@"goToMain" sender:self];
        
    });
}

#pragma mark CHECK FOR LATET FIRMWARE
- (void) checkIfLatestVersion:(id)sender
{
    
    if ( mCurrentPage != 5) return;
    
    KLog(@"Current Version : %@" , [KreyosDataManager sharedInstance].FirmwareVersion);
    [KreyosDataManager RequestforFirmwareUpdate:self selector:@selector(firmwareRequest:)];
    
}


- (void) firmwareRequest:(NSData*)pData
{
    NSString *dataParsed = [[NSString alloc] initWithData:pData encoding:NSUTF8StringEncoding];
    NSLog(@"REQUEST FIRMWARE DATA RECEIVED %@", dataParsed);
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:pData
                          
                          options:kNilOptions
                          error:&error];
    NSString *version = [json objectForKey:@"version_number"];
    NSString *pathToDownload = [json objectForKey:@"attachment"];
    
    if ( [version isEqualToString: [KreyosDataManager sharedInstance].FirmwareVersion])
    {
        [self.updateProgressIndicator setHidden:YES];
        [self.checkingForUpdateLabel setText:@"Your Software is up to date."];
        
        double delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [self performSegueWithIdentifier:@"goToMain" sender:self];
            
        });
        
        [[NSNotificationCenter defaultCenter]
         removeObserver:self name:@"firmwareVersion" object:nil];
        
    }
    else
    {
        mSavedUrl = [NSString stringWithFormat:@"https:%@", pathToDownload];
        
        [self continueTutorial:self];
    }
    
    [[BluetoothDelegate instance].currentlyDisplayingService writeTest:(int8_t)1];
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    KLog(@"REGISTERED AS FIRST TIME USE");
    [USERDATA setBool:true forKey:@"isUserLogB4"];
}


#pragma mark REFISH BLE DEVICES TIMER
- (void) setUpRefishTimer
{
    refishTimer = [[NSTimer alloc] init];
    refishTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(tableDataReload:) userInfo:connectedperipheral repeats:YES];
    
}

- (void) tableDataReload : (id) sender
{
    [self.mTBluetoothTable reloadData];
}

#pragma mark UITABLEVIEW DELEGATES
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell	*cell;
	CBPeripheral	*peripheral;
	NSArray			*devices;
	NSInteger		row	= [indexPath row];
    NSString        *peripheralSerial;
    static NSString *cellID = @"DeviceList";
    
	cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if (!cell){
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor clearColor];
    }
	if ([indexPath section] == 0) {
		devices = [[LkDiscovery sharedInstance] connectedServices];
        peripheral = [(LKreyosService*)[devices objectAtIndex:row] peripheral];
        
	} else {
		devices = [[LkDiscovery sharedInstance] foundPeripherals];
        peripheral = (CBPeripheral*)[devices objectAtIndex:row];
	}
    if ([[[LkDiscovery sharedInstance] peripheralSerial] count]  > 0) {
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
        currentlyDisplayingService = nil;
        currentlyDisplayingService  = [[BluetoothDelegate instance] serviceForPeripheral:peripheral];
        connectedperipheral         = peripheral;
        
        //UPDATE TIME
        [[BluetoothDelegate instance] updateTime];
        
        [currentlyConnectedSensor setText:[NSString stringWithFormat: @"{%@}",[peripheral name]]];
        
        // +AS:07172014 Please remove this.
        //[KreyosDataManager sharedInstance].DisplayingService = currentlyDisplayingService;
    }
}

- (void) hideTable:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mTBluetoothTableHolder setHidden:YES];
        [self.mPairingNextButton setHidden:NO];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
#pragma mark --- Didconnect Tutorial callback
-(void)didConnectFromBluethooth
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mTBluetoothTableHolder setHidden:YES];
        [self.mPairingNextButton setHidden:NO];
    });
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
