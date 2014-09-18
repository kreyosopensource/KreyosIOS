//
//  RegisterUser.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/16/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

//#define DEBUGREG

#import "RegisterUserViewController.h"
#import "RegisterUserIIBaseViewController.h"
#import "KreyosUtility.h"
#import "RequestManager.h"
#import "AccountManager.h"
#import "KreyosUtility.h"


@interface RegisterUserViewController ()

@end

@implementation RegisterUserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        m_currentSender = nil;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.userName setDelegate:self];
    [self.password setDelegate:self];
    [self.verifyPassword setDelegate:self];
    
    //ADD SPACE ON UITEXTFIELD
    UILabel * leftView = [[UILabel alloc] initWithFrame:CGRectMake(20,0,7,26)];
    leftView.backgroundColor = [UIColor clearColor];
    
    self.userName.leftView = leftView;
    self.userName.leftViewMode =  UITextFieldViewModeAlways;
    self.userName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    //allocate again
    leftView = [[UILabel alloc] initWithFrame:CGRectMake(20,0,7,26)];
    leftView.backgroundColor = [UIColor clearColor];
    self.password.leftView = leftView;
    self.password.leftViewMode =  UITextFieldViewModeAlways;
    self.password.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    //allocate again
    leftView = [[UILabel alloc] initWithFrame:CGRectMake(20,0,7,26)];
    leftView.backgroundColor = [UIColor clearColor];
    self.verifyPassword.leftView = leftView;
    self.verifyPassword.leftViewMode =  UITextFieldViewModeAlways;
    self.verifyPassword.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    //NSMUTABLEDICT FOR REGISTERING
    mFirstFormDict = [[NSMutableDictionary alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(void)registerAction:(NSData*)p_data
{
    
    if([self.userName.text isEqualToString:@"admin"])
    {
        NSLog(@"Authentication Not Completed!");
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Registration Error"
                                                          message:[NSString stringWithFormat:@"ID %@ has been taken!", self.userName.text]
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        self.userName.text       = nil;
        self.password.text       = nil;
        self.verifyPassword.text = nil;
        
        [message show];
    }
    else
    {
        
        
        //TO DO THIS DATA MUST COME FROM CLOUD
        [AccountManager getSharedAccountManager].userID=1;
        
        
        
        [AccountManager getSharedAccountManager].userName=self.userName.text;
        [AccountManager getSharedAccountManager].pass   =self.password.text;
        [self performSegueWithIdentifier:SEGUE_REGISTER_TO_REGISTER2 sender:m_currentSender];
    }
    
    
}
-(IBAction)tryRegister:(id)sender
{
    
#ifdef DEBUGREG
    [self performSegueWithIdentifier:SEGUE_REGISTER_TO_REGISTER2 sender:self];
    return
#endif
    
    NSLog(@"Register New User Try!");
    if ( ![self NSStringIsValidEmail:self.userName.text] )
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:REGISTRATION_EMAIL_ERROR_TITLE
                                                          message:REGISTRATION_EMAIL_ERROR_MESSAGE
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
    }
    else if(self.userName.text.length == 0 || self.password.text.length == 0 || self.verifyPassword.text.length == 0)
    {
        NSLog(@"Authentication Not Completed!");
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:REGISTRATION_MISSING_FIELD_ERROR_TITLE
                                                          message:REGISTRATION_MISSING_FIELD_ERROR_MESSAGE
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        self.userName.text       = nil;
        self.password.text       = nil;
        self.verifyPassword.text = nil;
        
        [message show];
    }
    else if (self.password.text.length < 8)
    {
        NSLog(@"Authentication Not Completed!");
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:REGISTRATION_PASS_CHARACTER_ERROR_TITLE
                                                          message:REGISTRATION_PASS_CHARACTER_ERROR_MESSAGE
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        self.userName.text       = nil;
        self.password.text       = nil;
        self.verifyPassword.text = nil;
        
        [message show];
    }
    else if(![self.password.text isEqualToString:self.verifyPassword.text])
    {
        
        NSLog(@"Authentication Not Completed!");
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:REGISTRATION_PASS_NOT_MATCH_ERROR_TITLE
                                                          message:REGISTRATION_PASS_NOT_MATCH_ERROR_MESSAGE
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        self.userName.text       = nil;
        self.password.text       = nil;
        self.verifyPassword.text = nil;
        
        [message show];
        
    }
    else
    {
        //UNCOMMENT WHEN USING WEB DB -Kreyos
        NSMutableDictionary *emailReg = [[NSMutableDictionary alloc] init];
        [emailReg setObject:self.userName.text forKey:@"email"];
        
        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:emailReg options:NSJSONWritingPrettyPrinted error:&err];
        NSString * dataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
#ifdef LOCAL
        [[RequestManager rm] sendRequestPostMethod:kServerUserCheckMailDEBUG withPostData:dataString target:self selector:@selector(checkEmailIfTaken:)];
#else
        [[RequestManager rm] sendRequestPostMethod:kServerUserCheckMail withPostData:dataString target:self selector:@selector(checkEmailIfTaken:)];
#endif
        
       /*
        m_currentSender = sender;
        [[RequestManager rm] sendRequest:@"https://www.google.com.ph/?gfe_rd=ctrl&ei=o0wlU8SQKoqE8QeV7YGQCA&gws_rd=cr" target:self selector:@selector(registerAction:)];
       */
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

-(BOOL) CheckIfHasIllegalCharacters:(NSString*)pStr
{
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"] invertedSet];
    
    if ([pStr rangeOfCharacterFromSet:set].location != NSNotFound) {
        return YES;
    }
    
    return NO;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [segue.identifier isEqualToString:SEGUE_REGISTER_TO_REGISTER2] )
    {
        [((RegisterUserIIBaseViewController*)segue.destinationViewController) addDataFromFirstForm:mFirstFormDict];
    }
}

- (void) checkEmailIfTaken:(NSData*)responseData
{
    NSString *dataParsed = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    KLog(@"RESPONSE %@", dataParsed);
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    int requestCallback = [[json objectForKey:@"status"] intValue];
    UIAlertView *alvw;
    
    switch (requestCallback) {
        case 204:
            
            alvw = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Email is already taken" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alvw show];
            
            return;
            break;
            
        case 200:
        {
            [mFirstFormDict setObject:self.userName.text            forKey:@"email"];
            [mFirstFormDict setObject:self.password.text            forKey:@"password"];
            [mFirstFormDict setObject:self.verifyPassword.text      forKey:@"password_confirmation"];
            
            [self performSegueWithIdentifier:SEGUE_REGISTER_TO_REGISTER2 sender:self];
        }
        break;
            
        default:
        break;
    }
    
    
//    [self performSegueWithIdentifier:SEGUE_REGISTER_TO_REGISTER2 sender:sender];
}

-(IBAction)backButton:(id)sender
{
    
    [self performSegueWithIdentifier:SEGUE_REGISTER_TOLOGIN sender:sender];
    
}



@end
