 //
//  KreyosHomeViewController.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/6/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "KreyosFacebookController.h"
#import "KreyosHomeViewController.h"
#import "KreyosUtility.h"
#import "AppDelegate.h"
#import "SVGFactoryManager.h"
#import "BadgeSystemManager.h"
#import "KreyosBluetoothViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "LkDiscovery.h"
#import "UIViewController+AMSlideMenu.h"
#import "AMSlideMenuMainViewController.h"
#import "DBManager.h"
#import "KreyosDataManager.h"
#import "SportsPageViewController.h"
#import "FDTakeController.h"
#import "RequestManager.h"
#import "LoginViewController.h"
#import "DatabaseStruct.h"
#import "AccountManager.h"
#import "BluetoothDelegate.h"
#import "MainVC.h"
#import "Scheduler.h"
#import "DeviceManager.h"

#define TITLE_LABEL_PICK_TARGET         @"PICK A DAILY TARGET"
#define TITLE_LABEL_OVERALL_TARGET      @"VIEW OVERALL ACTIVITIES"

@interface KreyosHomeViewController ()<KreyosDiscoveryDelegate, KreyosProtocol, UITableViewDataSource, UITableViewDelegate, FDTakeDelegate, UIAlertViewDelegate>
{
    CGPoint point;
    CGPoint movePoint;
    
    NSMutableArray          *badgeItems;
    NSMutableArray          *items;
    
    SVGKLayeredImageView    *inFrontBadge;
    
    NSUserDefaults          *userDef;
    
    IBOutlet UIPageControl *pageNumIndicator;
    
    double gSteps;
    float headerTotalSteps;
    
    NSTimer* animTimer;
    
    KreyosDataManager* m_dataManager;
    
    AMSlideMenuMainViewController* m_mainVC;
}

@property (retain, nonatomic) NSMutableArray            *connectedServices;
@property (retain, nonatomic) CBPeripheral              *connectedperipheral;
@property (retain, nonatomic) UILabel                   *currentlyConnectedSensor;
@property (retain, nonatomic) LKreyosService            *currentlyDisplayingService;
@end

@implementation KreyosHomeViewController

@synthesize GoalTab;
@synthesize goalView;
@synthesize badgeImageHolder;
@synthesize carouselView;
@synthesize currentlyDisplayingService;
@synthesize connectedServices;
@synthesize connectedperipheral;
@synthesize currentlyConnectedSensor;
//@synthesize bluetoothTable;
@synthesize _viewDictionary;
@synthesize btnDailyTarget;

static KreyosHomeViewController *sharedInstance = nil;
static NSTimer* m_fetchHomeData;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        //INITIALIZE THIS AS INSTANCE
        sharedInstance          = self;
        m_dataManager           = [KreyosDataManager sharedInstance];
        
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        // INITIALIZE THIS AS INSTANCE
        sharedInstance          = self;
        m_dataManager           = [KreyosDataManager sharedInstance];
        
        NSNotificationCenter* notifCenter = [NSNotificationCenter defaultCenter];
        
        [notifCenter addObserver:self
                        selector:@selector(reloadHomeActivities)
                            name:RELOAD_HOME_ACTIVITIES
                          object:nil];
        
        [self setUp];
    }
    return self;
}

- (void) reloadHomeActivities
{
    NSLog(@"KreyosHomeViewController::reloadHomeActivities %f %f %f",
          m_dataManager.totalData_Steps,
          m_dataManager.totalData_Calories,
          m_dataManager.totalData_DistanceInMeter);
    
    //~~~To be refactored quick fixed only :D
    int steps           = [[userDef objectForKey:@"g_steps"] intValue];
    gSteps              = steps < 1000 || [[NSUserDefaults standardUserDefaults] objectForKey:@"g_steps"] == nil ? 6000 : steps;
    headerTotalSteps    = ( m_dataManager.totalData_Steps / gSteps );
    
    if ( [NSThread mainThread] )
    {
        dispatch_async(dispatch_get_main_queue(),
        ^{
            float steps            = m_dataManager.totalData_Steps;
            float computedDistance = HOME_DISTANCE( m_dataManager.totalData_DistanceInMeter );
            float computedCalories = HOME_CALORIES( m_dataManager.totalData_Calories );
            
            totalSteps.text     = HOME_STEPS_STR(steps);
            totalDistance.text  = HOME_DIST_STR(computedDistance);
            totalCalories.text  = HOME_CAL_STR(computedCalories);
            animTimer           = [NSTimer scheduledTimerWithTimeInterval:1.0f/60.0f target:self selector:@selector(animateProgress:) userInfo:nil repeats:YES];
            [animTimer fire];
            
            NSDictionary* homeActivities    = [[DBManager getSharedInstance] getHomeActivities];
            BOOL hasTarget                  = (m_dataManager.totalData_Steps > 0) || (homeActivities && [homeActivities count]);
            [self setDailyTargetTitle:hasTarget];
        });
    }
    [self initFetchTimer];
}

- (void)initializeBluetooth
{
    //~~~get data from web (Kreyos:display data after this code executed.)0
    [[KreyosDataManager sharedInstance] getSportsDataFromWeb:self];
}

- (void)setUp
{
	//set up data
    _viewDictionary = [[NSMutableDictionary alloc] init];
    
    //Setup Fonts
    [self setUpAllUILabelData];
    
    //~~~Remove this part of code it's not necessary
//    [[SportsPageViewController sharedInstance] init];
}

- (void) setUpProgressBar
{
    self.progressView.showShadow = 0;
    self.progressView.thicknessRatio = 0.15f;
    self.progressView.innerBackgroundColor = LOGIN_BLUE;
    self.progressView.outerBackgroundColor = [UIColor colorWithRed:17/255.0 green:177/255.0 blue:220/255.0 alpha:1.0];
    self.progressView.progressFillColor = nil;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Disable swipes
    m_mainVC = [AMSlideMenuMainViewController getInstanceForVC:self];
    
    if(m_mainVC.rightMenu)
    {
        //mainVC.rightPanDisabled = YES;
        //m/ainVC.leftPanDisabled = YES;
        [self addRightMenuButton];
        [self addLeftMenuButton];
    }
    
    [m_indicatorView setHidden:YES];
    
    //m_indicatorView.layer.cornerRadius = 5;
    //[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    NSOperationQueue* queueOperation = [NSOperationQueue new];
    
    NSInvocationOperation* invokeInitView = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(initializeView:) object:nil];
    [queueOperation addOperation:invokeInitView];
    
    //CREATE QUEUE OPERATION TO AVOID FREEZING
    NSInvocationOperation* invokeOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(fetchOperation:) object:nil];
    [queueOperation addOperation:invokeOperation];
    
    NSInvocationOperation* firmwareTest = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(firmwareTest:) object:nil];
    [queueOperation addOperation:firmwareTest];
    
    [self setUpProgressBar];
    
    // set the current view on BluetoothDelegate
    [[BluetoothDelegate instance] setCurrentView:self];
    [[BluetoothDelegate instance] tryReconnectWithThePrevious];
    
    // init fetch timer
    if( m_fetchHomeData )
    {
        [m_fetchHomeData invalidate];
    }
    
    m_fetchHomeData = nil;
    [self reloadHomeActivities];

    NSDictionary* homeActivities    = [[DBManager getSharedInstance] getHomeActivities];
    BOOL hasTarget                  = (m_dataManager.totalData_Steps > 0) || (homeActivities && [homeActivities count]);
    [self setDailyTargetTitle:hasTarget];

    [USERDATA setBool:true forKey:@"isUserLogB4"];
}

- (void) dealloc
{
    NSNotificationCenter* notifCenter = [NSNotificationCenter defaultCenter];
    //[notifCenter removeObserver:self name:RELOAD_HOME_ACTIVITIES object:nil];
    [notifCenter removeObserver:self];
}

- (void) initializeView:(id)sender
{
    //Customize Tab
    [self setPanelTab];
    [self CustomizeGoalTab];
    [self SetGoalTab];
    [self setPanelValues];
}

- (void) initFetchTimer
{
    //~~~Timer is Initialized
    if ( m_fetchHomeData ) { return; }
    
    m_fetchHomeData = [NSTimer scheduledTimerWithTimeInterval:HOME_FETCH_INTERVAL
                                                       target:[BluetoothDelegate instance]
                                                     selector:@selector(readHomeData)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void) fetchOperation:(id)sender    
{
    //Get Personal Infomration
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* email     = [KreyosDataManager getUserDefaultEmail];
        NSString* oath      = [KreyosDataManager getUserDefaultOath];
        NSString* uid       = [KreyosDataManager getUserUID];
        NSString *urlString = [NSString stringWithFormat:@"%@?uid=%@&auth_token=%@&email=%@", kServerGetUserProfile, uid, oath, email ];

#ifndef OFFLINE_BUILD
        [[RequestManager rm] sendRequest:urlString target:self selector:@selector(fetchedData:)];
#endif
    });
}

- (void)fetchedData:(NSData*)responseData
{
    if (responseData == nil) {
        return;
    }
    
    NSError *error     = nil;
    NSDictionary *json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
    if ([[KreyosDataManager sharedInstance] isSessionExpired:json navCont:self.navigationController])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"User Alert"
                                                        message:[json objectForKey:@"message"]
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Ok", nil];
        alert.tag = 300;
        alert.delegate = self;
        [alert show];
        
        return;
    }
    
    NSDictionary* user          = [json objectForKey:@"user"];
    NSDictionary* dimensions    = [user objectForKey:@"dimensions"];
    
    NSString *birthdate = NULL;
    
    if ([user objectForKey:@"birthday"])
    {
        birthdate         = [user objectForKey:@"birthday"];
    }
    
    //~~~SAVE USER PROFILE DATA
    [userDef setObject:[user objectForKey:@"first_name"] forKey:@"info_0"];
    [userDef setObject:[user objectForKey:@"last_name"]  forKey:@"info_1"];
    //~~~Save Gender
    [userDef setObject:[user objectForKey:@"gender"] forKey:@"info_9"];
    
    //CHECK IF BIRTHDAY IS AVAILABLE
    if( ![birthdate isKindOfClass:[NSNull class]] )
    {
        NSString* day       = [birthdate substringWithRange:NSMakeRange(0, 2)];
        NSString* month     = [birthdate substringWithRange:NSMakeRange(3, 2)];
        NSString* year      = [birthdate substringWithRange:NSMakeRange(6, 4)];
        
        [userDef setObject:month            forKey:@"info_2"];
        [userDef setObject:day              forKey:@"info_3"];
        [userDef setObject:year             forKey:@"info_4"];
    }
    
    //~~~Check if dimensions is available since first user registers without dimensions
    if( dimensions != (id)[NSNull null] )
    {
        id weightdata = [dimensions objectForKey:@"weight"];
        if ( weightdata )
        {
            if ([weightdata isKindOfClass:[NSNumber class]])
            {
                NSString* string = [NSString stringWithFormat:@"%i", [weightdata intValue]];
                [userDef setObject:string forKey:@"info_6"];
            }
            else
            {
                [userDef setObject:weightdata forKey:@"info_6"];
            }
        }
        
        id heightdata = [dimensions objectForKey:@"height"];
        if ( heightdata )
        {
            if ([heightdata isKindOfClass:[NSNumber class]])
            {
                NSString* string = [NSString stringWithFormat:@"%i", [heightdata intValue]];
                [userDef setObject:string forKey:@"info_7"];
            }
            else
            {
                [userDef setObject:heightdata forKey:@"info_7"];
            }
        }
    }
    
    [self initializeBluetooth];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 200)return;
    if ( [KreyosDataManager sharedInstance].isConnectedToWifi )
    {
        if ([KreyosDataManager sharedInstance].IsConnectedUsingFB )
        {
            [FBSession.activeSession closeAndClearTokenInformation];
            [FBSession.activeSession close];
            [FBSession setActiveSession:nil];
            
            [KreyosDataManager sharedInstance].IsConnectedUsingFB = NO;
            
            NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc] init];
            [userDictionary setObject:[KreyosDataManager getUserDefaultEmail] forKey:@"email"];
            [userDictionary setObject:[KreyosDataManager getUserDefaultOath]  forKey:@"auth_token"];
            [userDictionary setObject:[KreyosFacebookController sharedInstance].getUserID forKey:@"uid"];
            
            NSError * err;
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:userDictionary options:0 error:&err];
            NSString * dataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            [[RequestManager rm] sendRequestPostMethod:kServerSessionLogoutURL withPostData:dataString target:self selector:nil];
        }
        else
        {
            NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc] init];
            [userDictionary setObject:[KreyosDataManager getUserDefaultEmail] forKey:@"email"];
            [userDictionary setObject:[KreyosDataManager getUserDefaultOath]  forKey:@"auth_token"];
            
            NSError * err;
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:userDictionary options:0 error:&err];
            NSString * dataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            [[RequestManager rm] sendRequestPostMethod:kServerSessionLogoutURL withPostData:dataString target:self selector:nil];
        }
        
        [[DBManager getSharedInstance] deleteAccountInDevice];
    }
    
    // If the session state is any of the two "open" states when the button is clicked
    if (   FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended
        )
    {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        
        
        [[KreyosFacebookController sharedInstance] releaseData];
        // If the session state is not any of the two "open" states when the button is clicked
    }
    
    LoginViewController *login =  [self.storyboard instantiateViewControllerWithIdentifier:LOGIN_STORYBOARD];
    [self.navigationController pushViewController:login animated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:[DeviceManager GetStoryboard] bundle:nil];
    
    LoginViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:LOGIN_STORYBOARD];
    [self presentViewController:ivc animated:YES completion:nil];
}


- (void) viewDidAppear:(BOOL)animated
{
    //Setup Home Data
    self.takeController = [[FDTakeController alloc] init];
    self.takeController.delegate = self;

    self.takeController.takePhotoText           = @"Take Photo";
    self.takeController.takeVideoText           = @"Take Video";
    self.takeController.chooseFromPhotoRollText = @"Choose Existing";
    self.takeController.chooseFromLibraryText   = @"Choose Existing";
    self.takeController.cancelText              = @"Cancel";
    self.takeController.noSourcesText           = @"No Photos Available";
}

#pragma mark FOR TESTING
- (void)firmwareTest:(id)sender
{
    NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc] init];
    [userDictionary setObject:[KreyosDataManager getUserDefaultEmail] forKey:@"email"];
    [userDictionary setObject:[KreyosDataManager getUserDefaultOath]  forKey:@"auth_token"];
    
    //NEED TO ADD UID SINCE SOMETIMES FB DOESNT RETURN EMAIL DATA
    if ([KreyosDataManager sharedInstance].IsConnectedUsingFB) {
        [userDictionary setObject:[KreyosFacebookController sharedInstance].getUserID forKey:@"uid"];
    }
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:userDictionary options:0 error:&err];
    NSString * dataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [[RequestManager rm] sendRequestPostMethod:kServerFirmwareURL withPostData:dataString target:self selector:@selector(firmwareTestCallback:)];
}

- (void) firmwareTestCallback:(NSData*)pData
{
    
    NSString *dataParsed = [[NSString alloc] initWithData:pData encoding:NSUTF8StringEncoding];
    NSLog(@"REQUEST FIRMWARE DATA RECEIVED %@", dataParsed);
}

#pragma mark CUSTOMIZATIONS
-(void) updateTime
{
    CFGregorianDate currentDate = CFAbsoluteTimeGetGregorianDate(CFAbsoluteTimeGetCurrent(), CFTimeZoneCopySystem());
    
    NSLog(@"CURRENTDATE %d", (int16_t)currentDate.year);
    NSLog(@"CURRENTDATE %d", (int8_t)currentDate.month);
    NSLog(@"CURRENTDATE %d", (int8_t)currentDate.day);
    
    [currentlyDisplayingService writeDateTime:(int16_t)currentDate.year
                                        month:(int8_t)currentDate.month
                                          day:(int8_t)currentDate.day
                                         hour:(int8_t)currentDate.hour
                                      minutes:(int8_t)currentDate.minute
                                      seconds:(int8_t)currentDate.second];
}

-(void)setPanelValues
{
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(panelUpdate:)
     name:@"panelUpdate"
     object:nil];

    [self panelUpdate:self];
    
    //USER PHOTO
    userDef = [[KreyosDataManager sharedInstance] getUserDefaults];
    
    //INFO_8 IS A IMAGEURL FROM PERSONALINFORMATIONVIEWCONTROLLER CLASS
    NSString* imageObject = [userDef objectForKey:@"info_8"];
    if ( [userDef objectForKey:USERDEF_PHOTO])
    {
        UIImage *photo = [UIImage imageWithData:[userDef objectForKey:USERDEF_PHOTO]];
        [self.profileImage setImage:photo];
    }
    else if ( imageObject && [imageObject length])
    {
        NSString    *imgUrl = [userDef objectForKey:@"info_8"];
        NSURL       *url    = [NSURL URLWithString:imgUrl];
        NSData      *data   = [NSData dataWithContentsOfURL:url];
        UIImage     *img    = [[UIImage alloc] initWithData:data];
        
        [self.profileImage setImage:img];
    }
    else if( [KreyosDataManager sharedInstance].IsConnectedUsingFB )
    {
        KreyosFacebookController *fbCntrler = [KreyosFacebookController sharedInstance];
        NSString *imageUrl;
        imageUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", (NSDictionary<FBGraphUser> *)[fbCntrler getUserID]];
        NSURL *url = [NSURL URLWithString:imageUrl];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [[UIImage alloc] initWithData:data];
    
        [userDef setObject:imageUrl forKey:@"info_8"];
        
        [self.profileImage setImage:img];
    }
    
    [self updatePhotoBorder];
}

-(void) panelUpdate : (id)sender
{
    //HIDE PICK A DAILY TARGET
    [self.mPickADailyTargetView setHidden:YES];
}

- (void) animateProgress:(NSTimer *) timer
{
    if (self.progressView.progress <= headerTotalSteps)
    {
        self.progressView.progress += 0.005f;
    }
    else
    {
        [animTimer invalidate];
    }
}

-(void)setPanelTab
{
    statsPanel.type = iCarouselTypeLinear;
    statsPanel.scrollSpeed = 0.2f;
    statsPanel.scrollToItemBoundary = YES;
    statsPanel.bounces = NO;
}

-(void)SetGoalTab
{
    carouselView.type = iCarouselTypeRotary;
    carouselView.scrollSpeed = 0.5f;
}

#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    if( carousel.tag == 1)  return 2;
    else                    return [badgeItems count];
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    if(carousel.type == iCarouselTypeLinear)
        pageNumIndicator.currentPage = carousel.currentItemIndex;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    //create new view if no view is available for recycling
    if (view == nil && [carousel.restorationIdentifier isEqualToString:@"badgeC"])
    {
        view = [[SVGFactoryManager sharedInstance] createSVGImage:@"active_time7_5k"];//[badgeItems[index] objectForKey:@"image"]];
        //view.contentMode = UIViewContentModeCenter;
    }
    else if (view == nil && [carousel.restorationIdentifier isEqualToString:@"panelC"])
    {
        view = [statsPanel viewWithTag:index+3];
        view.layer.anchorPoint = CGPointMake(0, 0);
    }
    else
    {
        
    }
    
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
            return value * ( [_carousel.restorationIdentifier isEqualToString:@"panelC"] ? 1 : 3.05f) ;
        }
        default:
        {
            return value;
        }
    }
}

- (void)CustomizeGoalTab
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                FONT_BEBAS(20), NSFontAttributeName,
                                [UIColor blackColor], NSForegroundColorAttributeName,
                                nil];
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:[UIColor grayColor] forKey:NSForegroundColorAttributeName];
    
    [GoalTab setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [GoalTab setTitleTextAttributes:highlightedAttributes forState:UIControlStateHighlighted];
    
    //[GoalTab setTintColor:KREYOS_GRAY];
    [GoalTab setSelectedSegmentIndex:0];
    [GoalTab setFrame:CGRectMake(GoalTab.frame.origin.x, GoalTab.frame.origin.y, GoalTab.frame.size.width, GoalTab.frame.size.height * 1.6f)];
    
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]} forState:UIControlStateSelected];

    [self updatePhotoBorder];
    [self segmentedControlCallback:GoalTab];
}

-(void)updatePhotoBorder
{
    id photo = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEF_PHOTO];
    if (!photo)return;

    //~~~Get the Layer of any view
    CALayer * profileImage = [self.profileImage layer];
    [profileImage setMasksToBounds:YES];
    [profileImage setCornerRadius:PHOTO_RAD];
    
    //~~~Border
    profileImage.borderWidth   = PHOTO_BORDER;
    profileImage.borderColor   = WHITE.CGColor;
}

- (IBAction) segmentedControlCallback:(UISegmentedControl*)sender
{
    for (int i=0; i<[sender.subviews count]; i++)
    {
        pickBtn.hidden = badgeDescription.hidden = carouselView.hidden = [[sender.subviews objectAtIndex:1] isSelected] == YES ? NO : YES;
        
        if ([[sender.subviews objectAtIndex:i]isSelected] )
        {
            UIColor *tintcolor= WHITE;
            [[sender.subviews objectAtIndex:i] setTintColor:tintcolor];
            
        }
        else
        {
            UIColor *tintcolor= KREYOS_GRAY;
            [[sender.subviews objectAtIndex:i] setTintColor:tintcolor];
            [[sender.subviews objectAtIndex:i] setBackgroundColor:KREYOS_GRAY];
            
        }
    }
}

#pragma mark SWIPE METHODS

-(void)handlePan:(UIPanGestureRecognizer *)gesture
{
    if ( gesture.view != inFrontBadge ) return;
    
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        //NSLog(@"Received a pan gesture");
        point = [gesture locationInView:gesture.view];
        
    }
    
    CGPoint newCoord = [gesture locationInView:gesture.view];
    float dX = newCoord.x-point.x;
    
    gesture.view.frame = CGRectMake(gesture.view.frame.origin.x+dX, gesture.view.frame.origin.y, gesture.view.frame.size.width, gesture.view.frame.size.height);
}



#pragma mark TABLE DELEGATES

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell	*cell;
	CBPeripheral	*peripheral;
	NSArray			*devices;
	NSInteger		row	= [indexPath row];
    static NSString *cellID = @"DeviceList";
    
	cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if (!cell)
    {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    if ([indexPath section] == 0)
    {
		devices     = [[LkDiscovery sharedInstance] connectedServices];
        peripheral  = [(LKreyosService*)[devices objectAtIndex:row] peripheral];
        
	} else {
		devices     = [[LkDiscovery sharedInstance] foundPeripherals];
        peripheral  = (CBPeripheral*)[devices objectAtIndex:row];
	}
    
    if ([[peripheral name] length])
        [[cell textLabel] setText:[peripheral name]];
    else
        [[cell textLabel] setText:@"Peripheral"];
    
    [[cell detailTextLabel] setText:[peripheral isConnected] ? @"Connected" : @"Not connected"];
    
    /* if( [peripheral isConnected] )
     [self SetThisButton:m_disconnectBtn setTruFalse:TRUE];
     */
	return cell;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger res = 0;
    
	if (section == 0)
		res = [[[LkDiscovery sharedInstance] connectedServices] count];
	else
		res = [[[LkDiscovery sharedInstance] foundPeripherals] count];
    
	return res;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	CBPeripheral	*peripheral;
	NSArray			*devices;
	NSInteger		row	= [indexPath row];

   
    if ([indexPath section] == 0)
    {
		devices     = [[LkDiscovery sharedInstance] connectedServices];
        peripheral  = [(LKreyosService*)[devices objectAtIndex:row] peripheral];
        
	} else {
		devices     = [[LkDiscovery sharedInstance] foundPeripherals];
    	peripheral  = (CBPeripheral*)[devices objectAtIndex:row];
	}
    
	if (![peripheral isConnected])
    {
        
		[[LkDiscovery sharedInstance] connectPeripheral:peripheral];
        [currentlyConnectedSensor setText:[NSString stringWithFormat: @"{%@}",[peripheral name]]];
        
        NSString *uuidString = [NSString stringWithFormat:@"%@", [[peripheral identifier] UUIDString]];
        [[NSUserDefaults standardUserDefaults] setObject:uuidString forKey:USERDEF_LASTDEVICE];
        
        // +AS:07172014 Please remove this.
        //[KreyosDataManager sharedInstance].DisplayingService = currentlyDisplayingService;
    }
	else
    {
        if ( currentlyDisplayingService != nil )
        {
            currentlyDisplayingService = nil;
        }
        
        connectedperipheral= peripheral;
        
        //UPDATE TIME
        [[BluetoothDelegate instance] updateTime];
        currentlyDisplayingService = [[BluetoothDelegate instance] serviceForPeripheral:peripheral];
        
        [currentlyConnectedSensor setText:[NSString stringWithFormat: @"{%@}",[peripheral name]]];
    }
}

#pragma mark TAP
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    if ([touch.view isKindOfClass: [UIImageView class]])
    {
        if (touch.view.tag == 5000)
        {
            [self.takeController takePhotoOrChooseFromLibrary];
        }
    }

}

#pragma mark SET UI LABELS
- (void) setUpAllUILabelData
{
    //SET FONTS
    [badgeDescription   setFont:FONT_BEBAS(15)];
    [self.badgeTitle    setFont:FONT_BEBAS(15)];
    [self.hrsLabel      setFont:FONT_BEBAS(40)];
    [self.minLabel      setFont:FONT_BEBAS(40)];
    [self.secondsLabel  setFont:FONT_BEBAS(40)];
}

#pragma mark - FDTakeDelegate
- (void)takeController:(FDTakeController *)controller didCancelAfterAttempting:(BOOL)madeAttempt
{
    return;
}

- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)info
{
    [self.profileImage setImage:photo];
    [userDef setObject:UIImageJPEGRepresentation(photo, 0.1f) forKey:USERDEF_PHOTO];
    
    [self updatePhotoBorder];
}

- (void) checkSession
{
    NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc] init];
    [userDictionary setObject:[KreyosDataManager getUserDefaultEmail] forKey:@"email"];
    [userDictionary setObject:[KreyosDataManager getUserDefaultOath]  forKey:@"auth_token"];
    
    //NEED TO ADD UID SINCE SOMETIMES FB DOESNT RETURN EMAIL DATA
    if ([KreyosDataManager sharedInstance].IsConnectedUsingFB)
    {
        [userDictionary setObject:[KreyosFacebookController sharedInstance].getUserID forKey:@"uid"];
    }
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:userDictionary options:0 error:&err];
    NSString * dataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [[RequestManager rm] sendRequestPostMethod:kServerSessionKeyURL withPostData:dataString target:self selector:@selector(sessionCheck:)];
}

- (void) sessionCheck : (NSData*)responseData
{
    NSError *error     = nil;
    NSDictionary *json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
    if([[KreyosDataManager sharedInstance] isSessionExpired:json navCont:self.navigationController])
    {
        [[KreyosDataManager sharedInstance] clearDataOnLogOut];
        
        LoginViewController *login =  [self.storyboard instantiateViewControllerWithIdentifier:LOGIN_STORYBOARD];
        [self.navigationController pushViewController:login animated:YES];
    }
}

-(IBAction)changeSceneDailyTarget:(id)sender{}

-(IBAction)btnDailyTargetCallback:(id)p_btn
{
#ifdef DEBUG_HOME_DATA
    [[BluetoothDelegate instance] readHomeData];
    return;
#endif
    
    NSDictionary* homeActivities    = [[DBManager getSharedInstance] getHomeActivities];
    BOOL hasTarget                  = (m_dataManager.totalData_Steps > 0) || (homeActivities && [homeActivities count]);
    NSString* const string[]        = { SEGUE_DAILY_TARGET, SEGUE_OVERALL_ACTIVITIES };
    [self performSegueWithIdentifier:string[ hasTarget ] sender:self];
}

-(void)setDailyTargetTitle:(BOOL)p_bHasTarget
{
    NSString* const string[] = { TITLE_LABEL_PICK_TARGET, TITLE_LABEL_OVERALL_TARGET };
    [self.btnDailyTarget setTitle:string[p_bHasTarget] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
