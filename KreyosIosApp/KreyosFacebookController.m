//
//  KreyosFacebookController.m
//  kreyos_watch
//
//  Created by Kreyos on 1/4/14.
//  Copyright (c) 2014 kreyos. All rights reserved.
//

#import "KreyosFacebookController.h"
#import <FacebookSDK/FacebookSDK.h>


@interface KreyosFacebookController ()


@end


@implementation KreyosFacebookController
@synthesize FbUser;

static KreyosFacebookController* _sharedInstance = nil;

+(KreyosFacebookController*) sharedInstance
{
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        
        _sharedInstance = [[KreyosFacebookController alloc] init];
        
    });
    
    return  _sharedInstance;
}

-(NSString*)getUserEmail
{
    if ( [FbUser objectForKey:@"email"] ) {
        return [FbUser objectForKey:@"email"];
    }else {
        return [NSString stringWithFormat:@"%@@facebook.com", [FbUser username]];
    }
}

-(NSString*)getUserID
{
    return FbUser.id;
}

-(NSString*)getUserName
{
    return FbUser.name;
}

-(NSString*)getFirstName
{
    return FbUser.first_name;
}

-(NSString*)getSurName
{
    return FbUser.last_name;
}

-(NSString*)getBirthday
{
    return FbUser.birthday;
}

-(id<FBGraphPlace>)getLocation
{
    return FbUser.location;
}

- (NSString*)getGender
{
    return  [FbUser objectForKey:@"gender"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) releaseData
{
    FbUser = nil;
}

@end
