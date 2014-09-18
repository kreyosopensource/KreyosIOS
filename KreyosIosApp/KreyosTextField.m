//
//  KreyosTextField.m
//  kreyos_watch
//
//  Created by hanqiu on 13-10-9.
//  Copyright (c) 2013年 kreyos. All rights reserved.
//

#import "KreyosTextField.h"
#import <QuartzCore/QuartzCore.h>
#import "KreyosUtility.h"
#import "KreyosInnerShadowView.h"

@implementation KreyosBaseTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.borderStyle = UITextBorderStyleNone;
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
        self.leftView = paddingView;
        self.leftViewMode = UITextFieldViewModeAlways;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        self.textColor = MAKE_RGB_UI_COLOR(134, 144, 147);
        self.font = [UIFont systemFontOfSize:12.92f];
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

@implementation KreyosTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [KreyosInnerShadowView initShadow:self];
    }
    return self;
}

@end