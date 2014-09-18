//
//  KreyosFacebookController.h
//  kreyos_watch
//
//  Created by Kreyos on 1/4/14.
//  Copyright (c) 2014 kreyos. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "KreyosUIViewBaseViewController.h"

@interface KreyosFacebookController : KreyosUIViewBaseViewController
{
    
}
-(void) releaseData;

+(KreyosFacebookController*) sharedInstance;
-(NSString*)getUserEmail;
-(NSString*)getUserID;
-(NSString*)getUserName;
-(NSString*)getFirstName;
-(NSString*)getSurName;
-(NSString*)getBirthday;
-(NSString*)getLocation;
-(NSString*)getGender;
@property (retain, nonatomic) id<FBGraphUser> FbUser;

@end
