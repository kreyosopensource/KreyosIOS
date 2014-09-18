//
//  KreyosShadowView.h
//  kreyos_watch
//
//  Created by hanqiu on 13-9-29.
//  Copyright (c) 2013年 kreyos. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SHADOW_VIEW_PADDING_HEIGHT 5.5f

@interface KreyosShadowView : UIView

@property (nonatomic, strong) UIImage* headImg;
@property (nonatomic, strong) UIImage* contentImg;
@property (nonatomic, strong) UIImage* footerImg;
@property (nonatomic, strong) UIView* container;

- (CGRect) getAvailBound;

@end
