//
//  KreyosUtility.c
//  KreyosIosApp
//
//  Created by Dev on 3/15/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#include "KreyosUtility.h"

//#pragma mark -
//#pragma mark Constants
//static const float DIVISOR = 1000.0f;
//
//#pragma mark -
//#pragma mark Utilities
//CGPoint MultiplyVector( CGPoint pVec1, CGPoint pVec2 )
//{
//    return (CGPoint){pVec1.x*pVec2.x,pVec1.y*pVec2.y};
//}
//
//CGPoint MultiplyVectorToScalar( CGPoint pVec1, CGFloat pScalar )
//{
//    return (CGPoint){pVec1.x*pScalar,pVec1.y*pScalar};
//}
//
//CGPoint AddVector( CGPoint pVec1, CGPoint pVec2 )
//{
//    return (CGPoint){pVec1.x+pVec2.x,pVec1.y+pVec2.y};
//}
//
//CGPoint AddVectorToScalar( CGPoint pVec1, CGFloat pScalar )
//{
//    return (CGPoint){pVec1.x+pScalar,pVec1.y+pScalar};
//}
//
//CGPoint GetMidPoint( CGPoint pPosition, CGSize pSize )
//{
//    return (CGPoint){pPosition.x + pSize.width*0.5f, pPosition.y + pSize.height*0.5f};
//}
//
//NSDate* DateFromEpoch( int p_epoch )
//{
//    NSDateFormatter* format = [[NSDateFormatter alloc] init];
//    [format setDateFormat:@"EEE, d MMM yyyy"]; //Thu, 29 Jul 2010
//    [format setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
//    NSDate* date = [[NSDate alloc] initWithTimeIntervalSince1970:(double)p_epoch];
//    return date;
//}
//
//NSDate* DateFromString( NSString* p_dd, NSString* p_mm, NSString* p_yyyy )
//{
//    //~~~Sample: 27/11/2014
//    //      Format should always be p_dd/p_mm/p_yyyy
//    NSDateFormatter* formatter  = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat: @"dd/MM/yyyy"];
//    NSString* dateString        = [NSString stringWithFormat:@"%@/%@/%@", p_dd, p_mm, p_yyyy];
//    NSDate* createdDate         = [formatter dateFromString:dateString];
//    if (!createdDate) { return [NSDate date]; }
//    return  createdDate;
//}
//
//NSString* DateStringFromEpoch( int p_epoch )
//{
//    NSDate* date = [[NSDate alloc] initWithTimeIntervalSince1970:(double)p_epoch];
//    return DateStringFromDate( date );
//}
//
//NSString* DateStringFromDate( NSDate* p_date )
//{
//    NSDateFormatter* format = [[NSDateFormatter alloc] init];
//    [format setDateFormat:@"EEE, d MMM yyyy"]; //Thu, 29 Jul 2010
//    [format setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
//    NSDate* date = p_date;
//    NSString* nsstr = [format stringFromDate:date];
//    return nsstr;
//}
//
//NSString* DateStringFromNow()
//{
//    return DateStringFromDate( [NSDate date] );
//}
//
//NSDateComponents* ComponentFromDate( NSDate* p_date )
//{
//    NSCalendar* calendar = [NSCalendar currentCalendar];
//    [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
//    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:p_date]; // Get necessary date components
//    return components;
//}
//
//NSArray* DictToArray( NSDictionary* p_dict )
//{
//    if( p_dict == nil
//    ||  [p_dict count] <= 0
//    ) {
//        return [NSArray array];
//    }
//    
//    NSMutableArray* array = [NSMutableArray array];
//    
//    for ( NSString* key in p_dict )
//    {
//        [array addObject:[p_dict objectForKey:key]];
//    }
//    
//    return array;
//}
//
//float PrecomputeData( float p_value )
//{
//    if ( p_value < DIVISOR ) { return p_value; }
//    
//    float value 	= p_value / DIVISOR;
//    int remainder   = (int)p_value % (int)DIVISOR;
//    float ret       = value + (float)remainder;
//    
//    return ret;
//}
//
//float ConvertCaloriesFromWatch( float p_calories )
//{
//    // base unit it 0.01
//    return p_calories / 100.0f / 1000.0f;
//}
//
////~~~Distance:
////      Watch displays m
////      Watch passes cm
////      App displays km
//float ConvertDistanceFromWatch( float p_distance )
//{
//    // meter - kilometers
//    return p_distance / 100.0f / 1000.0f;
//}
//
//id DataWithHexString(NSString * p_hex)
//{
//	char buf[3];
//	buf[2]                  = '\0';
//	unsigned char *bytes    = (unsigned char*)malloc([p_hex length]/2);
//	unsigned char *bp       = bytes;
//    
//	for (CFIndex i = 0; i < [p_hex length]; i += 2)
//    {
//		buf[0] = [p_hex characterAtIndex:i];
//		buf[1] = [p_hex characterAtIndex:i+1];
//		char *b2 = NULL;
//		*bp++ = strtol(buf, &b2, 16);
//	}
//	
//	return [NSData dataWithBytesNoCopy:bytes length:[p_hex length]/2 freeWhenDone:YES];
//}
//
//NSString* HexadecimalString(NSData* p_data)
//{
//    const unsigned char *dataBuffer = (const unsigned char *)[p_data bytes];
//    
//    if (!dataBuffer)
//    {
//        return [NSString string];
//    }
//    
//    NSUInteger          dataLength  = [p_data length];
//    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
//    
//    for (int i = 0; i < dataLength; ++i)
//    {
//        [hexString appendFormat:@"%02x", (unsigned int)dataBuffer[i]];
//    }
//    
//    return [NSString stringWithString:hexString];
//}
//
//void DebugWatchSendData()
//{
//    NSString* hexData   = @"00000000290000008A9D01005E06000000150E0A";
//    NSData* value       =  DataWithHexString(hexData);
//    
//    int32_t i[4];
//    [value getBytes: &i length: sizeof(i)];
//    
//    int32_t time = i[0];
//    int32_t steps = i[1];
//    int32_t cals = i[2];
//    int32_t dist = i[3];
//    
//    NSLog( @"Home Data: Time%i Steps:%i Cal:%i Dist:%i", time, steps, cals, dist );
//}
//
//NSString* GetMonthStringByIndex(u_int p_index)
//{
//    p_index--;
//    static const char* data[] =
//    {
//        "Jan",
//        "Feb",
//        "Mar",
//        "Apr",
//        "May",
//        "Jun",
//        "Jul",
//        "Aug",
//        "Sept",
//        "Oct.",
//        "Nov",
//        "Dec",
//    };
//    
//    return [NSString stringWithUTF8String:data[p_index]];
//}
//
//
