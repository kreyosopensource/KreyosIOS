//
//  KreyosFBFriendCell.m
//  kreyos_watch
//
//  Created by hanqiu on 13-10-13.
//  Copyright (c) 2013年 kreyos. All rights reserved.
//

#import "KreyosFBFriendCell.h"
#import <QuartzCore/QuartzCore.h>
#import "FriendListsViewController.h"
#import "KreyosUtility.h"

@implementation KreyosFBFriendCell

@synthesize avatar_name;
@synthesize friend_added;
@synthesize friend_id;
@synthesize btn_add;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        btn_add = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* image_add = [UIImage imageNamed:@"action_btn_add"];
        [btn_add setImage:image_add forState:UIControlStateNormal];
        [btn_add setFrame:CGRectMake(0, 0, image_add.size.width, image_add.size.height)];
        [btn_add addTarget:self action:@selector(inviteFriend:) forControlEvents:UIControlEventTouchDown];
        
        btn_added = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* image_added = [UIImage imageNamed:@"action_btn_added"];
        [btn_added setImage:image_added forState:UIControlStateNormal];
        [btn_added setFrame:CGRectMake(0, 0, image_added.size.width, image_added.size.height)];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andNameId:(NSString*)idOfFriend
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        btn_add = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* image_add = [UIImage imageNamed:@"action_btn_add"];
        [btn_add setImage:image_add forState:UIControlStateNormal];
        [btn_add setFrame:CGRectMake(0, 0, image_add.size.width, image_add.size.height)];
        [btn_add addTarget:self action:@selector(inviteFriend:) forControlEvents:UIControlEventTouchDown];
        
        btn_added = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* image_added = [UIImage imageNamed:@"action_btn_added"];
        [btn_added setImage:image_added forState:UIControlStateNormal];
        [btn_added setFrame:CGRectMake(0, 0, image_added.size.width, image_added.size.height)];
    }
    return self;
}


-(void)inviteFriend:(id)sender
{
    
    UIButton *btn = (UIButton*)sender;
    NSLog(@" KEY %i ", btn.tag);
    
    NSMutableDictionary *diction = [FriendListsViewController sharedLoader].buttonReferences;
    
    [[FriendListsViewController sharedLoader] SendFacebookRequest: [diction objectForKey:[NSString stringWithFormat:@"%i", btn.tag]]];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    float left_padding = 15.0f;
    float right_padding = 15.0f;
    float imageView_width = 42.0f; // width == height
    if (IS_IOS7) {
        imageView_width = 48.0f;
    }
    
    self.imageView.frame = CGRectMake(left_padding, (self.frame.size.height-imageView_width)/2, imageView_width, imageView_width);
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.imageView.layer.cornerRadius = imageView_width/2;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.borderWidth = 3.0f;
    self.imageView.layer.borderColor = MAKE_RGB_UI_COLOR(227, 233, 235).CGColor;
    
    CGRect label_frame = self.textLabel.frame;
    label_frame.origin.x = left_padding + imageView_width + 9.0f;
    label_frame.origin.y -= 1;
    self.textLabel.frame = label_frame;
    
    CGRect detail_frame = self.detailTextLabel.frame;
    detail_frame.origin.x = label_frame.origin.x;
    detail_frame.origin.y += 1;
    self.detailTextLabel.frame = detail_frame;
    
    CGRect accessory_frame = self.accessoryView.frame;
    accessory_frame.origin.x = self.frame.size.width - accessory_frame.size.width - right_padding;
    self.accessoryView.frame = accessory_frame;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview == nil)
    {
        return;
    }
    
    [[FriendListsViewController sharedLoader] hideLoadingState];
    NSLog(@"yy %f %f", self.imageView.frame.size.width, self.imageView.frame.size.height);
    
    
    self.textLabel.font = REGULAR_FONT_WITH_SIZE(12.92f);
    self.textLabel.textColor = MAKE_RGB_UI_COLOR(53, 60, 62);
    self.detailTextLabel.font = BOLD_FONT_WITH_SIZE(11.08f);
    self.detailTextLabel.textColor = MAKE_RGB_UI_COLOR(53, 60, 62);
    
    self.accessoryView = friend_added ? btn_added : btn_add;
}

@end
