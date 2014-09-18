//
//  FBEmailRegisterViewController.h
//  KreyosIosApp
//
//  Created by Kreyos on 5/27/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosUIViewBaseViewController.h"

@interface FBEmailRegisterViewController : KreyosUIViewBaseViewController
@property (weak, nonatomic) IBOutlet UITextField *mEmailField;
@property (weak, nonatomic) IBOutlet UIButton *mRegisterBtn;

- (void) registerWithData:(NSMutableDictionary*)p_data;

@end
