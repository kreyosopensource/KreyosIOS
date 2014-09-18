//
//  BadgeItem.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/25/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "BadgeItem.h"

@implementation BadgeItem
{
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (id)initWithBadgeType:(short)pType position:(CGPoint)pPos andData:(NSArray*)pData
{
    CGPoint badgePos = pPos;
    CGSize  badgeSize = (CGSize){50, 45};
    
    NSString* badgeImage         = pData[6];
    
    self = [KreyosSVGButton SVGButtonWith:badgeImage Position:badgePos Size:badgeSize];
    
    self.BadgeID                = [pData[0] integerValue];
    self.BadgeName              = pData[1];
    self.BadgeDescription       = pData[2];
    self.BadgeSnippet           = pData[3];
    self.BadgeCategory          = pData[4];
    self.BadgeSubCategory       = pData[5];
    self.BadgeImage             = pData[6];
    
    return self;
    
}

- (NSString*) getImage
{
    return self.BadgeImage;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
