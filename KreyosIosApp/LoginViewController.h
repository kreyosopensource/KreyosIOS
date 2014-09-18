//
//  LoginViewController.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/6/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosUIViewBaseViewController.h"

@interface LoginViewController : KreyosUIViewBaseViewController<UITextFieldDelegate, UIActionSheetDelegate>
{
    id m_currentSender;
}

@property (weak, nonatomic) IBOutlet UIButton *_facebookBtn;
@property (strong, nonatomic) IBOutlet UIButton *_twitterBtn;
@property (strong, nonatomic) IBOutlet UIButton *_googleBtn;


@property (strong, nonatomic) IBOutlet UITextField *userName;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIView *mActivityIndicatorView;

-(IBAction)tryLogin:(id)sender;
-(IBAction)registerNewUser:(id)sender;
- (void) showProgress:(BOOL)pb;

@end
