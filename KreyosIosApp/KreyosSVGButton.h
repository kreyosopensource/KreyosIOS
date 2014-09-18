//
//  KreyosSVGButton.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/14/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVGKFastImageView.h"

@interface KreyosSVGButton : UIButton
{
    NSString* mAssetName;
}

@property short     BadgeID;
@property NSString* BadgeName;
@property NSString* BadgeDescription;
@property NSString* BadgeSnippet;
@property NSString* BadgeCategory;
@property NSString* BadgeSubCategory;
@property ( nonatomic, retain ) NSString* BadgeImage;

+(id)SVGButtonWith:(NSString*)pFileName Position:(CGPoint)pPosition Size:(CGSize)pSize;


- (void) setImageForSVG:(SVGKImage*)image;
- (void) addSVGOnThisButton : (NSString*)svgName;
- (SVGKFastImageView*) getSVGImage;

@end
