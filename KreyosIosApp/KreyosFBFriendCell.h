//
//  KreyosFBFriendCell.h
//  kreyos_watch
//
//  Created by hanqiu on 13-10-13.
//  Copyright (c) 2013年 kreyos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KreyosFBFriendCell : UITableViewCell
{
    UIButton *btn_added;
}

@property (nonatomic, strong) NSString* avatar_name;
@property (nonatomic) BOOL friend_added;
@property (nonatomic, readwrite) int friend_id;
@property (assign) UIButton *btn_add;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andNameId:(NSString*)idOfFriend;

@end
