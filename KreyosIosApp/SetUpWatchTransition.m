//
//  SetUpWatchTransition.m
//  KreyosIosApp
//
//  Created by Kreyos on 8/28/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "SetUpWatchTransition.h"

@implementation SetUpWatchTransition
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UINavigationController *navController = self.navigationController;
    navController.navigationBar.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    double delayInSeconds   = 0.05;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                   {
                       [self performSegueWithIdentifier:@"ToTutorial" sender:self];
                   });
}

@end
