//
//  SetNewGoalViewController.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/7/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "SetNewGoalViewController.h"
#import "UIViewController+AMSlideMenu.h"
#import "AMSlideMenuMainViewController.h"
#import "StartNewGoalViewController.h"
#import "BadgeItem.h"
#import "KreyosDataManager.h"
#import "BadgeSystemManager.h"

const CGSize DEFAULT_SCROLL_VIEW_SIZE = {320,502};
const float kMinimumZoomscale = 0.5f;
const float kMaximumZoomscale = 6.0f;

@interface SetNewGoalViewController (Private) <UIScrollViewDelegate>
{
    
}


-(void) initButtons;
@end

@implementation SetNewGoalViewController
@synthesize pickedActivity;

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
    
    AMSlideMenuMainViewController *mainVC = [AMSlideMenuMainViewController getInstanceForVC:self];
    if (mainVC.rightMenu )
    {
        [self addRightMenuButton];
        [self addLeftMenuButton];
        
        [self disableSlidePanGestureForLeftMenu];
        [self disableSlidePanGestureForRightMenu];
    }
    
    //Set Image of the ACTIVITY
    if( activityImage )
    {
        [[pickedActivity getSVGImage] setImage:activityImage];
        pickedActivity.layer.anchorPoint = CGPointMake(0, 0.5f);
    }
    
    //Add Panning and Zooming
    mScrollView.minimumZoomScale=kMinimumZoomscale;
    mScrollView.maximumZoomScale=kMaximumZoomscale;
    mScrollView.contentSize=CGSizeMake(1280, 960);
    mScrollView.delegate=self;
    
    // initial views and buttons
    [self initButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)dismissThisView:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Send the BadgeItem selected from this view
    if ( [segue.identifier isEqualToString:@"SetNewGoalSegue"] )
    {
        KreyosSVGButton *bItem = (KreyosSVGButton*)sender;
        ((StartNewGoalViewController*)segue.destinationViewController).BadgeSelected = bItem;
    }
}

-(void) SetActivityTag:(id)pActivitySender
{
    enum Activities pActivity = [pActivitySender tag];
    KreyosSVGButton *senderBtn = (KreyosSVGButton*)pActivitySender;
    activityImage = [senderBtn getSVGImage].image;
    
    NSLog(@"setting activity tag:%i",pActivity);
    switch (pActivity) {
        case kActivity_Walking:
            //walking
            break;
        case kActivity_Running:
            //walking
            break;
        case kActivity_Biking:
            //walking
            break;
            
        default:
            break;
    }
}

-(void) ButtonTouchEnded:(id)sender
{
    BadgeItem *badgeItemBtn = (BadgeItem*)sender;
    
    
    mTouchedButtonTag = [sender tag];
    NSLog(@"touch tag:%i",mTouchedButtonTag);
    [self performSegueWithIdentifier: @"SetNewGoalSegue" sender: badgeItemBtn];
}


-(void) initButtons
{
    mActivityBtn = pickedActivity;
    
// temporary values
    NSArray *top =
    [NSArray arrayWithObjects:
        //[NSNumber numberWithInt:1],
        //[NSNumber numberWithInt:1],
        [NSNumber numberWithInt:1],
        [NSNumber numberWithInt:1],
        [NSNumber numberWithInt:1],
        [NSNumber numberWithInt:1], nil],
    
            *bottomLeft =
    [NSArray arrayWithObjects:
        //[NSNumber numberWithInt:1],
        //[NSNumber numberWithInt:1],
        [NSNumber numberWithInt:1],
        [NSNumber numberWithInt:1],
        [NSNumber numberWithInt:1],
        [NSNumber numberWithInt:1], nil],
    
        *bottomRight =
    [NSArray arrayWithObjects:
        //[NSNumber numberWithInt:1],
        //[NSNumber numberWithInt:1],
        [NSNumber numberWithInt:1],
        [NSNumber numberWithInt:1],
        [NSNumber numberWithInt:1],
        [NSNumber numberWithInt:1], nil];
    
    enum Directions
    {
        kDirection_Top,
        kDirection_BottomLeft,
        kDirection_BottomRight
    };
    
    const CGPoint   MID_POINT = { mActivityBtn.frame.origin.x + 56, mActivityBtn.frame.origin.y };
    const CGFloat   GAP = 10.0f, BOX = 40.0f, RADIUS = 70.0f;
    const CGPoint   DIRECTION_VECTORS[3] =
                                        { { 0,  -1},// kDirection_Top ( in reverse as origin is at top left )
                                          {-0.78f, 0.78f},  // kDirection_BottomLeft ( in reverse as origin is at top left ) 0.8f offset
                                          {0.78f, 0.78f} };// kDirection_BottomRight ( in reverse as origin is at top left )
    const int MAX = MAX( MAX([top count], [bottomLeft count]), [bottomLeft count] );
    
    BadgeSystemManager *badgeMngr = [BadgeSystemManager sharedInstance];
    
    for ( short index = -1; ++index < [badgeMngr.RepeatableBadges count]; )
    {
        CGFloat gap      = index * (GAP + BOX) + RADIUS;
        KreyosSVGButton *button;
    // top
        if ( index < [top count] )
        {
            CGPoint position = MultiplyVectorToScalar(DIRECTION_VECTORS[kDirection_Top], gap);
            position = AddVector(position, MID_POINT);
            //position = MID_POINT;
            //button = [KreyosSVGButton SVGButtonWith:@"active_time1_25k" Position:position Size:(CGSize){50,45}];
            button = [[BadgeItem alloc] initWithBadgeType:0 position:position andData:badgeMngr.RepeatableBadges[index]];
            button.tag = index;
            [button addTarget:self action:@selector(ButtonTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
            [badgesHolder addSubview:button];
        }
        
        
    }
    
    for ( short index = -1; ++index < [badgeMngr.OneOffsBadges count]; )
    {
        CGFloat gap      = index * (GAP + BOX) + RADIUS;
        KreyosSVGButton *button;
        
    // bottom left
        
        if ( index < [bottomLeft count] )
        {
            CGPoint position = MultiplyVectorToScalar(DIRECTION_VECTORS[kDirection_BottomLeft], gap);
            position = AddVector(position, MID_POINT);
            //button = [KreyosSVGButton SVGButtonWith:@"daily_steps5k" Position:position Size:(CGSize){50,45}];
            button = [[BadgeItem alloc] initWithBadgeType:0 position:position andData:badgeMngr.OneOffsBadges[index]];
            button.tag = index;
            [button addTarget:self action:@selector(ButtonTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
            [badgesHolder addSubview:button];
        }
    }
    
    
    for ( short index = -1; ++index < [badgeMngr.TimeLimitedBadges count]; )
    {
        CGFloat gap      = index * (GAP + BOX) + RADIUS;
        KreyosSVGButton *button;
    // bottom right
        if ( index < [bottomRight count] )
        {
            CGPoint position = MultiplyVectorToScalar(DIRECTION_VECTORS[kDirection_BottomRight], gap);
            position = AddVector(position, MID_POINT);
            //button = [KreyosSVGButton SVGButtonWith:@"consecutive_sync_2w" Position:position Size:(CGSize){50,45}];
            button = [[BadgeItem alloc] initWithBadgeType:0 position:position andData:badgeMngr.TimeLimitedBadges[index]];
            button.tag = index;
            [button addTarget:self action:@selector(ButtonTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
            [badgesHolder addSubview:button];
        }
    }
    
        //Set anchor of buttons
        //[badgesHolder setFrame:mScrollView.frame];
    
    CGFloat rightXY = RADIUS + bottomRight.count*(GAP+BOX);//sin(45 * (M_PI/180.0f)) * (RADIUS + bottomRight.count*(GAP+BOX));
    CGFloat leftXY = RADIUS + bottomLeft.count*(GAP+BOX);
    CGFloat topHeight = RADIUS + top.count * (GAP + BOX);
    
    NSLog(@"-- L:%f top:%f right:%f =%f LR=%f", RADIUS+GAP+BOX, topHeight,rightXY,topHeight+rightXY,leftXY+rightXY);
    
    mScrollView.contentSize = (CGSize){leftXY+rightXY, topHeight+rightXY };
    
    [mScrollView scrollRectToVisible:badgesHolder.frame animated:YES];
    
    CGFloat newContentOffsetX = (mScrollView.frame.size.width/2) - (badgesHolder.frame.size.width/2);
    
    badgesHolder.frame = CGRectSetPos( badgesHolder.frame, newContentOffsetX, badgesHolder.frame.origin.y );
    
    // adjust scroll view's frame size
    
}

#pragma mark SCROLL VIEW DELEGATE
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return badgesHolder;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    UIView *subView = [scrollView.subviews objectAtIndex:0];
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}


- (CGRect)zoomRectForScrollView:(UIScrollView *)scrollView withScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // The zoom rect is in the content view's coordinates.
    // At a zoom scale of 1.0, it would be the size of the
    // imageScrollView's bounds.
    // As the zoom scale decreases, so more content is visible,
    // the size of the rect grows.
    zoomRect.size.height = scrollView.frame.size.height / scale;
    zoomRect.size.width  = scrollView.frame.size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

@end
