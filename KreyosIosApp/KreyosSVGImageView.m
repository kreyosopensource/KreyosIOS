//
//  KreyosSVGImageView.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/13/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosSVGImageView.h"
#import "SVGKImage.h"
#import "SVGKFastImageView.h"

@implementation KreyosSVGImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSLog(@"HELLO UIIMAGE");
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        
        [self setImageAsSVGImage:[self restorationIdentifier]];
    }
    return self;
}

- (void) setImageAsSVGImage : (NSString*) p_svgName
{
    if (!p_svgName) {
        return;
    }
    
    if (![SVGKImage imageNamed:p_svgName]) {
        
        SVGKImage *svgImage = [SVGKImage imageNamed:p_svgName];
        
        [svgImage setSize:self.bounds.size];
        
        self.ImageView = [[SVGKFastImageView alloc] initWithSVGKImage:svgImage];
        
        [self addSubview: self.ImageView];
    }
}


@end
