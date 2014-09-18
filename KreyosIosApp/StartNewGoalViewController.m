//
//  StartNewGoalViewController.m
//  KreyosIosApp
//
//  Created by Dev on 3/16/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "StartNewGoalViewController.h"
#import "SetActivityViewController.h"
@interface StartNewGoalViewController ()

@end

@implementation StartNewGoalViewController
@synthesize BadgeSelected;

-(IBAction)dismissThisView:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

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
    
    //Set Image As the sender btn
    [(SVGKImageView*)mImageView.ImageView setImage:[SVGKImage imageNamed:BadgeSelected.BadgeImage]];
    badgeDescriptionLabel.text = BadgeSelected.BadgeDescription;
    badgeSubCategoryLabel.text = BadgeSelected.BadgeSubCategory;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
