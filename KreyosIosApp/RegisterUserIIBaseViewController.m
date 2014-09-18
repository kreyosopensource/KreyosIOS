//
//  RegisterUserIIBaseViewController.m
//  KreyosIosApp
//
//  Created by Kreyos on 3/23/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "RegisterUserIIBaseViewController.h"
#import "DBManager.h"
#import "AccountManager.h"
#import "KreyosUtility.h"
#import "RequestManager.h"
#import "KreyosDataManager.h"
#import "Profile.h"


@interface RegisterUserIIBaseViewController () <UITextFieldDelegate, UIAlertViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    int heightLength;
    
    NSMutableArray *ftArray;
    NSMutableArray *inchArray;
    NSMutableArray *cmArray;
    NSMutableArray *lbArray;
    NSMutableArray *kgArray;
    NSMutableArray *heightMetricArray;
    NSMutableArray *weightMetricArray;
    UIButton* weight_metric;
    UIButton* height_metric;
}
@end

@implementation RegisterUserIIBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) populatePickerArrays
{
    ftArray             = [[NSMutableArray alloc] init];
    inchArray           = [[NSMutableArray alloc] init];
    cmArray             = [[NSMutableArray alloc] init];
    lbArray             = [[NSMutableArray alloc] init];
    kgArray             = [[NSMutableArray alloc] init];
    heightMetricArray   = [[NSMutableArray alloc] init];
    weightMetricArray   = [[NSMutableArray alloc] init];
    
    int ftMin           = MIN_FT;
    int ftMax           = MAX_FT;
    int inchMin         = MIN_INCH;
    int inchMax         = MAX_INCH;
    int cmMin           = MIN_CM;
    int cmMax           = MAX_CM;
    int lbMin           = MIN_LBS;
    int lbMax           = MAX_LBS;
    int kgMin           = MIN_KG;
    int kgMax           = MAX_KG;
    
    for (int x = ftMin; x <= ftMax; x++) {
        [ftArray addObject:[NSNumber numberWithInt:x]];
    }
    
    for (int x = inchMin; x <= inchMax; x++) {
        [inchArray addObject:[NSNumber numberWithInt:x]];
    }
    
    for (int x = cmMin; x <= cmMax; x++) {
        [cmArray addObject:[NSNumber numberWithInt:x]];
    }
    
    for (int x = lbMin; x <= lbMax; x++) {
        [lbArray addObject:[NSNumber numberWithInt:x]];
    }
    
    for (int x = kgMin; x <= kgMax; x++) {
        [kgArray addObject:[NSNumber numberWithInt:x]];
    }
    
    [heightMetricArray addObject:@"FT.IN"];
    [heightMetricArray addObject:@"CM"];
    [weightMetricArray addObject:@"LBS"];
    [weightMetricArray addObject:@"KG"];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mActivityIndicator.layer.cornerRadius = 10;
    [self.mActivityIndicator setHidden:YES];
    
    UILabel * leftView = [[UILabel alloc] initWithFrame:CGRectMake(20,0,7,26)];
    leftView.backgroundColor = [UIColor clearColor];
    
    self.nameField.leftView = leftView;
    self.nameField.leftViewMode =  UITextFieldViewModeAlways;
    self.nameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    leftView = [[UILabel alloc] initWithFrame:CGRectMake(20,0,7,26)];
    leftView.backgroundColor = [UIColor clearColor];
    
    self.lastnameField.leftView = leftView;
    self.lastnameField.leftViewMode =  UITextFieldViewModeAlways;
    self.lastnameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    leftView = [[UILabel alloc] initWithFrame:CGRectMake(20,0,7,26)];
    leftView.backgroundColor = [UIColor clearColor];
    
    self.birthdayField.leftView = leftView;
    self.birthdayField.leftViewMode =  UITextFieldViewModeAlways;
    self.birthdayField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.birthdayField.clearsOnBeginEditing = TRUE;
    [self.birthdayField setInputView:datePicker];
    
    CGRect genderFrame = self.genderSegment.frame;
    genderFrame.size = CGSizeMake(125, 40);
    self.genderSegment.frame = genderFrame;
    self.genderSegment.tintColor = [UIColor grayColor];
    self.genderSegment.backgroundColor = [UIColor clearColor];
    
    //HEIGHT
    self.heightField.placeholder = DEFAULT_HEIGHT;
    self.heightField.clearsContextBeforeDrawing = TRUE;
    self.heightField.keyboardType = UIKeyboardTypeNumberPad;
    self.heightField.delegate = nil;
    self.heightField.clearsOnBeginEditing = TRUE;
    
    self.weightField.placeholder = DEFAULT_WEIGHT;
    self.weightField.clearsContextBeforeDrawing = TRUE;
    self.weightField.keyboardType = UIKeyboardTypeNumberPad;
    self.weightField.delegate = nil;
    self.weightField.clearsOnBeginEditing = TRUE;
    
    self.heightField.textAlignment      = self.weightField.textAlignment = UITextAlignmentCenter;
    self.heightField.textColor          = self.weightField.textColor = [UIColor grayColor];
    self.heightField.backgroundColor    = self.weightField.backgroundColor = [UIColor whiteColor];
    self.heightField.layer.cornerRadius = self.weightField.layer.cornerRadius = 3;
    self.heightField.layer.opacity      = self.weightField.layer.opacity = 75;
    self.heightField.font               = self.weightField.font = REGULAR_FONT_WITH_SIZE(12);
    
    height_metric = [UIButton buttonWithType:UIButtonTypeCustom];
    //[height_metric addTarget:self action:@selector(changeHeightMetric:) forControlEvents:UIControlEventTouchUpInside];
    height_metric.frame = CGRectMake(0, 0, 55, 30);
    height_metric.backgroundColor = MAKE_RGB_UI_COLOR(240, 245, 248);
    [height_metric setTitle:@"FT.IN" forState:UIControlStateNormal];
    [height_metric setTitleColor:MAKE_RGB_UI_COLOR(163, 188, 193) forState:UIControlStateNormal];
    [height_metric setImage:[UIImage imageNamed:@"icon_down_gray"] forState:UIControlStateNormal];
    height_metric.titleEdgeInsets = UIEdgeInsetsMake(0, -height_metric.imageView.frame.size.width, 0, height_metric.imageView.frame.size.width);
    height_metric.imageEdgeInsets = UIEdgeInsetsMake(0, height_metric.titleLabel.frame.size.width, 0, -height_metric.titleLabel.frame.size.width);
    height_metric.titleLabel.font = REGULAR_FONT_WITH_SIZE(12);
    
    self.heightField.rightView = height_metric;
    self.heightField.rightViewMode = UITextFieldViewModeAlways;
    
    weight_metric = [UIButton buttonWithType:UIButtonTypeCustom];
    //[weight_metric addTarget:self action:@selector(changeWeightMetric:) forControlEvents:UIControlEventTouchUpInside];
    weight_metric.frame = CGRectMake(0, 0, 55, 30);
    weight_metric.backgroundColor = MAKE_RGB_UI_COLOR(240, 245, 248);
    [weight_metric setTitle:@"LBS" forState:UIControlStateNormal];
    [weight_metric setTitleColor:MAKE_RGB_UI_COLOR(163, 188, 193) forState:UIControlStateNormal];
    [weight_metric setImage:[UIImage imageNamed:@"icon_down_gray"] forState:UIControlStateNormal];
    weight_metric.titleEdgeInsets = UIEdgeInsetsMake(0, -weight_metric.imageView.frame.size.width, 0, weight_metric.imageView.frame.size.width);
    weight_metric.imageEdgeInsets = UIEdgeInsetsMake(0, weight_metric.titleLabel.frame.size.width, 0, -weight_metric.titleLabel.frame.size.width);
    weight_metric.titleLabel.font = REGULAR_FONT_WITH_SIZE(12);
    
    self.weightField.rightView = weight_metric;
    self.weightField.rightViewMode = UITextFieldViewModeAlways;
    
    self.nameField.delegate = self.lastnameField.delegate = self.birthdayField.delegate = self.heightField.delegate = self.weightField.delegate = self;
    
    [self.heightField addTarget:self action:@selector(showHeightPicker:) forControlEvents:UIControlEventAllTouchEvents];
    [self.weightField addTarget:self action:@selector(showWeightPicker:) forControlEvents:UIControlEventAllTouchEvents];
    
    self.mPickerView.layer.borderColor      = BLUE.CGColor;
    self.mPickerView.layer.borderWidth      = 1;
    self.mPickerView.layer.cornerRadius     = 5;
    self.mHeightWidthPicker.delegate    = self;
    
    [self populatePickerArrays];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark BUTTON CALLBACKS
- (void) changeHeightMetric:(id)sender
{
    UIButton *metricBtn = (UIButton*)sender;
    
    if( [[metricBtn titleLabel].text isEqual:@"FT"])
    {
        [metricBtn setTitle:@"CMS" forState:UIControlStateNormal];
        
        if ( [self.heightField.text intValue] >= 0 )
        {
            float cms = [self.heightField.text floatValue] * 30.48f;
            self.heightField.text = [NSString stringWithFormat:@"%.1f",  cms ];
        }
    }
    else
    {
        [metricBtn setTitle:@"FT" forState:UIControlStateNormal];
        
        if ( [self.heightField.text intValue] >= 0 )
        {
            float ft = [self.heightField.text floatValue] / 30.48f;
            self.heightField.text = [NSString stringWithFormat:@"%.1f", ft ];
            
            if ( [self.heightField.text length] >= 2 )
            {
                self.heightField.text = [NSString stringWithFormat:@"%@'%@%@\"", [self.heightField.text substringToIndex:1], [self.heightField.text substringToIndex:2], [self.heightField.text substringToIndex:3]];
            }
        }
    }
}

- (void) addDataFromFirstForm:(NSMutableDictionary*)pFdict
{
    mUserDataDict = [[NSMutableDictionary alloc] init];
    mUserDataDict = pFdict;
}

- (void) changeWeightMetric:(id)sender
{
    UIButton *metricBtn = (UIButton*)sender;
    
    if( [[metricBtn titleLabel].text isEqual:@"LBS"]){
        [metricBtn setTitle:@"KG" forState:UIControlStateNormal];
        
        if ( [self.weightField.text intValue] >= 0 )
        {
            float Kg = [self.weightField.text floatValue] / 2.2f;
            self.weightField.text = [NSString stringWithFormat:@"%.1f",  Kg ];
            m_fWeightLbs = Kg * 2.2046f; // kg to lbs
        }
    }
    else{
        [metricBtn setTitle:@"LBS" forState:UIControlStateNormal];
        float lbs = [self.weightField.text floatValue] * 2.2f;
        self.weightField.text = [NSString stringWithFormat:@"%.1f", lbs ];
        m_fWeightLbs = lbs; // kg to lbs
    }
    
}

- (void)heightChanged : (UITextField*)textField
{
    
    if ( [textField isEqual:self.heightField] )
    {
        BOOL valid;
        NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
        NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:textField.text];
        valid = [alphaNums isSupersetOfSet:inStringSet];
        if (!valid)
        {
            self.heightField.text = @"";
            return;// Not numeric
        }
        
        if (self.heightField.text.length > 1 )
        {
            self.heightField.text = [NSString stringWithFormat:@" %@ \' %@ \"",
                                     [self.heightField.text substringWithRange:NSMakeRange(0, 1)] ,
                                     [self.heightField.text substringWithRange:NSMakeRange(1, [self.heightField.text length] - 1)]];
        }
    }
}


-(void)datePickerValueChanged:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker*)sender;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy"];
    
    //Optionally for time zone converstions
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    NSString *stringFromDate = [formatter stringFromDate:[datePicker date]];
    self.birthdayField.text = stringFromDate;
}

-(IBAction)doneButton:(id)sender
{
    if(self.nameField.text.length != 0  && self.weightField.text.length != 0 &&
       self.heightField.text.length != 0 && self.birthdayField.text != 0)
    {
        [self showProgress:YES];
        //UNCOMMENT WHEN USING WEB DB -Kreyos
        
        [mUserDataDict setObject:self.nameField.text                                                        forKey:@"first_name"];
        [mUserDataDict setObject:self.lastnameField.text                                                    forKey:@"last_name"];
        [mUserDataDict setObject:self.birthdayField.text                                                    forKey:@"birthday"];
        [mUserDataDict setObject:(self.genderSegment.selectedSegmentIndex == 0 ? @"Male" : @"Female")       forKey:@"gender"];
        //[mUserDataDict setObject:self.heightField.text                                                    forKey:@"height"];
        [mUserDataDict setObject:[NSNumber numberWithFloat:m_fHeightCentimeters]                            forKey:@"height"];
        //[mUserDataDict setObject:self.weightField.text                                                    forKey:@"weight"];
        [mUserDataDict setObject:[NSNumber numberWithFloat:m_fWeightLbs]                                    forKey:@"weight"];
        
        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:mUserDataDict options:NSJSONWritingPrettyPrinted error:&err];
        NSString * dataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        NSLog(@"DATA STRING %@:",dataString);
        
        [[RequestManager rm] sendRequestPostMethod:kServerUserRegisterURL withPostData:dataString target:self selector:@selector(tryRegisterUser:)];

        //TEMPORARY TO SAVE SYNC TODAYS DATA
        [AccountManager getSharedAccountManager].name           = self.nameField.text;
        [AccountManager getSharedAccountManager].userBirthDay   = [self.birthdayField.text intValue];
        [AccountManager getSharedAccountManager].userWeight     = [self.weightField.text floatValue];
        [AccountManager getSharedAccountManager].userHeight     = [self.heightField.text floatValue];
        [AccountManager getSharedAccountManager].userGender     = (int)self.genderSegment.selectedSegmentIndex;
    
        AccountManager* _manager = [AccountManager getSharedAccountManager];
        [[DBManager getSharedInstance] registerUser:_manager.userName password:_manager.pass weight:_manager.userWeight height:_manager.userHeight gender:_manager.userGender name:_manager.name];
       
    }
    else
    {
        NSLog(@"Authentication Not Completed!");
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:REGISTRATION_MISSING_FIELD_ERROR_TITLE
                                                          message:REGISTRATION_MISSING_FIELD_ERROR_MESSAGE
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
  
        
        [message show];
    }
       
}


#pragma mark UITEXTFIELD DELEGATE
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if (textField == self.heightField || textField == self.weightField) {
        return NO;
    }
    
    return YES;  // Hide both keyboard and blinking cursor.
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{

}

#pragma mark UIPICKER DELEGATE AND METHODS

- (IBAction)hidePicker:(id)sender
{
    bIsWeightSelected = NO;
    [self.mPickerView setHidden:YES];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField != self.heightField || textField != self.weightField) {
        return;
    }
    
    bIsWeightPicker = textField == self.heightField ? NO : YES;
    
    [self.mPickerView setHidden:NO];
    [self.mHeightWidthPicker reloadAllComponents];
    
}

- (void) showHeightPicker:(id)sender
{
    bIsWeightPicker     = NO;
    bIsWeightSelected   = NO;
    [self.mPickerView setHidden:NO];
    [self.mHeightWidthPicker reloadAllComponents];
}

- (void) showWeightPicker:(id)sender
{
    bIsWeightPicker     = YES;
    bIsWeightSelected   = YES;
    [self.mPickerView setHidden:NO];
    [self.mHeightWidthPicker reloadAllComponents];
}

- (int) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return bIsWeightPicker ? 2 : 3;
}

- (int) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(bIsWeightPicker)
    {
        NSInteger rowInComponent1;
        rowInComponent1 = [pickerView selectedRowInComponent:1];
        
        switch (component) {
            case 0:
                return rowInComponent1 == 1 ? [kgArray count] : [lbArray count];
                break;
            
            case 1:
                return [weightMetricArray count];
                break;
            default:
                break;
        }
    }
    else
    {
        NSInteger rowInComponent1;
        rowInComponent1 = [pickerView selectedRowInComponent:2];
        
        switch (component) {
            case 0:
                return rowInComponent1 == 0 ? [ftArray count] : [cmArray count];
                break;
            
            case 1:
                return rowInComponent1 == 0 ? [inchArray count] : 0;
                break;
                
            case 2:
                return [heightMetricArray count];
                break;
            default:
                break;
        }
    }
    
    
    return bIsWeightPicker ? 2 : 3;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    NSNumber *returnValue;
    
    if (bIsWeightPicker)
    {
        NSInteger rowInComponent1;
        rowInComponent1 = [pickerView selectedRowInComponent:1];
        
        switch (component) {
            case 0:
                
                returnValue = (NSNumber*)(rowInComponent1 == 1 ? kgArray[row] : lbArray[row]);
                
                break;
            
            case 1:
                
                return weightMetricArray[row];
                
                break;
                
            default:
                return nil;
                break;
        }
    }
    else
    {
        NSInteger rowInComponent2;
        rowInComponent2 = [pickerView selectedRowInComponent:2];
        
        switch (component) {
            case 0:
                
                returnValue = (NSNumber*)(rowInComponent2 == 0 ? [ftArray objectAtIndex:row] : [cmArray objectAtIndex:row]);
                
                break;
            
            case 1:
                
                returnValue = (rowInComponent2 == 0 ? inchArray[row] : @"");
                
                break;
                
            case 2:
                
                return heightMetricArray[row];
                
                break;
                
            default:
                return nil;
                
                break;
        }
    }
    
    return [NSString stringWithFormat:@"%@", returnValue];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSNumber *value;
    
    if (bIsWeightPicker)
    {
        NSInteger rowInComponent1;
        rowInComponent1 = [pickerView selectedRowInComponent:1];
        
        switch (component) {
            case 0:
            {
                value = (NSNumber*)(rowInComponent1 == 1 ? kgArray[row] : lbArray[row]);
                self.weightField.text = [NSString stringWithFormat:@"%@", value];
                
                // kg
                if( rowInComponent1 == 1 )
                {
                    m_fWeightLbs = [value floatValue] * 2.2046;
                }
                // lb
                else
                {
                    m_fWeightLbs = [value floatValue];
                }
            }
            break;
            case 1:
            {
                [self.mHeightWidthPicker reloadAllComponents];
                [weight_metric setTitle:[NSString stringWithFormat:@"%@", weightMetricArray[rowInComponent1]] forState:UIControlStateNormal];
            }
            break;
            default:
                break;
        }
    }else
    {
        NSMutableArray *arrayToUse;
        NSInteger rowInComponent2;
        NSInteger rowInComponent1;
        NSInteger rowInComponent0;
        
        rowInComponent0 = [pickerView selectedRowInComponent:0];
        rowInComponent1 = [pickerView selectedRowInComponent:1];
        rowInComponent2 = [pickerView selectedRowInComponent:2];
        
        arrayToUse = rowInComponent2 == 0 ? ftArray : cmArray;
        
        switch (component)
        {
            case 0:
            {
                value = (NSNumber*)(arrayToUse[row]);
                
                if(arrayToUse == ftArray)
                    self.heightField.text = [NSString stringWithFormat:@"%@'%@", value, inchArray[rowInComponent1]];
                
                else
                    self.heightField.text = [NSString stringWithFormat:@"%@", value];
                
                
                int inchesFromFeet = [value intValue] * 12;
                int inches = [inchArray[rowInComponent1] intValue];
                float totalInches = (float)inchesFromFeet + (float)inches;
                m_fHeightCentimeters = totalInches * 2.54f;
                
                NSLog(@"");
            }
            break;
            case 1:
            {
                self.heightField.text = [NSString stringWithFormat:@"%@'%@", arrayToUse[rowInComponent0], inchArray[rowInComponent1]];
                
                int inchesFromFeet = [arrayToUse[rowInComponent0] intValue] * 12;
                int inches = [inchArray[rowInComponent1] intValue];
                float totalInches = (float)inchesFromFeet + (float)inches;
                m_fHeightCentimeters = totalInches * 2.54f;
                
                NSLog(@"");
            }
            break;
            case 2:
            {
                [self.mHeightWidthPicker reloadAllComponents];
                [height_metric setTitle:[NSString stringWithFormat:@"%@", heightMetricArray[rowInComponent2]] forState:UIControlStateNormal];
                m_fHeightCentimeters = [heightMetricArray[rowInComponent2] floatValue];
                
                NSLog(@"");
            }
            break;
            default:
                break;
        }
    }
}

- (void)tryRegisterUser:(NSData*)pResponseData
{
    [self showProgress:NO];
    
    NSString *dataParsed = [[NSString alloc] initWithData:pResponseData encoding:NSUTF8StringEncoding];
    KLog(@"RESPONSE %@", dataParsed);
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:pResponseData
                          
                          options:kNilOptions
                          error:&error];
    
    int requestCallback = [[json objectForKey:@"status"] intValue];
    
    KLog(@"callback %i", requestCallback);
    if( requestCallback == kRegisterSuccess )
    {
        NSDictionary* userData  = (NSDictionary*)[json objectForKey:@"user"];
        NSString* userEmail     = [userData objectForKey:@"email"];
        NSString* userToken     = [userData objectForKey:@"auth_token"];
        int userId              = [[userData objectForKey:@"id"] intValue];
        NSString* userFirstName = self.nameField.text;
        NSString* userLastName  = self.lastnameField.text;
        NSString* birthDate     = self.birthdayField.text;
        //float height            = [self.heightField.text floatValue];
        //float weight            = [self.weightField.text floatValue];
        //int gender              = (int)self.genderSegment.selectedSegmentIndex;
        
        // save user profile
        Profile* userprofile    = [[Profile alloc] init];
        userprofile.email       = userEmail;
        userprofile.kreyosToken = userToken;
        userprofile.fbToken     = @"";
        userprofile.firstName   = userFirstName;
        userprofile.lastName    = userLastName;
        userprofile.birthday    = birthDate;
        userprofile.height      = [NSString stringWithFormat:@"%f", m_fHeightCentimeters]; //self.heightField.text;
        userprofile.weight      = [NSString stringWithFormat:@"%f", m_fWeightLbs]; //self.weightField.text;
        [userprofile saveData];
        [userprofile saveData2];
        
        UIAlertView *success = [[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                                          message:@"Registration Successful"
                                                         delegate:self
                                                cancelButtonTitle:nil
                                                otherButtonTitles:@"Done", nil];
        [success show];
        
        //TO DO THIS DATA MUST COME FROM CLOUD
        [AccountManager getSharedAccountManager].userID = userId;
        [KreyosDataManager setUserDefaultEmail:userEmail];
        [KreyosDataManager setUserDefaultOath:userToken];
    }
    else if (requestCallback == kRegisterFailed)
    {
        //TODO REGISTER FAILED
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex == 0)
    {
        [self performSegueWithIdentifier:SEGUE_REGISTER2_TO_LOGIN sender:self];
    }
}

- (void) showProgress:(BOOL)pb
{
    if (pb){
        [self.mActivityIndicator setHidden:NO];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    }else{
        [self.mActivityIndicator setHidden:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
}

@end
