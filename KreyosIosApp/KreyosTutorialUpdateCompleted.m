//
//  KreyosTutorialUpdateCompleted.m
//  KreyosIosApp
//
//  Created by Kreyos on 8/27/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosTutorialUpdateCompleted.h"

@implementation KreyosTutorialUpdateCompleted
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    double delayInSeconds   = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
        [self performSegueWithIdentifier:@"goToMain" sender:self];
    });
}

@end
