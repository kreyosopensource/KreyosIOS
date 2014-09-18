//
//  SetActivityViewController.m
//  KreyosIosApp
//
//  Created by Dev on 3/15/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "SetActivityViewController.h"
#import "SetNewGoalViewController.h"
#import "KreyosUtility.h"

@interface SetActivityViewController ()

@end

@implementation SetActivityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [segue.identifier isEqualToString:@"SetActToSetNewGoalSegue"] )
    {
        [((SetNewGoalViewController*)segue.destinationViewController) SetActivityTag:sender];
    }
}

- (void)buttonTouchEnded:(id)sender
{
    KreyosSVGButton *btnSender = (KreyosSVGButton*)sender;
// should assert here!
    mTouchedButtonTag = [btnSender tag];
}

@end
