//
//  RegisterUserIIBaseViewController.h
//  KreyosIosApp
//
//  Created by Kreyos on 3/23/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "KreyosUIViewBaseViewController.h"

@interface RegisterUserIIBaseViewController : KreyosUIViewBaseViewController
{
    NSMutableDictionary *mUserDataDict;
    BOOL bIsWeightSelected;
    BOOL bIsWeightPicker;
    float m_fHeightCentimeters;
    float m_fWeightLbs;
}

@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *lastnameField;

@property (strong, nonatomic) IBOutlet UITextField *birthdayField;
@property (strong, nonatomic) IBOutlet UISegmentedControl *genderSegment;
@property (strong, nonatomic) IBOutlet UITextField *heightField;
@property (strong, nonatomic) IBOutlet UITextField *weightField;
@property (strong, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UIView *mActivityIndicator;
@property (weak, nonatomic) IBOutlet UIPickerView *mHeightWidthPicker;
@property (weak, nonatomic) IBOutlet UIView *mPickerView;


-(IBAction)doneButton:(id)sender;
- (void) addDataFromFirstForm:(NSMutableDictionary*)pFdict;

@end
