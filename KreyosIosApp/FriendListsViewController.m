//
//  FriendListsViewController.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/17/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//
#define FRIENDS_TABLE @"ftable"

#import "FriendListsViewController.h"
#import "KreyosUtility.h"
#import "KreyosFBFriendCell.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"

@interface FriendListsViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *friends_data;
    NSMutableArray *ranking_data;
    NSMutableArray *facebookFriendIDList;
    NSMutableArray *facebookFriendRankingList;
}
@end

@implementation FriendListsViewController
@synthesize inviteFriendBtn;
@synthesize friendListsTableView;
@synthesize buttonStorage;
@synthesize buttonReferences;
@synthesize friend_view;
@synthesize friend_data_view;
@synthesize ranking_data_view;
@synthesize ranking_view;

static FriendListsViewController *sharedInstance = nil;

+ (FriendListsViewController *)sharedLoader
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:friendListsTableView forKey:FRIENDS_TABLE];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    self.friendListsTableView = [coder decodeObjectForKey:FRIENDS_TABLE];
}

/*
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configur*e the view for the selected state
}*/

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setUpFriendsData];
}

- (void)setUpFriendsData
{
    [friendListsTableView setDelegate:self];
    [friendListsTableView setDataSource:self];
    
    //INIT FB FRIENDS
    friends_data = [[NSMutableArray alloc] init];
    ranking_data = [[NSMutableArray alloc] init];
    facebookFriendIDList = [[NSMutableArray alloc] init];
    facebookFriendRankingList = [[NSMutableArray alloc] init];
    
    [FBRequestConnection startForMyFriendsWithCompletionHandler:
     ^(FBRequestConnection *connection, id<FBGraphUser> friends, NSError *error)
     {
         if(!error){
             
             NSDictionary *dict = [friends objectForKey:@"data"];
             NSLog(@"FRIEND %@" , dict);
             for (NSDictionary *frDct in dict) {
                 
                 [facebookFriendIDList addObject:frDct];
                 [facebookFriendRankingList addObject:frDct];
             }
             
             [self chooseFiveFriendToDisplay:self];
             [self chooseSixFriendToDisplayRank];
         }
     }];
}

- (IBAction) chooseFiveFriendToDisplay:(id)sender
{
    dispatch_queue_t queue = dispatch_queue_create("getFriendList", NULL);
    
    dispatch_async(queue, ^{
        //dispatch_retain([self hideLoadingState]);
        for(int x = 0 ; x < 5; x++)
        {
            if ( [facebookFriendIDList count] <= 0 ) return ;
            int randomFriend = arc4random() % [facebookFriendIDList count];
            
            NSMutableDictionary* fholder = [[NSMutableDictionary alloc] init];
            NSDictionary *dictPick = [facebookFriendIDList objectAtIndex:randomFriend];
            
            if ( dictPick == NULL) return ;
            
            [fholder setObject:[dictPick objectForKey:@"name"] forKey:@"name"];
            [fholder setObject:[dictPick objectForKey:@"id"] forKey:@"id"];
            
            
            //int fID = [[frDct objectForKey:@"id"] intValue];
            NSString *imageUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", (NSDictionary<FBGraphUser> *)[dictPick objectForKey:@"id"]];
            NSURL *url = [NSURL URLWithString:imageUrl];
            
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *img = [[UIImage alloc] initWithData:data];
            
            [fholder setObject:img forKey:@"image"];
            [fholder setObject:[NSNumber numberWithBool:NO] forKey:@"added"];
            [friends_data addObject:fholder];
            
            [facebookFriendIDList removeObjectAtIndex:randomFriend];
            
        }
        
        [friendListsTableView reloadData];
        
    });
}


-(void)chooseSixFriendToDisplayRank
{
    /*
    if( ![deleg isConnectedToWifi]) return;
    
    dispatch_queue_t queue = dispatch_queue_create("getRankingList", NULL);
    
    dispatch_async(queue, ^{
        //dispatch_retain([self hideLoadingState]);
        for(int x = 0 ; x < 6; x++)
        {
            if ([facebookFriendRankingList count] <= 0) return ;
            
            int randomFriend = arc4random() % [facebookFriendRankingList count];
            
            NSMutableDictionary* rholder = [[NSMutableDictionary alloc] init];
            NSDictionary *dictPick = [facebookFriendRankingList objectAtIndex:randomFriend];
            
            if ( dictPick == NULL) return ;
            
            [rholder setObject:[dictPick objectForKey:@"name"] forKey:@"name"];
            [rholder setObject:[dictPick objectForKey:@"id"] forKey:@"id"];
            
            
            //int fID = [[frDct objectForKey:@"id"] intValue];
            NSString *imageUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", (NSDictionary<FBGraphUser> *)[dictPick objectForKey:@"id"]];
            NSURL *url = [NSURL URLWithString:imageUrl];
            
            NSData *data = [NSData dataWithContentsOfURL:url];
            UIImage *img = [[UIImage alloc] initWithData:data];
            
            [rholder setObject:img forKey:@"image"];
            [rholder setObject:[NSNumber numberWithInt:50] forKey:@"score"];
            [ranking_data addObject:rholder];
            
            [facebookFriendRankingList removeObjectAtIndex:randomFriend];
            
        }
        
        [ranking_data_view reloadData];
        
    });
    */
}

#pragma mark --- TABLE VIEW DELEGATES ------

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:friendListsTableView])
    {
        if (IS_IPHONE_5)
        {
            return 57.5f;
        }
        return 49.5f;
    }
    else
    {
        if (IS_IPHONE_5)
        {
            return 42.5f;
        }
        return 33.5f;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:friendListsTableView])
    {
        return [friends_data count];
    }
    else
    {
        return [ranking_data count];
    }
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *result = nil;
    if ([tableView isEqual:friendListsTableView])
    {
        static NSString *TableViewCellIdentifier = @"FriendsCells";
        result = [tableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier];
        if (result == nil)
        {
            
            result = [[KreyosFBFriendCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                               reuseIdentifier:TableViewCellIdentifier];
            
            result.selectionStyle = UITableViewCellSelectionStyleNone;
            NSLog(@"TAG : %@", [[friends_data objectAtIndex:indexPath.row] valueForKey:@"id"]);
            
        }
        
        KreyosFBFriendCell* fb_cell = (KreyosFBFriendCell*)result;
        
        [buttonStorage addObject:fb_cell.btn_add];
        fb_cell.btn_add.tag = [buttonStorage indexOfObject:fb_cell.btn_add];
        [buttonReferences setObject:[[friends_data objectAtIndex:indexPath.row] valueForKey:@"id"] forKey:[NSString stringWithFormat:@"%i", fb_cell.btn_add.tag ]];
        
        result.textLabel.text = [[friends_data objectAtIndex:indexPath.row] valueForKey:@"name"];
        result.detailTextLabel.text = [[friends_data objectAtIndex:indexPath.row] valueForKey:@"location"];
        [result.imageView setImage:[[friends_data objectAtIndex:indexPath.row] valueForKey:@"image"]];
        fb_cell.friend_added = [[[friends_data objectAtIndex:indexPath.row] valueForKey:@"added"] boolValue];
    }
    else
    {
        /*
        static NSString *TableViewCellIdentifier = @"RankingCells";
        result = [tableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier];
        if (result == nil)
        {
            result = [[KreyosRankingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableViewCellIdentifier];
            result.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        KreyosRankingCell* cell = (KreyosRankingCell*)result;
        cell.order.text = [[NSNumber numberWithInt:indexPath.row+1] stringValue];
        [cell.image setImage:[[ranking_data objectAtIndex:indexPath.row] valueForKey:@"image"]];
        cell.name.text = [[ranking_data objectAtIndex:indexPath.row] valueForKey:@"name"];
        cell.score.text = [[[ranking_data objectAtIndex:indexPath.row] valueForKey:@"score"] stringValue];
        KreyosProgressView* progress = cell.progress;
        progress.progress = [[[ranking_data objectAtIndex:indexPath.row] valueForKey:@"progress"] floatValue];
        NSLog(@"fuck %f", progress.progress);
         */
    }
    return result;
}

-(void) showLoadingState
{
    UIImage *img1 = [UIImage imageNamed:@"timer1"];
    UIView *blackScreen = [[UIView alloc] initWithFrame:self.view.bounds];
    blackScreen.backgroundColor = [UIColor blackColor];
    blackScreen.layer.opacity = 0.25f;
    
    float loadCgRectWidth = img1.size.width / 2;
    float loadCgRectHeight = img1.size.height / 2;
    
    UIImageView* animatedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(friend_data_view.bounds.size.width / 2 - loadCgRectWidth / 2,
                                                                                   friend_data_view.bounds.size.height / 2 - loadCgRectHeight / 2,
                                                                                   loadCgRectWidth,
                                                                                   loadCgRectHeight)];
    
    animatedImageView.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"timer1"],
                                         [UIImage imageNamed:@"timer2"],
                                         [UIImage imageNamed:@"timer3"],
                                         [UIImage imageNamed:@"timer4"],
                                         [UIImage imageNamed:@"timer5"],
                                         [UIImage imageNamed:@"timer6"], nil];
    
    animatedImageView.animationDuration = 1.0f;
    animatedImageView.animationRepeatCount = 0;
    [animatedImageView startAnimating];
    
    blackScreen.tag = 101;
    animatedImageView.tag = 102;
    
    friend_data_view.scrollEnabled = NO;
    
    [friend_data_view addSubview:blackScreen];
    [friend_data_view addSubview: animatedImageView];
}

-(void) hideLoadingState
{
    for (UIView *view in [friend_data_view subviews]) {
        if ( view.tag == 101 || view.tag == 102 )
        {
            [view removeFromSuperview];
        }
    }
}

-(void) SendFacebookRequest:(NSString*)p_id
{
    // Display the requests dialog
    
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     // 2. Optionally provide a 'to' param to direct the request at
                                     p_id, @"to", // Ali
                                     nil];
    
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:[NSString stringWithFormat:@"I just smashed friends! Can you beat it?"]
                                                    title:@"Smashing!"
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // Case A: Error launching the dialog or sending request.
                                                          NSLog(@"Error sending request.");
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // Case B: User clicked the "x" icon
                                                              NSLog(@"User canceled request.");
                                                          } else {
                                                              NSLog(@"Request Sent.");
                                                          }
                                                      }}
                                              friendCache:nil];
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
