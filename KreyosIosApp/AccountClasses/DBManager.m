 //
//  DBManager.m
//  KreyosIosApp
//
//  Created by Dev on 3/23/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "DBManager.h"
#import "AccountManager.h"
#import "BadgeSystemManager.h"
#import "DatabaseStruct.h"
#import "ActivityStatsPageViewController.h"
#import "RequestManager.h"
#import "KreyosUtility.h"
#import "KreyosDataManager.h"
#import "Profile.h"
#import "KreyosFacebookController.h"

NSString* userActivitiesColumns[] =
{
	@"ActivityBestLap",
    @"ActivityAvgLap",
    @"ActivityCurrentLap",
    @"ActivityAvgPace",
    @"ActivityPace",
    @"ActivityTopSpeed",
    @"ActivityAvgSpeed",
    @"ActivitySpeed",
    @"ActivityElevation",
    @"ActivityAltitude",
    @"ActivityMaxHeart",
    @"AvgActivityHeart",
    @"ActivityHeart",
    @"Sport_ID",
    @"ActivityDistance",
    @"ActivityCalories",
    @"CreatedTime",
    @"ActivitySteps"
};

#pragma mark -
#pragma mark Statement Serializable
@implementation StatementSerializable

-(id)initWithKey:(NSString*)p_key
   withStatement:(NSString*)p_statement
{
    if( self = [super init] )
    {
        m_epochKey = p_key;
        m_dbStatement = p_statement;
    }
    
    return self;
}

-(NSString*) epochKey
{
    return m_epochKey;
}

-(NSString*) statement
{
    return m_dbStatement;
}

@end

#pragma mark -
#pragma mark Database Statics
static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

#pragma mark -
#pragma mark Database Manager's private Interface
@interface DBManager ()
{
    NSString* m_databasePath;
}

-(void)createCopyOfDatabaseIfNeeded;
-(BOOL)hasValidDbPath;
-(void)loadSavedUserDBPaths;
-(void)saveUserDbPath:(NSString*)p_dbPath;
-(BOOL)hasStackData:(NSString*)p_dbPath;
-(void)deleteUserProfile:(NSString*)p_dbPath;
-(void)deleteActivities:(NSString*)p_dbPath;

@end

#pragma mark -
#pragma mark Databse Manager
@implementation DBManager

#pragma mark - 
#pragma mark Database Manager Singleton
+(DBManager*) getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL] init];
        [sharedInstance initialize];
        
    }
    return sharedInstance;
}

-(id)init
{
    if(self = [super init])
    {
        self.bIs_DbExist = NO;
    }
    return self;
}

#pragma mark -
#pragma mark Database Manager's private functions
- (void) createCopyOfDatabaseIfNeeded{
    
    // Load Player Profile
    Profile* profile = [[Profile alloc] init];
    [profile loadData];
    
    // +AS:05212014 Reload, Load all the user databases
    [self loadSavedUserDBPaths];
    
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Database filename can have extension db/sqlite.
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    m_databasePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", profile. email, @"KreyosDefaultDB.sqlite"]];
    
    // recreate the copy
    if( ![self hasValidDbPath] )
    {
        NSLog(@"DBManager::createCopyOfDatabaseIfNeeded Invalid db path:%@",m_databasePath);
        [self createCopyOfDatabaseIfNeeded];
        return;
    }
    
    NSLog(@"DBManager::createCopyOfDatabaseIfNeeded Valid db path:%@",m_databasePath);
    
    success             = [fileManager fileExistsAtPath:m_databasePath];
    self.bIs_DbExist    = success;
    
    //~~~DB already exist
    if (success) { return; }
    
    // +AS:05212014 Save the name of the newly created db
    [self saveUserDbPath:m_databasePath];
    
    // recheck
    success = [fileManager fileExistsAtPath:m_databasePath];
    
    //~~~DB already exist
    if (success) { return; }
    
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"KreyosDefaultDB.sqlite"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:m_databasePath error:&error];
    if (!success) { NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]); }
}

-(BOOL) hasValidDbPath
{
    if( !m_databasePath || [m_databasePath rangeOfString:@"null"].location == NSNotFound )
    {
        return YES;
    }
    
    return NO;
}

-(void) loadSavedUserDBPaths
{
    NSMutableDictionary* dbPaths = (NSMutableDictionary*)[[NSUserDefaults standardUserDefaults] objectForKey:@"db_paths"];
    NSMutableDictionary* json = nil;
    
    if( dbPaths )
    {
        json = dbPaths;
    }
    
    if( json )
    {
        NSLog(@"DBManager::loadSavedUserDBPaths user_dbs:%@",[json description]);
        // userDBs = [NSMutableDictionary dictionaryWithDictionary:json];
        [m_userDatabase removeAllObjects];
        [m_userDatabase addEntriesFromDictionary:json];
    }
}

-(void) saveUserDbPath:(NSString*)p_dbPath
{
    [self loadSavedUserDBPaths];
    [m_userDatabase setObject:p_dbPath forKey:p_dbPath];
    [[NSUserDefaults standardUserDefaults] setObject:m_userDatabase forKey:@"db_paths"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL) hasStackData:(NSString*)p_dbPath
{
    if( sqlite3_open([p_dbPath UTF8String], &database)  == SQLITE_OK )
    {
        NSString* selectProfile =[NSString stringWithFormat:@"SELECT * FROM Kreyos_UpdateStack"];
        const char* select_stmt = [selectProfile UTF8String];
        
        if(sqlite3_prepare(database, select_stmt, -1, &statement, NULL)==SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                return YES;
            }
            else
            {
                return NO;
            }
        }
    }
    
    return NO;
}

-(void)deleteUserProfile:(NSString*)p_dbPath
{
    if(sqlite3_open([p_dbPath UTF8String], &database) == SQLITE_OK)
    {
        NSString *deleteSQL = [NSString stringWithFormat:
                               @"DELETE FROM Kreyos_UserProfile"];
        const char *delete_stmt = [deleteSQL UTF8String];
        sqlite3_prepare_v2(database, delete_stmt, -1, &statement, NULL);
        if(sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"Profile Delete Success");
        }
        else
        {
            NSLog(@"Profile Delete Failed");
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
}

-(void)deleteActivities:(NSString*)p_dbPath
{
    if(sqlite3_open([p_dbPath UTF8String], &database) == SQLITE_OK)
    {
        NSString *deleteSQL = [NSString stringWithFormat:
                               @"DELETE FROM Kreyos_User_Activities"];
        const char *delete_stmt = [deleteSQL UTF8String];
        sqlite3_prepare_v2(database, delete_stmt, -1, &statement, NULL);
        if(sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"Profile Delete Success");
        }
        else
        {
            NSLog(@"Profile Delete Failed");
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
}

#pragma mark -
#pragma mark Database Manager's Initialization
-(void) initialize
{
    NSString* key = [self homeDataKey];
    
    m_userDatabase = [[NSMutableDictionary alloc] init];
    m_failedStatements = [[NSMutableDictionary alloc] init];
    m_activityCache = [[NSMutableDictionary alloc] init];
    m_homeActivities = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if ( m_homeActivities )
    {
        m_homeActivities = [[NSMutableDictionary alloc] initWithDictionary:m_homeActivities];
    }
    else
    {
        m_homeActivities = [[NSMutableDictionary alloc] init];
    }
}

-(void) initDB
{
    dispatch_async(
        dispatch_get_global_queue(
            DISPATCH_QUEUE_PRIORITY_DEFAULT,
            (unsigned long)NULL),
            ^(void) { [self createCopyOfDatabaseIfNeeded]; }
    );
}

-(NSString*)homeDataKey
{
    // Load Player Profile
    Profile* profile = [[Profile alloc] init];
    [profile loadData];
    NSString* homeActivityPath = [NSString stringWithFormat:@"%@_%@",profile.email,KREYOS_HOME_ACTIVITIES];
    return homeActivityPath;
}

#pragma mark -
#pragma mark QUEUE
-(void) startStackQueries
{
    if ( [m_failedStatements count] > 0 )
    {
        for ( NSString* key in m_failedStatements )
        {
            StatementSerializable* statementSer = [m_failedStatements objectForKey:key];
            NSString* epochKey = [statementSer epochKey];
            NSString* sqlStatement = [statementSer statement];
            
            if ( [m_activityCache objectForKey:epochKey] )
            {
                NSLog(@"DBManager::startStackQueries DB Already contains this activity! epoch:%@ statement:%@",epochKey,sqlStatement);
                [m_failedStatements removeObjectForKey:key];
                [self startStackQueries];
                return;
            }
            
            if ( ![self hasValidDbPath] )
            {
                [self createCopyOfDatabaseIfNeeded];
            }
            
            if ( sqlite3_open( [m_databasePath UTF8String], &database )  == SQLITE_OK )
            {
                const char* insert_stmt = [sqlStatement UTF8String];
                int prepare = sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
                
                int statementResult = sqlite3_step(statement);
                
                if ( statementResult == SQLITE_DONE )
                {
                    NSLog(@"DBManager::startStackQueries SUCCESS.. satementResult:%i in query:%@ key:%@",statementResult,sqlStatement,epochKey);
                    [m_failedStatements removeObjectForKey:key];
                    [self startStackQueries];
                }
                else
                {
                    NSLog(@"DBManager::startStackQueries FAILED.. satementResult:%i in query:%@ key:%@",statementResult,sqlStatement,epochKey);
                }
            }
            
            break;
        }
    }
}

#pragma mark -
#pragma mark INSERT
-(BOOL)registerUser:(NSString *)p_uname
           password:(NSString *)p_pass
             weight:(int)p_weight
             height:(int)p_height
             gender:(int)p_gender
               name:(NSString *)p_name
{
    // +AS:07092014 Temp
    if ( ![self hasValidDbPath] )
    {
        [self createCopyOfDatabaseIfNeeded];
    }
    
    if(sqlite3_open([m_databasePath UTF8String], &database) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO Kreyos_UserProfile(User_Email, Password,Weight,Height,Gender,Name) VALUES (\"%@\", \"%@\",%i,%i,%i,\"%@\")", p_name,p_pass,p_weight,p_height,p_gender,p_name];
        const char *insert_stmt = [insertSQL UTF8String];
        
        
        sqlite3_prepare_v2(database, insert_stmt,
                           -1, &statement, NULL);
        if(sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"Registration Success");
            
            
            //### TO DO ADD DEFAULT VALUES
            
            
            sqlite3_finalize(statement);
            sqlite3_close(database);
            return YES;
        }
        else
        {
            NSLog(@"Registration Failed");
            
            sqlite3_finalize(statement);
            sqlite3_close(database);
        }
        
        
        
    }
    return NO;
}


//####TODO: If Offline remove saving to the net (already have localy saving)
-(void)recordActivity:(NSArray *)p_data
{
    NSDictionary* tableData = [NSDictionary dictionaryWithObjectsAndKeys:
                               [p_data objectAtIndex:ACTIVITY_SPORT_ID]               ,userActivitiesColumns[ACTIVITY_SPORT_ID],
                               [p_data objectAtIndex:ACTIVITY_BEST_LAP]               ,userActivitiesColumns[ACTIVITY_BEST_LAP],
                               [p_data objectAtIndex:ACTIVITY_AVG_LAP]                ,userActivitiesColumns[ACTIVITY_AVG_LAP],
                               [p_data objectAtIndex:ACTIVITY_CURRENT_LAP]            ,userActivitiesColumns[ACTIVITY_CURRENT_LAP],
                               [p_data objectAtIndex:ACTIVITY_AVG_PACE]               ,userActivitiesColumns[ACTIVITY_AVG_PACE],
                               [p_data objectAtIndex:ACTIVITY_PACE]                   ,userActivitiesColumns[ACTIVITY_PACE],
                               [p_data objectAtIndex:ACTIVITY_TOP_SPEED]              ,userActivitiesColumns[ACTIVITY_TOP_SPEED],
                               [p_data objectAtIndex:ACTIVITY_AVG_SPEED]              ,userActivitiesColumns[ACTIVITY_AVG_SPEED],
                               [p_data objectAtIndex:ACTIVITY_SPEED]                  ,userActivitiesColumns[ACTIVITY_SPEED],
                               [p_data objectAtIndex:ACTIVITY_ELEVATION]              ,userActivitiesColumns[ACTIVITY_ELEVATION],
                               [p_data objectAtIndex:ACTIVITY_ALTITUDE]               ,userActivitiesColumns[ACTIVITY_ALTITUDE],
                               [p_data objectAtIndex:ACTIVITY_MAXHEART]               ,userActivitiesColumns[ACTIVITY_MAXHEART],
                               [p_data objectAtIndex:ACTIVITY_AVGHEART]               ,userActivitiesColumns[ACTIVITY_AVGHEART],
                               [p_data objectAtIndex:ACTIVITY_HEART]                  ,userActivitiesColumns[ACTIVITY_HEART],
                               [p_data objectAtIndex:ACTIVITY_CALORIES]               ,userActivitiesColumns[ACTIVITY_CALORIES],
                               [p_data objectAtIndex:ACTIVITY_DISTANCE]               ,userActivitiesColumns[ACTIVITY_DISTANCE],
                               [p_data objectAtIndex:ACTIVITY_CREATED_TIME]           ,userActivitiesColumns[ACTIVITY_CREATED_TIME],
                               [p_data objectAtIndex:ACTIVITY_STEPS]                  ,userActivitiesColumns[ACTIVITY_STEPS],
                               nil];
    
    BOOL bIsSuccess = [self insert:@"INSERT INTO" tableName:@"Kreyos_User_Activities" valuePair:tableData];
    
    if ( bIsSuccess )
    {
        NSLog(@"Record Activity Succesful!");
        
        //~~~Check if has data already if not add it
        ActivityObject act  = [self FromData:p_data];
        NSValue* valAct     = [NSValue value:&act withObjCType:@encode(ActivityObject)];
        NSString* datefrom  = DateStringFromEpoch(act.time);
        
        NSMutableDictionary* container = (NSMutableDictionary*)[m_homeActivities objectForKey:datefrom];
        
        BOOL hasActivity = NO;
        if( container )
        {
            NSString* key = nil;
            for ( key in container )
            {
                ActivityObject object;
                NSValue* value  = (NSValue*)[container objectForKey:key];
                [value getValue:&object];
                
                if (act.sportID == object.sportID && act.time == object.time)
                {
                    hasActivity = YES;
                    break;
                }
            }
            
            if (!hasActivity)
            {
                [container setObject:valAct forKey:key];
                [m_homeActivities setObject:container forKey:datefrom];
            }
        }

#ifndef OFFLINE_BUILD
        [self sendDataActivityToWeb:p_data];
#endif
    }
    else
    {
        NSLog(@"Record Activity Failed!");
    }
}

//####TODO: Home activities Record activities to the data base
-(void)recordHomeActivity:(NSArray*)p_data
{
    ActivityObject act = [self FromData:p_data];
    NSValue* valAct = [NSValue value:&act withObjCType:@encode(ActivityObject)];
    
    NSString* epoch = [NSString stringWithFormat:@"%i",act.time];
    NSString* dateString = DateStringFromEpoch(act.time);
    NSMutableDictionary* container;
    
    if( [m_homeActivities objectForKey:dateString] )
    {
        container = (NSMutableDictionary*)[m_homeActivities objectForKey:dateString];
    }
    else
    {
        container = [[NSMutableDictionary alloc] init];
    }
    
    if( ![container objectForKey:epoch] )
    {
        [container setObject:valAct forKey:epoch];
        [m_homeActivities setObject:container forKey:dateString];

#ifndef OFFLINE_BUILD
        // upload data to web
        [self sendDataActivityToWeb:p_data];
#else
        dispatch_async(dispatch_get_main_queue(), ^{
            [self recordActivity:p_data];
        });
#endif
    }
}

#pragma mark -
#pragma mark DELETE
-(void)deleteUserProfile
{
    [self deleteUserProfile:m_databasePath];
}

-(void) deleteAccountInDevice
{
    // +AS:05212014 TODO
    //  Check the data on Stacks.
    //  Run this process on background or other thread..
    //  Whenever there are dbs that don't have Stack data.
    //    delete the dp and update the user dbs
    //    delete also the said db
    
    //DELETE STANDARDUSER DEFAULTS
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults removeObjectForKey:kUserEmail];
    [defaults removeObjectForKey:kUserPass];
    [defaults removeObjectForKey:kUserToken];
    [defaults removeObjectForKey:@"info_0"];
    [defaults removeObjectForKey:@"info_1"];
    [defaults removeObjectForKey:@"info_2"];
    [defaults removeObjectForKey:@"info_3"];
    [defaults removeObjectForKey:@"info_4"];
    [defaults removeObjectForKey:@"info_5"];
    [defaults removeObjectForKey:@"info_6"];
    [defaults removeObjectForKey:@"info_7"];
    [defaults removeObjectForKey:@"info_8"];
    [defaults removeObjectForKey:@"info_9"];
    [defaults removeObjectForKey:USERDEF_PHOTO];
    
    NSArray* dbpaths = [m_userDatabase allKeys];
    
    for ( NSString* path in dbpaths )
    {
        if( [self hasStackData:path] )
        {
            [self deleteUserProfile:path];
            [self deleteActivities:path];
            [self deleteLocalData];
        }
    }
    
    [self deleteLocalData];
    [self deleteUserProfile];
}

#pragma mark -
#pragma mark GET
-(void)getUserLoggedProfileData
{
    // +AS:07092014 Temp
    if ( ![self hasValidDbPath] )
    {
        [self createCopyOfDatabaseIfNeeded];
    }
    
    if(sqlite3_open([m_databasePath UTF8String], &database)  == SQLITE_OK)
    {
        NSString* selectProfile =[NSString stringWithFormat:@"SELECT * FROM Kreyos_UserProfile"];
        const char* select_stmt = [selectProfile UTF8String];
        
        if(sqlite3_prepare(database, select_stmt, -1, &statement, NULL)==SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                [AccountManager getSharedAccountManager].name           =  [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)] ;
                [AccountManager getSharedAccountManager].userGender     =  [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)] intValue];
                [AccountManager getSharedAccountManager].userID         =  [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)] intValue];
                [AccountManager getSharedAccountManager].userName       =  [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)] ;
                [AccountManager getSharedAccountManager].pass           = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)] ;
                [AccountManager getSharedAccountManager].userWeight     = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)] floatValue];
                [AccountManager getSharedAccountManager].userHeight     = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)] floatValue];
                [AccountManager getSharedAccountManager].userBirthDay   = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)] intValue];
                NSLog(@"This is  %i and %@ and %f %f",[AccountManager getSharedAccountManager].userID,[AccountManager getSharedAccountManager].userName,[AccountManager getSharedAccountManager].userWeight,[AccountManager getSharedAccountManager].userHeight);
                sqlite3_finalize(statement);
                sqlite3_close(database);
            }
            else
            {
                NSLog(@"Get USer Failed!");
            }
        }
    }
}

// Kreyos032514 -- SUBCATEGORY REPEATABLE - 1; ONEOFFS - 2; TIMELIMITED 3
- (void)getBadgeData
{
    // +AS:07092014 Temp
    if ( ![self hasValidDbPath] )
    {
        [self createCopyOfDatabaseIfNeeded];
    }
    
    if(sqlite3_open([m_databasePath UTF8String], &database)  == SQLITE_OK)
    {
        
        NSString* badgeData =[NSString stringWithFormat:@"SELECT * FROM BadgesData"];
        const char* select_stmt = [badgeData UTF8String];
        
        if(sqlite3_prepare_v2(database, select_stmt, -1, &statement, NULL)==SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSArray *_badgeData = [[NSArray alloc] initWithObjects:
                                       [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)],
                                       [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)],
                                       [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)],
                                       [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)],
                                       [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)],
                                       [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)],
                                       [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 6)],
                                       nil];
                
                //Check Category of Badge
                NSString *category = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
                
                if ( [category isEqualToString:@"1"] )
                {
                    [[BadgeSystemManager sharedInstance] addRepeatableBadges:_badgeData];
                }
                
                else if ( [category isEqualToString:@"2"] )
                {
                    [[BadgeSystemManager sharedInstance] addOneOffsBadges:_badgeData];
                }
                
                else if ( [category isEqualToString:@"3"] )
                {
                    [[BadgeSystemManager sharedInstance] addTimeLimitedBadges:_badgeData];
                }
            }
        }
    }
}

-(BOOL)getIfUserisLoggedIn
{
    // +AS:07092014 Temp
    if ( ![self hasValidDbPath] )
    {
        [self createCopyOfDatabaseIfNeeded];
    }
    
    if(sqlite3_open([m_databasePath UTF8String], &database)  == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT COUNT(*) FROM Kreyos_UserProfile"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if(sqlite3_prepare(database, query_stmt, -1, &statement, NULL)==SQLITE_OK)
        {
            
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString * countData= [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                
                
                NSLog(@"This is the count %i",[countData intValue]);
                
                sqlite3_finalize(statement);
                sqlite3_close(database);
                if([countData boolValue])
                {
                    
                    
                    return YES;
                }
                else
                {
                    return NO;
                }
            }
        }
    }
    
    
    return NO;
}

-(BOOL)LoginID:(NSString *)p_uname
      password:(NSString *)p_pass
{
    // +AS:07092014 Temp
    if ( ![self hasValidDbPath] )
    {
        [self createCopyOfDatabaseIfNeeded];
    }
    
    if(sqlite3_open([m_databasePath UTF8String], &database)  == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT COUNT(*) FROM Kreyos_UserProfile WHERE User_Email = \"%@\" and Password = \"%@\"",p_uname,p_pass];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if(sqlite3_prepare(database, query_stmt, -1, &statement, NULL)==SQLITE_OK)
        {
            
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString * countData= [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                
                
                NSLog(@"This is the count %i",[countData intValue]);
                
                if([countData boolValue])
                {
                    
                    sqlite3_finalize(statement);
                    sqlite3_close(database);
                    
                    //#### TO DO GET USER DATA
                    [self getUserLoggedProfileData];
                    
                    //GET BADGE DATA
                    [self getBadgeData];
                    
                    
                    return YES;
                }
                else
                {
                    sqlite3_finalize(statement);
                    sqlite3_close(database);
                    return NO;
                }
            }
        }
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(database);
    return NO;
}

-(NSMutableArray*)getActivitiesForUser
{
    // +AS:07092014 Temp
    if ( ![self hasValidDbPath] )
    {
        [self createCopyOfDatabaseIfNeeded];
    }
    
    NSMutableArray* _arrayActivities = [NSMutableArray array];
    
    if(sqlite3_open([m_databasePath UTF8String], &database)  == SQLITE_OK)
    {
        //NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM Kreyos_User_Activities WHERE KreyosUserID = %i",[AccountManager getSharedAccountManager].userID];
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM Kreyos_User_Activities"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if(sqlite3_prepare(database, query_stmt, -1, &statement, NULL)==SQLITE_OK)
        {
            int queryResult = sqlite3_step(statement);
            
            while ( queryResult == SQLITE_ROW )
            {
                ActivityObject _activity;
                
                _activity.bestLap   = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)] intValue];
                _activity.avgLap    = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)] intValue];
                _activity.currentLap= [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)] intValue];
                _activity.avgPace   = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)] intValue];
                _activity.pace      = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)] intValue];
                _activity.topSpeed  = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)] intValue];
                _activity.avgSpeed  = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 6)] intValue];
                _activity.speed     = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 7)] intValue];
                _activity.elevation = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 8)] intValue];
                _activity.altitude  = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 9)] intValue];
                _activity.maxHeart  = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 10)] intValue];
                _activity.avgHeart  = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 11)] intValue];
                _activity.heart     = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 12)] intValue];
                _activity.sportID   = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 14)] intValue];
                _activity.calories  = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 16)] intValue];
                _activity.steps     = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 17)] intValue];
                _activity.distance  = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 19)] intValue];
                _activity.time      = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 20)] intValue];
                
#ifdef DEBUG_WEIRD_DATE
                unsigned int dateOfActivity = _activity.time;
                NSString *epoctime = [NSString stringWithFormat:@"%i", dateOfActivity];
                NSTimeInterval seconds = [epoctime doubleValue];
                NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
                NSCalendar* calendar = [NSCalendar currentCalendar];
                NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date]; // Get necessary date components
                NSString *headerRef = [NSString stringWithFormat:@"%i-%i-%i", [components year], [components month], [components day]];
                
                NSDate *today = [NSDate date];
                components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:today];
                NSString *todayStr = [NSString stringWithFormat:@"%i-%i-%i", [components year], [components month], [components day]];
                
                NSString* headerDebug = [NSString stringWithFormat:@"Header Data:%@",headerRef];
                NSString* todayDebug = [NSString stringWithFormat:@"Today Data:%@",todayStr];
#endif
                if (_activity.time) {
                    [_arrayActivities addObject:[NSValue value:&_activity withObjCType:@encode(ActivityObject)]];
                }
                
                queryResult = sqlite3_step(statement);
            }
            
            [AccountManager getSharedAccountManager].activityObjects = _arrayActivities;
        }
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return _arrayActivities;
}

-(NSDictionary*)getHomeActivities
{
    NSString* now = DateStringFromNow();
    return (NSDictionary*)[m_homeActivities objectForKey:now];
}

-(void)clearHomeActivities
{
    if ( !m_homeActivities ) { return; }
    if ( ![m_homeActivities count] ) { return; }
    
    NSDictionary* homeActivities = [self getHomeActivities];
    
    if ( !homeActivities ) { return; }
    if ( ![homeActivities count] ) { return; }
    
    // clear the currently saved home activity
    [m_homeActivities setObject:[NSMutableDictionary dictionary] forKey:DateStringFromNow()];
}

#pragma mark -
#pragma mark UPDATE STACK
-(void)stackUpdate:(NSArray*)p_data
{
    // +AS:07092014 Temp
    if ( ![self hasValidDbPath] )
    {
        [self createCopyOfDatabaseIfNeeded];
    }
    
    if(sqlite3_open([m_databasePath UTF8String], &database) == SQLITE_OK)
    {
        int _sportID            = [[p_data objectAtIndex:ACTIVITY_SPORT_ID] intValue];
        int _bestLap            = [[p_data objectAtIndex:ACTIVITY_BEST_LAP] intValue];
        int _avgLap             = [[p_data objectAtIndex:ACTIVITY_AVG_LAP] intValue];
        int _currentLap         = [[p_data objectAtIndex:ACTIVITY_CURRENT_LAP] intValue];
        int _avgPace            = [[p_data objectAtIndex:ACTIVITY_AVG_PACE] intValue];
        int _pace               = [[p_data objectAtIndex:ACTIVITY_PACE] intValue];
        int _topSpeed           = [[p_data objectAtIndex:ACTIVITY_TOP_SPEED] intValue];
        int _avgSpeed           = [[p_data objectAtIndex:ACTIVITY_AVG_SPEED] intValue];
        int _speed              = [[p_data objectAtIndex:ACTIVITY_SPEED] intValue];
        int _elevation          = [[p_data objectAtIndex:ACTIVITY_ELEVATION] intValue];
        int _altitude           = [[p_data objectAtIndex:ACTIVITY_ALTITUDE] intValue];
        int _maxHeart           = [[p_data objectAtIndex:ACTIVITY_MAXHEART] intValue];
        int _avgHeart           = [[p_data objectAtIndex:ACTIVITY_AVGHEART] intValue];
        int _heart              = [[p_data objectAtIndex:ACTIVITY_HEART] intValue];
        int _calories           = [[p_data objectAtIndex:ACTIVITY_CALORIES] intValue];
        int _distance           = [[p_data objectAtIndex:ACTIVITY_DISTANCE] intValue];
        int _time               = [[p_data objectAtIndex:ACTIVITY_CREATED_TIME]intValue];
        int _steps              = [[p_data objectAtIndex:ACTIVITY_STEPS] intValue];
        
        NSString* insertSql = [NSString stringWithFormat:@"INSERT INTO Kreyos_UpdateStack ( Kreyos_UserId, Sport_ID, ActivityBestLap, ActivityAvgLap, ActivityCurrentLap, ActivityAvgPace, ActivityPace,ActivityTopSpeed, ActivityAvgSpeed, ActivitySpeed, ActivityElevation, ActivityAltitude, ActivityMaxHeart, AvgActivityHeart,ActivityHeart, ActivityCalories, ActivitySteps, ActivityDistance, CreatedTime, Coordinates) VALUES (%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,\"%@\")",1,_sportID,_bestLap,_avgLap,_currentLap,_avgPace,_pace,_topSpeed,_avgSpeed,_speed,_elevation,_altitude,_maxHeart,_avgHeart,_heart,_calories,_steps,_distance,_time,@"aa"];
        
        KLog(@"STEPS : %i :::: DISTANCE %i :::::: CALORIES %i ", _steps, _distance, _calories);
        const char* insert_stmt = [insertSql UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,
                           -1, &statement, NULL);
        if(sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"Record Stack Activity Succesful!");
        }
        else
        {
            NSLog(@"Record Stack Activity Failed!");
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
}

-(BOOL)getifThereIsStackedUpdates
{
    // +AS:07092014 Temp
    if ( ![self hasValidDbPath] )
    {
        [self createCopyOfDatabaseIfNeeded];
    }
    
    if(sqlite3_open([m_databasePath UTF8String], &database)  == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:
                              @"SELECT COUNT(*) FROM Kreyos_UpdateStack"];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if(sqlite3_prepare(database, query_stmt, -1, &statement, NULL)==SQLITE_OK)
        {
            
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString * countData= [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                
                
                NSLog(@"This is the count %i",[countData intValue]);
                
                sqlite3_finalize(statement);
                sqlite3_close(database);
                if([countData boolValue])
                {
                    
                    
                    return YES;
                }
                else
                {
                    return NO;
                }
            }
        }
    }
    
    return NO;
}

-(void) sendUpdateStackDatatoWeb
{
    // +AS:07092014 Temp
    if ( ![self hasValidDbPath] )
    {
        [self createCopyOfDatabaseIfNeeded];
    }
    
    //Send Updates in Web
    NSMutableArray* _arrayActivities = [NSMutableArray array];
    
    if(sqlite3_open([m_databasePath UTF8String], &database)  == SQLITE_OK)
    {
        
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM Kreyos_UpdateStack LIMIT 1,1"];//This is wrong
        
        const char *query_stmt = [querySQL UTF8String];
        
        if(sqlite3_prepare(database, query_stmt, -1, &statement, NULL)==SQLITE_OK)
        {
            
            while (sqlite3_step(statement)== SQLITE_ROW)
            {
                NSNumber*  _createdTime         = [NSNumber numberWithInt:[[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)] intValue]];
                NSNumber*  _activityDistance    = [NSNumber numberWithInt:[[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)] intValue]];
                //NSString*  _coordinates       = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];//### unimplemented
                NSNumber*  _activitySteps       = [NSNumber numberWithInt:[[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)] intValue]];
                NSNumber*  _activityCalories    = [NSNumber numberWithInt:[[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)] intValue]];
                NSNumber*  _sportID             = [NSNumber numberWithInt:[[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)] intValue]];
                //NSNumber*  _activityId        = [NSNumber numberWithInt:[[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 6)] intValue]];//### unimplemented
                NSNumber*  _activityHeart       = [NSNumber numberWithInt:[[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 7)] intValue]];
                NSNumber*  _avgActivityHeart    = [NSNumber numberWithInt:[[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 8)] intValue]];
                NSNumber*  _activityMaxHeart    = [NSNumber numberWithInt:[[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 9)] intValue]];
                NSNumber*  _activityAltitude    = [NSNumber numberWithInt:[[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 10)] intValue]];
                NSNumber*  _activityElevation   = [NSNumber numberWithInt:[[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 11)] intValue]];
                NSNumber*  _activitySpeed       = [NSNumber numberWithInt:[[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 12)] intValue]];
                NSNumber*  _activityAvgSpeed    = [NSNumber numberWithInt:[[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 13)] intValue]];
                NSNumber*  _activityTopSpeed    = [NSNumber numberWithInt:[[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 14)] intValue]];
                NSNumber*  _activityPace        = [NSNumber numberWithInt:[[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 15)] intValue]];
                NSNumber*  _activityAvgPace     = [NSNumber numberWithInt:[[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 16)] intValue]];
                NSNumber*  _activityCurrentLap  = [NSNumber numberWithInt:[[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 17)] intValue]];
                NSNumber*  _activityAvgLap      = [NSNumber numberWithInt:[[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 18)] intValue]];
                NSNumber*  _activityBestLap     = [NSNumber numberWithInt:[[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 19)] intValue]];
                //NSNumber*  _KreyosID          = [NSNumber numberWithInt:[[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 20)] intValue]];//### unimplemented
                
                [_arrayActivities insertObject:_createdTime atIndex:ACTIVITY_CREATED_TIME];
                [_arrayActivities insertObject:_activityDistance atIndex:ACTIVITY_DISTANCE];
                [_arrayActivities insertObject:_activitySteps atIndex:ACTIVITY_STEPS];
                [_arrayActivities insertObject:_activityCalories atIndex:ACTIVITY_CALORIES];
                [_arrayActivities insertObject:_sportID atIndex:ACTIVITY_SPORT_ID];
                [_arrayActivities insertObject:_activityHeart atIndex:ACTIVITY_HEART];
                [_arrayActivities insertObject:_activityMaxHeart atIndex:ACTIVITY_MAXHEART];
                [_arrayActivities insertObject:_avgActivityHeart atIndex:ACTIVITY_AVGHEART];
                [_arrayActivities insertObject:_activityAltitude atIndex:ACTIVITY_ALTITUDE];
                [_arrayActivities insertObject:_activityElevation atIndex:ACTIVITY_ELEVATION];
                [_arrayActivities insertObject:_activitySpeed atIndex:ACTIVITY_SPEED];
                [_arrayActivities insertObject:_activityAvgSpeed atIndex:ACTIVITY_AVG_SPEED];
                [_arrayActivities insertObject:_activityTopSpeed atIndex:ACTIVITY_TOP_SPEED];
                [_arrayActivities insertObject:_activityPace atIndex:ACTIVITY_PACE];
                [_arrayActivities insertObject:_activityAvgPace atIndex:ACTIVITY_AVG_SPEED];
                [_arrayActivities insertObject:_activityCurrentLap atIndex:ACTIVITY_CURRENT_LAP];
                [_arrayActivities insertObject:_activityAvgLap atIndex:ACTIVITY_AVG_LAP];
                [_arrayActivities insertObject:_activityBestLap atIndex:ACTIVITY_BEST_LAP];
                
                [self SendStackDataToWeb:_arrayActivities];
            }
        }
        
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(database);
}

-(void) deleteStackData:(int)p_userID
            CreatedTime:(int)p_createdTime
{
    // +AS:07092014 Temp
    if ( ![self hasValidDbPath] )
    {
        [self createCopyOfDatabaseIfNeeded];
    }
    
    if(sqlite3_open([m_databasePath UTF8String], &database) == SQLITE_OK)
    {
        NSString *deleteSQL = [NSString stringWithFormat:
                               @"DELETE FROM Kreyos_UpdateStack WHERE Kreyos_UserId = %i AND CreatedTime = %i",p_userID,p_createdTime];
        const char *delete_stmt = [deleteSQL UTF8String];
        sqlite3_prepare_v2(database, delete_stmt,
                           -1, &statement, NULL);
        if(sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"Profile Delete Success");
            [self startSendStackDataToWeb];
        }
        else
        {
            NSLog(@"Profile Delete Failed");
            
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
        
    }
    
}

-(void) startSendStackDataToWeb
{
    BOOL _bisThereStack = [self getifThereIsStackedUpdates];
    
    if(_bisThereStack)
    {
        [self sendUpdateStackDatatoWeb];
    }
}

#pragma mark -
#pragma mark Unknown Methods. ( Used )
-(void) deleteLocalData
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"alarms"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserEmail];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserPass];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserToken];
    [AccountManager getSharedAccountManager].activityObjects = nil;
}

-(void) deleteActivities
{
    [self deleteActivities:m_databasePath];
}

-(void) sendDataActivityToWeb : ( NSArray * ) p_data
{
    int _sportID            = [[p_data objectAtIndex:ACTIVITY_SPORT_ID] intValue];
    int _bestLap            = [[p_data objectAtIndex:ACTIVITY_BEST_LAP] intValue];
    int _avgLap             = [[p_data objectAtIndex:ACTIVITY_AVG_LAP] intValue];
    int _currentLap         = [[p_data objectAtIndex:ACTIVITY_CURRENT_LAP] intValue];
    int _avgPace            = [[p_data objectAtIndex:ACTIVITY_AVG_PACE] intValue];
    int _pace               = [[p_data objectAtIndex:ACTIVITY_PACE] intValue];
    int _topSpeed           = [[p_data objectAtIndex:ACTIVITY_TOP_SPEED] intValue];
    int _avgSpeed           = [[p_data objectAtIndex:ACTIVITY_AVG_SPEED] intValue];
    int _speed              = [[p_data objectAtIndex:ACTIVITY_SPEED] intValue];
    int _elevation          = [[p_data objectAtIndex:ACTIVITY_ELEVATION] intValue];
    int _altitude           = [[p_data objectAtIndex:ACTIVITY_ALTITUDE] intValue];
    int _maxHeart           = [[p_data objectAtIndex:ACTIVITY_MAXHEART] intValue];
    int _avgHeart           = [[p_data objectAtIndex:ACTIVITY_AVGHEART] intValue];
    int _heart              = [[p_data objectAtIndex:ACTIVITY_HEART] intValue];
    int _calories           = [[p_data objectAtIndex:ACTIVITY_CALORIES] intValue];
    int _distance           = [[p_data objectAtIndex:ACTIVITY_DISTANCE] intValue];
    int _time               = [[p_data objectAtIndex:ACTIVITY_CREATED_TIME]intValue];
    int _steps              = [[p_data objectAtIndex:ACTIVITY_STEPS] intValue];
    
    NSMutableDictionary *sportsData = [[NSMutableDictionary alloc] initWithCapacity:18];
    NSString *email = [KreyosDataManager getUserDefaultEmail];
    NSString *auth  = [KreyosDataManager getUserDefaultOath];
    
    //NEED TO ADD UID SINCE SOMETIMES FB DOESNT RETURN EMAIL DATA
    if ([KreyosDataManager sharedInstance].IsConnectedUsingFB) {
        [sportsData setObject:[KreyosFacebookController sharedInstance].getUserID forKey:@"uid"];
    }
    
    [sportsData setObject:email                                 forKey:@"email"     ];
    [sportsData setObject:auth                                  forKey:@"auth_token"];
    [sportsData setObject:[NSNumber numberWithInt:_sportID]     forKey:@"sport_id"  ];
    [sportsData setObject:[NSNumber numberWithInt:_bestLap]     forKey:@"best_lap"  ];
    [sportsData setObject:[NSNumber numberWithInt:_avgLap]      forKey:@"avg_lap"      ];
    [sportsData setObject:[NSNumber numberWithInt:_currentLap]  forKey:@"current_lap"  ];
    [sportsData setObject:[NSNumber numberWithInt:_avgPace]     forKey:@"avg_pace"];
    [sportsData setObject:[NSNumber numberWithInt:_pace]        forKey:@"pace"];
    [sportsData setObject:[NSNumber numberWithInt:_topSpeed]    forKey:@"top_speed"];
    [sportsData setObject:[NSNumber numberWithInt:_avgSpeed]    forKey:@"avg_speed"];
    [sportsData setObject:[NSNumber numberWithInt:_speed]       forKey:@"speed"];
    [sportsData setObject:[NSNumber numberWithInt:_elevation]   forKey:@"elevation"];
    [sportsData setObject:[NSNumber numberWithInt:_altitude]    forKey:@"altitude"];
    [sportsData setObject:[NSNumber numberWithInt:_maxHeart]    forKey:@"max_heart"];
    [sportsData setObject:[NSNumber numberWithInt:_avgHeart]    forKey:@"avg_heart"];
    [sportsData setObject:[NSNumber numberWithInt:_heart]       forKey:@"heart"];
    [sportsData setObject:[NSNumber numberWithInt:_calories]    forKey:@"calories"];
    [sportsData setObject:[NSNumber numberWithInt:_distance]    forKey:@"distance"];
    [sportsData setObject:[NSNumber numberWithInt:_time]        forKey:@"time"];
    [sportsData setObject:[NSNumber numberWithInt:_steps]       forKey:@"steps"];
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:sportsData options:0 error:&err];
    NSString * dataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    if([[RequestManager rm] sendRequestPostMethod:kServerUserActivitiesURL withPostData:dataString target:self selector:@selector(saveSportsDataCallback:)] == NO)
    {
        //Do update stack here
        [self stackUpdate:p_data];
    }
}

-(void) SendStackDataToWeb:(NSArray*)p_data
{
    int _sportID            = [[p_data objectAtIndex:ACTIVITY_SPORT_ID] intValue];
    int _bestLap            = [[p_data objectAtIndex:ACTIVITY_BEST_LAP] intValue];
    int _avgLap             = [[p_data objectAtIndex:ACTIVITY_AVG_LAP] intValue];
    int _currentLap         = [[p_data objectAtIndex:ACTIVITY_CURRENT_LAP] intValue];
    int _avgPace            = [[p_data objectAtIndex:ACTIVITY_AVG_PACE] intValue];
    int _pace               = [[p_data objectAtIndex:ACTIVITY_PACE] intValue];
    int _topSpeed           = [[p_data objectAtIndex:ACTIVITY_TOP_SPEED] intValue];
    int _avgSpeed           = [[p_data objectAtIndex:ACTIVITY_AVG_SPEED] intValue];
    int _speed              = [[p_data objectAtIndex:ACTIVITY_SPEED] intValue];
    int _elevation          = [[p_data objectAtIndex:ACTIVITY_ELEVATION] intValue];
    int _altitude           = [[p_data objectAtIndex:ACTIVITY_ALTITUDE] intValue];
    int _maxHeart           = [[p_data objectAtIndex:ACTIVITY_MAXHEART] intValue];
    int _avgHeart           = [[p_data objectAtIndex:ACTIVITY_AVGHEART] intValue];
    int _heart              = [[p_data objectAtIndex:ACTIVITY_HEART] intValue];
    int _calories           = [[p_data objectAtIndex:ACTIVITY_CALORIES] intValue];
    int _distance           = [[p_data objectAtIndex:ACTIVITY_DISTANCE] intValue];
    int _time               = [[p_data objectAtIndex:ACTIVITY_CREATED_TIME]intValue];
    int _steps              = [[p_data objectAtIndex:ACTIVITY_STEPS] intValue];

    //to do send to specific user id
     NSMutableDictionary *sportsData = [[NSMutableDictionary alloc] initWithCapacity:18];
    
    [sportsData setObject:[NSNumber numberWithInt:_sportID]     forKey:@"sport_id"  ];
    [sportsData setObject:[NSNumber numberWithInt:_bestLap]     forKey:@"best_lap"  ];
    [sportsData setObject:[NSNumber numberWithInt:_avgLap]      forKey:@"avg_lap"      ];
    [sportsData setObject:[NSNumber numberWithInt:_currentLap]  forKey:@"current_lap"  ];
    [sportsData setObject:[NSNumber numberWithInt:_avgPace]     forKey:@"avg_pace"];
    [sportsData setObject:[NSNumber numberWithInt:_pace]        forKey:@"pace"];
    [sportsData setObject:[NSNumber numberWithInt:_topSpeed]    forKey:@"top_speed"];
    [sportsData setObject:[NSNumber numberWithInt:_avgSpeed]    forKey:@"avg_speed"];
    [sportsData setObject:[NSNumber numberWithInt:_speed]       forKey:@"speed"];
    [sportsData setObject:[NSNumber numberWithInt:_elevation]   forKey:@"elevation"];
    [sportsData setObject:[NSNumber numberWithInt:_altitude]    forKey:@"altitude"];
    [sportsData setObject:[NSNumber numberWithInt:_maxHeart]    forKey:@"max_heart"];
    [sportsData setObject:[NSNumber numberWithInt:_avgHeart]    forKey:@"avg_heart"];
    [sportsData setObject:[NSNumber numberWithInt:_heart]       forKey:@"heart"];
    [sportsData setObject:[NSNumber numberWithInt:_calories]    forKey:@"calories"];
    [sportsData setObject:[NSNumber numberWithInt:_distance]    forKey:@"distance"];
    [sportsData setObject:[NSNumber numberWithInt:_time]        forKey:@"time"];
    [sportsData setObject:[NSNumber numberWithInt:_steps]       forKey:@"steps"];
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:sportsData options:0 error:&err];
    NSString * dataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    if([[RequestManager rm] sendRequestPostMethod:kServerUserActivitiesURL withPostData:dataString target:self selector:@selector(saveSportsDataCallback:)] == YES)
    {
        
        [self deleteStackData:1 CreatedTime:_time];//###User ID Here;
    }
}

- (void) saveSportsDataCallback:(NSData*)responseData
{
    NSString *dataParsed = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

    NSLog(@"SAVE SPORTS DATA : %@" , dataParsed);
}

#pragma mark -
#pragma mark DEBUG
-(void) printUserActivities
{
    // +AS:07092014 Temp
    if ( ![self hasValidDbPath] )
    {
        [self createCopyOfDatabaseIfNeeded];
    }
    
    if(sqlite3_open([m_databasePath UTF8String], &database)  == SQLITE_OK)
    {
        //NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM Kreyos_User_Activities WHERE KreyosUserID = %i",[AccountManager getSharedAccountManager].userID];
        NSString *querySQL = @"SELECT * FROM Kreyos_User_Activities";
        
        const char *query_stmt = [querySQL UTF8String];
        
        if(sqlite3_prepare(database, query_stmt, -1, &statement, NULL)==SQLITE_OK)
        {
            if ( sqlite3_step(statement) != SQLITE_ERROR )
            {
                int rows = sqlite3_column_int(statement, 0);
                int cacheCount = [m_activityCache count];
                
                if( cacheCount != rows || cacheCount == 0 )
                {
                    [m_activityCache removeAllObjects];
                    
                    while (sqlite3_step(statement)== SQLITE_ROW)
                    {
                        ActivityObject _activity;
                        
                        _activity.bestLap   = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)] intValue];
                        _activity.avgLap    = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)] intValue];
                        _activity.currentLap= [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)] intValue];
                        _activity.avgPace   = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)] intValue];
                        _activity.pace      = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)] intValue];
                        _activity.topSpeed  = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)] intValue];
                        _activity.avgSpeed  = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 6)] intValue];
                        _activity.speed     = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 7)] intValue];
                        _activity.elevation = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 8)] intValue];
                        _activity.altitude  = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 9)] intValue];
                        _activity.maxHeart  = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 10)] intValue];
                        _activity.avgHeart  = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 11)] intValue];
                        _activity.heart     = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 12)] intValue];
                        _activity.sportID   = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 14)] intValue];
                        _activity.calories  = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 16)] intValue];
                        _activity.steps     = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 17)] intValue];
                        _activity.distance  = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 19)] intValue];
                        _activity.time      = [[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 20)] intValue];
                        
                        NSString *epoctime = [NSString stringWithFormat:@"%i",_activity.time];
                        NSTimeInterval seconds = [epoctime doubleValue];
                        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
                        
#ifdef ENABLE_DB_PRINT
                        NSLog(@"DEBUG DBManager::printUserActivities SportsId:%i Epoch:%@ Date:%@", _activity.sportID, epoctime, date);
#endif
                        [m_activityCache setObject:[NSString stringWithFormat:@"%i",_activity.sportID] forKey:[NSString stringWithFormat:@"%i",_activity.time]];
                    }
                }
                else
                {
                    for ( NSString* epoch in m_activityCache )
                    {
                        NSTimeInterval seconds = [epoch doubleValue];
                        NSDate *date = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
#ifdef ENABLE_DB_PRINT
                        NSLog(@"DEBUG DBManager::printUserActivities SportsId:%@ Epoch:%@ Date:%@", [m_activityCache objectForKey:epoch], epoch, date);
#endif
                    }
                    
                    if ( [m_activityCache count] == 0 )
                    {
                        NSLog(@"DEBUG DBManager::printUserActivities NO DATA");
                    }
                }
            }
        }
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(database);
}

#pragma mark - Insert Command
-(BOOL)insert:(NSString*)p_command
    tableName:(NSString*)p_table
    valuePair:(NSDictionary*)p_pair
{
    // +AS:07112014 test
    statement = nil;
    database = nil;
    
    BOOL bIsSuccess = NO;
    
    // +AS:07092014 Temp
    if ( ![self hasValidDbPath] )
    {
        [self createCopyOfDatabaseIfNeeded];
    }
    
    if(sqlite3_open([m_databasePath UTF8String], &database)  == SQLITE_OK)
    {
        NSString* sqlStatement = [self serializeStatement:p_command
                                                tableName:p_table
                                                valuePair:p_pair];
        
        const char* insert_stmt = [sqlStatement UTF8String];
        int prepare = sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
        
        int statementResult = sqlite3_step(statement);
        
        if( statementResult == SQLITE_DONE )
        {
            bIsSuccess = YES;
        }
        else
        {
            //[self insert:p_command tableName:p_table valuePair:p_pair];
            NSLog(@"DBManager::insert WARNING.. satementResult:%i in query:%@",statementResult,sqlStatement);
            
            // save the failed dbs
            // created time in string
            NSString *createdTime = [p_pair objectForKey:userActivitiesColumns[ACTIVITY_CREATED_TIME]];
            if( ![m_failedStatements objectForKey:createdTime] )
            {
                StatementSerializable* statementSer = [[StatementSerializable alloc] initWithKey:createdTime withStatement:sqlStatement];
                [m_failedStatements setObject:statementSer forKey:createdTime];
            }
        }
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(database);
    
    return bIsSuccess;
}

-(NSString*)serializeStatement:(NSString*)p_command
                     tableName:(NSString*)p_table
                     valuePair:(NSDictionary*)p_pair
{
    NSMutableString* sqlStatement = [NSMutableString stringWithFormat:@"%@ %@ ",p_command,p_table];
    NSMutableString* sqlTables = [NSMutableString stringWithString:@"( "];
    NSMutableString* sqlValues = [NSMutableString stringWithString:@"( "];
    
    int ctr = 0;
    
    // append table keys
    for ( NSString* tableKey in p_pair )
    {
        NSString* tableValue = [NSString stringWithFormat:@"%i",[[p_pair objectForKey:tableKey] intValue]];
        
        if( ctr > 0 )
        {
            [sqlTables appendString:@", "];
            [sqlValues appendString:@", "];
        }
        
        [sqlTables appendString:tableKey];
        [sqlValues appendString:tableValue];
        
        ctr++;
    }
    
    [sqlTables appendString:@") VALUES "];
    [sqlValues appendString:@") "];
    
    [sqlStatement appendString:sqlTables];
    [sqlStatement appendString:sqlValues];
    
    return sqlStatement;
}

-(ActivityObject) FromData:(NSArray*)p_data
{
    ActivityObject actObj;
    
    actObj.sportID      = [[p_data objectAtIndex:ACTIVITY_SPORT_ID] intValue];
    actObj.bestLap      = [[p_data objectAtIndex:ACTIVITY_BEST_LAP] intValue];
    actObj.avgLap       = [[p_data objectAtIndex:ACTIVITY_AVG_LAP] intValue];
    actObj.currentLap   = [[p_data objectAtIndex:ACTIVITY_CURRENT_LAP] intValue];
    actObj.avgPace      = [[p_data objectAtIndex:ACTIVITY_AVG_PACE] intValue];
    actObj.pace         = [[p_data objectAtIndex:ACTIVITY_PACE] intValue];
    actObj.topSpeed     = [[p_data objectAtIndex:ACTIVITY_TOP_SPEED] intValue];
    actObj.avgSpeed     = [[p_data objectAtIndex:ACTIVITY_AVG_SPEED] intValue];
    actObj.speed        = [[p_data objectAtIndex:ACTIVITY_SPEED] intValue];
    actObj.elevation    = [[p_data objectAtIndex:ACTIVITY_ELEVATION] intValue];
    actObj.altitude     = [[p_data objectAtIndex:ACTIVITY_ALTITUDE] intValue];
    actObj.maxHeart     = [[p_data objectAtIndex:ACTIVITY_MAXHEART] intValue];
    actObj.avgHeart     = [[p_data objectAtIndex:ACTIVITY_AVGHEART] intValue];
    actObj.heart        = [[p_data objectAtIndex:ACTIVITY_HEART] intValue];
    actObj.calories     = [[p_data objectAtIndex:ACTIVITY_CALORIES] intValue];
    actObj.distance     = [[p_data objectAtIndex:ACTIVITY_DISTANCE] intValue];
    actObj.time         = [[p_data objectAtIndex:ACTIVITY_CREATED_TIME] intValue];
    actObj.steps        = [[p_data objectAtIndex:ACTIVITY_STEPS] intValue];
    
    return actObj;
}

@end
