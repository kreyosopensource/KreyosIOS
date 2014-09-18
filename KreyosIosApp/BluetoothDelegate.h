//
//  BluetoothDelegate.h
//  KreyosIosApp
//
//  Created by Kreyos on 7/14/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#ifndef __KreyosIosApp__BluetoothDelegate__
#define __KreyosIosApp__BluetoothDelegate__

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LkDiscovery.h"
#import "SportsPageViewController.h"
#import "KreyosBluetoothViewController.h"
#import "DBManager.h"


// Listener Keys ( Methods Names )
#define DISCOVERY_DID_REFRESH           @"discoveryDidRefresh"
#define DISCOVERY_DID_POWERED_OFF       @"discoveryStatePoweredOff"
#define SERVICE_DID_CHANGED             @"kreyosServiceDidChangeStatus"
#define SERVICE_DID_RESET               @"kreyosServiceDidReset"
#define CHARACTERISTIC_VALUE_CHANGED    @"valueChangedfromCharacteristic"
#define OPEN_VC_FOR_SPORTS              @"openContentViewControllerForSports"
#define UPDATE_FIRMWARE                 @"updateWatchFirmware"
#define UPDATE_CONNECTED_PERIPHERAL     @"conenctPeripheral"    // parameter: { "peripheral":[p_peripheral name] }
#define REFRESH_DEVICE_DISCOVERIES      @"discoveryDidRefresh"
#define BLUETOOTH_POWER_WARNING         @"discoveryStatePoweredOff"


// Constants
#define kVersion @"20140414"
#define DELEGATE_CLASS NSObject<KreyosDiscoveryDelegate, KreyosProtocol>

// UPDATE_CONNECTED_PERIPHERAL Key
#define PERIPHERAL_KEY                  @"peripheral"

#pragma mark -
#pragma mark Bluetooth Delegate
@interface BluetoothDelegate : NSObject<KreyosDiscoveryDelegate,KreyosProtocol>
{
    // Fetch Timer.
    //  Interval would be1sec at initial run of the app, 20sec after 30sec on initial run
    NSTimer* m_fetchTimer;
    int m_timerInterval;
    
    // Reconnect Timer
    NSTimer* reconnectionTimer;
    
    // Listeners. ( Array of DELEGATE_CLASS* )
    NSMutableArray* m_listeners;
    
    // Member properties
    NSMutableArray* passedData;
    NSMutableArray* modeData;
    NSMutableArray* headerData;
    
    // Ref of current view. Note: Always update the current view of BluetoothDelegate
    UIViewController* m_currentView;
    
    // Notification dispatcher
    NSNotificationCenter* m_distapcher;
    
    // Data Manager
    KreyosDataManager* m_dataManager;
}

#pragma mark -
#pragma mark Singleton
+ (BluetoothDelegate*) instance;

//*
#pragma mark -
#pragma mark Global Properties
//@property (weak, nonatomic) IBOutlet UIButton*        searchDevicesBtn;
//@property (weak, nonatomic) IBOutlet UITableView*     sensorsTable;
@property (retain, nonatomic) LKreyosService*           currentlyDisplayingService;
@property (readwrite, nonatomic)  NSString*             CurrentFirmwareVersion;
@property (nonatomic, readwrite) NSString*              firmwareURL;
// TODO: Make this private
@property (retain, nonatomic) NSMutableArray*           connectedServices;
@property (retain, nonatomic) CBPeripheral*             connectedperipheral;
//@property (retain, nonatomic) UILabel*                currentlyConnectedSensor;
//*/

@property (nonatomic, readwrite) BOOL                   isUpdating;

#pragma mark -
#pragma mark Initialization
- (void) initialize;
- (void) initService;
- (void) initTimer;
- (void) stopTimer;

#pragma mark -
#pragma mark Getter | Setter
- (void) setListener:(DELEGATE_CLASS*)p_listener;
- (void) clearListener;
- (void) setCurrentView:(UIViewController*)p_currentView;
- (void) setSportViewController:(SportsPageViewController*)p_controller;
- (void) setBluetoothViewController:(KreyosBluetoothViewController*)p_controller;
- (UIViewController*) getCurrentController;

#pragma mark -
#pragma mark Functionalities
- (void) stopScan;
- (void) startScan;
- (void) initializeFileTransistor;
- (void) disconnect;
- (void) conenctPeripheral:(CBPeripheral*)p_peripheral;
//- (void) writeFileDesc:(int8_t)flag blockId:(int8_t)block blockSize:(int16_t)size fileName:(NSString*)name;
- (void) readActivityData;
- (void) readHomeData;
//- (void) readFileBlock;
- (void) updateWatchFirmware;
- (void) parseActivityData:(NSData*)value;
//- (void) sendFileBLock;
- (void) tryReconnectWithThePrevious;
- (void) tryToConnect;

-(BOOL) getDidLogout;
-(void) setDidLogOut:(BOOL)p_bool;


#pragma mark -
#pragma mark Read / Write
- (void) doWrite:(NSData*)dataValue forCharacteristics:(NSString*)characteristic;
- (void) updateTime;
//- (NSData*) doRead:(NSString*)p_bleKey;


#pragma mark -
#pragma mark Lkreyos Interactions
- (LKreyosService*) serviceForPeripheral:(CBPeripheral*)peripheral;


#pragma mark -
#pragma mark Callbacks
- (void) fetchDataFromWatch:(NSTimer *)p_timer;
- (void) didEnterForegroundNotification:(NSNotification*)notificationuu;
- (void) didEnterBackgroundNotification:(NSNotification*)notification;

#pragma mark -
#pragma mark KreyosDiscoveryDelegate Methods
- (void) discoveryDidRefresh;
- (void) discoveryStatePoweredOff;

#pragma mark -
#pragma mark KreyosProtocol Methods
- (void) kreyosServiceDidChangeStatus:(LKreyosService*)service;
- (void) kreyosServiceDidReset;
- (void) valueChanged:(NSData*)value
   fromCharacteristic:(NSString*)characteristic;

#pragma mark -
#pragma mark Utils
-(BOOL) isDataValidForSaving:(int)pCat
                  withActObj:(ActivityObject)p_object;


-(void)initializeUpdateFirmWare;
@end

#endif /* defined(__KreyosIosApp__BluetoothDelegate__) */
