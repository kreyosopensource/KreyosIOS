//
//  PersonalInformationViewController.h
//  KreyosIosApp
//
//  Created by Kreyos on 4/1/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosUIViewBaseViewController.h"
#import "KreyosTextField.h"
#import "SVSegmentedControl.h"

@interface PersonalInformationViewController : KreyosUIViewBaseViewController
{
    UIButton* avatar_add;
    KreyosBaseTextField* first_name;
    KreyosBaseTextField* last_name;
    KreyosTextField* location_tf;
    
    KreyosTextField* mm;
    KreyosTextField* dd;
    KreyosTextField* yyyy;
    
    KreyosTextField* weight_tf;
    KreyosTextField* height_tf;
    
    NSString *imageUrl;
    
    UISegmentedControl* gender_seg;
    UILabel* location_hint;
    
    UIImage *avatar_add_bg;
    
    UIButton* import_btn;
}

@end
