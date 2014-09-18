//
//  DBManager.h
//  KreyosIosApp
//
//  Created by Dev on 3/23/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "DatabaseStruct.h"

#pragma mark -
#pragma mark Macros

// DB Actions
#define SELECT              @"SELECT"
#define INSERT_INTO         @"INSERT INTO"
#define DELETE              @"DELETE"
#define ALL                 @"*"
#define COUNT               @"COUNT(*)"
#define FROM                @"FROM"
#define WHERE               @"WHERE"
#define AND                 @"AND"
#define VALUES              @"VALUES"

// DB Tables
#define USER_PROFILE        @"Kreyos_UserProfile"
#define USER_ACTIVITIES     @"Kreyos_User_Activities"
#define USER_UPDATE_STACK   @"Kreyos_UpdateStack"
#define USER_BADGES         @"BadgesData"

// DB Columns (you can use the enum, instead of these macros)
#define USER_EMAIL          @"User_Email"
#define USER_PASSWORD       @"Password"
#define USER_ID             @"Kreyos_UserId"
#define CREATED_TIME        @"CreatedTime"

enum{
    ACTIVITY_BEST_LAP       =   0,  // 0
    ACTIVITY_AVG_LAP,               // 1
    ACTIVITY_CURRENT_LAP,           // 2
    ACTIVITY_AVG_PACE,              // 3
    ACTIVITY_PACE,                  // 4
    ACTIVITY_TOP_SPEED,             // 5
    ACTIVITY_AVG_SPEED,             // 6
    ACTIVITY_SPEED,                 // 7
    ACTIVITY_ELEVATION,             // 8
    ACTIVITY_ALTITUDE,              // 9
    ACTIVITY_MAXHEART,              // 10
    ACTIVITY_AVGHEART,              // 11
    ACTIVITY_HEART,                 // 12
    ACTIVITY_SPORT_ID,              // 13
    ACTIVITY_DISTANCE,              // 14
    ACTIVITY_CALORIES       = 15,   // 15
    ACTIVITY_CREATED_TIME,          // 16
    ACTIVITY_STEPS          = 17    // 17
};


#pragma mark -
#pragma mark Statement Serializable
@interface StatementSerializable : NSObject
{
    // private
    NSString* m_epochKey; // epoch time in string format
    NSString* m_dbStatement;
}

-(id)initWithKey:(NSString*)p_key
   withStatement:(NSString*)p_statement;

-(NSString*) epochKey;
-(NSString*) statement;

@end

/************************************************************
 * TODO:
 *  Refactor DBManager
 **
#pragma mark -
#pragma mark Database Protocol
typedef enum {
    Insert,
    Update,
    Get
} Query_Type;

@protocol DBProtocol <NSObject>
- (void) OnQueryComplete:(Query_Type)p_type
                  Result:(BOOL)p_result
                    Data:(NSArray*)p_data;
- (void) OnQueryError:(Query_Type)p_type
                Error:(NSArray*)p_error;
@end
//*/

#pragma mark -
#pragma mark Databse Manager
@interface DBManager : NSObject
{
    NSString* dataBasePath;
    NSMutableDictionary* m_userDatabase;
    NSMutableDictionary* m_failedStatements;
    
    // user activities cache
    NSMutableDictionary* m_activityCache;
    
    // cache of homne activity
    // {
    //      "DD_MM_YYYY":
    //      {
    //          "epochTime":tableData({}) // please see the tableData dict in 'recordActivity:(NSArray *)p_data' function
    //      }
    // }
    NSMutableDictionary* m_homeActivities;
}

@property (nonatomic, assign)BOOL bIs_DbExist;

#pragma mark -
#pragma mark Database Manager Singleton
+(DBManager*)getSharedInstance;

#pragma mark -
#pragma mark Database Manager's Initialization
-(void)initialize;
-(void)initDB; //INITIALIZE (This should only be called after the login)
-(NSString*)homeDataKey;

#pragma mark -
#pragma mark QUEUE
-(void)startStackQueries;

#pragma mark -
#pragma mark INSERT
-(BOOL)registerUser:(NSString *)p_uname
           password:(NSString *)p_pass
             weight:(int)p_weight
             height:(int)p_height
             gender:(int)p_gender
               name:(NSString*)p_name;

-(void)recordActivity:(NSArray*)p_data;
-(void)recordHomeActivity:(NSArray*)p_data;

#pragma mark -
#pragma mark DELETE
-(void)deleteUserProfile;
-(void)deleteAccountInDevice;

#pragma mark -
#pragma mark GET
-(void)getUserLoggedProfileData;
-(void)getBadgeData;
-(BOOL)getIfUserisLoggedIn;
-(BOOL)LoginID:(NSString*)p_uname
      password:(NSString*)p_pass;
-(NSMutableArray*)getActivitiesForUser;
-(NSDictionary*)getHomeActivities;
-(void)clearHomeActivities;

#pragma mark -
#pragma mark UPDATE STACK
-(void)stackUpdate:(NSArray*)p_data;
-(BOOL)getifThereIsStackedUpdates;
-(void)sendUpdateStackDatatoWeb;
-(void)deleteStackData:(int)p_userID
           CreatedTime:(int)p_createdTime;
-(void)startSendStackDataToWeb;

#pragma mark -
#pragma mark DEBUG | UTILS
-(void)printUserActivities;
-(BOOL)insert:(NSString*)p_command
    tableName:(NSString*)p_table
    valuePair:(NSDictionary*)p_pair;

-(NSString*)serializeStatement:(NSString*)p_command
                     tableName:(NSString*)p_table
                     valuePair:(NSDictionary*)p_pair;

-(ActivityObject) FromData:(NSArray*)p_data;

@end
