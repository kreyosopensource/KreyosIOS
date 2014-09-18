//
//  KreyosSVGButton.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/14/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosSVGButton.h"
#import "SVGKImage.h"
#import "SVGKLayeredImageView.h"
#import "KreyosUtility.h"

@implementation KreyosSVGButton
{
    SVGKFastImageView *imageSet;
}

+(id)SVGButtonWith:(NSString *)pFileName Position:(CGPoint)pPosition Size:(CGSize)pSize
{
    SVGKImage *svgImage = [SVGKImage imageNamed:pFileName];
    [svgImage setSize:pSize];
    SVGKFastImageView *imageSet = [[SVGKFastImageView alloc] initWithSVGKImage:svgImage];
    
    imageSet.userInteractionEnabled = false;
    
    KreyosSVGButton* returnButton = [KreyosSVGButton buttonWithType:UIButtonTypeCustom];
    returnButton.frame = CGRectMake(pPosition.x - pSize.width*0.5f, pPosition.y + pSize.height*0.5f, pSize.width, pSize.height);
    //[returnButton.layer setAnchorPoint:(CGPoint){0.5f,0.5f}];
    //returnButton.backgroundColor = [UIColor redColor];
    [returnButton addSubview: imageSet];
    return returnButton;
}

- (void) awakeFromNib
{
    if ( [self restorationIdentifier] )
        [self addSVGOnThisButton:[self restorationIdentifier]];
}

- (void) addSVGOnThisButton : (NSString*)svgName
{
    if (![SVGKImage imageNamed:svgName]) {
        SVGKImage *svgImage = [SVGKImage imageNamed:svgName];
        
        [svgImage setSize:self.frame.size];
        
        imageSet = [[SVGKFastImageView alloc] initWithSVGKImage:svgImage];
        
        imageSet.userInteractionEnabled = false;
        
        [self addSubview: imageSet];
    }
}

- (SVGKFastImageView*) getSVGImage
{
    return imageSet;
}


- (void) setImageForSVG:(SVGKImage*)image
{
    [imageSet setImage:image];
}

@end



