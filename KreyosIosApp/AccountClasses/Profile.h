//
//  Profile.h
//  KreyosIosApp
//
//  Created by Kreyos on 5/21/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Profile : NSObject 
{
    NSUserDefaults* m_defaults;
    NSString* m_email;
    NSString* m_fbToken;
    NSString* m_kreyosToken;
    NSString* m_firstName;
    NSString* m_lastName;
    NSString* m_birthday;
    NSString* m_gender;
    NSString* m_weight;
    NSString* m_height;
}

@property(nonatomic, readwrite)NSString* email;
@property(nonatomic, readwrite)NSString* fbToken;
@property(nonatomic, readwrite)NSString* kreyosToken;
@property(nonatomic, readwrite)NSString* firstName;
@property(nonatomic, readwrite)NSString* lastName;
@property(nonatomic, readwrite)NSString* birthday;
@property(nonatomic, readwrite)NSString* gender;
@property(nonatomic, readwrite)NSString* weight;
@property(nonatomic, readwrite)NSString* height;

-(id)   init;
-(void) loadData;
-(void) saveData;
-(void) clear;
-(void) saveData2;
-(void) saveProfile;
@end
