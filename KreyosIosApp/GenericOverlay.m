//
//  GenericOverlay.m
//  KreyosIosApp
//
//  Created by Kreyos on 7/10/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "GenericOverlay.h"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

enum
{
    TAG_YES,
    TAG_NO,
    TAG_MAX,
}GenericTag;

@interface GenericOverlay()
{
    SEL m_selectors[TAG_MAX];
    id  m_target;
}
@end

@implementation GenericOverlay

+(id)createOverlayWarningDeviceIsConnected:(id)p_target selectors1:(SEL)p_sel1 selector1:(SEL)p_sel2 deviceFrom:(const char*)p_dev1 deviceTo:(const char*)p_dev2
{
    //~~~For Message
    char buffer[512];
    sprintf(buffer, "It seems like you're transferring your connection from %s to %s. Proceed?", p_dev1, p_dev2 );
    
    const char* genericStr[GENERIC_MAX];
    genericStr[GENERIC_TITLE]   = "Wait a sec.";
    genericStr[GENERIC_MESSAGE] = buffer;
    genericStr[GENERIC_YES]     = "YES";
    genericStr[GENERIC_NO]      = "NO";
    return [[self alloc]initWithTitle:genericStr target:p_target selectors1:p_sel1 selector1:p_sel2];
}

+(id)createOverlayWarningDeviceIsConnecting:(id)p_target selectors1:(SEL)p_sel1 selector1:(SEL)p_sel2
{
    const char* genericStr[GENERIC_MAX];
    genericStr[GENERIC_TITLE]   = "Wait a sec.";
    genericStr[GENERIC_MESSAGE] = "Kreyos is currently connecting to a watch. Do you want to cancel current connection?";
    genericStr[GENERIC_YES]     = "YES";
    genericStr[GENERIC_NO]      = "NO";
    return [[self alloc]initWithTitle:genericStr target:p_target selectors1:p_sel1 selector1:p_sel2];
}

-(id)initWithTitle:(const char**)p_strings target:(id)p_target selectors1:(SEL)p_sel1 selector1:(SEL)p_sel2
{
    if( self = [super initWithTitle:    GetSFString(p_strings[GENERIC_TITLE])
                          message:      GetSFString(p_strings[GENERIC_MESSAGE])
                          delegate:     self
                 cancelButtonTitle:     nil
                 otherButtonTitles:     GetSFString(p_strings[GENERIC_YES]),
                                        GetSFString(p_strings[GENERIC_NO]) ,nil] )
    {
        m_selectors[TAG_YES]    = p_sel1;
        m_selectors[TAG_NO]     = p_sel2;
        m_target                = p_target;
        self.delegate           = self;
    }
    
    return self;
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(m_target && m_selectors[buttonIndex])
    {
         SuppressPerformSelectorLeakWarning( [m_target performSelector:m_selectors[buttonIndex] withObject:nil] );
    }
    
    [self dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

NSString* GetSFString(const char* p_char)
{
    return [NSString stringWithCString:p_char encoding:NSUTF8StringEncoding];
}

@end
