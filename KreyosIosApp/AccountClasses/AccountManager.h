 //
//  AccountManager.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/15/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountManager : NSObject
{
    //Pesonnal Data
    NSString* m_userName;
    NSString* m_name;
    
    //TEMP DONT SAVE PASSWORD
    NSString* m_pass;
    int m_userID;
    
    //Stats Data
    float m_weight;
    float m_height;
    float m_birthDay;
    int m_gender;
    
    //Social Data
    NSString* m_fbID;
    NSString* m_twitterID;
    NSString* m_googlePlus;
    
    //Stats
    unsigned int m_loginCounter;
    unsigned int m_friendCounter;
    unsigned int m_shareFBCounter;
    unsigned int m_syncCounter;
    unsigned int m_hourTotalCounter;
    unsigned int m_totalTravelDistance;
    
    //Array of ActivityObjects
    NSMutableArray* m_activityStruct;
}

@property(nonatomic,readwrite)NSString* userName;
@property(nonatomic,readwrite)NSString* name;
@property(nonatomic,readwrite)NSString* pass;
@property(nonatomic,readwrite)int userID;
@property(nonatomic,readwrite)float userWeight;
@property(nonatomic,readwrite)float userHeight;
@property(nonatomic, readwrite)float userBirthDay;
@property(nonatomic,readwrite)int userGender;
@property(nonatomic,readwrite)NSString* userFBID;
@property(nonatomic,readwrite)NSString* userTwitterID;
@property(nonatomic,readwrite)NSString* userGooglePlus;
@property(nonatomic,readwrite)NSMutableArray* activityObjects;

+(AccountManager*)getSharedAccountManager;

@end
