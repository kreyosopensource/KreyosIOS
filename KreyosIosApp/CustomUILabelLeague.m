//
//  CustomUILabelLeague.m
//  KreyosIosApp
//
//  Created by Kreyos on 5/5/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "CustomUILabelLeague.h"
#import "KreyosUtility.h"

@implementation CustomUILabelLeague

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        [self setFont:FONT_LEAGUE([self font].pointSize)];
    }
    return self;
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
