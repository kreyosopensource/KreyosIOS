//
//  KreyosUIViewBaseViewController.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/6/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosUIViewBaseViewController.h"
#import "SVGKFastImageView.h"
#import "KreyosUtility.h"
#import "PersonalInformationViewController.h"
#import "KreyosDataManager.h"


@interface KreyosUIViewBaseViewController ()
{
    
    //LOCK UNLOCK OBJECTS
    UIView *blackBg;
    UIActivityIndicatorView *indicator;
    KreyosDataManager       *dataMngr;
}
@end


@implementation KreyosUIViewBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //Iterate through your subviews, or some other custom array of view
    
    UITouch *touch = [touches anyObject];
    NSLog(@"VIEW %@", [touch.view class]);
    
    if ( [touch.view isKindOfClass:[SVGKFastImageView class]])
    {
        NSLog(@"SVGKFASTIMAGE AKO!!");
    }
    
    for (UIView *view in self.view.subviews)
        [view resignFirstResponder];
    
    
}

- (void) setTitleForViewCont
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleLabel.font = FONT_BEBAS(25);
    titleLabel.shadowColor = [UIColor clearColor];
    titleLabel.textColor =[UIColor blackColor];
    titleLabel.text = self.title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    
    //hide back
    [self.navigationItem setHidesBackButton:YES];
}

- (void) hideNavigationItem:(UIViewController*)p_vc
{
    if( p_vc.navigationController.navigationBar)
    {
        [p_vc.navigationController.navigationBar setHidden:TRUE];
    }
}

#pragma mark TEXTFIELD DELEGATES
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField up:NO];
}


-(void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    int movementDistance = -130; // tweak as needed
    float movementDuration = 0.3f; // tweak as needed
    
    if ( [self isKindOfClass:[PersonalInformationViewController class]] )
    {
        movementDistance = -80;
    }
        
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

#pragma mark LOCK UNLOCK SCREENS
- (void) lockScreen :(id)sender
{
    if ( blackBg == nil )
    {
        CGSize screenSize = [self.view frame].size;
        blackBg = [[ UIView alloc] initWithFrame:CGRectMake(screenSize.width / 2 - 50, screenSize.height / 2 - 50, 100, 100)];
        
        indicator = [[UIActivityIndicatorView alloc] initWithFrame:blackBg.frame];
        [indicator startAnimating];
        
        [blackBg addSubview:indicator];
        
        [self.view addSubview:blackBg];
    }
    
    [blackBg setHidden:NO];
    [indicator setHidden:NO];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
}

- (void) unlockScreen : (id) sender
{
    if (blackBg)
    {
        [blackBg setHidden:YES];
        [indicator setHidden:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    dataMngr = [KreyosDataManager sharedInstance];
    if ([dataMngr.BaseChildViews count] == 0) {
        dataMngr.BaseChildViews = [[NSMutableArray alloc] init];
    }
    
    if (![dataMngr.BaseChildViews containsObject:self]) {
        [dataMngr.BaseChildViews addObject:self];
    }    
    
    UIColor *navColor = [UIColor redColor];
    if ([KreyosDataManager sharedInstance].HasConnectedDevice) {
        navColor = LOGIN_BLUE;
    }
    
    //Set navigation bar color
    self.navigationController.navigationBar.barTintColor = navColor;
}


-(void) viewDidDisappear:(BOOL)animated
{
    dataMngr = [KreyosDataManager sharedInstance];
    if ([dataMngr.BaseChildViews count] == 0)
    {
        return;
    }
    
    if ([dataMngr.BaseChildViews containsObject:self])
    {
        [dataMngr.BaseChildViews removeObject:self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitleForViewCont];
    
    [[KreyosDataManager sharedInstance] setActiveView:self];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
