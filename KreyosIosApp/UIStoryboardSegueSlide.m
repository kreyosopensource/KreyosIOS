//
//  UIStoryboardSegueSlide.m
//  Sample
//
//  Created by Kreyos on 8/20/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "UIStoryboardSegueSlide.h"

@implementation UIStoryboardSegueSlide

- (void)perform
{
    UIViewController *srcViewController = (UIViewController *) self.sourceViewController;
    UIViewController *destViewController = (UIViewController *) self.destinationViewController;
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [srcViewController.view.window.layer addAnimation:transition forKey:nil];
    
    [srcViewController presentViewController:destViewController animated:NO completion:nil];
}
@end
