//
//  KreyosTutorialTableViewController.h
//  KreyosIosApp
//
//  Created by Kreyos on 8/26/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosUIViewBaseViewController.h"
#import "EAManager.h"
#import "LKreyosService.h"

@interface KreyosTutorialTableViewController : KreyosUIViewBaseViewController


@property (strong)              EAManager *             externalAccessoryMgr;
@property (strong, nonatomic)   IBOutlet UIView*        bluetoothTableHolder;
@property (strong, nonatomic)   IBOutlet UITableView*   mTBluetoothTable;
@property (strong, nonatomic)   IBOutlet UIButton*      mNextButton;
@end
