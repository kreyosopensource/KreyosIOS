//
//  FriendListsViewController.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/17/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosUIViewBaseViewController.h"
#import "AppDelegate.h"

@interface FriendListsViewController : KreyosUIViewBaseViewController
{
    AppDelegate *deleg;
}
+ (FriendListsViewController *)sharedLoader;
-(void) SendFacebookRequest:(NSString*)p_id;
-(void) hideLoadingState;

@property (strong, nonatomic) IBOutlet UITableView *friendListsTableView;
@property (strong, nonatomic) IBOutlet UIButton *inviteFriendBtn;
@property (nonatomic,strong) UIView* friend_view;
@property (nonatomic,strong) UIView* ranking_view;
@property (nonatomic,strong) UITableView* friend_data_view;
@property (nonatomic,strong) UITableView* ranking_data_view;
@property (nonatomic,strong) NSMutableArray *buttonStorage;
@property (nonatomic,strong) NSMutableDictionary *buttonReferences;

//IB ACTIONS
- (IBAction) chooseFiveFriendToDisplay:(id)sender;

@end
