

#import "LkDiscovery.h"
#import "KreyosDataManager.h"
#import "KreyosBluetoothViewController.h"
#import "KreyosHomeViewController.h"
#import "KreyosUtility.h"
#import "BluetoothDelegate.h"
#import "DBManager.h"

typedef enum
{
    STATE_CONNECTED,
    STATE_CONNECTING,
    STATE_DISCONNECTED,
}BlueToothManagerState;

@interface LkDiscovery () <CBCentralManagerDelegate, CBPeripheralDelegate> {
	CBCentralManager        *centralManager;
	BOOL                    pendingInit;
    BlueToothManagerState   m_managerState;
}
@end


@implementation LkDiscovery
{
    LKreyosService *currentlyDisplayingService;
}

@synthesize foundPeripherals;
@synthesize peripheralSerial;
@synthesize connectedServices;
@synthesize discoveryDelegate;
@synthesize peripheralDelegate;
@synthesize previouslyConnectedPeripherals;

NSString *storedServiceUUID = @"fff0";

#pragma mark -
#pragma mark Init
/****************************************************************************/
/*									Init									*/
/****************************************************************************/
+ (id) sharedInstance
{
	static LkDiscovery	*this	= nil;

	if (!this)
		this = [[LkDiscovery alloc] init];

	return this;
}


- (id) init
{
    self = [super init];
    if (self)
    {
        
		pendingInit         = YES;
        m_managerState      = STATE_DISCONNECTED;
        
        dispatch_queue_t centralQueue = dispatch_queue_create("com.yo.mycentral", DISPATCH_QUEUE_SERIAL);
        
        centralManager      = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue];
		foundPeripherals    = [[NSMutableArray alloc] init];
		connectedServices   = [[NSMutableArray alloc] init];
        peripheralSerial    = [[NSMutableArray alloc] init];
        previouslyConnectedPeripherals = [[NSMutableArray alloc] init];
	}
    return self;
}


- (void) dealloc
{
    // We are a singleton and as such, dealloc shouldn't be called.
    assert(NO);
    [super dealloc];
}



#pragma mark -
#pragma mark Restoring
/****************************************************************************/
/*								Settings									*/
/****************************************************************************/
/* Reload from file. */
- (int) loadSavedDevices
{
	NSArray	*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:@"StoredDevices"];

	if (![storedDevices isKindOfClass:[NSArray class]]) {
        NSLog(@"No stored array to load");
        return 0;
    }
    
    int counter = 0;
    for (id deviceUUIDString in storedDevices) {
        
        if (![deviceUUIDString isKindOfClass:[NSString class]])
            continue;
        
        CFUUIDRef uuid = CFUUIDCreateFromString(NULL, (CFStringRef)deviceUUIDString);
        if (!uuid)
            continue;
        
        counter++;
        [centralManager retrievePeripherals:[NSArray arrayWithObject:(id)uuid]];
        CFRelease(uuid);
    }

    return counter;
}


- (void) addSavedDevice:(CFUUIDRef) uuid
{
	NSArray			*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:@"StoredDevices"];
	NSMutableArray	*newDevices		= nil;
	CFStringRef		uuidString		= NULL;

	if (![storedDevices isKindOfClass:[NSArray class]]) {
        NSLog(@"Can't find/create an array to store the uuid");
        return;
    }

    newDevices = [NSMutableArray arrayWithArray:storedDevices];
    
    uuidString = CFUUIDCreateString(NULL, uuid);
    if (uuidString) {
        [newDevices addObject:(NSString*)uuidString];
        CFRelease(uuidString);
    }
    /* Store */
    [[NSUserDefaults standardUserDefaults] setObject:newDevices forKey:@"StoredDevices"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void) removeSavedDevice:(CFUUIDRef) uuid
{
	NSArray			*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:@"StoredDevices"];
	NSMutableArray	*newDevices		= nil;
	CFStringRef		uuidString		= NULL;

	if ([storedDevices isKindOfClass:[NSArray class]]) {
		newDevices = [NSMutableArray arrayWithArray:storedDevices];

		uuidString = CFUUIDCreateString(NULL, uuid);
		if (uuidString) {
			[newDevices removeObject:(NSString*)uuidString];
            CFRelease(uuidString);
        }
		/* Store */
		[[NSUserDefaults standardUserDefaults] setObject:newDevices forKey:@"StoredDevices"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}


#pragma mark -
#pragma mark Discovery
/****************************************************************************/
/*								Discovery                                   */
/****************************************************************************/
- (void) startScaning
{
    
}

- (void) startScanningForUUIDString:(NSString *)uuidString
{
    storedServiceUUID = uuidString;
    CBUUID* serviceUUID = [[CBUUID UUIDWithString:storedServiceUUID] retain];
    NSArray* serviceUUIDArray = [NSArray arrayWithObject:serviceUUID];
    
    
    NSLog(@"Star Scanning Peripherals with %@",uuidString);
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];

#ifndef EMULATOR_BUILD
    [centralManager scanForPeripheralsWithServices:serviceUUIDArray options:options];
#endif
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    
    switch (peripheral.state)
    {
            
        case CBPeripheralManagerStatePoweredOn:
            
            NSLog(@"Powered On!!!");
            
            break;
            
        default:
            
            NSLog(@"Peripheral Manager did change state");
            
            break;
            
    }
    
}

- (void) stopScanning
{
    NSLog(@"Stop Scanning peripherals");
	[centralManager stopScan];
}

/****************************************************************************/
/*								Events                                      */
/****************************************************************************/
/****************************************************************
 * Function is called at the fullowing..
 *  - Tappinmg the 'SEARCH DEVICES' button
 **/
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"CentralManager:[didDiscoverPeripheral]: %@ , %@", peripheral.name, [peripheral identifier]);
    if (![foundPeripherals containsObject:peripheral]) {
        //
        if ([advertisementData objectForKey:@"kCBAdvDataLocalName"])
        {
            [peripheralSerial addObject:[advertisementData objectForKey:@"kCBAdvDataLocalName"]];
        }
      
        [self addSavedDevice:[peripheral UUID]];
		[foundPeripherals addObject:peripheral];
		[discoveryDelegate discoveryDidRefresh];
	}
}

/****************************************************************
 * Function is called at the fullowing..
 *  - Tap connect device. ( On Tutorial )
 **/
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"CentralManager:[didConnectPeriperal]: %@ , %@", peripheral.name, [peripheral identifier]);
    
    m_managerState              = STATE_CONNECTED;
	LKreyosService	*service	= nil;
	
	/* Create a service instance. */
	service = [[LKreyosService alloc] initWithPeripheral:peripheral controller:peripheralDelegate] ;
	[service start];
    
	if (![connectedServices containsObject:service])
		[connectedServices addObject:service];
    
	if ([foundPeripherals containsObject:peripheral])
		[foundPeripherals removeObject:peripheral];
    
    // Get a reference of the currently connected peripheral
    [KreyosDataManager sharedInstance].DisplayingService = service;
    
    [peripheralDelegate kreyosServiceDidChangeStatus:service];
	[discoveryDelegate discoveryDidRefresh];
}


- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"CentralManager:[didFailToConnectPeripheral]peripheral %@ failed: %@", [peripheral name], [error localizedDescription]);
    m_managerState = STATE_DISCONNECTED;
}

/****************************************************************
 * Function is called at the fullowing..
 *  - Whenever a peripheral is disconnected to the device.
 **/
- (void) centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                  error:(NSError *)error
{
    NSLog(@"CentralManager:[didDisconnectPeripheral]peripheral %@ failed: %@", [peripheral name], [error localizedDescription]);
    m_managerState              = STATE_DISCONNECTED;
	LKreyosService	*service	= nil;
    BOOL isDisconnectedService  = NO;
    
	for (service in connectedServices)
    {
        isDisconnectedService = ( [service peripheral] == peripheral );
        
        if (isDisconnectedService && [KreyosDataManager sharedInstance].DisplayingService == service )
        {
            // nil the previously connected device
            [KreyosDataManager sharedInstance].DisplayingService = nil;
        }
        
		if (isDisconnectedService) {
			[connectedServices removeObject:service];
            [peripheralDelegate kreyosServiceDidChangeStatus:service];
            
            // clear db data here
            //[[DBManager getSharedInstance] clearHomeActivities];

			break;
		}
	}
    
	[discoveryDelegate discoveryDidRefresh];
    [self startScanningForUUIDString:storedServiceUUID];
}

#pragma mark KJ+0619 ---- RETRIEVE PREVIOUSLY CONNECTED DEVICE
- (void)retrievePeripheral:(NSString *)uuidString
{
    
    NSUUID *nsUUID = [[NSUUID UUID] initWithUUIDString:uuidString];
    
    if(nsUUID)
    {
        NSArray *peripheralArray = [centralManager retrievePeripheralsWithIdentifiers:@[nsUUID]];
        
        // Check for known Peripherals
        if([peripheralArray count] > 0)
        {
            //[KreyosDataManager sharedInstance].PreviouslyConnectedDevices = peripheralArray;
            
            for(CBPeripheral *peripheral in peripheralArray)
            {
                [centralManager cancelPeripheralConnection:peripheral];
                [self.previouslyConnectedPeripherals addObject:peripheral];
            }
        }
        // There are no known Peripherals so we check for∂ connected Peripherals if any
        else
        {
            CBUUID *cbUUID = [CBUUID UUIDWithNSUUID:nsUUID];
            
            NSArray *connectedPeripheralArray = [centralManager retrieveConnectedPeripheralsWithServices:@[cbUUID]];
            
            // If there are connected Peripherals
            if([connectedPeripheralArray count] > 0)
            {
                for(CBPeripheral *peripheral in connectedPeripheralArray)
                {
                    NSLog(@"Connecting to Peripheral - %@", peripheral);
                    
                    [self connectPeripheral:peripheral];
                }
            }
            // Else there are no available Peripherals
            else
            {
                // No Dice!
                NSLog(@"There are no available Peripherals");
            }
        }
    }
    
    [[BluetoothDelegate instance] tryToConnect];
}

- (void) centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    NSLog(@"CentralManager:[didRetrieveConnectedPeripherals]");
    CBPeripheral	*peripheral;
    
	/* Add to list. */
//	for (peripheral in peripherals)
//    {
//		[central connectPeripheral:peripheral options:nil];
//	}
    
	[discoveryDelegate discoveryDidRefresh];
}


- (void) centralManager:(CBCentralManager *)central didRetrievePeripheral:(CBPeripheral *)peripheral
{
    
    NSLog(@"CentralManager:[didRetrievePeripheral]: peripheral=%@", [peripheral UUID]);
    [self connectPeripheral:peripheral];
	[discoveryDelegate discoveryDidRefresh];
}

- (void) centralManager:(CBCentralManager *)central didFailToRetrievePeripheralForUUID:(CFUUIDRef)UUID error:(NSError *)error
{
    NSLog(@"CentralManager:[didRetrievePeripheral]: peripheral=%@, error=%@", UUID, [error localizedDescription]);
	[self removeSavedDevice:UUID];
}

- (void) centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    
}

- (void) centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict
{
    
}

#pragma mark -
#pragma mark Connection/Disconnection
/****************************************************************************/
/*						Connection/Disconnection                            */
/****************************************************************************/
- (void) connectPeripheral:(CBPeripheral*)peripheral
{
    if ( m_managerState == STATE_CONNECTING ||  m_managerState == STATE_CONNECTED)return;
    if ([peripheral state] == CBPeripheralStateConnecting || [peripheral state] == CBPeripheralStateDisconnected)
    {
		[centralManager connectPeripheral:peripheral options:nil];
        m_managerState = STATE_CONNECTING;
	}
}

- (void) disconnectPeripheral:(CBPeripheral*)peripheral
{
    if ([peripheral state] == CBPeripheralStateConnecting || [peripheral state] == CBPeripheralStateConnected)
    {
       	[centralManager cancelPeripheralConnection:peripheral];
    }
}

- (void) clearDevices
{
    LKreyosService	*service;
    [foundPeripherals removeAllObjects];
    
    for (service in connectedServices) {
        [service reset];
    }
    [connectedServices removeAllObjects];
}


- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    static CBCentralManagerState previousState = -1;
    
    NSLog(@"CentralManager State:%zi=>%zi", previousState, [centralManager state]);
    
	switch ([centralManager state]) {
		case CBCentralManagerStatePoweredOff:
		{
            [self clearDevices];
            [discoveryDelegate discoveryDidRefresh];
            NSLog(@"S0 CentralManager powered off");
			/* Tell user to power ON BT for functionality, but not on first run - the Framework will alert in that instance. */
            [discoveryDelegate discoveryStatePoweredOff];
            
            m_managerState = STATE_DISCONNECTED;
            break;
		}
            
		case CBCentralManagerStateUnauthorized:
		{
            NSLog(@"S1 This APP with CentralManager is not allowed");
			/* Tell user the app is not allowed. */
            
            m_managerState = STATE_DISCONNECTED;
			break;
		}
            
		case CBCentralManagerStateUnknown:
		{
            NSLog(@"S2 State unknow and wait for anthoer event");
			/* Bad news, let's wait for another event. */
			break;
		}
            
		case CBCentralManagerStatePoweredOn:
		{
            NSLog(@"S3 Central Manager is powered on");
            
            // +AS:07172014 Test comment
            /*
            //Test reconnection
            if ([[NSUserDefaults standardUserDefaults] objectForKey:USERDEF_LASTDEVICE]) {
                
                NSString	*peripheralID;
                peripheralID = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEF_LASTDEVICE];
                [self retrievePeripheral:peripheralID];
            }
            //*/

            [self startScanningForUUIDString:kKreyosServiceUUIDString];
            
			break;
		}
            
		case CBCentralManagerStateResetting:
		{
            NSLog(@"S4 CentralManager reset state");
			[self clearDevices];
            [discoveryDelegate discoveryDidRefresh];
            [peripheralDelegate kreyosServiceDidReset];
			pendingInit = YES;
			break;
		}
            
        case CBCentralManagerStateUnsupported:
        {
            NSLog(@"S5 CentralManager in an unspoorted state");
			/* Bad news, let's wait for another event. */
			break;
        }

	}
    
    previousState = [centralManager state];
}

-(void)disconectCurrentPeriperal
{
    LKreyosService	*service;
    for ( service in connectedServices )
    {
        [self disconnectPeripheral:service.peripheral];
    }
    
    //~~~All prev device clean
    [self.previouslyConnectedPeripherals removeAllObjects];
}

-(void)cleanAllDevicesConnected
{
    
    for(CBPeripheral *peripheral in self.previouslyConnectedPeripherals)
    {
        [self disconnectPeripheral:peripheral];
    }
    
    LKreyosService	*service;
    bool hasService = false;
    for ( service in connectedServices )
    {
        [self disconnectPeripheral:service.peripheral];
        hasService = true;
    }
    
    //~~~All prev device clean
    [self.previouslyConnectedPeripherals removeAllObjects];
    
    NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
    if([def objectForKey:USERDEF_LASTDEVICE])
    {
        [def removeObjectForKey:USERDEF_LASTDEVICE];
    }
    
    if(!hasService)
    {
        m_managerState = STATE_DISCONNECTED;
    }
}

- (BOOL) hasValidCharacteristics
{
    LKreyosService	*service;
    BOOL hasValid = NO;
    
    for ( service in connectedServices )
    {
        hasValid = [service hasValidCharacteristics];
        if ( hasValid ) { return YES; }
    }
    
    return NO;
}

-(void)connectForRandomDevice
{
    if ([KreyosDataManager sharedInstance].HasConnectedDevice == true)return;
    CBPeripheral* per = nil;
    for (per in foundPeripherals)
    {
        [self connectPeripheral:per];
        break;
    }
}

-(void)disconnectCurrentPeriperal
{
    CBPeripheral *peripheral = [KreyosDataManager sharedInstance].DisplayingService.peripheral;
    if (peripheral)
    {
        [centralManager cancelPeripheralConnection:peripheral];
    }

}

-(BOOL)isDeviceConnecting //~~~Check if pheriperal currently connecting
{
    return m_managerState == STATE_CONNECTING;
}



@end
