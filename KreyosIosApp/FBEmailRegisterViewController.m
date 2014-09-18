//
//  FBEmailRegisterViewController.m
//  KreyosIosApp
//
//  Created by Kreyos on 5/27/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "FBEmailRegisterViewController.h"
#import "RequestManager.h"
#import "KreyosUtility.h"
#import "KreyosDataManager.h"
#import "AccountManager.h"

@interface FBEmailRegisterViewController ()
{
    NSMutableDictionary* m_dict;
}
@end

@implementation FBEmailRegisterViewController

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
    
    
}

- (void) registerWithData:(NSMutableDictionary*)p_data
{
    if(!m_dict)
        m_dict = [[NSMutableDictionary alloc] init];
        
    m_dict = p_data;
}

- (IBAction)registerEmail:(id)sender
{
    //CHECK IF USER ENTERED AN EMAIL
    if ( [self.mEmailField.text length] == 0 )
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:REGISTRATION_MISSING_FIELD_ERROR_TITLE message:REGISTRATION_MISSING_FIELD_ERROR_MESSAGE delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
        return;
    }
    
    //CHECK IF EMAIL IS VALID
    if ( ![self NSStringIsValidEmail:self.mEmailField.text] ) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:REGISTRATION_EMAIL_ERROR_TITLE message:REGISTRATION_EMAIL_ERROR_MESSAGE delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alertView show];
        return;
    }
    
    [m_dict setObject:self.mEmailField.text forKey:@"email"];
    
    NSLog(@"EMAIL FB  : %@", self.mEmailField.text);
    
    NSError     * err;
    NSData      * jsonData      = [NSJSONSerialization dataWithJSONObject:m_dict options:0 error:&err];
    NSString    * dataString    = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [[RequestManager rm] sendRequestPostMethod:kServerFacebookLogin withPostData:dataString target:self selector:@selector(fbCallBack:)];
}

-(void) fbCallBack:(id)sender
{
   [self performSegueWithIdentifier:@"email->firsttime" sender:self];
}

- (void) moveUserAfterLogin
{
    BOOL hasLoggedInBefore = (BOOL)[USERDATA objectForKey:@"isUserLogB4"];
    
    if( !hasLoggedInBefore)
    {
        [self performSegueWithIdentifier:@"email->firsttime" sender:self];
    }
    else
    {
        [self performSegueWithIdentifier:@"email->mainpage" sender:self];
    }
    
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
