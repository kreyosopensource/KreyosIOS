//
//  DatabaseStruct.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/16/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LOGIN_BADGE_COUNT 8





typedef struct
{
    //Upsell Badges
    unsigned char completeProfile:1;
    unsigned char installKreyosApp:1;
    unsigned char activateSmartWatch:1;
    unsigned char completeFirstSync:1;
    unsigned char shareWithFacebook:1;
    
}KreyosUpSellBadge;


typedef struct
{
    //Distance
    unsigned int marathonBadge:1;
    unsigned int halfMarathonBadge:1;
    unsigned int chunnelBadge:1;
    unsigned int panamaCanalBadge:1;
    unsigned int orientExpressBadge:1;
    unsigned int nileRiverBadge:1;
    unsigned int greatWallBadge:1;
    unsigned int equatorCircumeferenceBadge:1;
    unsigned int earthToMoonBadge:1;
    
    //Climb
    unsigned int empireStateBadge:1;
    unsigned int burjKhalifaBadge:1;
    unsigned int sphinxBadge:1;
    unsigned int machuPichuBadge:1;
    unsigned int mtEverestBadge:1;
    unsigned int eiffelTowerBadge:1;
    unsigned int kilimanjaroBadge:1;
    unsigned int statueOfLibertyBadge:1;
    
    //Active Running
    unsigned int apollo17Badge:1;
    unsigned int wearFor250Badge:1;
    
    
}KreyosOneOffsBadges;


typedef struct
{
    //Burst Challenges
    unsigned char walk1kBadge:1;
    
    //daily Challenges
    unsigned char walk15kBadge:1;
    unsigned char walk10hBadhe:1;
    unsigned char walk7miBadge:1;
    
    
}KreyosTimeLimited;





typedef struct
{
    
    int sportID;
    int bestLap;
    int avgLap;
    int currentLap;
    int avgPace;
    int pace;
    int topSpeed;
    int avgSpeed;
    int speed;
    int elevation;
    int altitude;
    int maxHeart;
    int avgHeart;
    int heart;
    int calories;
    int distance;
    int time;
    int steps;
    
}ActivityObject;


typedef struct
{
    unsigned int year:10;
    unsigned int month:4;
    unsigned int day:5;
    unsigned int hour:5;
    unsigned int minutes:6;
    
}IntegerTime;




