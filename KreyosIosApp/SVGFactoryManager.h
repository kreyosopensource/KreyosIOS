//
//  SVGFactoryManager.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/10/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosUIViewBaseViewController.h"

@interface SVGFactoryManager : KreyosUIViewBaseViewController

-(SVGKFastImageView*) createSVGImage:(NSString*)imageName;
+(SVGFactoryManager*) sharedInstance;

@end
