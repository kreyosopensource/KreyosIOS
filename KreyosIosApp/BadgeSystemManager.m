//
//  BadgeSystemManager.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/10/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "BadgeSystemManager.h"
#import "SVGKLayeredImageView.h"
#import "SVGFactoryManager.h"

@interface BadgeSystemManager ()

@end

@implementation BadgeSystemManager
@synthesize BadgeArray;

static BadgeSystemManager* _sharedInstance = nil;

+(BadgeSystemManager*) sharedInstance
{
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        
        _sharedInstance = [[BadgeSystemManager alloc] init];
        
    });
    
    return  _sharedInstance;
}

- (void) createBadgeDataTable
{
   // CREATE  TABLE "main"."BadgesData" ("ID" INTEGER PRIMARY KEY  NOT NULL  DEFAULT 0, "Name" TEXT, "Description" TEXT, "Snippet" TEXT, "Category" TEXT, "SubCategory" TEXT, "ImagePath" TEXT)
}

/*
- (void) loadBadgesOnHomePage
{
    float viewWidth = viewHolder.frame.size.width;
    float viewHeight = viewHolder.frame.size.height;
    
    //Allocate badgearray
    
    
    NSMutableArray *badgeLists = [self getBadges];
    int badgeCount = 0;
    
    for (NSMutableDictionary *badgeDict in badgeLists) {
        
        NSLog(@"BADGE COUNT : %i", badgeCount);
        
        SVGKLayeredImageView *badge = [[SVGFactoryManager sharedInstance] createSVGImage:[badgeDict objectForKey:@"image"]];
        
        float badgeWidth = badge.frame.size.width ;
        float badgeHeight = badge.frame.size.height ;
        
        [badge setFrame:CGRectMake((viewWidth / 2 - badgeWidth / 2 ) + ((viewWidth / 2) * badgeCount) ,
                                        viewHeight / 2 - badgeHeight / 2,
                                        badgeWidth,
                                        badgeHeight )];
        
        CGAffineTransform transform = badge.transform;
        badge.transform = CGAffineTransformScale(transform, ( badgeCount > 0 ? 0.5f : 1 ), ( badgeCount > 0 ? 0.5f : 1 ));
        
        [viewHolder addSubview:badge];
        /*
        NSLog(@"WIDTH  : %f", viewHolder.frame.size.width);
        
        viewHolder.frame = CGRectMake(viewHolder.frame.origin.x,
                                      viewHolder.frame.origin.y,
                                      viewHolder.frame.size.width + (viewHolder.frame.size.width / 4),
                                      viewHolder.frame.size.height);
 
        badgeCount++;
        
    }
}*/

- (void) addRepeatableBadges : (NSArray*)badgeData
{
    if ( !self.RepeatableBadges ) self.RepeatableBadges = [[NSMutableArray alloc] init];
    [self.RepeatableBadges addObject:badgeData];
}

- (void) addOneOffsBadges : (NSArray*)badgeData
{
    if ( !self.OneOffsBadges ) self.OneOffsBadges = [[NSMutableArray alloc] init];
    [self.OneOffsBadges addObject:badgeData];
}

- (void) addTimeLimitedBadges : (NSArray*)badgeData
{
    if ( !self.TimeLimitedBadges ) self.TimeLimitedBadges = [[NSMutableArray alloc] init];
    [self.TimeLimitedBadges addObject:badgeData];
}

- (NSMutableArray*) getBadges
{
    BadgeArray = [[NSMutableArray alloc] init];
    
    NSArray *names = [NSArray arrayWithObjects:@"RUN 400 KILOMETERS", @"RUN 800 KILOMETERS", @"RUN 1200 KILOMETERS", nil];
    NSArray *images = [NSArray arrayWithObjects:@"active_time1_5k", @"active_time1_25k", @"active_time1k", nil];
    
    for (int b = 0; b < [names count]; b++) {
        
        NSMutableDictionary *BadgeList = [[NSMutableDictionary alloc] init];
        [BadgeList setValue:names[b] forKey:@"title"];
        [BadgeList setValue:images[b] forKey:@"image"];
        
        [BadgeArray addObject:BadgeList];
    }
    
    return BadgeArray;
}


@end
