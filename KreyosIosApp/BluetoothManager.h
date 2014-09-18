//
//  BluetoothManager.h
//  Xodee
//
//  Created by Michael Dautermann on 1/2/14.
//
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface BluetoothManager : NSObject <CBCentralManagerDelegate>
{
}

@property (strong) CBCentralManager *cbManager;

@property (retain, nonatomic) NSMutableArray *foundPeripheral;
@property (nonatomic, readwrite) NSMutableArray *btListDevices;
+ (BluetoothManager *)sharedInstance;


@end
