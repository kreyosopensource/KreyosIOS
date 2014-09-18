
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


/****************************************************************************/
/*						Service Characteristics								*/
/****************************************************************************/

extern NSString *kKreyosServiceUUIDString;

extern NSString *BLE_HANDLE_TEST_READ;
extern NSString *BLE_HANDLE_TEST_WRITE;
extern NSString *BLE_HANDLE_DATETIME;
extern NSString *BLE_HANDLE_ALARM_0;
extern NSString *BLE_HANDLE_ALARM_1;
extern NSString *BLE_HANDLE_ALARM_2;
extern NSString *BLE_HANDLE_SPORTS_GRID;
extern NSString *BLE_HANDLE_SPORTS_DATA;
extern NSString *BLE_HANDLE_SPORTS_DESC;
extern NSString *BLE_HANDLE_DEVICE_ID;
extern NSString *BLE_HANDLE_FILE_DESC;
extern NSString *BLE_HANDLE_FILE_DATA;
extern NSString *BLE_HANDLE_GPS_INFO;
extern NSString *BLE_HANDLE_CONF_GESTURE;
extern NSString *BLE_HANDLE_CONF_WORLDCLOCK_0;
extern NSString *BLE_HANDLE_CONF_WORLDCLOCK_1;
extern NSString *BLE_HANDLE_CONF_WORLDCLOCK_2;
extern NSString *BLE_HANDLE_CONF_WORLDCLOCK_3;
extern NSString *BLE_HANDLE_CONF_WORLDCLOCK_4;
extern NSString *BLE_HANDLE_CONF_WORLDCLOCK_5;
extern NSString *BLE_HANDLE_CONF_WATCHFACE;
extern NSString *BLE_HANDLE_CONF_GOALS;
extern NSString *BLE_HANDLE_CONF_USER_PROFILE;
extern NSString *BLE_HANDLE_CONF_ACTIVE_TIME;

extern NSString *kServiceEnteredBackgroundNotification;
extern NSString *kServiceEnteredForegroundNotification;
/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class LKreyosService;

@protocol KreyosProtocol<NSObject>
- (void) kreyosServiceDidChangeStatus:(LKreyosService*)service;
- (void) kreyosServiceDidReset;
- (void) valueChanged:(NSData*)value fromCharacteristic:(NSString *)characteristic;
@end


/****************************************************************************/
/*						Kreyos service.                                     */
/****************************************************************************/
@interface LKreyosService : NSObject
{
    // read from kreyos
}

- (id) initWithPeripheral:(CBPeripheral *)peripheral controller:(id<KreyosProtocol>)controller;
- (void) reset;
- (void) start;
- (void) renewConnection;

- (void) writeKreyos:(NSData *)valuex toCharacteristic:(NSString*)UUIDString;
- (void) readKreyosfrom:(NSString *)characteristic;

/* Behave properly when heading into and out of the background */
- (void)enteredBackground;
- (void)enteredForeground;

//getters
- (BOOL) hasValidCharacteristics;

//interfaces-read
-(NSData*) readDeviceId;
-(NSData*) readGPSInfo;
-(NSData*) readSportsGrid;
-(NSData*) readSportsData;
-(NSData*) readSportsDesc;
-(NSData*) readSportsGoal;
-(NSData*) readFileData;
-(NSData*) readFileDesc;
-(NSData*) readTestUnlock;
-(NSData*) readVersion;
-(NSData*) readTotalHomeActivities;

//interfaces-write
-(void) writeData:(NSData*)value characterisc: (NSString*)cc;
-(void) writeTest:(int8_t)value;
-(void) writeDateTime:(int8_t)y month:(int8_t)mon day:(int8_t)d hour:(int8_t)h minutes:(int8_t)min seconds:(int8_t)sec;
-(void) writeAlarm0:(int8_t)state hour:(int8_t)h minutes:(int8_t)min;
-(void) writeAlarm1:(int8_t)state hour:(int8_t)h minutes:(int8_t)min;
-(void) writeAlarm2:(int8_t)state hour:(int8_t)h minutes:(int8_t)min;
-(void) writeGpsInfo:(int32_t)v1 altitude:(int32_t)v2 distance:(int32_t)v3 reserved:(int32_t)v4;
-(void) writeGesture:(int8_t)v1 value2:(int8_t)v2 value3:(int8_t)v3 value4:(int8_t)v4 value5:(int8_t)v5;
-(void) writeWorldClock0:(NSString*)value;
-(void) writeWorldClock1:(NSString*)value;
-(void) writeWorldClock2:(NSString*)value;
-(void) writeWorldClock3:(NSString*)value;
-(void) writeWorldClock4:(NSString*)value;
-(void) writeWorldClock5:(NSString*)value;
-(void) writeWatchFace:(int8_t)v1 value2:(int8_t)v2;
-(void) writeSportsGoals:(int16_t)v1 value2:(int16_t)v2 value3:(int16_t)v3;
-(void) writeUserProfile:(int8_t)v1 value2:(int8_t)v2;
-(void) writeSportsGrids:(int8_t)v1 value1:(int8_t)v2 value2:(int8_t)v3 value3:(int8_t)v4;

@property (readonly) CBPeripheral *peripheral;
@property (readonly) CBPeripheralManager *peripheralManager;
@end
