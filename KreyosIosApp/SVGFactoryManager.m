//
//  SVGFactoryManager.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/10/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "SVGFactoryManager.h"
#import "SVGKImage.h"
#import "SVGKLayeredImageView.h"
#import "SVGKFastImageView.h"

@interface SVGFactoryManager ()

@end

@implementation SVGFactoryManager

static SVGFactoryManager* _sharedInstance = nil;

+(SVGFactoryManager*) sharedInstance
{
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        
        _sharedInstance = [[SVGFactoryManager alloc] init];
        
    });
    
    return  _sharedInstance;
}

-(SVGKFastImageView*) createSVGImage:(NSString*)imageName
{
    SVGKFastImageView *svgImg = [[SVGKFastImageView alloc] initWithSVGKImage:[SVGKImage imageNamed:imageName]];
    return svgImg;
}

+ (void) swapImageToThis:(id)sender
{
    
}

@end
