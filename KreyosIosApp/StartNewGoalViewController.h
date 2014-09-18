//
//  StartNewGoalViewController.h
//  KreyosIosApp
//
//  Created by Dev on 3/16/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosActivityViewController.h"
#import "KreyosSVGImageView.h"
#import "BadgeItem.h"
#import "CustomUILabelBebas.h"

@interface StartNewGoalViewController : KreyosActivityViewController
{
    __weak IBOutlet KreyosSVGImageView  *mImageView;
    IBOutlet UILabel *badgeDescriptionLabel;
    
    IBOutlet CustomUILabelBebas *badgeSubCategoryLabel;
}
-(IBAction)dismissThisView:(id)sender;

@property (nonatomic, retain) KreyosSVGButton *BadgeSelected;
@end
