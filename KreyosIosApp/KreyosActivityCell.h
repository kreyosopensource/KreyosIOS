//
//  KreyosActivityCell.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/20/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVGKFastImageView.h"
#import "DatabaseStruct.h"

@interface KreyosActivityCell : UITableViewCell < UIScrollViewDelegate>
{
    //-- Icon of the activity
    UIImageView *activityIcon;
    
    //-- Activity name ex : GOAL REACHED!, ACTIVITY
    UILabel *activityType;
    
    //-- Activity description
    UILabel *activityDesc;
    
    //-- Array of activity types like heartrate, average pace
    NSArray *_activityStats;
    
    //-- Array of activity type icon names like heartrate, average pace
    NSArray *_activityStatsIcons;
    
    //-- Header Values
    UILabel *dayLabel;
    UILabel *dateLabel;
    UILabel *stepsLabel;
    UILabel *dstLabel;
    UILabel *calLabel;

}
@property (nonatomic, readwrite) BOOL isHeader;
@property (nonatomic, assign) int   mHeaderID;
@property ( nonatomic , readwrite) UILabel *stepsValue;
@property ( nonatomic , readwrite) UILabel *dstValue;
@property ( nonatomic , readwrite) UILabel *calValue;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withData:(ActivityObject)pDataArray;
- (NSString*) getDay;
- (NSString*) getDate;

@end
