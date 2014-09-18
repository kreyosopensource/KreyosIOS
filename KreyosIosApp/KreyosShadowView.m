//
//  KreyosShadowView.m
//  kreyos_watch
//
//  Created by hanqiu on 13-9-29.
//  Copyright (c) 2013年 kreyos. All rights reserved.
//

#import "KreyosShadowView.h"
#import "QuartzCore/QuartzCore.h" 

@implementation KreyosShadowView

@synthesize headImg;
@synthesize contentImg;
@synthesize footerImg;
@synthesize container;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        headImg = [UIImage imageNamed:@"shadow_table_head"];
        contentImg = [UIImage imageNamed:@"shadow_table_bg"];
        footerImg = [UIImage imageNamed:@"shadow_table_footer"];
        container = [[UIView alloc] initWithFrame:CGRectMake(2, 2, self.bounds.size.width - 4, self.bounds.size.height - 5.5f)];
        container.layer.cornerRadius = 5.0f;
        container.layer.masksToBounds = YES;

        // don't use self here, since we override addSubview
        [super addSubview:container];
        
        //[self drawRect:frame];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    headImg = [UIImage imageNamed:@"shadow_table_head"];
    contentImg = [UIImage imageNamed:@"shadow_table_bg"];
    footerImg = [UIImage imageNamed:@"shadow_table_footer"];
    
    [headImg drawInRect:CGRectMake(0, 0, rect.size.width, headImg.size.height)];
    [contentImg drawInRect:CGRectMake(0, headImg.size.height, rect.size.width, rect.size.height - headImg.size.height - footerImg.size.height)];
    [footerImg drawInRect:CGRectMake(0, rect.size.height - footerImg.size.height, rect.size.width, footerImg.size.height)];
}

// override addSubView to move the subview into correct content area
- (void)addSubview:(UIView *)view
{
    [container addSubview:view];
}

- (CGRect) getAvailBound
{
    CGRect ret;
    ret.origin.x = 0;
    ret.origin.y = 0;
    ret.size.height = self.bounds.size.height - 5.5f;
    ret.size.width = self.bounds.size.width - 4;
    
    return ret;
}

@end
