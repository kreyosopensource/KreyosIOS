//
//  LoginViewController.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/6/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "LoginViewController.h"
#import "KreyosHomeViewController.h"
#import "KreyosFacebookController.h"
#import "AppDelegate.h"
#import "KreyosUtility.h"
#import "RequestManager.h"
#import "DBManager.h"
#import "KreyosDataManager.h"
#import "Profile.h"
#import "FBEmailRegisterViewController.h"

#import "KreyosTutorialViewController.h"
#import "KreyosBluetoothViewController.h"
#import "BluetoothDelegate.h"

#import <Accounts/Accounts.h>
#import "OAuth+Additions.h"
#import "TWAPIManager.h"
#import "TWSignedRequest.h"
#import "AccountManager.h"
#import <FacebookSDK/FacebookSDK.h>


#define ERROR_TITLE_MSG @"Whoa, there user"
#define ERROR_NO_ACCOUNTS @"You must add a Twitter account in Settings."
#define ERROR_PERM_ACCESS @"We weren't granted access to the user's accounts"
#define ERROR_NO_KEYS @"You need to add your Twitter app keys to Info.plist to use this demo.\nPlease see README.md for more info."
#define ERROR_OK @"OK"

@interface LoginViewController () <FBLoginViewDelegate, UIAlertViewDelegate>
{
    AppDelegate *deleg;
    FBSession *session;
    BOOL viewIsMovedUp;
    
    
    NSMutableDictionary *m_userDictionary;
}

//Twitter Variables
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) TWAPIManager *apiManager;
@property (nonatomic, strong) NSArray *accounts;


@end

@implementation LoginViewController
@synthesize _facebookBtn;
@synthesize _twitterBtn;
@synthesize _googleBtn;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        m_currentSender = nil;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    _accountStore = [[ACAccountStore alloc] init];
    _apiManager = [[TWAPIManager alloc] init];
    
    //UNCOMMENT FOR TWITTER LOGIN
    //[self _refreshTwitterAccounts];
    
    [[KreyosDataManager sharedInstance] setActiveView:self];
}

- (void)viewDidLoad
{
    //*
    [super viewDidLoad];
    
    // set the current view on BluetoothDelegate
    [[BluetoothDelegate instance] setCurrentView:self];
    [[BluetoothDelegate instance] setIsUpdating:NO];
    //*/
     
    //~~~Debug Hex Data
    //[LoginViewController debugHexData];
}

+(void)debugHexData
{
    //NSString* hexData = @"00000000290000008A9D01005E06000000150E0A";
    NSString* hexData = @"00000000290000008a9d01005e0600000000003c";
    NSData* value = [LoginViewController dataWithHexString:hexData];
    
    int32_t i[4];
    [value getBytes: &i length: sizeof(i)];
    
    int32_t time = i[0];
    int32_t steps = i[1];
    int32_t cals = i[2];
    int32_t dist = i[3];
    
    NSLog( @"Home Data: Time%i Steps:%i Cal:%i Dist:%i", time, steps, cals, dist );
}

+(id)dataWithHexString:(NSString*)hex
{
	char buf[3];
	buf[2]  = '\0';
	unsigned char *bytes = (unsigned char*)malloc([hex length]/2);
	unsigned char *bp = bytes;
	for (CFIndex i = 0; i < [hex length]; i += 2)
    {
		buf[0] = [hex characterAtIndex:i];
		buf[1] = [hex characterAtIndex:i+1];
		char *b2 = NULL;
		*bp++ = strtol(buf, &b2, 16);
	}
	
	return [NSData dataWithBytesNoCopy:bytes length:[hex length]/2 freeWhenDone:YES];
}

- (void) viewDidAppear:(BOOL)animated
{
    
    [super hideNavigationItem:self]; 
    
    deleg =  (AppDelegate* )[[UIApplication sharedApplication] delegate];
    
    viewIsMovedUp = NO;
    
    [self.userName setDelegate:self];
    [self.password setDelegate:self];
    
    [self.userName setLeftViewMode:UITextFieldViewModeAlways];
    self.userName.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kreyosid"]];
    self.userName.leftView.frame = CGRectMake(5, 0, 30, 30);
    
    //Hide indicator
    self.mActivityIndicatorView.layer.cornerRadius = 10;
    [self.mActivityIndicatorView setHidden:YES];
    
    
    [self.password setLeftViewMode:UITextFieldViewModeAlways];
    self.password.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"password"]];
    self.password.leftView.frame = CGRectMake(5, 0, 30, 30);
    //Add Login FB
    FBLoginView *loginview = [[FBLoginView alloc] initWithPublishPermissions:[NSArray arrayWithObjects:@"publish_actions", @"email", @"user_birthday", nil] defaultAudience:FBSessionDefaultAudienceFriends];
    
    //Notification Center
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshTwitterAccounts) name:ACAccountStoreDidChangeNotification object:nil];
    
    //Set Anchors
    [loginview.layer setAnchorPoint:CGPointMake(0.5, 0)];
    
    CGRect usedFrame = _facebookBtn.frame;
    usedFrame.origin.y += IS_IPHONE_5 ? 70 : 25;
    usedFrame.size.height += 10;
    loginview.frame = usedFrame;
    
    
    CGRect socialFrame = _twitterBtn.frame;
    socialFrame.origin = CGPointMake(loginview.frame.origin.x + 90, loginview.frame.origin.y + 30);
    _twitterBtn.frame = socialFrame;
    
    socialFrame.origin = CGPointMake(socialFrame.origin.x + 90, socialFrame.origin.y);
    _googleBtn.frame = socialFrame;
    
    loginview.delegate = self;
    
    ADD_TO_ROOT_VIEW(loginview);
    
}

- (void) establishLoginUser
{
    //Check for Internet Connection
    if( ![deleg isConnectedToWifi] ) return;
    
    //TRY LOGIN USING SESSION COOKIE
    if ( ![KreyosDataManager getUserDefaultEmail] || ![KreyosDataManager getUserDefaultOath] ) {
        return;
    }
    
    NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc] init];
    [userDictionary setObject:[KreyosDataManager getUserDefaultEmail] forKey:@"email"];
    [userDictionary setObject:[KreyosDataManager getUserDefaultOath]  forKey:@"auth_token"];
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:userDictionary options:0 error:&err];
    NSString * dataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self showProgress:YES];
    [[RequestManager rm] sendRequestPostMethod:kServerSessionKeyURL withPostData:dataString target:self selector:@selector(tryLoginBySessionKey:)];

}

#pragma mark FACEBOOK LOGIN

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [FBLoginView class];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}

// This method will be called when the user information has been fetched
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    NSLog(@"Fetched User Info ");
    
    [KreyosFacebookController sharedInstance].FbUser = user;
    
    NSString* fbAccessToken = [FBSession activeSession].accessTokenData.accessToken;
    NSString* uid           = (NSString*)[user id];
    
    m_userDictionary = [[NSMutableDictionary alloc] init];
    [m_userDictionary setObject:uid             forKey:@"uid"];
    [m_userDictionary setObject:fbAccessToken   forKey:@"auth_token"];
    [m_userDictionary setObject:@"facebook"     forKey:@"provider"];
    
    NSString *emailOfUser = [user objectForKey:@"email"];
    NSString *alternativeEmail = [NSString stringWithFormat:@"%@@facebook.com", [user username]];
    
    [KreyosDataManager setUserDefaultOath:fbAccessToken];
    [KreyosDataManager setUserUID:uid];
    
    Profile* userprofile    = [[Profile alloc] init];
    [userprofile clear];
    userprofile.email       = emailOfUser;
    userprofile.fbToken     = fbAccessToken;
    userprofile.firstName   = [user first_name];
    userprofile.lastName    = [user last_name];
    userprofile.birthday    = [user birthday];
    [userprofile saveData];
    
    if(emailOfUser)
    {
        [m_userDictionary setObject:emailOfUser  forKey:@"email"];
        [KreyosDataManager setUserDefaultEmail:emailOfUser];
    }
    else
    {
        [m_userDictionary setObject:alternativeEmail forKey:@"email"];
        [KreyosDataManager setUserDefaultEmail:alternativeEmail];
    }
    
    NSError     * err;
    NSData      * jsonData      = [NSJSONSerialization dataWithJSONObject:m_userDictionary options:0 error:&err];
    NSString    * dataString    = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [[RequestManager rm] sendRequestPostMethod:kServerFacebookLogin withPostData:dataString target:self selector:@selector(fbCallBack:)];
}

-(void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    
    if( [KreyosDataManager sharedInstance].isConnectedToWifi ){
        [self showProgress:YES];
    }
}


- (void) fbCallBack:(NSData*)responseData
{
    [self showProgress:NO];
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    // Initialize db
    [[DBManager getSharedInstance] initDB];
    
    [self moveUserAfterLogin];

    [KreyosDataManager sharedInstance].IsConnectedUsingFB = YES;
    [AccountManager getSharedAccountManager].userID = 1;
}

-(void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    NSLog(@"Logged Out user");
    
    [self establishLoginUser];
}

-(void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    NSLog(@"Error %@", error);
    
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended)
    {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];

        [self performSegueWithIdentifier:SEGUE_LOADING_TO_MAINSCREEN sender:self];
        
        [[KreyosFacebookController sharedInstance] releaseData];
        // If the session state is not any of the two "open" states when the button is clicked
    }
    
    if (! [deleg isConnectedToWifi] ) return;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag           = textField.tag + 1;
    UIResponder* nexResponder   = [textField.superview viewWithTag:nextTag];
    
    if (nexResponder && [self.password.text length] <= 0)
    {
        [nexResponder becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{}
-(void)textFieldDidEndEditing:(UITextField *)textField{}

-(void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    const int movementDistance      = -130; // tweak as needed
    const float movementDuration    = 0.3f; // tweak as needed
    
    viewIsMovedUp = up;
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark LOGIN USING SESSION KEY
- (void) tryLoginBySessionKey : (NSData*)responseData
{
    NSString *dataParsed = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"LOGIN DATA RECEIVED %@", dataParsed);
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
    // Initialize db
    [[DBManager getSharedInstance] initDB];
    
    int status = [[json objectForKey:@"status"] intValue];
    
    if( status == kLoginSuccess)
    {
        [KreyosDataManager sharedInstance].IsConnectedUsingFB = NO;
        
        [AccountManager getSharedAccountManager].userID = 1;
        
        //Set connected to app
        [KreyosDataManager sharedInstance].IsMainBluetoothSearchShown = YES;
        
        [self moveUserAfterLogin];
    }
    
    [self showProgress:NO];
}

-(IBAction)tryLogin:(id)sender
{
#ifdef BYPASS_LOGIN
    [self didLoginUser:nil];
    [self performSegueWithIdentifier:SEGUE_LOGIN_TO_FIRSTTIME sender:sender];
    return;
#endif
    //Check for Internet Connection
    if( ![deleg isConnectedToWifi] ) return;
    
#ifndef DEBUG_BYPASS_LOGIN
    NSLog(@"this is the login Button! %@",self.userName.text);
    if(self.userName.text.length != 0 && self.password.text.length != 0)
    {
        m_currentSender = sender;
        
        if ( ! [[KreyosDataManager sharedInstance] isConnectedToWifi]) return;
        
        //Show indicator
        [self showProgress:YES];
        
        //UNCOMMENT WHEN USING WEB DB -Kreyos
        
        NSMutableDictionary *userDictionary = [[NSMutableDictionary alloc] init];
        [userDictionary setObject:self.userName.text forKey:@"email"];
        [userDictionary setObject:self.password.text forKey:@"password"];
        
        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:userDictionary options:0 error:&err];
        NSString * dataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [[RequestManager rm] sendRequestPostMethod:kServerUserLoginURL withPostData:dataString target:self selector:@selector(didLoginUser:)];
        
    }
    else
    {
        
        NSLog(@"User Name or Password Incomplete!");
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"User Authentication Error"
                                                          message:@"Username or password field are missing!"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        //self.userName.text = nil;
        self.password.text = nil;
        
        [message show];
        
        
    }
#else
    [self performSegueWithIdentifier:SEGUE_LOGIN_TO_FIRSTTIME sender:sender];
#endif
}

#pragma mark LOGIN CALLBACKS
-(void)didLoginUser:(NSData*)pResponseData
{
#ifdef BYPASS_LOGIN
    [AccountManager getSharedAccountManager].userID = 1;
    static NSString* user = @"Kreyos_test";
    static NSString* email = @"Kreyos_test@gmail.com";
    static NSString* auth = @"123123qweasd123qwesd123qwe123";
    
    //SAVE AUTHENTICATION KEY
    [KreyosDataManager setUserDefaultOath:auth];
    [KreyosDataManager setUserDefaultEmail:email];
    
    //SAVE CURRENT PROFILE
    Profile* profile        = [[Profile alloc] init];
    [profile clear];
    profile.email           = email;
    profile.kreyosToken     = auth;
    profile.firstName       = @"Kreyos";
    profile.lastName        = @"meteor";
    profile.gender          = @"male";
    profile.fbToken         = @"";
    profile.birthday        = @"";
    profile.weight          = @"";
    profile.height          = @"";
    [profile saveData];
    
    // Initialize db
    [[DBManager getSharedInstance] initDB];
    
    //Set connected to app
    [KreyosDataManager sharedInstance].IsMainBluetoothSearchShown = YES;
    
    //Hide indicator
    [self showProgress:NO];
    return;
#endif
    
    NSString *dataParsed = [[NSString alloc] initWithData:pResponseData encoding:NSUTF8StringEncoding];
    NSLog(@"DATA RECEIVED %@", dataParsed);
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:pResponseData
                                                         options:kNilOptions
                                                           error:&error];
    
    int requestCallback = [[json objectForKey:@"status"] intValue];
    //int userID = [[[json objectForKey:@"user"]  objectForKey:@"id"] intValue];
    [AccountManager getSharedAccountManager].userID = 1;

    if(requestCallback == kLoginSuccess)
    {
        [self moveUserAfterLogin];
        
        //SAVE AUTHENTICATION KEY
        [KreyosDataManager setUserDefaultOath:[[json objectForKey:@"user"] objectForKey:@"auth_token"] ];
        [KreyosDataManager setUserDefaultEmail:[[json objectForKey:@"user"] objectForKey:@"email"] ];
        
        //SAVE CURRENT PROFILE
        NSDictionary* userData  = [json objectForKey:@"user"];
        Profile* profile        = [[Profile alloc] init];
        [profile clear];
        profile.email           = [userData objectForKey:@"email"];
        profile.kreyosToken     = [userData objectForKey:@"auth_token"];
        profile.firstName       = [userData objectForKey:@"first_name"];
        profile.lastName        = [userData objectForKey:@"last_name"];
        profile.gender          = [userData objectForKey:@"gender"];
        profile.fbToken         = @"";
        profile.birthday        = @"";
        profile.weight          = @"";
        profile.height          = @"";
        [profile saveData];
        
        // Initialize db
        [[DBManager getSharedInstance] initDB];
        
        //Set connected to app
        [KreyosDataManager sharedInstance].IsMainBluetoothSearchShown = YES;
    }
    else
    {
        
        NSLog(@"Authentication Not Completed!");
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"User Authentication Error"
                                                          message:[json objectForKey:@"message"]
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        //self.userName.text = nil;
        self.password.text = nil;
        
        [message show];
    }
    
    //Hide indicator
    [self showProgress:NO];
}

#pragma mark TWITTER DELEGATES
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [_apiManager performReverseAuthForAccount:_accounts[buttonIndex] withHandler:^(NSData *responseData, NSError *error) {
            if (responseData) {
                NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                
                KLog(@"Reverse Auth process returned: %@", responseStr);
                
                NSArray *parts = [responseStr componentsSeparatedByString:@"&"];
                NSString *lined = [parts componentsJoinedByString:@"\n"];
                NSString *message = @"Thanks for Logging In!";
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    alert.delegate = self;
                    
                    [alert show];
                });
            }
            else {
                KWLog(@"Reverse Auth process failed. Error returned was: %@\n", [error localizedDescription]);
            }
        }];
    }
}

#pragma mark ALERTVIEW DELEGATE
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self performSegueWithIdentifier:SEGUE_LOADING_TO_MAINSCREEN sender:self];
    
}

- (void)_refreshTwitterAccounts
{
    KLog(@"Refreshing Twitter Accounts \n");
    
    if (![TWAPIManager hasAppKeys]) {
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE_MSG message:ERROR_NO_KEYS delegate:nil cancelButtonTitle:ERROR_OK otherButtonTitles:nil];
        //[alert show];
    }
    else if (![TWAPIManager isLocalTwitterAccountAvailable]) {
        ///UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE_MSG message:ERROR_NO_ACCOUNTS delegate:nil cancelButtonTitle:ERROR_OK otherButtonTitles:nil];
        //[alert show];
    }
    else {
        [self _obtainAccessToAccountsWithBlock:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    //_reverseAuthBtn.enabled = YES;
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:ERROR_TITLE_MSG message:ERROR_PERM_ACCESS delegate:nil cancelButtonTitle:ERROR_OK otherButtonTitles:nil];
                    [alert show];
                    KWLog(@"You were not granted access to the Twitter accounts.");
                }
            });
        }];
    }
}

- (IBAction)performReverseAuth:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Choose an Account" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (ACAccount *acct in _accounts) {
        [sheet addButtonWithTitle:acct.username];
    }
    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
    [sheet showInView:self.view];
}

- (void)_obtainAccessToAccountsWithBlock:(void (^)(BOOL))block
{
    ACAccountType *twitterType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
        if (granted) {
            self.accounts = [_accountStore accountsWithAccountType:twitterType];
        }
        
        block(granted);
    };
    [_accountStore requestAccessToAccountsWithType:twitterType options:NULL completion:handler];
}

-(IBAction)registerNewUser:(id)sender
{
    
    if ( ![[KreyosDataManager sharedInstance] isConnectedToWifi ]) return;
    
    [self performSegueWithIdentifier:SEGUE_LOADING_TO_REGISTERUSER sender:self];

    /*
    BOOL _hasUser = [[DBManager getSharedInstance] getIfUserisLoggedIn];
   
    if(!_hasUser)
    {
        
     KLog(@"Register New User!");
    [self performSegueWithIdentifier:SEGUE_LOADING_TO_REGISTERUSER sender:sender];
    }
    else
    {
        KLog(@"User Name or Password Incomplete!");
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Currently Unavailable"
                                                          message:@"Already Has a User!"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        self.userName.text = nil;
        self.password.text = nil;
        
        [message show];
    }'*/
}

#pragma mark LOGIN 
- (void) moveUserAfterLogin
{
    BOOL hasLoggedInBefore = (BOOL)[USERDATA objectForKey:@"isUserLogB4"];
    
    //INITIALIZE BLUETOOTH CLASS
    [[BluetoothDelegate instance] initialize];
    [[BluetoothDelegate instance] initializeFileTransistor];
    [[BluetoothDelegate instance] setDidLogOut:NO];
    
    if( !hasLoggedInBefore)
    {
        [self performSegueWithIdentifier:SEGUE_LOGIN_TO_FIRSTTIME sender:m_currentSender];
    }
    else
    {
        [self performSegueWithIdentifier:SEGUE_LOADING_TO_MAINSCREEN sender:m_currentSender];
    }
}

#pragma mark SHOW PROGRESS
- (void) showProgress:(BOOL)pb
{
    if (pb){
        [self.mActivityIndicatorView setHidden:NO];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    }else{
        [self.mActivityIndicatorView setHidden:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
}

#pragma mark PREPARE FOR SEGUE
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // CHECK IF YOUR DESTINATION CLASS IS FBEMAILREGISTER
    if ( [[segue destinationViewController] isKindOfClass:[FBEmailRegisterViewController class]] )
    {
        [(FBEmailRegisterViewController*)[segue destinationViewController] registerWithData:m_userDictionary];
    }
}


@end
