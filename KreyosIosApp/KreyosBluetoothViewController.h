//
//  KreyosBluetoothViewController.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/7/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosUIViewBaseViewController.h"
#import "LKreyosService.h"
#import "AMSlideMenuMainViewController.h"
#import "KreyosDataManager.h"

@interface KreyosBluetoothViewController : KreyosUIViewBaseViewController
{
    BOOL *bIsReadingActivityFile;
    
    AMSlideMenuMainViewController *slideMenuMainView;
    KreyosDataManager *mKreyosDataMangr;
    
    NSTimer *fetchTimer;
    int m_fetchTimerInterval;
    NSTimer *reconnectionTimer;
    
    // +AS:07152014 Please remove this
    /*
    NSMutableArray *passedData;
    NSMutableArray *modeData;
    NSMutableArray *headerData;
    //*/
}

// +AS:07152014 Please remove this
@property (weak, nonatomic) IBOutlet UIButton           *searchDevicesBtn;
@property (weak, nonatomic) IBOutlet UITableView        *sensorsTable;
/*
@property (retain, nonatomic) LKreyosService            *currentlyDisplayingService;
@property (readwrite, nonatomic)  NSString              *CurrentFirmwareVersion;
@property (nonatomic, readwrite) NSString               *firmwareURL;
//*/

//Methods
// +AS:07152014 Please remove this
//+ (KreyosBluetoothViewController *)sharedInstance;

// +AS:07152014 Please remove this
- (void) initialize;
/*
- (IBAction)scan:(id)sender;
- (BOOL)isDeviceConnectedToBT;
- (void) doWrite:(NSData*)dataValue forCharacteristics:(NSString*)characteristic;
- (LKreyosService*) serviceForPeripheral:(CBPeripheral *)peripheral;
- (NSData*) doRead:(NSString*)p_bleKey;
- (void) readActivityData;
- (void) updateWatchFirmware;
- (void) updateWatchFirmware:(NSString*)p_url;
- (void) initializeFileTransistor;
- (void) startTestSportsData;
- (void) updateTime;
//*/
@end
