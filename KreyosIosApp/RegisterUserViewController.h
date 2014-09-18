//
//  RegisterUser.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/16/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosUIViewBaseViewController.h"

@interface RegisterUserViewController : KreyosUIViewBaseViewController<UITextFieldDelegate>
{
    id m_currentSender;
    NSMutableDictionary *mFirstFormDict;
}

@property (strong, nonatomic) IBOutlet UITextField *userName;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UITextField *verifyPassword;
@property (strong, nonatomic) IBOutlet UIButton *registerButton;
@property (strong, nonatomic) IBOutlet UIButton *BackButton;

-(IBAction)tryRegister:(id)sender;
-(IBAction)backButton:(id)sender;

@end
