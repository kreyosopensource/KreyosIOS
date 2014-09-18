//
//  BadgeItem.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/25/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosSVGButton.h"

@interface BadgeItem : KreyosSVGButton
{

}

//methods
- (id)initWithBadgeType:(short)pType position:(CGPoint)pPos andData:(NSArray*)pData;
- (NSString*) getImage;

@end
