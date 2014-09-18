//
//  KreyosDailyTargetViewController.m
//  KreyosIosApp
//
//  Created by Kreyos on 4/4/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#define kGoalStep           @"g_steps"
#define kGoalDistance       @"g_distance"
#define kGoalTime           @"g_time"
#define kMaxKilometer       31

#import "KreyosDailyTargetViewController.h"
#import "AMSlideMenuMainViewController.h"
#import "UIViewController+AMSlideMenu.h"
#import "KreyosDataManager.h"
#import "KreyosBluetoothViewController.h"
#import "KreyosUtility.h"
#import "DeviceManager.h"

@interface KreyosDailyTargetViewController ()
{
    NSUserDefaults *userDef;
    NSArray *sliderValues;
    NSMutableArray *items;
    
    int mCurrentItemSelected;
}
@end

@implementation KreyosDailyTargetViewController

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
    userDef = [[KreyosDataManager sharedInstance] getUserDefaults];
    
    
    sliderValues = [NSArray arrayWithObjects:[NSNumber numberWithInteger:4000],
                                             [NSNumber numberWithInteger:6000],
                                             [NSNumber numberWithInteger:8000],
                                             [NSNumber numberWithInteger:10000],
                                             [NSNumber numberWithInteger:12000], nil];
    
    double gSteps      = [userDef objectForKey:kGoalStep]      == nil ? 6000 : [[userDef objectForKey:kGoalStep] intValue];
    double gDistance   = [userDef objectForKey:kGoalDistance]  == nil ? 35 : [[userDef objectForKey:kGoalDistance] intValue];
    double gTime       = [userDef objectForKey:kGoalTime]      == nil ? 2 : [[userDef objectForKey:kGoalTime] intValue];
    
    self.stepsValue.text    = [NSString stringWithFormat:@"%.0f", gSteps];
    self.distanceValue.text = [NSString stringWithFormat:@"%.0f", gDistance];
    self.timeValue.text     = [NSString stringWithFormat:@"%.0f", gTime];
    
    self.stepsSlider.value      = gSteps / 2000 - 2;
    self.distanceSlider.value   = gDistance;
    self.timeSlider.value       = gTime;
    
    
    [self.mTargetSlider setMinimumTrackImage:[UIImage new] forState:UIControlStateNormal];
    [self.mTargetSlider setMaximumTrackImage:[UIImage new] forState:UIControlStateNormal];
    
    //Add slide menu
    AMSlideMenuMainViewController *mainVC = [AMSlideMenuMainViewController getInstanceForVC:self];
    if(mainVC.rightMenu)
    {
        [self addRightMenuButton];
        [self addLeftMenuButton];
    }
    
    if (![userDef objectForKey:kGoalStep]) {
        [userDef setFloat:self.stepsSlider.value  forKey:kGoalStep];
    }
    
    
    //configure carousel
    self.carousel.type = iCarouselTypeCylinder;
    
    
    //scroll to fixed offset
    [self.carousel scrollToItemAtIndex: ([[userDef objectForKey:kGoalStep] intValue] / 1000) animated:NO];
    
    CGSize offset = CGSizeMake(0.0f, -100);
    self.carousel.viewpointOffset = offset;

    self.carousel.contentOffset = offset;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Slider DELEGATES
-(IBAction) stepsChanged : (UISlider*) sender
{
    UISlider *slider = (UISlider *)sender;
    
    // Figure out what the intvalue of the slider is and
    // snap to nearest int
    
    int sliderIntValue = (int)slider.value;
    float sliderModValue = (float)sliderIntValue;
    if ( (slider.value - sliderModValue) >= 0.5 ) {
        sliderModValue++;
    }
    
    slider.value = sliderModValue;
    
    float stepsGoalValue = [[sliderValues objectAtIndex:sliderModValue] intValue];
    [userDef setInteger:stepsGoalValue forKey:kGoalStep];
    
}
-(IBAction) distanceChanged : (UISlider*) sender
{
    self.distanceValue.text = [NSString stringWithFormat:@"%.0f",sender.value];
    [userDef setInteger:sender.value forKey:kGoalDistance];
}
-(IBAction) timeChanged : (UISlider*) sender
{
    self.timeValue.text = [NSString stringWithFormat:@"%.0f",sender.value];
    [userDef setInteger:sender.value forKey:kGoalTime];
}

-(IBAction)saveGoals:(id)sender
{
    
    if ( ![[KreyosDataManager sharedInstance] HasConnectedDevice] )
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Device not found" message:@"Please connect your Kreyos watch" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
        return;
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Goal Updated" message:@"Goodluck on today's training!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
    int16_t steps      = (mCurrentItemSelected + 1) * 1000;
    int16_t distance   = [[userDef objectForKey:kGoalDistance] shortValue];
    int16_t time       = [[userDef objectForKey:kGoalTime] shortValue];
    
    [userDef setInteger:steps forKey:kGoalStep];
    [[[KreyosDataManager sharedInstance] DisplayingService] writeSportsGoals:steps value2:distance value3:time];
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    if ([items count] <= 0) {
        //set up data
        items = [[NSMutableArray alloc] init];
        for (int i = 1; i < kMaxKilometer; i++)
        {
            [items addObject:[NSString stringWithFormat:@"%iK", i]];
        }
    }
    
    return [items count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    
    NSString* filename = [DeviceManager IS_IPhone4S] ? @"page4S.png" : @"page.png";
    
#ifdef EMULATOR_BUILD
    filename = @"page4S.png";
#endif
    
    if (view == nil)
    {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150.0f, 100.0f)];
        ((UIImageView *)view).image = [UIImage imageNamed:filename];
        view.contentMode = UIViewContentModeCenter;
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [label.font fontWithSize:50];
        [label setTextColor:LOGIN_BLUE];
        label.tag = 1;
        [view addSubview:label];
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    label.text = items[index];
    
    return view;
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.05f;
        }
        default:
        {
            return value;
        }
    }
}

- (void)carouselWillBeginDragging:(iCarousel *)carousel
{
	NSLog(@"Carousel will begin dragging");
}

- (void)carouselDidEndDragging:(iCarousel *)carousel willDecelerate:(BOOL)decelerate
{
	NSLog(@"Carousel did end dragging and %@ decelerate", decelerate? @"will": @"won't");
}

- (void)carouselWillBeginDecelerating:(iCarousel *)carousel
{
	NSLog(@"Carousel will begin decelerating");
}

- (void)carouselDidEndDecelerating:(iCarousel *)carousel
{
	NSLog(@"Carousel did end decelerating");
}

- (void)carouselWillBeginScrollingAnimation:(iCarousel *)carousel
{
	NSLog(@"Carousel will begin scrolling");
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel
{
	NSLog(@"Carousel did end scrolling");
    mCurrentItemSelected = [carousel currentItemIndex];
}

@end
