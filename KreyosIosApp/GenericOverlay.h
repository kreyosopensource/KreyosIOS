//
//  GenericOverlay.h
//  KreyosIosApp
//
//  Created by Kreyos on 7/10/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import <Foundation/Foundation.h>


enum
{
    GENERIC_TITLE,
    GENERIC_MESSAGE,
    GENERIC_YES,
    GENERIC_NO,
    GENERIC_MAX,
}OverlayString;

@interface GenericOverlay : UIAlertView <UIAlertViewDelegate>
-(id)initWithTitle:(const char**)p_strings target:(id)p_target selectors1:(SEL)p_sel1 selector1:(SEL)p_sel2;
+(id)createOverlayWarningDeviceIsConnected:(id)p_target selectors1:(SEL)p_sel1 selector1:(SEL)p_sel2 deviceFrom:(const char*)p_dev1 deviceTo:(const char*)p_dev2;
+(id)createOverlayWarningDeviceIsConnecting:(id)p_target selectors1:(SEL)p_sel1 selector1:(SEL)p_sel2;
@end
