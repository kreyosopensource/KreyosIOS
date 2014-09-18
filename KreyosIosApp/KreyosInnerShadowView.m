//
//  KreyosInnerShadowView.m
//  kreyos_watch
//
//  Created by hanqiu on 13-10-10.
//  Copyright (c) 2013年 kreyos. All rights reserved.
//

#import "KreyosInnerShadowView.h"
#import "KreyosUtility.h"

@implementation KreyosInnerShadowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [KreyosInnerShadowView initShadow:self];
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

+ (void) initShadow:(UIView*) view
{
    view.layer.cornerRadius = 5.0f;
    view.layer.masksToBounds = YES;
    view.layer.borderWidth = 0.5f;
    view.layer.borderColor = MAKE_RGB_UI_COLOR(192, 201, 203).CGColor;
    
    UIImageView* bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0.5f, view.frame.size.width, view.frame.size.height-0.5f)];
    [bgView setImage:[[UIImage imageNamed:@"bg_textfield"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 6, 0, 6)]];
    [view insertSubview:bgView atIndex:0];
}

@end
