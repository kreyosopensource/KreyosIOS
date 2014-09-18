//
//  KreyosProtocol.h
//  kreyos_watch
//
//  Created by Kreyos on 12/26/13.
//  Copyright (c) 2013 kreyos. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KreyosProtocol <NSObject>

public static final int headVersion  = 0;
public static final int headFlag     = 1;
public static final int bodyLength   = 2;
public static final int packSequence = 3;

public static final String elementTypeEcho     = "E";
public static final String elementTypeClock    = "C";
public static final String elementTypeMsgSMS   = "MS";
public static final String elementTypeMsgFB    = "MF";
public static final String elementTypeMsgTWI   = "MT";

public static final String msgSubTypeIdentity = "i";
public static final String msgSubTypeMessage  = "d";

public static final int maxBodySize = 200;
public static final int headSize = 4;
public static final int elementHeadSize = 2;
public static final byte continueElementTypeMarker = (byte) 0x80;

private static final int STLV_INVALID_HANDLE       = -1;
private static final int STLV_PACKET_MAX_BODY_SIZE = 240;
private static final int STLV_HEAD_SIZE            = 4;
private static final int STLV_PACKET_MAX_SIZE      = (STLV_PACKET_MAX_BODY_SIZE + STLV_HEAD_SIZE);
private static final int MAX_ELEMENT_NESTED_LAYER  = 4;
private static final int MIN_ELEMENT_SIZE          = 2;
private static final int MAX_ELEMENT_TYPE_SIZE     = 3;
private static final int MAX_ELEMENT_TYPE_BUFSIZE  = (MAX_ELEMENT_TYPE_SIZE + 1);
private static final int HEADFIELD_VERSION         = 0;
private static final int HEADFIELD_FLAG            = 1;
private static final int HEADFIELD_BODY_LENGTH     = 2;
private static final int HEADFIELD_SEQUENCE        = 3;
private static final int ELEMENT_TYPE_CLOCK            = 'C';
private static final int ELEMENT_TYPE_ECHO             = 'E';
private static final int ELEMENT_TYPE_SPORT_HEARTBEAT  = 'H';
private static final int ELEMENT_TYPE_GET_FILE         = 'G';
private static final int ELEMENT_TYPE_GET_DATA         = 'A';
private static final int 	  SUB_TYPE_SPORTS_DATA_ID       = 'i';
private static final int 	  SUB_TYPE_SPORTS_DATA_DATA     = 'd';
private static final int 	  SUB_TYPE_SPORTS_DATA_FLAG     = 'f';


private static final int ELEMENT_TYPE_GET_GRID         = 'R';
private static final int ELEMENT_TYPE_SN               = 'S';
private static final int ELEMENT_TYPE_WATCHFACE        = 'W';


private static final int ELEMENT_TYPE_FILE             = 'F';
private static final int     SUB_TYPE_FILE_NAME        = 'n';
private static final int     SUB_TYPE_FILE_DATA        = 'd';
private static final int     SUB_TYPE_FILE_END         = 'e';
private static final int ELEMENT_TYPE_MESSAGE              = 'M';
private static final int     ELEMENT_TYPE_MESSAGE_SMS      = 'S';
private static final int     ELEMENT_TYPE_MESSAGE_FB       = 'F';
private static final int     ELEMENT_TYPE_MESSAGE_TW       = 'T';
private static final int         SUB_TYPE_MESSAGE_IDENTITY = 'i';
private static final int         SUB_TYPE_MESSAGE_MESSAGE  = 'd';

private static final byte DATA_WORKOUT      = 0;
private static final byte DATA_SPEED        = 1;
private static final byte DATA_HEARTRATE    = 2;
private static final byte DATA_CALS         = 3;
private static final byte DATA_DISTANCE     = 4;
private static final byte DATA_SPEED_AVG    = 5;
private static final byte DATA_ALTITUDE     = 6;
private static final byte DATA_TIME         = 7;
private static final byte DATA_SPEED_TOP    = 8;
private static final byte DATA_CADENCE      = 9;

@end
