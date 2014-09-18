//
//  BadgeSystemManager.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/10/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosUIViewBaseViewController.h"

@interface BadgeSystemManager : KreyosUIViewBaseViewController
{
    
}

@property (retain, readwrite) NSMutableArray *BadgeArray;
@property (retain, readwrite) NSMutableArray *RepeatableBadges;
@property (retain, readwrite) NSMutableArray *OneOffsBadges;
@property (retain, readwrite) NSMutableArray *TimeLimitedBadges;

+(BadgeSystemManager*) sharedInstance;

- (void) loadBadgesOnHomePage;
- (NSMutableArray*) getBadges;

//add badges methods
- (void) addRepeatableBadges : (NSArray*)badgeData;
- (void) addOneOffsBadges : (NSArray*)badgeData;
- (void) addTimeLimitedBadges : (NSArray*)badgeData;
@end
