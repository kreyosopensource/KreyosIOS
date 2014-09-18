//
//  KreyosSVGImageView.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/13/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVGKFastImageView.h"

@interface KreyosSVGImageView : UIImageView

@property (nonatomic, retain) SVGKFastImageView *ImageView;

- (void) setImageAsSVGImage : (NSString*) p_svgName;

@end
