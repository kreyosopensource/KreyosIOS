//
//  KreyosTools.h
//  KreyosIosApp
//
//  Created by Kreyos on 8/29/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import <Foundation/Foundation.h>


extern CGPoint MultiplyVector( CGPoint pVec1, CGPoint pVec2 );
extern CGPoint MultiplyVectorToScalar( CGPoint pVec1, CGFloat pScalar );
extern CGPoint AddVector( CGPoint pVec1, CGPoint pVec2 );
extern CGPoint AddVectorToScalar( CGPoint pVec1, CGFloat pScalar );
extern CGPoint GetMidPoint( CGPoint pPosition, CGSize pSize );
extern NSDate* DateFromEpoch( int p_epoch );
extern NSDate* DateFromString( NSString* p_dd, NSString* p_mm, NSString* p_yyyy );
extern NSString* DateStringFromEpoch( int p_epoch );
extern NSString* DateStringFromDate( NSDate* p_date );
extern NSString* DateStringFromNow();
extern NSDateComponents* ComponentFromDate( NSDate* p_date );
extern NSArray* DictToArray( NSDictionary* p_dict );
extern float PrecomputeData( float p_value );
extern NSString* GetMonthStringByIndex(u_int p_index);
extern void            DebugWatchSendData();
extern NSString*       HexadecimalString(NSData* p_data);
extern id              DataWithHexString(NSString * p_hex);

@interface KreyosTools : NSObject

@end
