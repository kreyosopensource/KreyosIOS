//
//  Profile.m
//  KreyosIosApp
//
//  Created by Kreyos on 5/21/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "Profile.h"

#define EMPTY_FIELD     @""
#define EMAIL			@"email"
#define FB_TOKEN		@"fbToken"
#define KREYOS_TOKEN	@"kreyosToken"
#define FIRST_NAME		@"firstName"
#define LAST_NAME		@"lastName"
#define BIRTHDAY		@"birthday"
#define GENDER			@"gender"
#define WEIGHT			@"weight"
#define HEIGHT			@"height"

#define SAVE2_FIRSTNAME         @"info_0"
#define SAVE2_LASTNAME          @"info_1"
#define SAVE2_MONTH             @"info_2"
#define SAVE2_DAY               @"info_3"
#define SAVE2_YEAR              @"info_4"
#define SAVE2_WEIGHT            @"info_6"
#define SAVE2_HEIGHT            @"info_7"
#define SAVE2_GENDER            @"info_9"

@implementation Profile

@synthesize email					= m_email;
@synthesize fbToken					= m_fbToken;
@synthesize kreyosToken				= m_kreyosToken;
@synthesize firstName				= m_firstName;
@synthesize lastName				= m_lastName;
@synthesize birthday				= m_birthday;
@synthesize gender					= m_gender;
@synthesize weight					= m_weight;
@synthesize height					= m_height;

-(id) init
{
    self = [super init];
    
    if ( self )
    {
        m_defaults                  = [NSUserDefaults standardUserDefaults];
        self.email                  = EMPTY_FIELD;
        self.fbToken                = EMPTY_FIELD;
        self.kreyosToken            = EMPTY_FIELD;
        self.firstName              = EMPTY_FIELD;
        self.lastName               = EMPTY_FIELD;
        self.birthday               = EMPTY_FIELD;
        self.gender                 = EMPTY_FIELD;
        self.weight                 = EMPTY_FIELD;
        self.height                 = EMPTY_FIELD;
    }
    
    return self;
}

-(void) loadData
{
    self.email                      = (NSString*)[m_defaults objectForKey:EMAIL];
    self.fbToken                    = (NSString*)[m_defaults objectForKey:FB_TOKEN];
    self.kreyosToken                = (NSString*)[m_defaults objectForKey:KREYOS_TOKEN];
    self.firstName                  = (NSString*)[m_defaults objectForKey:FIRST_NAME];
    self.lastName                   = (NSString*)[m_defaults objectForKey:LAST_NAME];
    self.birthday                   = (NSString*)[m_defaults objectForKey:BIRTHDAY];
    self.gender                     = (NSString*)[m_defaults objectForKey:GENDER];
    self.weight                     = (NSString*)[m_defaults objectForKey:WEIGHT];
    self.height                     = (NSString*)[m_defaults objectForKey:HEIGHT];
}

-(void) saveData
{
    [m_defaults setObject:m_email			forKey:EMAIL];
    [m_defaults setObject:m_fbToken			forKey:FB_TOKEN];
    [m_defaults setObject:m_kreyosToken		forKey:KREYOS_TOKEN];
    [m_defaults setObject:m_firstName		forKey:FIRST_NAME];
    [m_defaults setObject:m_lastName		forKey:LAST_NAME];
    [m_defaults setObject:m_birthday		forKey:BIRTHDAY];
    [m_defaults setObject:m_gender			forKey:GENDER];
    [m_defaults setObject:m_weight			forKey:WEIGHT];
    [m_defaults setObject:m_height			forKey:HEIGHT];
    [m_defaults synchronize];
}

-(void) clear
{
    [m_defaults removeObjectForKey:EMPTY_FIELD];
    [m_defaults removeObjectForKey:EMAIL];
    [m_defaults removeObjectForKey:FB_TOKEN];
    [m_defaults removeObjectForKey:KREYOS_TOKEN];
    [m_defaults removeObjectForKey:FIRST_NAME];
    [m_defaults removeObjectForKey:LAST_NAME];
    [m_defaults removeObjectForKey:BIRTHDAY];
    [m_defaults removeObjectForKey:GENDER];
    [m_defaults removeObjectForKey:WEIGHT];
    [m_defaults removeObjectForKey:HEIGHT];
    
    self.email                  = EMPTY_FIELD;
    self.fbToken                = EMPTY_FIELD;
    self.kreyosToken            = EMPTY_FIELD;
    self.firstName              = EMPTY_FIELD;
    self.lastName               = EMPTY_FIELD;
    self.birthday               = EMPTY_FIELD;
    self.gender                 = EMPTY_FIELD;
    self.weight                 = EMPTY_FIELD;
    self.height                 = EMPTY_FIELD;
}

-(void)saveData2
{
    [m_defaults setObject:m_email			forKey:EMAIL];
    [m_defaults setObject:m_fbToken			forKey:FB_TOKEN];
    [m_defaults setObject:m_kreyosToken		forKey:KREYOS_TOKEN];
    [m_defaults setObject:m_firstName		forKey:SAVE2_FIRSTNAME];
    [m_defaults setObject:m_lastName		forKey:SAVE2_LASTNAME];
    [m_defaults setObject:m_gender			forKey:SAVE2_GENDER];
    [m_defaults setObject:m_weight			forKey:SAVE2_WEIGHT];
    [m_defaults setObject:m_height			forKey:SAVE2_HEIGHT];
    
    [m_defaults synchronize];
}

-(void)saveProfile
{
    [m_defaults setObject:m_email			forKey:EMAIL];
    [m_defaults setObject:m_kreyosToken		forKey:KREYOS_TOKEN];
}

@end
