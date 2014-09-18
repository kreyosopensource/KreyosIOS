
#import "LKreyosService.h"
#import "LkDiscovery.h"

NSString *kKreyosServiceUUIDString          =@"fff0";

NSString *BLE_HANDLE_TEST_READ              =@"fff1";
NSString *BLE_HANDLE_TEST_WRITE             =@"fff2";
NSString *BLE_HANDLE_DATETIME               =@"fff3";
NSString *BLE_HANDLE_ALARM_0                =@"fff4";
NSString *BLE_HANDLE_ALARM_1                =@"fff5";
NSString *BLE_HANDLE_ALARM_2                =@"fff6";
NSString *BLE_HANDLE_SPORTS_GRID            =@"fff7";
NSString *BLE_HANDLE_SPORTS_DATA            =@"fff8";
NSString *BLE_HANDLE_SPORTS_DESC            =@"fff9";
NSString *BLE_HANDLE_DEVICE_ID              =@"ff10";

NSString *BLE_HANDLE_FILE_DESC              =@"ff11";
NSString *BLE_HANDLE_FILE_DATA              =@"ff12";
NSString *BLE_HANDLE_GPS_INFO               =@"ff13";
NSString *BLE_HANDLE_CONF_GESTURE           =@"ff14";

NSString *BLE_HANDLE_CONF_WORLDCLOCK_0      =@"ff15";
NSString *BLE_HANDLE_CONF_WORLDCLOCK_1      =@"ff16";
NSString *BLE_HANDLE_CONF_WORLDCLOCK_2      =@"ff17";
NSString *BLE_HANDLE_CONF_WORLDCLOCK_3      =@"ff18";
NSString *BLE_HANDLE_CONF_WORLDCLOCK_4      =@"ff19";
NSString *BLE_HANDLE_CONF_WORLDCLOCK_5      =@"ff20";

NSString *BLE_HANDLE_CONF_WATCHFACE         =@"ff21";
NSString *BLE_HANDLE_CONF_GOALS             =@"ff22";
NSString *BLE_HANDLE_CONF_USER_PROFILE      =@"ff23";
NSString *BLE_HANDLE_CONF_ACTIVE_TIME       =@"ff24";



NSString *kServiceEnteredBackgroundNotification = @"kServiceEnteredBackgroundNotification";
NSString *kServiceEnteredForegroundNotification = @"kServiceEnteredForegroundNotification";


@interface LKreyosService() <CBPeripheralDelegate> {
@private
    CBPeripheral		*servicePeripheral;
    CBService			*kreyosService;
    NSMutableDictionary *characteristicTable;
    NSMutableArray      *characateristicLists;
    
    CBCharacteristic    *BLE_HANDLE_TEST_READ_CHARACTERISTIC;
    CBUUID              *BLE_HANDLE_TEST_READ_UUID;
    
    CBCharacteristic    *BLE_HANDLE_TEST_WRITE_CHARACTERISTIC;
    CBUUID              *BLE_HANDLE_TEST_WRITE_UUID;
    
    CBCharacteristic    *BLE_HANDLE_DATETIME_CHARACTERISTIC;
    CBUUID              *BLE_HANDLE_DATETIME_UUID;
    
    CBCharacteristic    *BLE_HANDLE_ALARM_0_CHARACTERISTIC;
    CBUUID              *BLE_HANDLE_ALARM_0_UUID;
    
    CBCharacteristic    *BLE_HANDLE_ALARM_1_CHARACTERISTIC;
    CBUUID              *BLE_HANDLE_ALARM_1_UUID;
    
    CBCharacteristic    *BLE_HANDLE_ALARM_2_CHARACTERISTIC;
    CBUUID              *BLE_HANDLE_ALARM_2_UUID;
    
    CBCharacteristic    *BLE_HANDLE_SPORTS_GRID_CHARACTERISTIC;
    CBUUID              *BLE_HANDLE_SPORTS_GRID_UUID;
    
    CBCharacteristic    *BLE_HANDLE_SPORTS_DATA_CHARACTERISTIC;
    CBUUID              *BLE_HANDLE_SPORTS_DATA_UUID;
    
    CBCharacteristic    *BLE_HANDLE_SPORTS_DESC_CHARACTERISTIC;
    CBUUID              *BLE_HANDLE_SPORTS_DESC_UUID;
    
    CBCharacteristic    *BLE_HANDLE_DEVICE_ID_CHARACTERISTIC;
    CBUUID              *BLE_HANDLE_DEVICE_ID_UUID;
    
    CBCharacteristic    *BLE_HANDLE_FILE_DESC_CHARACTERISTIC;
    CBUUID              *BLE_HANDLE_FILE_DESC_UUID;
    
    CBCharacteristic    *BLE_HANDLE_FILE_DATA_CHARACTERISTIC;
    CBUUID              *BLE_HANDLE_FILE_DATA_UUID;
    
    CBCharacteristic    *BLE_HANDLE_GPS_INFO_CHARACTERISTIC;
    CBUUID              *BLE_HANDLE_GPS_INFO_UUID;
    
    CBCharacteristic    *BLE_HANDLE_CONF_GESTURE_CHARACTERISTIC;
    CBUUID              *BLE_HANDLE_CONF_GESTURE_UUID;
    
    CBCharacteristic    *BLE_HANDLE_CONF_WORLDCLOCK_0_CHARACTERISTIC;
    CBUUID              *BLE_HANDLE_CONF_WORLDCLOCK_0_UUID;
    
    CBCharacteristic    *BLE_HANDLE_CONF_WORLDCLOCK_1_CHARACTERISTIC;
    CBUUID              *BLE_HANDLE_CONF_WORLDCLOCK_1_UUID;
    
    CBCharacteristic    *BLE_HANDLE_CONF_WORLDCLOCK_2_CHARACTERISTIC;
    CBUUID              *BLE_HANDLE_CONF_WORLDCLOCK_2_UUID;
    
    CBCharacteristic    *BLE_HANDLE_CONF_WORLDCLOCK_3_CHARACTERISTIC;
    CBUUID              *BLE_HANDLE_CONF_WORLDCLOCK_3_UUID;
    
    CBCharacteristic    *BLE_HANDLE_CONF_WORLDCLOCK_4_CHARACTERISTIC;
    CBUUID              *BLE_HANDLE_CONF_WORLDCLOCK_4_UUID;
    
    CBCharacteristic    *BLE_HANDLE_CONF_WORLDCLOCK_5_CHARACTERISTIC;
    CBUUID              *BLE_HANDLE_CONF_WORLDCLOCK_5_UUID;
    
    CBCharacteristic    *BLE_HANDLE_CONF_WATCHFACE_CHARACTERISTIC;
    CBUUID              *BLE_HANDLE_CONF_WATCHFACE_UUID;
    
    CBCharacteristic    *BLE_HANDLE_CONF_GOALS_CHARACTERISTIC;
    CBUUID              *BLE_HANDLE_CONF_GOALS_UUID;
    
    CBCharacteristic    *BLE_HANDLE_CONF_USER_PROFILE_CHARACTERISTIC;
    CBUUID              *BLE_HANDLE_CONF_USER_PROFILE_UUID;
    
    CBCharacteristic    *BLE_HANDLE_CONF_ACTIVE_TIME_CHARACTERISTIC;
    CBUUID              *BLE_HANDLE_CONF_ACTIVE_TIME_UUID;
    
    id<KreyosProtocol>	peripheralDelegate;
}
@end



@implementation LKreyosService


@synthesize peripheral = servicePeripheral;


#pragma mark -
#pragma mark Init

- (id) initWithPeripheral:(CBPeripheral *)peripheral controller:(id<KreyosProtocol>)controller
{
    NSLog(@"LKreyos::initWithPeripheral Peripheral:%@ Controller:%@",peripheral,controller);
    
    self = [super init];
    
    if (self) {
        
        servicePeripheral = [peripheral retain];
        [servicePeripheral setDelegate:self];
		peripheralDelegate = controller;
        
        characteristicTable = [NSMutableDictionary dictionaryWithCapacity:23];
        
        BLE_HANDLE_TEST_READ_UUID              = [[CBUUID UUIDWithString:BLE_HANDLE_TEST_READ] retain];
        BLE_HANDLE_TEST_WRITE_UUID             = [[CBUUID UUIDWithString:BLE_HANDLE_TEST_WRITE] retain];
        BLE_HANDLE_DATETIME_UUID               = [[CBUUID UUIDWithString:BLE_HANDLE_DATETIME] retain];
        BLE_HANDLE_ALARM_0_UUID                = [[CBUUID UUIDWithString:BLE_HANDLE_ALARM_0] retain];
        BLE_HANDLE_ALARM_1_UUID                = [[CBUUID UUIDWithString:BLE_HANDLE_ALARM_1] retain];
        BLE_HANDLE_ALARM_2_UUID                = [[CBUUID UUIDWithString:BLE_HANDLE_ALARM_2] retain];
        BLE_HANDLE_SPORTS_GRID_UUID            = [[CBUUID UUIDWithString:BLE_HANDLE_SPORTS_GRID] retain];
        BLE_HANDLE_SPORTS_DATA_UUID            = [[CBUUID UUIDWithString:BLE_HANDLE_SPORTS_DATA] retain];
        BLE_HANDLE_SPORTS_DESC_UUID            = [[CBUUID UUIDWithString:BLE_HANDLE_SPORTS_DESC] retain];
        BLE_HANDLE_DEVICE_ID_UUID              = [[CBUUID UUIDWithString:BLE_HANDLE_DEVICE_ID] retain];
        
        BLE_HANDLE_FILE_DESC_UUID              = [[CBUUID UUIDWithString:BLE_HANDLE_FILE_DESC] retain];
        BLE_HANDLE_FILE_DATA_UUID              = [[CBUUID UUIDWithString:BLE_HANDLE_FILE_DATA] retain];
        BLE_HANDLE_GPS_INFO_UUID               = [[CBUUID UUIDWithString:BLE_HANDLE_GPS_INFO] retain];
        BLE_HANDLE_CONF_GESTURE_UUID           = [[CBUUID UUIDWithString:BLE_HANDLE_CONF_GESTURE] retain];
        
        BLE_HANDLE_CONF_WORLDCLOCK_0_UUID      = [[CBUUID UUIDWithString:BLE_HANDLE_CONF_WORLDCLOCK_0] retain];
        BLE_HANDLE_CONF_WORLDCLOCK_1_UUID      = [[CBUUID UUIDWithString:BLE_HANDLE_CONF_WORLDCLOCK_1] retain];
        BLE_HANDLE_CONF_WORLDCLOCK_2_UUID      = [[CBUUID UUIDWithString:BLE_HANDLE_CONF_WORLDCLOCK_2] retain];
        BLE_HANDLE_CONF_WORLDCLOCK_3_UUID      = [[CBUUID UUIDWithString:BLE_HANDLE_CONF_WORLDCLOCK_3] retain];
        BLE_HANDLE_CONF_WORLDCLOCK_4_UUID      = [[CBUUID UUIDWithString:BLE_HANDLE_CONF_WORLDCLOCK_4] retain];
        BLE_HANDLE_CONF_WORLDCLOCK_5_UUID      = [[CBUUID UUIDWithString:BLE_HANDLE_CONF_WORLDCLOCK_5] retain];
        
        BLE_HANDLE_CONF_WATCHFACE_UUID         = [[CBUUID UUIDWithString:BLE_HANDLE_CONF_WATCHFACE] retain];
        BLE_HANDLE_CONF_GOALS_UUID             = [[CBUUID UUIDWithString:BLE_HANDLE_CONF_GOALS] retain];
        BLE_HANDLE_CONF_USER_PROFILE_UUID      = [[CBUUID UUIDWithString:BLE_HANDLE_CONF_USER_PROFILE] retain];
        BLE_HANDLE_CONF_ACTIVE_TIME_UUID       = [[CBUUID UUIDWithString:BLE_HANDLE_CONF_ACTIVE_TIME] retain];
	}
    return self;
}


- (void) dealloc {
	if (servicePeripheral) {
        
		//[servicePeripheral setDelegate:[LkDiscovery sharedInstance]];
		[servicePeripheral release];
		servicePeripheral = nil;
        
        [BLE_HANDLE_TEST_READ_UUID              release];
        [BLE_HANDLE_TEST_WRITE_UUID             release];
        [BLE_HANDLE_DATETIME_UUID               release];
        [BLE_HANDLE_ALARM_0_UUID                release];
        [BLE_HANDLE_ALARM_1_UUID                release];
        [BLE_HANDLE_ALARM_2_UUID                release];
        [BLE_HANDLE_SPORTS_GRID_UUID            release];
        [BLE_HANDLE_SPORTS_DATA_UUID            release];
        [BLE_HANDLE_SPORTS_DESC_UUID            release];
        [BLE_HANDLE_DEVICE_ID_UUID              release];
        
        [BLE_HANDLE_FILE_DESC_UUID              release];
        [BLE_HANDLE_FILE_DATA_UUID              release];
        [BLE_HANDLE_GPS_INFO_UUID               release];
        [BLE_HANDLE_CONF_GESTURE_UUID           release];
        
        [BLE_HANDLE_CONF_WORLDCLOCK_0_UUID      release];
        [BLE_HANDLE_CONF_WORLDCLOCK_1_UUID      release];
        [BLE_HANDLE_CONF_WORLDCLOCK_2_UUID      release];
        [BLE_HANDLE_CONF_WORLDCLOCK_3_UUID      release];
        [BLE_HANDLE_CONF_WORLDCLOCK_4_UUID      release];
        [BLE_HANDLE_CONF_WORLDCLOCK_5_UUID      release];
        
        [BLE_HANDLE_CONF_WATCHFACE_UUID         release];
        [BLE_HANDLE_CONF_GOALS_UUID             release];
        [BLE_HANDLE_CONF_USER_PROFILE_UUID      release];
        [BLE_HANDLE_CONF_ACTIVE_TIME_UUID       release];
    }
    [super dealloc];
}


- (void) renewConnection
{
    BLE_HANDLE_TEST_READ_UUID              = [[CBUUID UUIDWithString:BLE_HANDLE_TEST_READ] retain];
    BLE_HANDLE_TEST_WRITE_UUID             = [[CBUUID UUIDWithString:BLE_HANDLE_TEST_WRITE] retain];
    BLE_HANDLE_DATETIME_UUID               = [[CBUUID UUIDWithString:BLE_HANDLE_DATETIME] retain];
    BLE_HANDLE_ALARM_0_UUID                = [[CBUUID UUIDWithString:BLE_HANDLE_ALARM_0] retain];
    BLE_HANDLE_ALARM_1_UUID                = [[CBUUID UUIDWithString:BLE_HANDLE_ALARM_1] retain];
    BLE_HANDLE_ALARM_2_UUID                = [[CBUUID UUIDWithString:BLE_HANDLE_ALARM_2] retain];
    BLE_HANDLE_SPORTS_GRID_UUID            = [[CBUUID UUIDWithString:BLE_HANDLE_SPORTS_GRID] retain];
    BLE_HANDLE_SPORTS_DATA_UUID            = [[CBUUID UUIDWithString:BLE_HANDLE_SPORTS_DATA] retain];
    BLE_HANDLE_SPORTS_DESC_UUID            = [[CBUUID UUIDWithString:BLE_HANDLE_SPORTS_DESC] retain];
    BLE_HANDLE_DEVICE_ID_UUID              = [[CBUUID UUIDWithString:BLE_HANDLE_DEVICE_ID] retain];
    
    BLE_HANDLE_FILE_DESC_UUID              = [[CBUUID UUIDWithString:BLE_HANDLE_FILE_DESC] retain];
    BLE_HANDLE_FILE_DATA_UUID              = [[CBUUID UUIDWithString:BLE_HANDLE_FILE_DATA] retain];
    BLE_HANDLE_GPS_INFO_UUID               = [[CBUUID UUIDWithString:BLE_HANDLE_GPS_INFO] retain];
    BLE_HANDLE_CONF_GESTURE_UUID           = [[CBUUID UUIDWithString:BLE_HANDLE_CONF_GESTURE] retain];
    
    BLE_HANDLE_CONF_WORLDCLOCK_0_UUID      = [[CBUUID UUIDWithString:BLE_HANDLE_CONF_WORLDCLOCK_0] retain];
    BLE_HANDLE_CONF_WORLDCLOCK_1_UUID      = [[CBUUID UUIDWithString:BLE_HANDLE_CONF_WORLDCLOCK_1] retain];
    BLE_HANDLE_CONF_WORLDCLOCK_2_UUID      = [[CBUUID UUIDWithString:BLE_HANDLE_CONF_WORLDCLOCK_2] retain];
    BLE_HANDLE_CONF_WORLDCLOCK_3_UUID      = [[CBUUID UUIDWithString:BLE_HANDLE_CONF_WORLDCLOCK_3] retain];
    BLE_HANDLE_CONF_WORLDCLOCK_4_UUID      = [[CBUUID UUIDWithString:BLE_HANDLE_CONF_WORLDCLOCK_4] retain];
    BLE_HANDLE_CONF_WORLDCLOCK_5_UUID      = [[CBUUID UUIDWithString:BLE_HANDLE_CONF_WORLDCLOCK_5] retain];
    
    BLE_HANDLE_CONF_WATCHFACE_UUID         = [[CBUUID UUIDWithString:BLE_HANDLE_CONF_WATCHFACE] retain];
    BLE_HANDLE_CONF_GOALS_UUID             = [[CBUUID UUIDWithString:BLE_HANDLE_CONF_GOALS] retain];
    BLE_HANDLE_CONF_USER_PROFILE_UUID      = [[CBUUID UUIDWithString:BLE_HANDLE_CONF_USER_PROFILE] retain];
    BLE_HANDLE_CONF_ACTIVE_TIME_UUID       = [[CBUUID UUIDWithString:BLE_HANDLE_CONF_ACTIVE_TIME] retain];

}

- (void) reset
{
	if (servicePeripheral)
    {
		[servicePeripheral release];
		servicePeripheral = nil;
	}
}


- (void)enteredBackground
{
    
}


- (void)enteredForeground
{
    
}

#pragma mark -
#pragma mark Has Valid characteristis
- (BOOL) hasValidCharacteristics
{
    if (
        BLE_HANDLE_TEST_READ_CHARACTERISTIC == nil
        || BLE_HANDLE_DATETIME_CHARACTERISTIC == nil
        || BLE_HANDLE_TEST_WRITE_CHARACTERISTIC == nil
        || BLE_HANDLE_ALARM_0_CHARACTERISTIC == nil
        || BLE_HANDLE_ALARM_1_CHARACTERISTIC == nil
        || BLE_HANDLE_ALARM_2_CHARACTERISTIC == nil
        || BLE_HANDLE_SPORTS_GRID_CHARACTERISTIC == nil
        || BLE_HANDLE_SPORTS_DATA_CHARACTERISTIC == nil
        || BLE_HANDLE_SPORTS_DESC_CHARACTERISTIC == nil
        || BLE_HANDLE_DEVICE_ID_CHARACTERISTIC == nil
        || BLE_HANDLE_FILE_DESC_CHARACTERISTIC == nil
        || BLE_HANDLE_FILE_DATA_CHARACTERISTIC == nil
        || BLE_HANDLE_GPS_INFO_CHARACTERISTIC == nil
        || BLE_HANDLE_CONF_GESTURE_CHARACTERISTIC == nil
        || BLE_HANDLE_CONF_WORLDCLOCK_0_CHARACTERISTIC == nil
        || BLE_HANDLE_CONF_WORLDCLOCK_1_CHARACTERISTIC == nil
        || BLE_HANDLE_CONF_WORLDCLOCK_2_CHARACTERISTIC == nil
        || BLE_HANDLE_CONF_WORLDCLOCK_3_CHARACTERISTIC == nil
        || BLE_HANDLE_CONF_WORLDCLOCK_4_CHARACTERISTIC == nil
        || BLE_HANDLE_CONF_WORLDCLOCK_5_CHARACTERISTIC == nil
        || BLE_HANDLE_CONF_WATCHFACE_CHARACTERISTIC == nil
        || BLE_HANDLE_CONF_GOALS_CHARACTERISTIC == nil
        || BLE_HANDLE_CONF_USER_PROFILE_CHARACTERISTIC == nil
        //|| BLE_HANDLE_CONF_ACTIVE_TIME_CHARACTERISTIC == nil
    ) {
        return NO;
    }
    
    return YES;
}

#pragma mark -
#pragma mark Service interaction
- (void) start
{
    if(servicePeripheral == nil) return;
    
    if ([servicePeripheral state] == CBPeripheralStateConnected) {
        NSLog(@"Start discoverServices");
        [servicePeripheral discoverServices:nil];
    }
    
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	NSArray		*services	= nil;
	NSArray		*uuids	= [[NSArray arrayWithObjects:
                           BLE_HANDLE_TEST_READ_UUID,
                           BLE_HANDLE_TEST_WRITE_UUID,
                           BLE_HANDLE_DATETIME_UUID,
                           BLE_HANDLE_ALARM_0_UUID,
                           BLE_HANDLE_ALARM_1_UUID,
                           BLE_HANDLE_ALARM_2_UUID,
                           BLE_HANDLE_SPORTS_GRID_UUID,
                           BLE_HANDLE_SPORTS_DATA_UUID,
                           BLE_HANDLE_SPORTS_DESC_UUID,
                           BLE_HANDLE_DEVICE_ID_UUID,
                           BLE_HANDLE_FILE_DESC_UUID,
                           BLE_HANDLE_FILE_DATA_UUID,
                           BLE_HANDLE_GPS_INFO_UUID,
                           BLE_HANDLE_CONF_GESTURE_UUID,
                           BLE_HANDLE_CONF_WORLDCLOCK_0_UUID,
                           BLE_HANDLE_CONF_WORLDCLOCK_1_UUID,
                           BLE_HANDLE_CONF_WORLDCLOCK_2_UUID,
                           BLE_HANDLE_CONF_WORLDCLOCK_3_UUID,
                           BLE_HANDLE_CONF_WORLDCLOCK_4_UUID,
                           BLE_HANDLE_CONF_WORLDCLOCK_5_UUID,
                           BLE_HANDLE_CONF_WATCHFACE_UUID,
                           BLE_HANDLE_CONF_GOALS_UUID,
                           BLE_HANDLE_CONF_USER_PROFILE_UUID,
                           BLE_HANDLE_CONF_ACTIVE_TIME_UUID,
                           nil] retain];
    
	if (peripheral != servicePeripheral) {
		NSLog(@"Wrong Peripheral.\n");
		return ;
	}
    
    if (error != nil) {
        NSLog(@"Error %@\n", error);
		return ;
	}
    
	services = [peripheral services];
    
    for (CBService *service in peripheral.services) {
        NSLog(@"Find services: %@", [service UUID]);
    }
    
	if (!services || ![services count]) {
		return ;
	}
    
	kreyosService = nil;
    
	for (CBService *service in services) {
		if ([[service UUID] isEqual:[CBUUID UUIDWithString:kKreyosServiceUUIDString]]) {
			kreyosService = service;
			break;
		}
	}
    
	if (kreyosService) {
		[peripheral discoverCharacteristics:uuids forService:kreyosService];
	}
}


- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
    NSLog(@"LKreyosService::didDiscoverCharacteristicsForService characteristics:%@",[service characteristics]);
    
	NSArray *characteristics = [service characteristics];
	CBCharacteristic *characteristic;
    
    
	for (characteristic in characteristics) {
        NSLog(@"discovered characteristic UUID:%@ Value:%@", [characteristic UUID], [characteristic value]);
        //[characteristicTable setObject:[characteristic retain] forKey:[[characteristic UUID] UUIDString]];

        /* Inite services */
        if ([[characteristic UUID] isEqual:BLE_HANDLE_TEST_READ_UUID])
        {
            BLE_HANDLE_TEST_READ_CHARACTERISTIC = [characteristic retain];
        }
        else if ([[characteristic UUID] isEqual:BLE_HANDLE_DATETIME_UUID])
        {
            BLE_HANDLE_DATETIME_CHARACTERISTIC = [characteristic retain];
        }
        else if ([[characteristic UUID] isEqual:BLE_HANDLE_TEST_WRITE_UUID])
        {
            BLE_HANDLE_TEST_WRITE_CHARACTERISTIC = [characteristic retain];
        }
        else if ([[characteristic UUID] isEqual:BLE_HANDLE_ALARM_0_UUID])
        {
            BLE_HANDLE_ALARM_0_CHARACTERISTIC = [characteristic retain];
        }
        else if ([[characteristic UUID] isEqual:BLE_HANDLE_ALARM_1_UUID])
        {
            BLE_HANDLE_ALARM_1_CHARACTERISTIC = [characteristic retain];
        }
        else if ([[characteristic UUID] isEqual:BLE_HANDLE_ALARM_2_UUID])
        {
            BLE_HANDLE_ALARM_2_CHARACTERISTIC = [characteristic retain];
        }
        else if ([[characteristic UUID] isEqual:BLE_HANDLE_SPORTS_GRID_UUID])
        {
            BLE_HANDLE_SPORTS_GRID_CHARACTERISTIC = [characteristic retain];
        }
        else if ([[characteristic UUID] isEqual:BLE_HANDLE_SPORTS_DATA_UUID])
        {
            BLE_HANDLE_SPORTS_DATA_CHARACTERISTIC = [characteristic retain];
        }
        else if ([[characteristic UUID] isEqual:BLE_HANDLE_SPORTS_DESC_UUID])
        {
            BLE_HANDLE_SPORTS_DESC_CHARACTERISTIC = [characteristic retain];
        }
        else if ([[characteristic UUID] isEqual:BLE_HANDLE_DEVICE_ID_UUID])
        {
            BLE_HANDLE_DEVICE_ID_CHARACTERISTIC = [characteristic retain];
        }
        else if ([[characteristic UUID] isEqual:BLE_HANDLE_FILE_DESC_UUID])
        {
            BLE_HANDLE_FILE_DESC_CHARACTERISTIC = [characteristic retain];
        }
        else if ([[characteristic UUID] isEqual:BLE_HANDLE_FILE_DATA_UUID])
        {
            BLE_HANDLE_FILE_DATA_CHARACTERISTIC = [characteristic retain];
        }
        else if ([[characteristic UUID] isEqual:BLE_HANDLE_GPS_INFO_UUID])
        {
            BLE_HANDLE_GPS_INFO_CHARACTERISTIC = [characteristic retain];
        }
        else if ([[characteristic UUID] isEqual:BLE_HANDLE_CONF_GESTURE_UUID])
        {
            BLE_HANDLE_CONF_GESTURE_CHARACTERISTIC = [characteristic retain];
        }
        else if ([[characteristic UUID] isEqual:BLE_HANDLE_CONF_WORLDCLOCK_0_UUID])
        {
            BLE_HANDLE_CONF_WORLDCLOCK_0_CHARACTERISTIC = [characteristic retain];
        }
        else if ([[characteristic UUID] isEqual:BLE_HANDLE_CONF_WORLDCLOCK_1_UUID])
        {
            BLE_HANDLE_CONF_WORLDCLOCK_1_CHARACTERISTIC = [characteristic retain];
        }
        else if ([[characteristic UUID] isEqual:BLE_HANDLE_CONF_WORLDCLOCK_2_UUID])
        {
            BLE_HANDLE_CONF_WORLDCLOCK_2_CHARACTERISTIC = [characteristic retain];
        }
        else if ([[characteristic UUID] isEqual:BLE_HANDLE_CONF_WORLDCLOCK_3_UUID])
        {
            BLE_HANDLE_CONF_WORLDCLOCK_3_CHARACTERISTIC = [characteristic retain];
        }
        else if ([[characteristic UUID] isEqual:BLE_HANDLE_CONF_WORLDCLOCK_4_UUID])
        {
            BLE_HANDLE_CONF_WORLDCLOCK_4_CHARACTERISTIC = [characteristic retain];
        }
        else if ([[characteristic UUID] isEqual:BLE_HANDLE_CONF_WORLDCLOCK_5_UUID])
        {
            BLE_HANDLE_CONF_WORLDCLOCK_5_CHARACTERISTIC = [characteristic retain];
        }
        else if ([[characteristic UUID] isEqual:BLE_HANDLE_CONF_WATCHFACE_UUID])
        {
            BLE_HANDLE_CONF_WATCHFACE_CHARACTERISTIC = [characteristic retain];
        }
        else if ([[characteristic UUID] isEqual:BLE_HANDLE_CONF_GOALS_UUID])
        {
            BLE_HANDLE_CONF_GOALS_CHARACTERISTIC = [characteristic retain];
        }
        else if ([[characteristic UUID] isEqual:BLE_HANDLE_CONF_USER_PROFILE_UUID])
        {
            BLE_HANDLE_CONF_USER_PROFILE_CHARACTERISTIC = [characteristic retain];
        }
        else if ([[characteristic UUID] isEqual:BLE_HANDLE_CONF_ACTIVE_TIME_UUID])
        {
            BLE_HANDLE_CONF_ACTIVE_TIME_CHARACTERISTIC = [characteristic retain];
        }
	}
    
    NSLog(@"-LKreyosService::peripheralDidDiscovered!");
}

- (void) clearCharacteristics
{


}


#pragma mark -
#pragma mark Characteristics interaction
- (void) writeKreyos:(NSData *)valuex toCharacteristic:(NSString*)UUIDString
{
      
    if (!servicePeripheral) {
        NSLog(@"Not connected to a peripheral");
    }
    
    
/*
    CBCharacteristic* cha = [characteristicTable objectForKey:UUIDString];
    if (cha) {
        NSLog(@"Write Characteristic: %@", UUIDString);
        [servicePeripheral writeValue:valuex forCharacteristic:cha type:CBCharacteristicWriteWithResponse];
    }
    else {
        NSLog(@"No Characteristic %@ found", UUIDString);
    }
    */
    
    //~~~TODO: REmove Log if stable
    //NSLog(@"LOG UUIDString %@", UUIDString);
    
    if (![self hasValidCharacteristics])
    {
        NSLog(@"Can't write must initialize characteristic first");
        return;
    }
    
    if ([UUIDString isEqual:BLE_HANDLE_TEST_READ])
        [servicePeripheral writeValue:valuex forCharacteristic:BLE_HANDLE_TEST_READ_CHARACTERISTIC type:CBCharacteristicWriteWithResponse];
    else if ([UUIDString isEqual:BLE_HANDLE_TEST_WRITE])
        [servicePeripheral writeValue:valuex forCharacteristic:BLE_HANDLE_TEST_WRITE_CHARACTERISTIC type:CBCharacteristicWriteWithResponse];
    else if ([UUIDString isEqual:BLE_HANDLE_DATETIME])
        [servicePeripheral writeValue:valuex forCharacteristic:BLE_HANDLE_DATETIME_CHARACTERISTIC type:CBCharacteristicWriteWithResponse];
    else if ([UUIDString isEqual:BLE_HANDLE_ALARM_0])
        [servicePeripheral writeValue:valuex forCharacteristic:BLE_HANDLE_ALARM_0_CHARACTERISTIC type:CBCharacteristicWriteWithResponse];
    else if ([UUIDString isEqual:BLE_HANDLE_ALARM_1])
        [servicePeripheral writeValue:valuex forCharacteristic:BLE_HANDLE_ALARM_1_CHARACTERISTIC type:CBCharacteristicWriteWithResponse];
    else if ([UUIDString isEqual:BLE_HANDLE_ALARM_2])
        [servicePeripheral writeValue:valuex forCharacteristic:BLE_HANDLE_ALARM_2_CHARACTERISTIC type:CBCharacteristicWriteWithResponse];
    else if ([UUIDString isEqual:BLE_HANDLE_SPORTS_GRID])
        [servicePeripheral writeValue:valuex forCharacteristic:BLE_HANDLE_SPORTS_GRID_CHARACTERISTIC type:CBCharacteristicWriteWithResponse];
    else if ([UUIDString isEqual:BLE_HANDLE_SPORTS_DATA])
        [servicePeripheral writeValue:valuex forCharacteristic:BLE_HANDLE_SPORTS_DATA_CHARACTERISTIC type:CBCharacteristicWriteWithResponse];
    else if ([UUIDString isEqual:BLE_HANDLE_SPORTS_DESC])
        [servicePeripheral writeValue:valuex forCharacteristic:BLE_HANDLE_SPORTS_DESC_CHARACTERISTIC type:CBCharacteristicWriteWithResponse];
    else if ([UUIDString isEqual:BLE_HANDLE_DEVICE_ID])
        [servicePeripheral writeValue:valuex forCharacteristic:BLE_HANDLE_DEVICE_ID_CHARACTERISTIC type:CBCharacteristicWriteWithResponse];
    else if ([UUIDString isEqual:BLE_HANDLE_FILE_DESC])
        [servicePeripheral writeValue:valuex forCharacteristic:BLE_HANDLE_FILE_DESC_CHARACTERISTIC type:CBCharacteristicWriteWithResponse];
    else if ([UUIDString isEqual:BLE_HANDLE_FILE_DATA])
        [servicePeripheral writeValue:valuex forCharacteristic:BLE_HANDLE_FILE_DATA_CHARACTERISTIC type:CBCharacteristicWriteWithResponse];
    else if ([UUIDString isEqual:BLE_HANDLE_GPS_INFO])
        [servicePeripheral writeValue:valuex forCharacteristic:BLE_HANDLE_GPS_INFO_CHARACTERISTIC type:CBCharacteristicWriteWithResponse];
    else if ([UUIDString isEqual:BLE_HANDLE_CONF_GESTURE])
        [servicePeripheral writeValue:valuex forCharacteristic:BLE_HANDLE_CONF_GESTURE_CHARACTERISTIC type:CBCharacteristicWriteWithResponse];
    else if ([UUIDString isEqual:BLE_HANDLE_CONF_WORLDCLOCK_0])
        [servicePeripheral writeValue:valuex forCharacteristic:BLE_HANDLE_CONF_WORLDCLOCK_0_CHARACTERISTIC type:CBCharacteristicWriteWithResponse];
    else if ([UUIDString isEqual:BLE_HANDLE_CONF_WORLDCLOCK_1])
        [servicePeripheral writeValue:valuex forCharacteristic:BLE_HANDLE_CONF_WORLDCLOCK_1_CHARACTERISTIC type:CBCharacteristicWriteWithResponse];
    else if ([UUIDString isEqual:BLE_HANDLE_CONF_WORLDCLOCK_2])
        [servicePeripheral writeValue:valuex forCharacteristic:BLE_HANDLE_CONF_WORLDCLOCK_2_CHARACTERISTIC type:CBCharacteristicWriteWithResponse];
    else if ([UUIDString isEqual:BLE_HANDLE_CONF_WORLDCLOCK_3])
        [servicePeripheral writeValue:valuex forCharacteristic:BLE_HANDLE_CONF_WORLDCLOCK_3_CHARACTERISTIC type:CBCharacteristicWriteWithResponse];
    else if ([UUIDString isEqual:BLE_HANDLE_CONF_WORLDCLOCK_4])
        [servicePeripheral writeValue:valuex forCharacteristic:BLE_HANDLE_CONF_WORLDCLOCK_4_CHARACTERISTIC type:CBCharacteristicWriteWithResponse];
    else if ([UUIDString isEqual:BLE_HANDLE_CONF_WORLDCLOCK_5])
        [servicePeripheral writeValue:valuex forCharacteristic:BLE_HANDLE_CONF_WORLDCLOCK_5_CHARACTERISTIC type:CBCharacteristicWriteWithResponse];
    else if ([UUIDString isEqual:BLE_HANDLE_CONF_WATCHFACE])
        [servicePeripheral writeValue:valuex forCharacteristic:BLE_HANDLE_CONF_WATCHFACE_CHARACTERISTIC type:CBCharacteristicWriteWithResponse];
    else if ([UUIDString isEqual:BLE_HANDLE_CONF_GOALS])
        [servicePeripheral writeValue:valuex forCharacteristic:BLE_HANDLE_CONF_GOALS_CHARACTERISTIC type:CBCharacteristicWriteWithResponse];
    else if ([UUIDString isEqual:BLE_HANDLE_CONF_USER_PROFILE])
        [servicePeripheral writeValue:valuex forCharacteristic:BLE_HANDLE_CONF_USER_PROFILE_CHARACTERISTIC type:CBCharacteristicWriteWithResponse];
}

- (void) readKreyosfrom:(NSString *)characteristic{
    
    if (!servicePeripheral) {
        NSLog(@"Not connected to a peripheral");
    }
    
    if ( [servicePeripheral state] != CBPeripheralStateConnected )
    {
        NSLog(@"Peripheral's state is %zi", [servicePeripheral state]);
        return;
    }
    
    NSLog(@"LKreyosService::readKreyosfrom characteristic to read:%@",characteristic);
    
    if ( characteristic == nil )
    {
        NSLog(@"LKreyosService::readKreyosfrom not valid characteristic! Peripheral's state is %zi", [servicePeripheral state]);
        return;
    }
        
    if      ([characteristic isEqual:BLE_HANDLE_TEST_READ])     [servicePeripheral readValueForCharacteristic:BLE_HANDLE_TEST_READ_CHARACTERISTIC];
    else if ([characteristic isEqual:BLE_HANDLE_TEST_WRITE])    [servicePeripheral readValueForCharacteristic:BLE_HANDLE_TEST_WRITE_CHARACTERISTIC];
    else if ([characteristic isEqual:BLE_HANDLE_DATETIME])      [servicePeripheral readValueForCharacteristic:BLE_HANDLE_DATETIME_CHARACTERISTIC];
    else if ([characteristic isEqual:BLE_HANDLE_ALARM_0])       [servicePeripheral readValueForCharacteristic:BLE_HANDLE_ALARM_0_CHARACTERISTIC];
    else if ([characteristic isEqual:BLE_HANDLE_ALARM_1])       [servicePeripheral readValueForCharacteristic:BLE_HANDLE_ALARM_1_CHARACTERISTIC];
    else if ([characteristic isEqual:BLE_HANDLE_ALARM_2])       [servicePeripheral readValueForCharacteristic:BLE_HANDLE_ALARM_2_CHARACTERISTIC];
    else if ([characteristic isEqual:BLE_HANDLE_SPORTS_GRID])   [servicePeripheral readValueForCharacteristic:BLE_HANDLE_SPORTS_GRID_CHARACTERISTIC];
    else if ([characteristic isEqual:BLE_HANDLE_SPORTS_DATA])   [servicePeripheral readValueForCharacteristic:BLE_HANDLE_SPORTS_DATA_CHARACTERISTIC];
    else if ([characteristic isEqual:BLE_HANDLE_SPORTS_DESC])   [servicePeripheral readValueForCharacteristic:BLE_HANDLE_SPORTS_DESC_CHARACTERISTIC];
    else if ([characteristic isEqual:BLE_HANDLE_DEVICE_ID])     [servicePeripheral readValueForCharacteristic:BLE_HANDLE_DEVICE_ID_CHARACTERISTIC];
    else if ([characteristic isEqual:BLE_HANDLE_FILE_DESC])     [servicePeripheral readValueForCharacteristic:BLE_HANDLE_FILE_DESC_CHARACTERISTIC];
    else if ([characteristic isEqual:BLE_HANDLE_FILE_DATA])     [servicePeripheral readValueForCharacteristic:BLE_HANDLE_FILE_DATA_CHARACTERISTIC];
    else if ([characteristic isEqual:BLE_HANDLE_GPS_INFO])      [servicePeripheral readValueForCharacteristic:BLE_HANDLE_GPS_INFO_CHARACTERISTIC];
    else if ([characteristic isEqual:BLE_HANDLE_CONF_GESTURE])  [servicePeripheral readValueForCharacteristic:BLE_HANDLE_CONF_GESTURE_CHARACTERISTIC];
    else if ([characteristic isEqual:BLE_HANDLE_CONF_WORLDCLOCK_0])[servicePeripheral readValueForCharacteristic:BLE_HANDLE_CONF_WORLDCLOCK_0_CHARACTERISTIC];
    else if ([characteristic isEqual:BLE_HANDLE_CONF_WORLDCLOCK_1])[servicePeripheral readValueForCharacteristic:BLE_HANDLE_CONF_WORLDCLOCK_1_CHARACTERISTIC];
    else if ([characteristic isEqual:BLE_HANDLE_CONF_WORLDCLOCK_2])[servicePeripheral readValueForCharacteristic:BLE_HANDLE_CONF_WORLDCLOCK_2_CHARACTERISTIC];
    else if ([characteristic isEqual:BLE_HANDLE_CONF_WORLDCLOCK_3])[servicePeripheral readValueForCharacteristic:BLE_HANDLE_CONF_WORLDCLOCK_3_CHARACTERISTIC];
    else if ([characteristic isEqual:BLE_HANDLE_CONF_WORLDCLOCK_4])[servicePeripheral readValueForCharacteristic:BLE_HANDLE_CONF_WORLDCLOCK_4_CHARACTERISTIC];
    else if ([characteristic isEqual:BLE_HANDLE_CONF_WORLDCLOCK_5])[servicePeripheral readValueForCharacteristic:BLE_HANDLE_CONF_WORLDCLOCK_5_CHARACTERISTIC];
    else if ([characteristic isEqual:BLE_HANDLE_CONF_WATCHFACE])[servicePeripheral readValueForCharacteristic:BLE_HANDLE_CONF_WATCHFACE_CHARACTERISTIC];
    else if ([characteristic isEqual:BLE_HANDLE_CONF_GOALS])[servicePeripheral readValueForCharacteristic:BLE_HANDLE_CONF_GOALS_CHARACTERISTIC];
    else if ([characteristic isEqual:BLE_HANDLE_CONF_USER_PROFILE])[servicePeripheral readValueForCharacteristic:BLE_HANDLE_CONF_USER_PROFILE_CHARACTERISTIC];
    else if ([characteristic isEqual:BLE_HANDLE_CONF_ACTIVE_TIME]) [servicePeripheral readValueForCharacteristic:BLE_HANDLE_CONF_ACTIVE_TIME_CHARACTERISTIC];
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
	if (peripheral != servicePeripheral) {
		NSLog(@"Wrong peripheral\n");
		return ;
	}
    
    if ([error code] != 0) {
		NSLog(@"Error %@\n", error);
		return ;
	}
    
    //[peripheralDelegate valueChanged:characteristic.value fromCharacteristic:[[characteristic UUID] UUIDString]];

    if ([[characteristic UUID] isEqual:BLE_HANDLE_TEST_READ_UUID]) {
        NSData *data=characteristic.value;
        NSLog(@"Read Value: %@",data);
        [peripheralDelegate valueChanged:data fromCharacteristic:BLE_HANDLE_TEST_READ];
        return;
    }
    else if ([[characteristic UUID] isEqual:BLE_HANDLE_TEST_WRITE_UUID])[peripheralDelegate valueChanged:characteristic.value fromCharacteristic:BLE_HANDLE_TEST_WRITE];
    else if ([[characteristic UUID] isEqual:BLE_HANDLE_DATETIME_UUID])[peripheralDelegate valueChanged:characteristic.value fromCharacteristic:BLE_HANDLE_DATETIME];
    else if ([[characteristic UUID] isEqual:BLE_HANDLE_ALARM_0_UUID])[peripheralDelegate valueChanged:characteristic.value fromCharacteristic:BLE_HANDLE_ALARM_0];
    else if ([[characteristic UUID] isEqual:BLE_HANDLE_ALARM_1_UUID])[peripheralDelegate valueChanged:characteristic.value fromCharacteristic:BLE_HANDLE_ALARM_1];
    else if ([[characteristic UUID] isEqual:BLE_HANDLE_ALARM_2_UUID])[peripheralDelegate valueChanged:characteristic.value fromCharacteristic:BLE_HANDLE_ALARM_2];
    else if ([[characteristic UUID] isEqual:BLE_HANDLE_SPORTS_GRID_UUID])[peripheralDelegate valueChanged:characteristic.value fromCharacteristic:BLE_HANDLE_SPORTS_GRID];
    else if ([[characteristic UUID] isEqual:BLE_HANDLE_SPORTS_DATA_UUID])[peripheralDelegate valueChanged:characteristic.value fromCharacteristic:BLE_HANDLE_SPORTS_DATA];
    else if ([[characteristic UUID] isEqual:BLE_HANDLE_SPORTS_DESC_UUID])[peripheralDelegate valueChanged:characteristic.value fromCharacteristic:BLE_HANDLE_SPORTS_DESC];
    else if ([[characteristic UUID] isEqual:BLE_HANDLE_DEVICE_ID_UUID])[peripheralDelegate valueChanged:characteristic.value fromCharacteristic:BLE_HANDLE_DEVICE_ID];
    else if ([[characteristic UUID] isEqual:BLE_HANDLE_FILE_DESC_UUID])[peripheralDelegate valueChanged:characteristic.value fromCharacteristic:BLE_HANDLE_FILE_DESC];
    else if ([[characteristic UUID] isEqual:BLE_HANDLE_FILE_DATA_UUID])[peripheralDelegate valueChanged:characteristic.value fromCharacteristic:BLE_HANDLE_FILE_DATA];
    else if ([[characteristic UUID] isEqual:BLE_HANDLE_GPS_INFO_UUID])[peripheralDelegate valueChanged:characteristic.value fromCharacteristic:BLE_HANDLE_GPS_INFO];
    else if ([[characteristic UUID] isEqual:BLE_HANDLE_CONF_GESTURE_UUID])[peripheralDelegate valueChanged:characteristic.value fromCharacteristic:BLE_HANDLE_CONF_GESTURE];
    else if ([[characteristic UUID] isEqual:BLE_HANDLE_CONF_WORLDCLOCK_0_UUID])[peripheralDelegate valueChanged:characteristic.value fromCharacteristic:BLE_HANDLE_CONF_WORLDCLOCK_0];
    else if ([[characteristic UUID] isEqual:BLE_HANDLE_CONF_WORLDCLOCK_1_UUID])[peripheralDelegate valueChanged:characteristic.value fromCharacteristic:BLE_HANDLE_CONF_WORLDCLOCK_1];
    else if ([[characteristic UUID] isEqual:BLE_HANDLE_CONF_WORLDCLOCK_2_UUID])[peripheralDelegate valueChanged:characteristic.value fromCharacteristic:BLE_HANDLE_CONF_WORLDCLOCK_2];
    else if ([[characteristic UUID] isEqual:BLE_HANDLE_CONF_WORLDCLOCK_3_UUID])[peripheralDelegate valueChanged:characteristic.value fromCharacteristic:BLE_HANDLE_CONF_WORLDCLOCK_3];
    else if ([[characteristic UUID] isEqual:BLE_HANDLE_CONF_WORLDCLOCK_4_UUID])[peripheralDelegate valueChanged:characteristic.value fromCharacteristic:BLE_HANDLE_CONF_WORLDCLOCK_4];
    else if ([[characteristic UUID] isEqual:BLE_HANDLE_CONF_WORLDCLOCK_5_UUID])[peripheralDelegate valueChanged:characteristic.value fromCharacteristic:BLE_HANDLE_CONF_WORLDCLOCK_5];
    else if ([[characteristic UUID] isEqual:BLE_HANDLE_CONF_WATCHFACE_UUID])[peripheralDelegate valueChanged:characteristic.value fromCharacteristic:BLE_HANDLE_CONF_WATCHFACE];
    else if ([[characteristic UUID] isEqual:BLE_HANDLE_CONF_GOALS_UUID])[peripheralDelegate valueChanged:characteristic.value fromCharacteristic:BLE_HANDLE_CONF_GOALS];
    else if ([[characteristic UUID] isEqual:BLE_HANDLE_CONF_USER_PROFILE_UUID])[peripheralDelegate valueChanged:characteristic.value fromCharacteristic:BLE_HANDLE_CONF_USER_PROFILE];
    else if ([[characteristic UUID] isEqual:BLE_HANDLE_CONF_ACTIVE_TIME_UUID])
        [peripheralDelegate valueChanged:characteristic.value fromCharacteristic:BLE_HANDLE_CONF_ACTIVE_TIME];
    
}

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
}


#pragma mark DATA-INTERFACE-READ

-(NSData*) readSportsGoal
{
    [self readKreyosfrom:BLE_HANDLE_CONF_GOALS];
    if(BLE_HANDLE_CONF_GOALS_CHARACTERISTIC)
    {
        short data8[3];
        [[BLE_HANDLE_CONF_GOALS_CHARACTERISTIC value] getBytes:&data8[0] length:sizeof(data8)];
        NSData* data = [NSData dataWithBytes:data8 length:sizeof(data8)];
        
        //NSLog(@"readSportsGoal data: %d, %d, %d", data8[0], data8[1], data8[2]);
        
        return data;
    }
    return nil;
}

-(NSData*) readSportsGrid
{
    [self readKreyosfrom:BLE_HANDLE_SPORTS_GRID];
    if(BLE_HANDLE_SPORTS_GRID_CHARACTERISTIC)
    {
        int8_t data8[4];
        [[BLE_HANDLE_SPORTS_GRID_CHARACTERISTIC value] getBytes:&data8[0] length:sizeof(data8)];
        NSData* data = [NSData dataWithBytes:data8 length:sizeof(data8)];
        //NSLog(@"readSportsGrid data: %d, %d, %d, %d", data8[0], data8[1], data8[2], data8[3]);
        return data;
    }
    return nil;
}

-(NSData*) readSportsData
{
    [self readKreyosfrom:BLE_HANDLE_SPORTS_DATA];
    if(BLE_HANDLE_SPORTS_DATA_CHARACTERISTIC)
    {
        int32_t data32[5];
        [[BLE_HANDLE_SPORTS_DATA_CHARACTERISTIC value] getBytes:data32 length:sizeof(data32)];
        NSData* data = [NSData dataWithBytes:data32 length:sizeof(data32)];
        //NSLog(@"readSportsData data: %d, %d, %d, %d, %d", data32[0],  data32[1],  data32[2],  data32[3],  data32[4] );
        
        return data;
    }
    
    return nil;
}

-(NSData*) readSportsDesc
{
    [self readKreyosfrom:BLE_HANDLE_SPORTS_DESC];
    if(BLE_HANDLE_SPORTS_DESC_CHARACTERISTIC)
    {
        int32_t data32[2];
        [[BLE_HANDLE_SPORTS_DESC_CHARACTERISTIC value] getBytes:&data32[0] length:sizeof(data32)];
        NSData* data = [NSData dataWithBytes:&data32 length:sizeof(data32)];
        //NSLog(@"readSportsDesc data: %d, %d", data32[0], data32[1]);
        return data;
    }
    
    NSLog(@"readSportsDesc nil");
    
    return nil;
}

-(NSData*)readGPSInfo
{
    [self readKreyosfrom:BLE_HANDLE_GPS_INFO];
    if(BLE_HANDLE_GPS_INFO_CHARACTERISTIC)
    {
        int32_t data32[4];
        [[BLE_HANDLE_GPS_INFO_CHARACTERISTIC value] getBytes:&data32[0] length:sizeof(data32)];
        NSData *data = [NSData dataWithBytes:&data32 length:sizeof(data32)];
        
       // NSLog(@"readGPSInfo data : %d, %d, %d, %d, ", data32[0], data32[1], data32[2], data32[3] );
        return  data;
        
    }
    
    return nil;
}


-(NSData*) readDeviceId
{
    [self readKreyosfrom:BLE_HANDLE_DEVICE_ID];
    if(BLE_HANDLE_DEVICE_ID_CHARACTERISTIC)
    {
        int32_t data32;
        [[BLE_HANDLE_DEVICE_ID_CHARACTERISTIC value] getBytes:&data32 length:sizeof(data32)];
        NSData* data = [NSData dataWithBytes:&data32 length:sizeof(data32)];
        return data;
    }
    return nil;
}


-(NSData*) readFileDesc
{
    [self readKreyosfrom:BLE_HANDLE_FILE_DESC];
    if(BLE_HANDLE_FILE_DESC_CHARACTERISTIC)
    {
        int8_t data8t[20];
        [[BLE_HANDLE_FILE_DESC_CHARACTERISTIC value] getBytes:&data8t length:sizeof(data8t)];
        NSData *data = [NSData dataWithBytes:&data8t length:sizeof(data8t)];
        return data;
    }
    
    return nil;
}


-(NSData*) readFileData
{
    [self readKreyosfrom:BLE_HANDLE_FILE_DATA];
    if(BLE_HANDLE_FILE_DATA_CHARACTERISTIC)
    {
        Byte data32[20];
        [[BLE_HANDLE_FILE_DATA_CHARACTERISTIC value] getBytes:&data32 length:sizeof(data32)];
        NSData *data = [NSData dataWithBytes:&data32 length:sizeof(data32)];
        
        return data;
    }
    
    return nil;
}

-(NSData*) readVersion
{
    [self readKreyosfrom:BLE_HANDLE_TEST_WRITE];
    if ( BLE_HANDLE_TEST_WRITE_CHARACTERISTIC)
    {
        int8_t versionData[20];
        
        [[BLE_HANDLE_TEST_WRITE_CHARACTERISTIC value] getBytes:&versionData length:sizeof(versionData)];
        NSData *data = [NSData dataWithBytes:&versionData length:sizeof(versionData)];
        
        return data;
    }
    
    return nil;
}

-(NSData*) readTotalHomeActivities
{
    [self readKreyosfrom:BLE_HANDLE_CONF_ACTIVE_TIME];
    if ( BLE_HANDLE_CONF_ACTIVE_TIME_CHARACTERISTIC )
    {
        int32_t totalHomeActivity[4];
        
        [[BLE_HANDLE_CONF_ACTIVE_TIME_CHARACTERISTIC value] getBytes:&totalHomeActivity length:sizeof(totalHomeActivity)];
        NSData *data = [NSData dataWithBytes:&totalHomeActivity length:sizeof(totalHomeActivity)];
        
        return data;
    }
    
    return nil;
}


#pragma mark DATA-INTERFACE-WRITE
- (void) writeData:(NSData*)value characterisc: (NSString*)cc
{
    [self writeKreyos:value toCharacteristic:cc];
}

-(void) writeTest:(int8_t)value
{
    [self writeData:[NSData dataWithBytes:&value length:sizeof(int8_t)] characterisc:BLE_HANDLE_TEST_READ];
}

-(void) writeDateTime:(int8_t)y month:(int8_t)mon day:(int8_t)d hour:(int8_t)h minutes:(int8_t)min seconds:(int8_t)sec
{
    
    int8_t data8[6];
    data8[0] = y;
    data8[1] = mon;
    data8[2] = d;
    data8[3] = h;
    data8[4] = min;
    data8[5] = sec;
    
    [self writeData:[NSData dataWithBytes:data8 length:sizeof(data8)] characterisc:BLE_HANDLE_DATETIME];
}

-(void) writeAlarm0:(int8_t)state hour:(int8_t)h minutes:(int8_t)min
{
    int8_t data8[3];
    data8[0] = state;
    data8[1] = h;
    data8[2] = min;
    
    
    [self writeData:[NSData dataWithBytes:data8 length:sizeof(data8)] characterisc:BLE_HANDLE_ALARM_0];
}
-(void) writeAlarm1:(int8_t)state hour:(int8_t)h minutes:(int8_t)min
{
    int8_t data8[3];
    data8[0] = state;
    data8[1] = h;
    data8[2] = min;
    
    
    [self writeData:[NSData dataWithBytes:data8 length:sizeof(data8)] characterisc:BLE_HANDLE_ALARM_1];
}
-(void) writeAlarm2:(int8_t)state hour:(int8_t)h minutes:(int8_t)min
{
    int8_t data8[3];
    data8[0] = state;
    data8[1] = h;
    data8[2] = min;
    
    
    [self writeData:[NSData dataWithBytes:data8 length:sizeof(data8)] characterisc:BLE_HANDLE_ALARM_2];
}


-(void) writeGpsInfo:(int32_t)v1 altitude:(int32_t)v2 distance:(int32_t)v3 reserved:(int32_t)v4
{
    int32_t data16[4];
    data16[0] = v1;
    data16[1] = v2;
    data16[2] = v3;
    data16[3] = v4;
    
    [self writeData:[NSData dataWithBytes:&data16[0] length:sizeof(data16)] characterisc:BLE_HANDLE_GPS_INFO];
}

-(void) writeGesture:(int8_t)v1 value2:(int8_t)v2 value3:(int8_t)v3 value4:(int8_t)v4 value5:(int8_t)v5
{
    int8_t data8[5];
    data8[0] = v1;
    data8[1] = v2;
    data8[2] = v3;
    data8[3] = v4;
    data8[4] = v5;
    
    
    [self writeData:[NSData dataWithBytes:data8 length:sizeof(data8)] characterisc:BLE_HANDLE_CONF_GESTURE];
}

-(void) writeWorldClock0:(NSString*)value
{
    [self writeData:[value dataUsingEncoding:NSUTF8StringEncoding] characterisc:BLE_HANDLE_CONF_WORLDCLOCK_0];
}

-(void) writeWorldClock1:(NSString*)value
{
    [self writeData:[value dataUsingEncoding:NSUTF8StringEncoding] characterisc:BLE_HANDLE_CONF_WORLDCLOCK_1];
}

-(void) writeWorldClock2:(NSString*)value
{
    [self writeData:[value dataUsingEncoding:NSUTF8StringEncoding] characterisc:BLE_HANDLE_CONF_WORLDCLOCK_2];
}

-(void) writeWorldClock3:(NSString*)value
{
    [self writeData:[value dataUsingEncoding:NSUTF8StringEncoding] characterisc:BLE_HANDLE_CONF_WORLDCLOCK_3];
}

-(void) writeWorldClock4:(NSString*)value
{
    [self writeData:[value dataUsingEncoding:NSUTF8StringEncoding] characterisc:BLE_HANDLE_CONF_WORLDCLOCK_4];
}

-(void) writeWorldClock5:(NSString*)value
{
    [self writeData:[value dataUsingEncoding:NSUTF8StringEncoding] characterisc:BLE_HANDLE_CONF_WORLDCLOCK_5];
}

-(void) writeWatchFace:(int8_t)v1 value2:(int8_t)v2
{
    int8_t data8[2];
    data8[0] = v1;
    data8[1] = v2;
    [self writeData:[NSData dataWithBytes:data8 length:sizeof(data8)] characterisc:BLE_HANDLE_CONF_WATCHFACE];
}

-(void) writeSportsGoals:(int16_t)v1 value2:(int16_t)v2 value3:(int16_t)v3
{
    int16_t data16[3];
    data16[0] = v1;
    data16[1] = v2;
    data16[2] = v3;
    
    KLog(@"DATA SPORTS GOAL : %i, %i, %i", data16[0], data16[1], data16[2] );
    
    [self writeData:[NSData dataWithBytes:&data16[0] length:sizeof(data16)] characterisc:BLE_HANDLE_CONF_GOALS];
}

-(void) writeUserProfile:(int8_t)v1 value2:(int8_t)v2
{
    int8_t data8[2];
    data8[0] = v1;
    data8[1] = v2;
    [self writeData:[NSData dataWithBytes:data8 length:sizeof(data8)] characterisc:BLE_HANDLE_CONF_USER_PROFILE];
}

-(void) writeSportsGrids:(int8_t)v1 value1:(int8_t)v2 value2:(int8_t)v3 value3:(int8_t)v4
{
    int8_t data8[4];
    data8[0] = v1;
    data8[1] = v2;
    data8[2] = v3;
    data8[3] = v4;
    [self writeData:[NSData dataWithBytes:data8 length:sizeof(data8)] characterisc:BLE_HANDLE_SPORTS_GRID];
}

@end
