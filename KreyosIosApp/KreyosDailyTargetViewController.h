//
//  KreyosDailyTargetViewController.h
//  KreyosIosApp
//
//  Created by Kreyos on 4/4/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosUIViewBaseViewController.h"
#import "CustomUILabelBebas.h"
#import "iCarousel.h"

@interface KreyosDailyTargetViewController : KreyosUIViewBaseViewController <iCarouselDataSource, iCarouselDelegate>
@property (strong, nonatomic) IBOutlet CustomUILabelBebas *stepsValue;
@property (strong, nonatomic) IBOutlet CustomUILabelBebas *distanceValue;
@property (strong, nonatomic) IBOutlet CustomUILabelBebas *timeValue;
@property (weak, nonatomic) IBOutlet UISlider *stepsSlider;
@property (weak, nonatomic) IBOutlet UISlider *distanceSlider;
@property (weak, nonatomic) IBOutlet UISlider *timeSlider;
@property (weak, nonatomic) IBOutlet UISlider *mTargetSlider;
@property (nonatomic, strong) IBOutlet iCarousel *carousel;

@end
