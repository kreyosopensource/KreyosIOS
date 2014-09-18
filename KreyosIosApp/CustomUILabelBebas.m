//
//  CustomUILabelBebas.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/26/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "CustomUILabelBebas.h"
#import "KreyosUtility.h"

@implementation CustomUILabelBebas

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setFont:FONT_BEBAS([self font].pointSize)];
        
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        [self setFont:FONT_BEBAS([self font].pointSize)];
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
