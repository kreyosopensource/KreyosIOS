//
//  AccountManager.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/15/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "AccountManager.h"
#import "DatabaseStruct.h"
@implementation AccountManager

static AccountManager* s_account = nil;

@synthesize userName        = m_userName;
@synthesize name            = m_name;
@synthesize pass            = m_pass;
@synthesize userID          = m_userID;
@synthesize userWeight      = m_weight;
@synthesize userHeight      = m_height;
@synthesize userBirthDay    = m_birthDay;
@synthesize userGender      = m_gender;
@synthesize userFBID        = m_fbID;
@synthesize userTwitterID   = m_twitterID;
@synthesize userGooglePlus  = m_googlePlus;
@synthesize activityObjects = m_activityStruct;

+(AccountManager*) getSharedAccountManager
{
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate,
    ^{
        s_account = [[AccountManager alloc] init];
    });

    return  s_account;
}

@end
