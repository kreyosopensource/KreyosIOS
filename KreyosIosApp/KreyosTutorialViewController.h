//
//  KreyosTutorialViewController.h
//  KreyosIosApp
//
//  Created by Kreyos on 4/2/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosUIViewBaseViewController.h"
#import "CustomUILabelProxi.h"
#import "BluetoothManager.h"
#import "EAManager.h"

@interface KreyosTutorialViewController : KreyosUIViewBaseViewController

//Tutorial Screens
@property (strong, nonatomic) IBOutlet UIView *mPFirstTutorialPage;
@property (strong, nonatomic) IBOutlet UIView *mPFirstIITutorialPage;
@property (strong, nonatomic) IBOutlet UIView *mPSecondTutorialPage;
@property (strong, nonatomic) IBOutlet UIView *mPThirdTutorialPage;
@property (strong, nonatomic) IBOutlet UIView *mPFourthTutorialPage;
@property (strong, nonatomic) IBOutlet UIView *mPFifthTutorialPage;
@property (strong, nonatomic) IBOutlet UIView *mPSixthTutorialPage;


@property (strong, nonatomic) IBOutlet UITableView *mTBluetoothTable;
@property (strong, nonatomic) IBOutlet UIView *mTBluetoothTableHolder;
@property (weak, nonatomic) IBOutlet UIButton *mIhaveConnected;
@property (weak, nonatomic) IBOutlet UIButton *mPairingNextButton;


@property (strong, nonatomic) IBOutlet UIButton *mfirstTutContinueBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *updateProgressIndicator;
@property (weak, nonatomic) IBOutlet CustomUILabelProxi *checkingForUpdateLabel;

//@property (strong) BluetoothManager *blueMgr;
@property (strong) EAManager *externalAccessoryMgr;

@end
