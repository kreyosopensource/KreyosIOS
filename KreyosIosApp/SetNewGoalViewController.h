//
//  SetNewGoalViewController.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/7/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosUIViewBaseViewController.h"
#import "AMSlideMenuMainViewController.h"
#import "KreyosUtility.h"
#import "KreyosSVGButton.h"

@interface SetNewGoalViewController : KreyosUIViewBaseViewController<UIScrollViewDelegate>
{
    IBOutlet KreyosSVGButton    *mActivityBtn;
    IBOutlet UIScrollView       *mScrollView;
    NSInteger                   mTouchedButtonTag;
    
    SVGKImage                   *activityImage;

    IBOutlet UIView *badgesHolder;
    
    
}
@property (strong, nonatomic) IBOutlet KreyosSVGButton *pickedActivity;
@property float zoomScale;
@property float minimumZoomScale;
@property float maximumZoomScale;

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
-(void) SetActivityTag:(id)pActivitySender;
-(void) ButtonTouchEnded:(id)sender;

@end
