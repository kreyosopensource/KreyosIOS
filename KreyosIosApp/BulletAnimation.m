//
//  BulletAnimation.m
//  KreyosIosApp
//
//  Created by Kreyos on 4/10/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "BulletAnimation.h"

@implementation BulletAnimation

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self animateBullet];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self animateBullet];
    }
    return self;
}

- (void) animateBullet
{
    // load all the frames of our animation
    self.animationImages = [NSArray arrayWithObjects:
                                    [UIImage imageNamed:@"load1.png"],
                                    [UIImage imageNamed:@"load2.png"],
                                    [UIImage imageNamed:@"load3.png"],
                                    [UIImage imageNamed:@"load4.png"],
                                    [UIImage imageNamed:@"load5.png"],
                                    [UIImage imageNamed:@"load6.png"],
                                    [UIImage imageNamed:@"load7.png"],
                                    [UIImage imageNamed:@"load8.png"],  nil];
    
    self.animationDuration = 1.75;
    // repeat the annimation forever
    self.animationRepeatCount = 0;
    // start animating
    [self startAnimating];

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
