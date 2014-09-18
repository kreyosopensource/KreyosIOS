//
//  KreyosTutorialSoftwareUpdate.h
//  KreyosIosApp
//
//  Created by Kreyos on 8/26/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosUIViewBaseViewController.h"



@interface KreyosTutorialSoftwareUpdate : KreyosUIViewBaseViewController

@property (strong, nonatomic)   IBOutlet UIButton*                      mbtnNextButton;
@property (strong, nonatomic)   IBOutlet UIButton*                      mbtnPleaseWait;
@property (strong, nonatomic)   IBOutlet UILabel*                       mLabelUpdate;
@property (strong, nonatomic)   IBOutlet UIActivityIndicatorView*       mLoadingIndicator;

@end
