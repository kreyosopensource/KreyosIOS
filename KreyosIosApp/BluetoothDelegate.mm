//
//  BluetoothDelegate.cpp
//  KreyosIosApp
//
//  Created by Kreyos on 7/14/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "BluetoothDelegate.h"
#import "GenericOverlay.h"
#import "Scheduler.h"
#import "SportsPageViewController.h"
#import "KreyosDataManager.h"
#import "KreyosUtility.h"
#import "AMSlideMenuMainViewController.h"


#include <vector>
#include <limits.h>


//#import "KreyosBluetoothViewController.h"
#pragma mark -
#pragma mark Wath's CONSTANTS
#define kMaxStepsPerMin 240
#define kMaxDistancePerMin 60000

//FILE DESC DATAS
const int8_t DATA_COL_INVALID = 0x00;
const int8_t DATA_COL_STEP    = 0x01;
const int8_t DATA_COL_DIST    = 0x02;
const int8_t DATA_COL_CALS    = 0x03;
const int8_t DATA_COL_CADN    = 0x04;
const int8_t DATA_COL_HR      = 0x05;
const int8_t DATA_COL_TIME    = 0x06;

//file transferring status flags
NSString* FS_IDLE          = @"FS_IDLE";
NSString* FS_INVESTIGATING = @"FS_INVESTIGATING";
NSString* FS_READING       = @"FS_READING";
NSString* FS_READING_DATA  = @"FS_READING_DATA";
NSString* FS_READING_PAUSE = @"FS_READING_PAUSE";
NSString* FS_FILE_FOUND    = @"FS_FILE_FOUND";
NSString* FS_READING_END   = @"FS_READING_END";

NSString* FS_WRITE         = @"FS_WRITE";
NSString* FS_WF_PREPARED   = @"FS_WF_PREPARED";
NSString* FS_SENDING       = @"FS_SENDING";
NSString* FS_SEND_OK       = @"FS_SEND_OK";

//sports data sync status
NSString* WS_IDLE    = @"IDLE";
NSString* WS_RUNNING = @"RUNNING";
NSString* WS_CYCLING = @"CYCLING";


#pragma mark -
#pragma mark Wath's global variables
int retryCount = 0;
int timerCount = 0;

//file transferring status machine
NSString*   fileDataStatus;
int8_t      readBlockId   = 0;
int8_t      fileDataFlag  = 0;
int16_t     fileBlockSize = 0;
int8_t      fileBlockId   = 0;
NSString*   fileName      = nil;

//firmware file desc
NSData* firmwareReader = nil;
int     firmwareReadCursor = 0;

//activity data buffer
NSMutableData* activityDataBuffer      = nil;
int            activityFileBlockCursor = 0;

//file transferring (firmware upgrading) configurations:
const int blockUnitSize = 80;
const int maxBlockSize  = 2000; //blockUnitSize * batchCount; //byte size of the chunk
const int maxRetryCountUpdateFirmware = 30;
//NSString* firmwareUrl   = @"https://kreyos-development.s3.amazonaws.com/mobile/firmware-20140409.bin";

//these 3 lines of integer are used for emulate gps info sent to watch
int32_t speedValue = 3000;
int32_t distanceValue = 3000;
int32_t altValue = 123;

//sports data sync status machine
NSString* sportsWatchStatus = nil;

//sports data sync configuration
const int sportsDataQueryInterval = 5;

//BOOLEANS
BOOL bIsReadingFile = false;

@interface BluetoothDelegate ()
{
    SportsPageViewController*       m_sportsViewController;
    KreyosBluetoothViewController*  m_blueToothController;
    BOOL                            m_didLogout;
    NSTimer*                        m_navControllerTimer;
    BOOL                            m_isUpdating;
    std::vector<SEL>                m_selector;
    UIBackgroundTaskIdentifier      backgroundTaskID;
    NSTimer*                        m_updateTimer;
}
@end

#pragma mark -
#pragma mark Bluetooth Event Handler Class
@implementation BluetoothDelegate
@synthesize isUpdating  = m_isUpdating;

#pragma mark -
#pragma mark Singleton
static BluetoothDelegate* singleInstance = nil;

+ (BluetoothDelegate*) instance
{
    if ( singleInstance == nil )
    {
        singleInstance = [[BluetoothDelegate alloc] init];
    }
    
    return singleInstance;
}

//*
#pragma mark -
#pragma mark Global Properties
@synthesize currentlyDisplayingService;
//@synthesize sensorsTable;
@synthesize firmwareURL;
@synthesize CurrentFirmwareVersion;
@synthesize connectedServices;
@synthesize connectedperipheral;
//@synthesize currentlyConnectedSensor;
//*/

#pragma mark -
#pragma mark Initialization
-(id)init
{
    if(self = [super init])
    {
        m_didLogout = NO;
        m_isUpdating = NO;
        
        [self startUpdate];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                         selector:@selector(cleanBluetoothDelegate)
                             name:USER_DID_LOG_OUT
                           object:nil];
    }
    return self;
}

- (void) initialize
{
    m_timerInterval         = INITIAL_FETCH_INTERVAL;
    CurrentFirmwareVersion  = kVersion;
    //Connected Services
    connectedServices       = [[NSMutableArray alloc] init];
    m_listeners             = [[NSMutableArray alloc] init];
    
    [[LkDiscovery sharedInstance] setDiscoveryDelegate:self];           // KreyosDiscoveryDelegate
    [[LkDiscovery sharedInstance] setPeripheralDelegate:self];          // KreyosProtocol
    
#ifndef EMULATOR_BUILD
    [[LkDiscovery sharedInstance] startScanningForUUIDString:kKreyosServiceUUIDString];
#endif
    
    // setup listener
    [m_distapcher addObserver:self
                     selector:@selector(didEnterBackgroundNotification:)
                         name:kServiceEnteredBackgroundNotification
                       object:nil];
    
    [m_distapcher addObserver:self
                     selector:@selector(didEnterForegroundNotification:)
                         name:kServiceEnteredForegroundNotification
                       object:nil];
    
    //initialize status machine
    fileDataStatus    = FS_IDLE;
    sportsWatchStatus = WS_IDLE;
    
    // get ref of Data Manager
    m_dataManager = [KreyosDataManager sharedInstance];
}

- (void) initService
{
    if ( currentlyDisplayingService == nil )
    {
        //currentlyDisplayingService = [self serviceForPeripheral:connectedperipheral];
        currentlyDisplayingService = [KreyosDataManager sharedInstance].DisplayingService;
        
        //UPDATE TIME: Note: updateTime should'nt be called when there are 'nil' Service Description
        [self updateTime];
        [self readActivityData];
        [self readHomeData];
        return;
    }
}

- (void) initTimer
{
    dispatch_async(dispatch_get_main_queue(), ^{
    if ( !m_fetchTimer )
    {
        m_fetchTimer = [Scheduler createTimer:self
                                     selector:@selector(fetchDataFromWatch:)
                                     interval:m_timerInterval];
        [m_fetchTimer fire];
    }
    });
}


- (void) initUpdateTimer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ( !m_fetchTimer )
        {
            m_fetchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(fetchDataFromWatch:) userInfo:nil repeats:YES];
            [m_fetchTimer fire];
        }
    });
}


- (void) stopTimer
{
    if ( m_fetchTimer )
    {
        [m_fetchTimer invalidate];
        m_fetchTimer = nil;
    }
    
    if ( reconnectionTimer )
    {
        [reconnectionTimer invalidate];
        reconnectionTimer = nil;
    }
}

- (void) startReconnectionTimer
{
    dispatch_async(dispatch_get_main_queue(), ^{
    if ( !reconnectionTimer )
    {
        reconnectionTimer = [Scheduler createReconnectionTimer:self
                                                      selector:@selector(tryReconnectWithThePrevious)
                                                      userInfo:[BluetoothDelegate instance].connectedperipheral];
    }
    });
}

#pragma mark -
#pragma mark Getter | Setter
- (void) setListener:(DELEGATE_CLASS*) p_listener
{
    if ( [m_listeners containsObject:p_listener] ) { return; }
    [m_listeners addObject:p_listener];
}

- (void) clearListener
{
    [m_listeners removeAllObjects];
}

- (void) setCurrentView:(UIViewController*)p_currentView
{
    m_currentView = p_currentView;
}

- (void) setSportViewController:(SportsPageViewController *)p_controller
{
    m_sportsViewController = p_controller;
    
    if(m_sportsViewController == nil)
    {
        sportsWatchStatus = WS_IDLE;
    }
}

-(void) setDidLogOut:(BOOL)p_bool
{
    m_didLogout = p_bool;
}

-(BOOL) getDidLogout
{
    return m_didLogout;
}

- (UIViewController*) getCurrentController
{
    return m_currentView;
}

#pragma mark -
#pragma mark Functionalities
- (void) stopScan
{
    //[self setCurrentlyConnectedSensor:nil];
    [self setConnectedServices:nil];
    [self setCurrentlyDisplayingService:nil];
    [self setConnectedperipheral:nil];
    [[LkDiscovery sharedInstance] stopScanning];
}

- (void) startScan
{
    [[LkDiscovery sharedInstance] startScanningForUUIDString:kKreyosServiceUUIDString];
    [self discoveryDidRefresh];
}

- (void) initializeFileTransistor
{
    int8_t flag = (int8_t)'X';
	NSMutableData  *data = [[NSMutableData alloc] init];
	[data appendBytes:&flag length:sizeof(flag)]; //append flag
    //write command to watch
    [[KreyosDataManager sharedInstance].DisplayingService writeKreyos:data toCharacteristic:BLE_HANDLE_FILE_DESC];
    retryCount = 0;
    fileDataStatus = FS_IDLE;
}

- (void) disconnect
{
    if ([BluetoothDelegate instance].connectedperipheral!=nil)
    {
        NSLog(@"Trying to disconnect this Kreyos");
        [[LkDiscovery sharedInstance] disconnectPeripheral:[BluetoothDelegate instance].connectedperipheral];
        //[self SetThisButton:m_disconnectBtn setTruFalse:false];
    }
}

- (void) conenctPeripheral:(CBPeripheral*)p_peripheral
{
    [[LkDiscovery sharedInstance] connectPeripheral:p_peripheral];
    /*
    [currentlyConnectedSensor setText:[NSString stringWithFormat: @"{%@}",[p_peripheral name]]];
    [currentlyConnectedSensor setEnabled:NO];
    //*/
    NSDictionary* userInfo = @{PERIPHERAL_KEY:[NSString stringWithFormat: @"{%@}",[p_peripheral name]]};
    [m_distapcher postNotificationName:UPDATE_CONNECTED_PERIPHERAL object:nil userInfo:userInfo];
    
    [BluetoothDelegate instance].currentlyDisplayingService  = [self serviceForPeripheral:p_peripheral];
    NSString *uuidString = [NSString stringWithFormat:@"%@", [[p_peripheral identifier] UUIDString]];
    
    [[NSUserDefaults standardUserDefaults] setObject:uuidString forKey:USERDEF_LASTDEVICE];
}

-(void) disconnectCheckSportsMode
{
    if (m_sportsViewController)
        [(SportsPageViewController*)m_currentView resetSportsPage];
}

#pragma mark Private Functionalities
- (void) writeFileDesc:(int8_t)flag blockId:(int8_t)block blockSize:(int16_t)size fileName:(NSString*)name
{
    NSMutableData  *data = [[NSMutableData alloc] init];
    [data appendBytes:&flag  length:sizeof(flag)];  //append flag
    [data appendBytes:&block length:sizeof(block)]; //append blockid
    [data appendBytes:&size  length:sizeof(size)];  //append size
    [data appendData:[name dataUsingEncoding:NSUTF8StringEncoding]]; //file name
    
    NSLog(@"WRITING FILE_DESC:Flag=%c, BlockId=%d, Size=%d, FileName=%@", flag, block, size, name);
    
    //write command to watch
    [[KreyosDataManager sharedInstance].DisplayingService writeKreyos:data toCharacteristic:BLE_HANDLE_FILE_DESC];
}

- (void) readActivityData
{
    //if( m_isUpdating ) { return; }
    
    LKreyosService* service = [KreyosDataManager sharedInstance].DisplayingService;
    
    if ( !service && ![service hasValidCharacteristics] ) { return; }
    
	if ( [fileDataStatus isEqual:FS_IDLE] )
    {
        [self writeFileDesc:'I' blockId:0 blockSize:0 fileName:fileName];
		fileDataStatus = FS_INVESTIGATING;
	}
	else if ( [fileDataStatus isEqual:FS_INVESTIGATING] )
    {
		if ( fileDataFlag == (int8_t)'F' )
        {
            activityDataBuffer = [[NSMutableData alloc] init];
            activityFileBlockCursor = 0;
            readBlockId = 0;
            
            [self writeFileDesc:'R' blockId:0 blockSize:0 fileName:fileName];
			fileDataStatus = FS_READING;
		}
        // Get Activity Data
		else if ( fileDataFlag == (int8_t)'N' )
        {
			fileDataStatus = FS_IDLE;
			return;
		}
        else { return; }
	}
    else if ([fileDataStatus isEqual:FS_READING]) {
    	if (fileDataFlag == (int8_t)'D') {
            
            //set status to FS_READING_DATA and wait the data read back
            fileDataStatus = FS_READING_DATA;
            
            //start a thread to read
            NSThread* worker = [[NSThread alloc]initWithTarget:self selector:@selector(readFileBlock) object:0];
            [worker start];
            return;
		}
		else if (fileDataFlag == (int8_t)'E') {
            
            [[BluetoothDelegate instance].currentlyDisplayingService readFileData];
            fileDataStatus = FS_READING_END;
            //NSLog(@"Data End: totally %zd bytes read", [activityDataBuffer length]);
            
            //[self parseActivityData:activityDataBuffer];
            
			//continue reading next file
            //[self writeFileDesc:'I' blockId:0 blockSize:0 fileName:fileName];
			//fileDataStatus = FS_INVESTIGATING;
		}
        else {
            return;
        }
    }
    else if ([fileDataStatus isEqual:FS_READING_DATA]) {
        if (fileDataFlag == (int8_t)'E') {
            [[BluetoothDelegate instance].currentlyDisplayingService readFileData];
            fileDataStatus = FS_READING_END;
			//TODO: the file is completed, save it and close file handle
            KLog(@"DONE READING MEN");
            
            
			//continue reading next file
            //[self writeFileDesc:'I' blockId:0 blockSize:0 fileName:fileName];
			//fileDataStatus = FS_INVESTIGATING;
		}
        else {
            return;
        }
    }
    else {
    	//all other status indicate error, reset status to idle
    	fileDataStatus = FS_IDLE;
    	return;
    }
}

- (void) readHomeData
{
    //~~~Block during updating
    if( m_isUpdating ) return;
    [[BluetoothDelegate instance].currentlyDisplayingService readTotalHomeActivities];
}

- (void) readFileBlock
{
    NSLog(@"readFileBlock:");
    for (int bytesRead = 0; bytesRead < fileBlockSize; bytesRead += 20) {
        [[BluetoothDelegate instance].currentlyDisplayingService readFileData];
        [NSThread sleepForTimeInterval:0.05];
    }
}

- (void) updateWatchFirmware
{
	NSString* filename = @"firmware";
    NSLog(@"LOG UPDATE FIRMWARE %@ , %hhd", fileDataStatus, fileDataFlag);
	if ([fileDataStatus isEqual:FS_IDLE])
    {
        retryCount = 0;
		int8_t flag = (int8_t)'W';
        
		//this the special case, no size and block id
		//write command to watch
		NSMutableData  *data = [[NSMutableData alloc] init];
		[data appendBytes:&flag length:sizeof(flag)];
		[data appendData:[filename dataUsingEncoding:NSUTF8StringEncoding]];
		//write command to watch
        
		[[BluetoothDelegate instance].currentlyDisplayingService writeKreyos:data toCharacteristic:BLE_HANDLE_FILE_DESC];
        NSLog(@"WRITING FILE_DESC:Flag=%c, Filename=%@", flag, filename);
        
		fileDataStatus = FS_WRITE;
        
        [[BluetoothDelegate instance].currentlyDisplayingService readFileDesc];
        return;
        
	}
	else if ([fileDataStatus isEqual:FS_WRITE])
    {
		if (fileDataFlag == (int8_t)'H')
        {
            retryCount = 0;
            fileBlockId = 0;
            
            //at this point initialize file reader and all other things
            if (firmwareReader == nil)
            {
                firmwareReader = [NSData dataWithContentsOfURL:[NSURL URLWithString:[BluetoothDelegate instance].firmwareURL]];
                firmwareReadCursor = 0;
            }
            
            int16_t size = 0;
			int32_t left_size = (u_int)[firmwareReader length] - firmwareReadCursor;
            if (left_size > maxBlockSize)
                size = maxBlockSize;
            else
                size = (int16_t)left_size;
            [self writeFileDesc:'S' blockId:0 blockSize:size fileName:filename];
            
			fileDataStatus = FS_WF_PREPARED;
            
            [[BluetoothDelegate instance].currentlyDisplayingService readFileDesc];
		}
        else if (fileDataFlag == (int8_t)'O')
        {
            fileDataStatus = FS_SENDING;
        }
		else if (retryCount > maxRetryCountUpdateFirmware)
        {
            NSLog(@"FS_WRITE Reached the retry count during the update..");
			fileDataStatus = FS_IDLE;
            [self initializeFileTransistor];
			return;
		}
	}
    else if ([fileDataStatus isEqual:FS_WF_PREPARED])
    {
    	if (fileDataFlag == (int8_t)'P')
        {
            retryCount = 0;
            //NSThread* worker = [[NSThread alloc]initWithTarget:self selector:@selector(sendFileBLock) object:0];
            //[worker start];
            [self sendFileBLock];
            [[BluetoothDelegate instance].currentlyDisplayingService readFileDesc];
            return;
		}
		else if (retryCount > maxRetryCountUpdateFirmware)
        {
            NSLog(@"FS_WF_PREPARED Reached the retry count during the update..");
			fileDataStatus = FS_IDLE;
            //~~~Note: Restart Everything here.
            [[BluetoothDelegate instance] initializeFileTransistor];
			return;
		}
    }
    else if ([fileDataStatus isEqual:FS_SENDING]) {
        
    	if (fileDataFlag == (int8_t)'O')
        {
            retryCount = 0;
			int32_t left_size = (u_int)[firmwareReader length] - firmwareReadCursor;
            NSLog(@"LeftSize=%d=%zd-%d", left_size, [firmwareReader length], firmwareReadCursor);
            if (left_size == 0)
            {
                //all data sent
                [self writeFileDesc:'C' blockId:0 blockSize:0 fileName:filename];
                fileDataStatus = FS_IDLE;
                
                KLog(@"END OF UPDATE2");
                NSDictionary *userInfo = nil;    // may be nil
                [m_distapcher postNotificationName:@"firmwareUpdate"
                                            object:nil
                                          userInfo:userInfo];
            }
            else
            {
                //calculate size
                int16_t size = 0;
                if (left_size > maxBlockSize)
                {
                    size = (int16_t)maxBlockSize;
                }
                else
                {
                    size = (int16_t)left_size;
                }
                
                //send next block
                [self writeFileDesc:'S' blockId:fileBlockId + 1 blockSize:size fileName:filename];
                fileDataStatus = FS_WF_PREPARED;
                [[BluetoothDelegate instance].currentlyDisplayingService readFileDesc];
                
            }
            
            
		}
        // This must be removed..
        //  Please debug more on this.. instead of using retry cound, try to use a timer to check for timeout.
		else if (retryCount > maxRetryCountUpdateFirmware)
        {
			fileDataStatus = FS_IDLE;
			return;
		}
    }
    else
    {
    	//all other status indicate error, reset status to idle
    	fileDataStatus = FS_IDLE;
    	return;
    }
    retryCount = retryCount + 1;
    //[currentlyDisplayingService readFileDesc];
}

- (void) parseActivityData:(NSData*)value
{
    NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    NSLog(@"KreyosBluetoothViewController::parseActivityData Parsing data from watch...");
    NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    
	int32_t cursor = 0;
	int32_t filelen = (int32_t)[value length];
    
	int32_t signature = 0;
    
	int8_t versoin = 0;
	int8_t year = 0;
    int8_t month = 0;
    int8_t day = 0;
    
    [value getBytes:&signature range:NSMakeRange(cursor, sizeof(signature))];
    cursor = cursor + sizeof(signature);
    
    [value getBytes:&versoin range:NSMakeRange(cursor, sizeof(versoin))];
    cursor = cursor + sizeof(versoin);
    
    [value getBytes:&year range:NSMakeRange(cursor, sizeof(year))];
    cursor = cursor + sizeof(year);
    
    [value getBytes:&month range:NSMakeRange(cursor, sizeof(month))];
    cursor = cursor + sizeof(month);
    
    [value getBytes:&day range:NSMakeRange(cursor, sizeof(day))];
    cursor = cursor + sizeof(day);
    
    //NSLog(@"KreyosBluetoothViewController::parseActivityData Version:%d, YY-MM-DD %d-%d-%d", versoin, year, month, day);
    
    NSMutableArray* _arrayActivity = [[NSMutableArray alloc] init];
    
    headerData = [[NSMutableArray alloc] init];
    [headerData addObject:[NSNumber numberWithInt:versoin]];
    [headerData addObject:[NSNumber numberWithInt:year]];
    [headerData addObject:[NSNumber numberWithInt:month]];
    [headerData addObject:[NSNumber numberWithInt:day]];
    
    passedData = [[NSMutableArray alloc] init];
    [passedData addObject:headerData];
    
    //NSLog(@"KreyosBluetoothViewController::parseActivityData passedData(ver:%@,yy:%@,mm:%@,dd:%@)", passedData[0][0], passedData[0][1], passedData[0][2], passedData[0][3]);
    
    int rowId = 0;
    while (cursor < filelen - 8)
    {
        
    	//read data row
        
    	int8_t mode = 0;
    	int8_t hour = 0;
    	int8_t minutes = 0;
    	int8_t slots = 0;
        
    	[value getBytes:&mode range:NSMakeRange(cursor, sizeof(mode))];
    	cursor = cursor + sizeof(mode);
        
    	[value getBytes:&hour range:NSMakeRange(cursor, sizeof(hour))];
    	cursor = cursor + sizeof(hour);
        
    	[value getBytes:&minutes range:NSMakeRange(cursor, sizeof(minutes))];
    	cursor = cursor + sizeof(minutes);
        
    	[value getBytes:&slots range:NSMakeRange(cursor, sizeof(slots))];
    	cursor = cursor + sizeof(slots);
        
        modeData = [[NSMutableArray alloc] init];
        [modeData addObject:[NSNumber numberWithShort:mode]];
        [modeData addObject:[NSNumber numberWithShort:hour]];
        [modeData addObject:[NSNumber numberWithShort:minutes]];
        [modeData addObject:[NSNumber numberWithShort:slots]];
        
        //NSLog(@"    ~~~~ ROW (Mode,Meta,Data)");
        //NSLog(@"KreyosBluetoothViewController::parseActivityData Row[%zd]: data(mode:%@,hr:%@,min:%@,slots:%@)", rowId, modeData[0], modeData[1], modeData[2], modeData[3]);
        
    	//read meta
    	int8_t dataType[8];
        int8_t dataTypePos = 0;
        
    	int8_t rawDataTypeBuf[4];
        [value getBytes:rawDataTypeBuf range:NSMakeRange(cursor, sizeof(rawDataTypeBuf))];
        cursor += 4;
        
    	for (int i = 0; i < 4; ++i)
        {
            
            int32_t intvalue = rawDataTypeBuf[i];
            intvalue = intvalue & 0x000000ff;
            
            int8_t left = intvalue >> 4;
            int8_t right = intvalue & 0x0f;
            
            if (left != 0) {
                dataType[dataTypePos] = left;
                dataTypePos++;
            }
            else {
                break;
            }
            if (right != 0) {
                dataType[dataTypePos] = right;
                dataTypePos++;
            }
            else {
                break;
            }
        }
        
        BOOL bIsNotCorrupted = ( slots == dataTypePos );
        NSAssert( bIsNotCorrupted, @"The data is Corrupted" );
        //if ( !bIsNotCorrupted)return;
        
        //NSLog(@"Activity: Row[%zd]: Meta: %d, %d, %d", rowId, dataType[0], dataType[1], dataType[2]);
        //NSLog(@"    ~~~~ META");
        //NSLog(@"KreyosBluetoothViewController::parseActivityData Row[%zd]: type(%d,%d,%d)", rowId, dataType[0], dataType[1], dataType[2]);
        
    	//read data
    	int32_t dataValue[8];
        int8_t dataValuePos = 0;
    	for (int i = 0; i < slots; ++i) {
    		int32_t intvalue = 0;
            
    		[value getBytes:&intvalue range:NSMakeRange(cursor, sizeof(intvalue))];
    		cursor = cursor + sizeof(intvalue);
            
			dataValue[dataValuePos] = intvalue;
            dataValuePos++;
		}
        
        //NSLog(@"Activity: Row[%zd]: Data: %d, %d, %d", rowId, dataValue[0], dataValue[1], dataValue[2]);
        //NSLog(@"    ~~~~ DATA");
        //NSLog(@"KreyosBluetoothViewController::parseActivityData Row[%zd]: value(%d,%d,%d)", rowId, dataValue[0], dataValue[1], dataValue[2]);
        rowId++;
        
		//now the data array and meta array stored the data type and the value
		//for exampe:
		//metaArray = [DATA_COL_STEP, DATA_COL_DIST, DATA_COL_CAL]
		//dataArray = [50 steps,      7500 cm,       60 cals]
        
        [passedData addObject:modeData];
        [passedData addObject:[NSArray arrayWithObjects:
                               [NSNumber numberWithShort:dataType[0]],
                               [NSNumber numberWithShort:dataType[1]],
                               [NSNumber numberWithShort:dataType[2]],
                               [NSNumber numberWithShort:dataType[3]],
                               [NSNumber numberWithShort:dataType[4]],nil]];
        
        NSMutableArray *dataArray = [[NSMutableArray alloc] init];
        [dataArray addObject:[NSNumber numberWithShort:dataValue[0]]];
        [dataArray addObject:[NSNumber numberWithShort:dataValue[1]]];
        [dataArray addObject:[NSNumber numberWithShort:dataValue[2]]];
        [dataArray addObject:[NSNumber numberWithShort:dataValue[3]]];
        [dataArray addObject:[NSNumber numberWithShort:dataValue[4]]];
        [dataArray addObject:[NSNumber numberWithShort:dataValue[5]]];
        [dataArray addObject:[NSNumber numberWithShort:dataValue[6]]];
        [dataArray addObject:[NSNumber numberWithShort:dataValue[7]]];
        
        
        //NSLog(@"PASSED DATA VAL :::: , %@", dataArray);
        
        [passedData addObject:dataArray];
        
        // +AS:
        for(int x=0; x < 30; x++ )
        {
            [_arrayActivity addObject:[NSNumber numberWithInt:0]];
        }
        
        //Save Mode to DB
        [_arrayActivity replaceObjectAtIndex:(int)ACTIVITY_SPORT_ID withObject:[NSNumber numberWithInt:mode]];
        
        NSDateFormatter *dateFormat;
        dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [dateFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSDate *date = [dateFormat dateFromString: [NSString stringWithFormat:@"%i-%i-%i %d:%d", 2000+year,month,day,hour, minutes]];
        
        int timestamp = [date timeIntervalSince1970];
        
        [_arrayActivity replaceObjectAtIndex:(int)ACTIVITY_CREATED_TIME withObject:[NSNumber numberWithInt:timestamp]];
        
        short indexToReplace = 0;
        BOOL isCorruptData = NO;
        
        if ( year   != 0
        &&   month  != 0
        &&   day    != 0
        &&   hour   != 0 )
        {
            for (unsigned int actv = 0; actv < [passedData[2] count]; actv++)
            {
                int indexUseFromMeta = [[[passedData objectAtIndex:2] objectAtIndex:actv] intValue];
                
                switch (indexUseFromMeta)
                {
                    case DATA_COL_INVALID:
                        
                        indexToReplace = 0;
                        
                        break;
                    case DATA_COL_STEP:
                        
                        indexToReplace = (int)ACTIVITY_STEPS;
                        //isCorruptData = (BOOL)[self isDataValidForSaving:DATA_COL_STEP withData:[[dataArray objectAtIndex:actv]  intValue]];
                        
                        break;
                    case DATA_COL_DIST:
                        
                        indexToReplace = (int)ACTIVITY_DISTANCE;
                        //isCorruptData = (BOOL)[self isDataValidForSaving:DATA_COL_DIST withData:[[dataArray objectAtIndex:actv]  intValue]];
                        
                        break;
                    case DATA_COL_CALS:
                        
                        indexToReplace  = (int)ACTIVITY_CALORIES;
                        //isCorruptData   = (BOOL)[self isDataValidForSaving:DATA_COL_CALS withData:[[dataArray objectAtIndex:actv]  intValue]];
                        
                        break;
                    case DATA_COL_HR:
                        
                        indexToReplace = (int)ACTIVITY_HEART;
                        
                        break;
                    case DATA_COL_CADN:
                        
                        indexToReplace = (int)ACTIVITY_PACE;
                        
                        break;
                    default:
                        indexToReplace = 0;
                        break;
                }
                
                if(isCorruptData)
                {
                    break;
                }
                
                if(indexToReplace)
                {
                    //NSLog(@"KreyosBluetoothViewController::parseActivityData indexToReplace:%i :: withObject %@ ",indexToReplace, [NSNumber numberWithInt:[[dataArray objectAtIndex:actv]  intValue]]);
                    [_arrayActivity replaceObjectAtIndex:indexToReplace withObject:[NSNumber numberWithInt:[[dataArray objectAtIndex:actv]  intValue]]];
                }
            }
            
            // +AS:07232014 Cache Home Activities came from watch
            
            ActivityObject act  = [[DBManager getSharedInstance] FromData:_arrayActivity];
            if (act.sportID != 0)
            {
                NSLog(@"");
            }
            
            if ( (BOOL)[self isDataValidForSaving:DATA_COL_STEP withActObj:act]     ||
                 (BOOL)[self isDataValidForSaving:DATA_COL_DIST withActObj:act]     ||
                 (BOOL)[self isDataValidForSaving:DATA_COL_CALS withActObj:act]
                )
            {
                isCorruptData = YES;
            }


            if ( !isCorruptData )
            {
                [[DBManager getSharedInstance] recordHomeActivity:_arrayActivity];
            }
            
            isCorruptData = NO;
        }
    }
    
    // +AS:07232014 Reload Overall Activity Screen
    [m_distapcher postNotificationName:RELOAD_OVERALL_ACTIVITIES
                                object:nil];
}

- (void) sendFileBLock
{
    backgroundTaskID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void)
    {
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskID];
        backgroundTaskID = UIBackgroundTaskInvalid;
    }];
    
    NSLog(@"Send Data Blocks");
    int8_t count = 0;
    for (int32_t cursor = 0; cursor < maxBlockSize; cursor += blockUnitSize)
    {
        int8_t block[blockUnitSize];
        int8_t sid[1];
        sid[0]              = count;
        NSInteger blocksize = [firmwareReader length] - firmwareReadCursor;
        if (blocksize == 0)
        {
            //file end send end flag
            [self writeFileDesc:'C' blockId:0 blockSize:0 fileName:fileName];
            fileDataStatus = FS_IDLE;
            
            KLog(@"END OF UPDATE");
            
            [self updateFirmwareDidFinished];
            
            break;
        }
        else if (blocksize > sizeof(block))
        {
            blocksize = sizeof(block);
        }
        
        [firmwareReader getBytes:block range:NSMakeRange(firmwareReadCursor, blocksize)];
        firmwareReadCursor += blocksize;
        
        NSMutableData  *dummyData = [[NSMutableData alloc] init];
        [dummyData appendBytes:sid length:1];
        [dummyData appendBytes:block length:blocksize];
        [[BluetoothDelegate instance].currentlyDisplayingService writeKreyos:dummyData toCharacteristic:BLE_HANDLE_FILE_DATA];
        NSLog(@"WRITING FILE_DATA:BlockId=%u, SID=%i, Size=%zd", fileBlockId, count, blocksize);
        
        count++;
        fileDataStatus = FS_SENDING;
        [NSThread sleepForTimeInterval:0.2];
    }
}

#pragma mark - 
#pragma mark Read / Write
-(void) doWrite:(NSData*)dataValue forCharacteristics:(NSString*)characteristic
{
    
    if ( [BluetoothDelegate instance].connectedperipheral == nil) return;
    
    NSLog(@"Write Characteristices %@", characteristic);
    
    NSData  *data	= nil;
    
    if ([characteristic isEqual:BLE_HANDLE_TEST_READ]) {
        
        data = [NSData dataWithBytes:&dataValue length:sizeof (dataValue)];
    }
    else if ([characteristic isEqual:BLE_HANDLE_TEST_WRITE]) {
    
        data = [NSData dataWithBytes:&dataValue length:sizeof (dataValue)];
        
    }
    else if ([characteristic isEqual:BLE_HANDLE_DATETIME]) {
    
        data = [NSData dataWithBytes:&dataValue length:sizeof (dataValue)];
    }
    else if ([characteristic isEqual:BLE_HANDLE_ALARM_0]) {
        NSLog(@"ALARM SET 0");
    }
    else if ([characteristic isEqual:BLE_HANDLE_ALARM_1]) {
        NSLog(@"ALARM SET 1");
    }
    else if ([characteristic isEqual:BLE_HANDLE_ALARM_2]) {
        NSLog(@"ALARM SET 2");
    }
    else if ([characteristic isEqual:BLE_HANDLE_SPORTS_GRID]) {
        
        data = dataValue;
    }
    else if ([characteristic isEqual:BLE_HANDLE_SPORTS_DATA]) {
    }
    else if ([characteristic isEqual:BLE_HANDLE_SPORTS_DESC]) {
    }
    else if ([characteristic isEqual:BLE_HANDLE_DEVICE_ID]) {
    }
    else if ([characteristic isEqual:BLE_HANDLE_FILE_DESC]) {
        
        //int8_t fileDescFlag = (int8_t)dataValue;
        //data = [NSData dataWithBytes:&fileDescFlag length:sizeof (fileDescFlag)];
        
    }
    else if ([characteristic isEqual:BLE_HANDLE_FILE_DATA]) {
    }
    else if ([characteristic isEqual:BLE_HANDLE_GPS_INFO]) {
    }
    else if ([characteristic isEqual:BLE_HANDLE_CONF_GESTURE]) {
    }
    else if ([characteristic isEqual:BLE_HANDLE_CONF_WORLDCLOCK_0]) {
    }
    else if ([characteristic isEqual:BLE_HANDLE_CONF_WORLDCLOCK_1]) {
    }
    else if ([characteristic isEqual:BLE_HANDLE_CONF_WORLDCLOCK_2]) {
    }
    else if ([characteristic isEqual:BLE_HANDLE_CONF_WORLDCLOCK_3]) {
    }
    else if ([characteristic isEqual:BLE_HANDLE_CONF_WORLDCLOCK_4]) {
    }
    else if ([characteristic isEqual:BLE_HANDLE_CONF_WORLDCLOCK_5]) {
    }
    else if ([characteristic isEqual:BLE_HANDLE_CONF_WATCHFACE]) {
    }
    else if ([characteristic isEqual:BLE_HANDLE_CONF_GOALS]) {
    }
    else if ([characteristic isEqual:BLE_HANDLE_CONF_USER_PROFILE]) {
    }
    //***End***//
    
    [currentlyDisplayingService writeKreyos:data toCharacteristic:characteristic];
}

-(void) updateTime
{
    //ReadData once connected
    [self initializeFileTransistor];
    [self readActivityData];
    
    [currentlyDisplayingService writeTest:(int8_t)1];
    
    // +AS:07172014 Please remove this.
    //SAVE DISPLAYING SERVICE AS CURRENTLYDISPLAYINGSERVICE
    //[KreyosDataManager sharedInstance].DisplayingService = [BluetoothDelegate instance].currentlyDisplayingService;
    
    CFGregorianDate currentDate = CFAbsoluteTimeGetGregorianDate(CFAbsoluteTimeGetCurrent(), CFTimeZoneCopySystem());
    
    [currentlyDisplayingService writeDateTime:(int8_t)(currentDate.year - 2000)
                                        month:(int8_t)currentDate.month - 1
                                          day:(int8_t)currentDate.day
                                         hour:(int8_t)currentDate.hour
                                      minutes:(int8_t)currentDate.minute
                                      seconds:(int8_t)currentDate.second];
    
    
    //WRITE GESTURE TEST
    [currentlyDisplayingService writeGesture:(int8_t)1
                                      value2:(int8_t)1
                                      value3:(int8_t)3
                                      value4:(int8_t)6
                                      value5:(int8_t)7];
}

-(NSData*) doRead:(NSString*)p_bleKey
{
    [[BluetoothDelegate instance].currentlyDisplayingService readKreyosfrom:p_bleKey];
    return  nil;
}

- (IBAction)scan:(id)sender {
#ifdef __i386__
    NSLog(@"SIMULATOR MODE");
#else
    [[LkDiscovery sharedInstance] startScanningForUUIDString:kKreyosServiceUUIDString];
    [self discoveryDidRefresh];
#endif
}



#pragma mark -
#pragma mark Lkreyos Interactions
- (LKreyosService*) serviceForPeripheral:(CBPeripheral *)peripheral
{
    for ( LKreyosService *service in connectedServices )
    {
        if ( [[service peripheral] isEqual:peripheral] ) {
            return service;
        }
    }
    return nil;
}

#pragma mark -
#pragma mark Callbacks
- (void) fetchDataFromWatch:(NSTimer *)p_timer
{
    //NSLog(@"BluetoothDelegate::fetchDataFromWatch");
    
    //~~~block here
    if ( ![[LkDiscovery sharedInstance] hasValidCharacteristics] )
    {
        NSLog(@"BluetoothDelegate::fetchDataFromWatch BLOCKED");
        
        return;
    }
    
    if(m_isUpdating)
    {
        [self invokeMethod];
        NSLog(@"UPDATING FIRMWARE: ret count:%i",retryCount);
        if (![fileDataStatus isEqual:FS_WRITE] || ![fileDataStatus isEqual:FS_WF_PREPARED] || ![fileDataStatus isEqual:FS_SENDING] || ![fileDataStatus isEqual:FS_SEND_OK])
            //if ([fileDataStatus isEqual:FS_IDLE] || [fileDataStatus isEqual:FS_INVESTIGATING])
        {
            [self addFirmwareCallWithPriority:NO];
        }
        return;
    }
    
    //~~~Moved the initialization of service to a seperate method.
    [self initService];
    
    timerCount++;
    NSLog(@"Timer Triggered[%i]:sportsWatchStatus = %@, fileDataStatus=%@", timerCount , sportsWatchStatus, fileDataStatus);
    
    if (sportsWatchStatus)
    {
        if ([sportsWatchStatus isEqual:WS_IDLE] && (timerCount % sportsDataQueryInterval) == 0) {
            [currentlyDisplayingService readSportsDesc];
        }
        else if ([sportsWatchStatus isEqual:WS_RUNNING] || [sportsWatchStatus isEqual:WS_CYCLING]) {
            [currentlyDisplayingService readSportsDesc];
        }
    }
    
    if (fileDataStatus)
    {
        if (![fileDataStatus isEqual:FS_IDLE])
        {
            [currentlyDisplayingService readFileDesc];
        }
    }
    
    // reset timer after 30 sec. put back to 20
    // test
    //*
    if ( timerCount >= RESET_TIMER_CAP
    &&   m_timerInterval == INITIAL_FETCH_INTERVAL
    ) {
        m_timerInterval = DEFAULT_FETCH_INTERVAL;
        [m_fetchTimer invalidate];
        m_fetchTimer = nil;
        [self initTimer];
    }
    //*/
}

- (void)didEnterBackgroundNotification:(NSNotification*)notification
{
    NSLog(@"Entered background notification called.");
    for (LKreyosService *service in connectedServices) {
        [service enteredBackground];
    }
}

- (void)didEnterForegroundNotification:(NSNotification*)notificationuu
{
    NSLog(@"Entered foreground notification called.");
    for (LKreyosService *service in connectedServices) {
        [service enteredForeground];
    }
}

#pragma mark -
#pragma mark KreyosDiscoveryDelegate Methods
- (void) discoveryDidRefresh
{
    // Don't need this. please adjust
    /*
    for ( DELEGATE_CLASS* del in m_listeners )
    {
        [del discoveryDidRefresh];
    }
    //*/
    [m_distapcher postNotificationName:REFRESH_DEVICE_DISCOVERIES object:nil];
}

- (void) discoveryStatePoweredOff
{
    // Don't need this. please adjust
    /*
    for ( DELEGATE_CLASS* del in m_listeners )
    {
        [del discoveryStatePoweredOff];
    }
    //*/
    [m_distapcher postNotificationName:BLUETOOTH_POWER_WARNING object:nil];
}

- (void) tryReconnectWithThePrevious
{
    if ([KreyosDataManager sharedInstance].HasConnectedDevice)return;
    //~~~Test reconnection
    if ( [[NSUserDefaults standardUserDefaults] objectForKey:USERDEF_LASTDEVICE] )
    {
        NSString* peripheralID;
        peripheralID = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEF_LASTDEVICE];
        [[LkDiscovery sharedInstance] retrievePeripheral:peripheralID];
    }
}

- (void) tryToConnect
{
    LkDiscovery* lkd = [LkDiscovery sharedInstance];
    for (CBPeripheral* peripheral in [lkd previouslyConnectedPeripherals])
    {
        if (![peripheral isConnected])
        {
            [lkd connectPeripheral:peripheral];
            
            //NSString* stringName =[NSString stringWithFormat: @"{%@}",[peripheral name]];
            
            NSString *uuidString = [NSString stringWithFormat:@"%@", [[peripheral identifier] UUIDString]];
            [[NSUserDefaults standardUserDefaults] setObject:uuidString forKey:USERDEF_LASTDEVICE];
 
            break;
        }
    }
}

#pragma mark -
#pragma mark KreyosProtocol Methods
- (void) kreyosServiceDidChangeStatus:(LKreyosService*)service
{
    BluetoothDelegate* delegate = [BluetoothDelegate instance];
    if ( [[service peripheral] isConnected] )
    {
        NSLog(@"Service (%@) connected", service.peripheral.name);
        
        if ( ![delegate.connectedServices containsObject:service] )
        {
            [delegate.connectedServices addObject:service];
          
            delegate.connectedperipheral                            = service.peripheral;
            [KreyosDataManager sharedInstance].HasConnectedDevice   = true;

            [m_distapcher postNotificationName:@"connectedToKreyos"
                                        object:nil];
        }
        
        //~~~Clear db data here
        NSString* uuidString = [NSString stringWithFormat:@"%@", [[[service peripheral] identifier] UUIDString]];
        NSString* prevDevice = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEF_LASTDEVICE];
        
        if ((!uuidString || !prevDevice) ||                 //~~~Either if one of them is null clear
            ![uuidString isEqualToString:prevDevice])       //   Not equal to previous device clear activities
        {
            [[DBManager getSharedInstance] clearHomeActivities];
        }
        
        //~~~Read total home data. STEPS, DISTANCE and CALORIES
        //~~~initTimer is moved at valueChanged ACTIVE_TIME
        //[self readHomeData];
        
        //~~~Init global timer after the Home Data are Fetched.
        //~~~Fire interval checking for bluetooth data
        [self initTimer];
        
        //~~~Invalidate reconnection timer has device connected
        [reconnectionTimer invalidate];
        reconnectionTimer = nil;
        
    }
    else if ( [KreyosDataManager sharedInstance].HasConnectedDevice )
    {
        NSLog(@"Service (%@) disconnected", service.peripheral.name);
    
        //~~~Has connected device to false
        [KreyosDataManager sharedInstance].HasConnectedDevice = false;
        
        //~~~Start Reconnection Timer
        [self startReconnectionTimer];
    
        //~~~Invalidate Timer
        //   No need to fetch data device id disconected
        [m_fetchTimer invalidate];
        m_fetchTimer = nil;
        
        //~~~If disconected need to clean the current reference for Service
        currentlyDisplayingService = nil;
        
        // +AS:07142014 Nullify the service here
        service = nil;
        
        
        [self disconnectCheckSportsMode];
    }
    else
    {
        //~~~Note:  You need to clean services in state logout
        if(m_didLogout)
        {
            currentlyDisplayingService  = nil;
            service                     = nil;
            m_didLogout                 = NO;
        }
    }
    
    NSDictionary *userInfo = nil;    // may be nil
    [m_distapcher postNotificationName:CHANGE_TOPBAR_COLOR
                                object:nil
                              userInfo:userInfo];
}

- (void) kreyosServiceDidReset
{
    for ( DELEGATE_CLASS* del in m_listeners )
    {
        [del kreyosServiceDidReset];
    }
}

- (void) valueChanged:(NSData*)value
   fromCharacteristic:(NSString*)characteristic
{
    // Don't need this. please adjust
    /*
    for ( DELEGATE_CLASS* del in m_listeners )
    {
        [del valueChanged:value fromCharacteristic:characteristic];
    }
    //*/
    
    KreyosDataManager* mKreyosDataMangr = [KreyosDataManager sharedInstance];
    
    NSLog(@"BLE Value Read:%@ Value:+%@", characteristic, value);
    
    if ([characteristic isEqual:BLE_HANDLE_TEST_READ]) {
        int8_t i;
        [value getBytes: &i length: sizeof(i)];
        
    }
    else if ([characteristic isEqual:BLE_HANDLE_TEST_WRITE])
    {
        NSString *dataValue = nil;
        dataValue = [NSString stringWithUTF8String:(const char*)[value bytes]];
        
        NSLog(@"FIRMWARE VER : %@", dataValue);
        
        [KreyosDataManager sharedInstance].FirmwareVersion = dataValue;
        
        NSDictionary *userInfo = nil;    // may be nil
        [m_distapcher postNotificationName:@"firmwareVersion"
                                    object:nil
                                  userInfo:userInfo];
    }
    else if ([characteristic isEqual:BLE_HANDLE_DATETIME]) {
        int8_t i[6];
        [value getBytes: &i length: sizeof(i)];
    }
    else if ([characteristic isEqual:BLE_HANDLE_ALARM_0]) {
        int8_t i[3];
        [value getBytes: &i length: sizeof(i)];
    }
    else if ([characteristic isEqual:BLE_HANDLE_ALARM_1]) {
        int8_t i[3];
        [value getBytes: &i length: sizeof(i)];
    }
    else if ([characteristic isEqual:BLE_HANDLE_ALARM_2]) {
        int8_t i[3];
        [value getBytes: &i length: sizeof(i)];
    }
    else if ([characteristic isEqual:BLE_HANDLE_SPORTS_GRID]) {
        int8_t i[4];
        [value getBytes: &i length: sizeof(i)];
        NSLog(@"GRID DATA : <%@>:%d", characteristic, i[0] );
        NSLog(@"GRID DATA : <%@>:%d", characteristic, i[1] );
        NSLog(@"GRID DATA : <%@>:%d", characteristic, i[2] );
        NSLog(@"GRID DATA : <%@>:%d", characteristic, i[3] );
    }
    else if ([characteristic isEqual:BLE_HANDLE_SPORTS_DATA]) {
        if ([sportsWatchStatus isEqual:WS_RUNNING]
            || [sportsWatchStatus isEqual:WS_CYCLING]) {
            int32_t i[5];
            [value getBytes: &i length: sizeof(i)];
            NSLog(@"SPORTS DATA : <%@>:%d", characteristic, i[0] );
            NSLog(@"SPORTS DATA : <%@>:%d", characteristic, i[1] );
            NSLog(@"SPORTS DATA : <%@>:%d", characteristic, i[2] );
            NSLog(@"SPORTS DATA : <%@>:%d", characteristic, i[3] );
            NSLog(@"SPORTS DATA : <%@>:%d", characteristic, i[4] );
            
            if (m_sportsViewController)
            {
                [m_sportsViewController updateWorkOutData:i];
            }
        }
    }
    else if ([characteristic isEqual:BLE_HANDLE_SPORTS_DESC]) {
        int32_t i[2];
        [value getBytes: &i length: sizeof(i)];
        NSLog(@"SPORTS DESC : <%@>:%d", characteristic, i[0] );
        NSLog(@"SPORTS DESC : <%@>:%d", characteristic, i[1] );
        
        if (i[0] == 1)
        {
            distanceValue = 0;
            //[currentlyDisplayingService writeGpsInfo:speedValue altitude:altValue distance:distanceValue reserved:0];
            
            if (![mKreyosDataMangr IsWorkoutMode])
            {
                [[AMSlideMenuMainViewController getInstanceForVC:m_currentView] openContentViewControllerForSports:self];
                //[m_distapcher postNotificationName:OPEN_VC_FOR_SPORTS object:nil];
                mKreyosDataMangr.IsWorkoutMode = YES;
            }
            
            [[BluetoothDelegate instance].currentlyDisplayingService readSportsData];
//            [[SportsPageViewController sharedInstance] updateTimer:0];
            if (m_sportsViewController)
            {
                [m_sportsViewController updateTimer:0];
            }
        }
        else if (i[0] == 2)
        {
            //[currentlyDisplayingService writeGpsInfo:speedValue altitude:altValue distance:distanceValue reserved:0];
            NSLog(@"Send GPS Info : %d, %d, %d", speedValue, altValue, distanceValue);
            
            if (![mKreyosDataMangr IsWorkoutMode])
            {
                [[AMSlideMenuMainViewController getInstanceForVC:m_currentView] openContentViewControllerForSports:self];
                //[m_distapcher postNotificationName:OPEN_VC_FOR_SPORTS object:nil];
                mKreyosDataMangr.IsWorkoutMode = YES;
            }
            
            [[BluetoothDelegate instance].currentlyDisplayingService readSportsData];
            //[[SportsPageViewController sharedInstance] updateTimer:0];
            
            if (m_sportsViewController)
            {
                [m_sportsViewController updateTimer:0];
            }
        }
        else
        {
//            [[SportsPageViewController sharedInstance] updateTimer:1];
            if (m_sportsViewController)
            {
                [m_sportsViewController updateTimer:1];
            }
            
            mKreyosDataMangr.IsWorkoutMode = NO;
        }
        
        //Change Activity ICON on sports page
//        [[SportsPageViewController sharedInstance] changeActivity:i[1]];
        
        if (m_sportsViewController)
        {
            [m_sportsViewController changeActivity:i[1]];
        }
        
        //CHANGE WORKOUT
        int sportsSelected = i[1];
        [KreyosDataManager sharedInstance].WorkModeType = sportsSelected;
        
        if (sportsSelected == 0)
        {
            sportsWatchStatus = WS_IDLE;
        }
        else if ( sportsSelected == 1 )
        {
            sportsWatchStatus = WS_RUNNING;
        }
        else if ( sportsSelected == 2 )
        {
            sportsWatchStatus = WS_CYCLING;
        }
        
        if(m_sportsViewController)
        {
            //~~~Update view depending of the workmode type
            
            [m_sportsViewController initCell];
        }
        
    }
    else if ([characteristic isEqual:BLE_HANDLE_DEVICE_ID]) {
        int32_t i;
        [value getBytes: &i length: sizeof(i)];
    }
    else if ([characteristic isEqual:BLE_HANDLE_FILE_DESC]) {
        
        //the flag to control flow
        
        int8_t  cursor  = 0;
        int8_t  flag    = 0;
        int8_t  blockid = 0;
        int16_t size    = 0;
        NSString* filename = nil;
        
        [value getBytes:&flag range:NSMakeRange(cursor, sizeof(flag))];
        cursor = cursor + sizeof(flag);
        
        [value getBytes:&blockid range:NSMakeRange(cursor, sizeof(blockid))];
        cursor = cursor + sizeof(blockid);
        
        [value getBytes:&size range:NSMakeRange(cursor, sizeof(size))];
        cursor = cursor + sizeof(size);
        
        filename = [[NSString alloc] initWithData:[value subdataWithRange:NSMakeRange(cursor, [value length] - cursor)] encoding:NSUTF8StringEncoding];
        cursor = [value length];
        
        fileDataFlag  = flag;
        fileBlockSize = size;
        fileBlockId   = blockid;
        fileName      = filename;
        
        NSLog(@"Read FILE_DESC: FLAG=%c, BLOCKID=%i, SIZE=%i, FILENAME=%@", fileDataFlag, fileBlockId, fileBlockSize, fileName);
        NSLog(@"FILE_DATASTATUS : %@", fileDataStatus);
        
        if ([fileDataStatus isEqual:FS_IDLE]) {
            //do nothing
        }
        else if ([fileDataStatus isEqual:FS_INVESTIGATING]) [self readActivityData];
        else if ([fileDataStatus isEqual:FS_READING])       [self readActivityData];
        else if ([fileDataStatus isEqual:FS_FILE_FOUND])    [self readActivityData];
        else if ([fileDataStatus isEqual:FS_WRITE])         [self addFirmwareCallWithPriority:YES];
        else if ([fileDataStatus isEqual:FS_WF_PREPARED])   [self addFirmwareCallWithPriority:YES];
        else if ([fileDataStatus isEqual:FS_SENDING])       [self addFirmwareCallWithPriority:YES];
        else if ([fileDataStatus isEqual:FS_SEND_OK])       [self addFirmwareCallWithPriority:YES];
    }
    else if ([characteristic isEqual:BLE_HANDLE_FILE_DATA]) {
        if ([fileDataStatus isEqual:FS_READING_DATA]) {
            NSLog(@"Read FILE_DATA: BlockID=%d, Size=%d+%zd/%d", fileBlockId, activityFileBlockCursor, [value length], fileBlockSize);
            [activityDataBuffer appendData:value];
            activityFileBlockCursor += [value length];
            
            if (activityFileBlockCursor >= fileBlockSize) {
                NSLog(@"Read Next Block:%d", fileBlockId);
                activityFileBlockCursor = 0;
                readBlockId += 1;
                [self writeFileDesc:(int8_t)'R' blockId:fileBlockId + 1 blockSize:0 fileName:fileName];
                fileDataStatus = FS_READING;
            }
        }
        else if ([fileDataStatus isEqual:FS_READING_END]) {
            NSLog(@"Read FILE_DATA End: BlockID=%d, Size=%d", fileBlockId, fileBlockSize);
            //[activityDataBuffer appendData:value];
            
            NSLog(@"%zd bytes Data Read %@", [value length], value);
            [activityDataBuffer appendData:value];
            
            @try
            {
                [self parseActivityData:activityDataBuffer];
            }
            @catch (NSException* e)
            {
                //do nothing since the file might be bad formated
            }
            
            [self writeFileDesc:(int8_t)'I' blockId:fileBlockId + 1 blockSize:0 fileName:fileName];
            fileDataStatus = FS_INVESTIGATING;
        }
    }
    else if ([characteristic isEqual:BLE_HANDLE_GPS_INFO]) {
        short i[4];
        [value getBytes: &i length: sizeof(i)];
        
        NSLog(@"SPORTS GPS INFO : <%@>:%d", characteristic, i[0]  );
        //[[KreyosHomeViewController sharedInstance] updateCurrentData: i];
    }
    else if ([characteristic isEqual:BLE_HANDLE_CONF_GESTURE]) {
        int8_t i[5];
        [value getBytes: &i length: sizeof(i)];
        
        KLog(@"GESTURE %i", i[0]);
        KLog(@"GESTURE %i", i[1]);
        KLog(@"GESTURE %i", i[2]);
        KLog(@"GESTURE %i", i[3]);
        KLog(@"GESTURE %i", i[4]);
    }
    else if ([characteristic isEqual:BLE_HANDLE_CONF_WORLDCLOCK_0]) {
        NSString *i[10];
        [value getBytes: &i length: sizeof(i)];
    }
    else if ([characteristic isEqual:BLE_HANDLE_CONF_WORLDCLOCK_1]) {
        NSString *i[10];
        [value getBytes: &i length: sizeof(i)];
    }
    else if ([characteristic isEqual:BLE_HANDLE_CONF_WORLDCLOCK_2]) {
        NSString *i[10];
        [value getBytes: &i length: sizeof(i)];
    }
    else if ([characteristic isEqual:BLE_HANDLE_CONF_WORLDCLOCK_3]) {
        NSString *i[10];
        [value getBytes: &i length: sizeof(i)];
    }
    else if ([characteristic isEqual:BLE_HANDLE_CONF_WORLDCLOCK_4]) {
        NSString *i[10];
        [value getBytes: &i length: sizeof(i)];
    }
    else if ([characteristic isEqual:BLE_HANDLE_CONF_WORLDCLOCK_5]) {
        NSString *i[10];
        [value getBytes: &i length: sizeof(i)];
    }
    else if ([characteristic isEqual:BLE_HANDLE_CONF_WATCHFACE]) {
        int8_t *i[2];
        [value getBytes: &i length: sizeof(i)];
    }
    else if ([characteristic isEqual:BLE_HANDLE_CONF_GOALS]) {
        short i[3];
        [value getBytes: &i length: sizeof(i)];
    }
    else if ([characteristic isEqual:BLE_HANDLE_CONF_USER_PROFILE]) {
        int8_t i[2];
        [value getBytes: &i length: sizeof(i)];
    }
    else if ([characteristic isEqual:BLE_HANDLE_CONF_ACTIVE_TIME])
    {
        int32_t i[4];
        [value getBytes: &i length: sizeof(i)];
        
        int32_t time = i[0];
        int32_t steps = i[1];
        int32_t cals = i[2];
        int32_t dist = i[3];
        
        NSLog( @"Home Data: Time%i Steps:%i Cal:%i Dist:%i", time, steps, cals, dist );
        
        m_dataManager.totalData_Steps = steps;
        m_dataManager.totalData_Calories = cals;
        m_dataManager.totalData_DistanceInMeter = dist;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_HOME_ACTIVITIES
                                                            object:nil];
    }
}


#pragma mark -
#pragma mark Utils
-(BOOL) isDataValidForSaving:(int)pCat
                  withActObj:(ActivityObject)p_object

{
    BOOL isNormal = p_object.sportID == kActivity_Walking;
    switch (pCat)
    {
        case DATA_COL_STEP:
            if (isNormal)
            {
                if (p_object.steps > kMaxStepsPerMin || p_object.steps <= 0)
                {
                    return YES;
                }
            }
            else
            {
                if (p_object.steps > kMaxStepsPerMin || p_object.steps < 0)
                    return YES;
            }
            break;
            
        case DATA_COL_DIST:
            
            if (isNormal)
            {
                if (p_object.distance > kMaxDistancePerMin || p_object.distance <= 0)
                    return YES;
            }
            else
            {
                if (p_object.distance > kMaxDistancePerMin || p_object.distance < 0)
                    return YES;
            }
            
            break;
        case DATA_COL_CALS:
            
            if (isNormal)
            {
                if (p_object.calories > UINT32_MAX || p_object.calories <= 0)
                    return YES;
            }
            else
            {
                if (p_object.calories > UINT32_MAX || p_object.calories < 0)
                    return YES;
            }
            break;
            
            
        default:
            break;
    }
    
    return NO;
}

-(void)startUpdate
{
    m_distapcher = [NSNotificationCenter defaultCenter];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        m_navControllerTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(callBaseControllerDelegate) userInfo:nil repeats:YES];
    });
}

-(void)callBaseControllerDelegate
{
    KreyosDataManager       *dataMngr = [KreyosDataManager sharedInstance];
    for (UIViewController *viewController in dataMngr.BaseChildViews)
    {
        viewController.navigationController.navigationBar.barStyle = UIBarStyleBlack;
        if ([KreyosDataManager sharedInstance].HasConnectedDevice)
        {
            viewController.navigationController.navigationBar.barTintColor = LOGIN_BLUE;
        }
        else
        {
            viewController.navigationController.navigationBar.barTintColor = [UIColor redColor];
        }
        
        [viewController setNeedsStatusBarAppearanceUpdate];
        [viewController.navigationController setNeedsStatusBarAppearanceUpdate];
    }
}

#pragma mark -
#pragma mark CLEAN TIMER  AND CURRENT DEVICE CONNECTED
//~~~This function will be called in state logout
//   It stop fetching of timers to the watch and disconnect current device
-(void)cleanBluetoothDelegate
{
    m_didLogout = YES;
    
    [reconnectionTimer invalidate];
    [m_fetchTimer invalidate];
    
    reconnectionTimer   = nil;
    m_fetchTimer        = nil;
    
    [[LkDiscovery sharedInstance]disconnectCurrentPeriperal];
    [KreyosDataManager sharedInstance].HasConnectedDevice = NO;
}

#pragma mark -
#pragma mark FIRMWARE UPDATE
-(void)initializeUpdateFirmWare
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self stopTimer];
        [self initializeFileTransistor];
        
        m_isUpdating = YES;
        [self performSelector:@selector(initVarsToUpdate) withObject:nil afterDelay:2.0f];
    });
    
}

-(void)initVarsToUpdate
{

    if(m_isUpdating)
    {
        fileDataStatus  = FS_IDLE;
        retryCount      = 0;
        fileDataFlag    = 0;
        m_selector.clear();
        [self initUpdateTimer];
    }
}

-(void)addFirmwareCallWithPriority:(BOOL)p_priority
{
    if(p_priority == YES)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateWatchFirmware) object:nil];
        [self performSelector:@selector(updateWatchFirmware) withObject:nil afterDelay:0.2f];
        m_selector.clear();
        return;
    }
    
    m_selector.push_back(@selector(updateWatchFirmware));
}

-(void)invokeMethod
{
    //NSLog(@"LOG SIZE %lu", m_selector.size());
    if (!(BOOL)m_selector.size())return;
    
    [self performSelector:m_selector[0] withObject:nil afterDelay:0.2f];
    m_selector.erase(m_selector.begin());
}

-(void)updateFirmwareDidFinished
{
    NSDictionary *userInfo = nil;
    [m_distapcher postNotificationName:@"firmwareUpdate"
                                object:nil
                              userInfo:userInfo];
    m_isUpdating = NO;
    [self stopTimer];
    [self initTimer];
}


@end
