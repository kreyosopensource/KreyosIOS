//
//  TimezoneTableViewController.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/29/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimezoneTableViewController : UITableViewController
{
    NSString *timeZoneData;
    
}
@property (nonatomic, assign)id delegate;

-(void) setThisDelegate:(id)delegate;

@end
