//
//  BluetoothManager.m
//  Xodee
//
//  Created by Michael Dautermann on 1/2/14.
//
//

#import "BluetoothManager.h"

@interface BluetoothManager (Interface)

@end

@implementation BluetoothManager
@synthesize btListDevices;
@synthesize foundPeripheral;

+ (BluetoothManager *)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _bluetoothMGR = nil;
    
    dispatch_once(&pred, ^{
        _bluetoothMGR = [[BluetoothManager alloc] init];
    });
    
    return _bluetoothMGR;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        dispatch_queue_t centralQueue = dispatch_queue_create("com.yo.mycentral", DISPATCH_QUEUE_SERIAL);
        
        btListDevices = [[NSMutableArray alloc] init];
        foundPeripheral = [[NSMutableArray alloc] init];
    
        // whether we try this on a queue of "nil" (the main queue) or this separate thread, still not getting results
        self.cbManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue options:nil];
    }
    return self;
}

// this would hit.... if I instantiated this in a storyboard of XIB file
- (void)awakeFromNib
{
    
    if(!self.cbManager)
        self.cbManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    if( [foundPeripheral containsObject:peripheral] )
    {
        return;
    }
    
    NSLog(@"hey I found %@", peripheral);
    [foundPeripheral addObject:peripheral];
    [btListDevices addObject:advertisementData];
    
}
  

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    NSLog( @"I retrieved CONNECTED peripherals");
}

-(void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals{
    NSLog(@"This is it!");
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSString *messtoshow;
    
    switch (central.state) {
        case CBCentralManagerStateUnknown:
        {
            messtoshow=@"State unknown, update imminent.";
            break;
        }
        case CBCentralManagerStateResetting:
        {
            messtoshow=@"The connection with the system service was momentarily lost, update imminent.";
            break;
        }
        case CBCentralManagerStateUnsupported:
        {
            messtoshow=@"The platform doesn't support Bluetooth Low Energy";
            break;
        }
        case CBCentralManagerStateUnauthorized:
        {
            messtoshow=@"The app is not authorized to use Bluetooth Low Energy";
            break;
        }
        case CBCentralManagerStatePoweredOff:
        {
            messtoshow=@"Bluetooth is currently powered off.";
            break;
        }
        case CBCentralManagerStatePoweredOn:
        {
            messtoshow=@"Bluetooth is currently powered on and available to use.";
            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];

            [_cbManager scanForPeripheralsWithServices:nil options:options];
            
            break;
        }   
            
    }
    NSLog(@"%@", messtoshow);
}

@end
