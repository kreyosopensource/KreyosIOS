//
//  PersonalInformationViewController.m
//  KreyosIosApp
//
//  Created by Kreyos on 4/1/14.
//  Copyright (c) 2014 Kreyos. All rights reserved.
//

#import "PersonalInformationViewController.h"
#import "KreyosShadowView.h"
#import "KreyosUtility.h"
#import "KreyosInnerShadowView.h"
#import "KreyosFacebookController.h"
#import "KreyosDataManager.h"
#import "RequestManager.h"
#import "DeviceManager.h"

#define KEY_GENDER_MALE     @"male"
#define KEY_GENDER_FEMALE   @"female"

//~~~User Data Index
enum
{
    INDEX_F_NAME    = 0,
    INDEX_L_NAME,
    INDEX_MM,
    INDEX_DD,
    INDEX_YYYY,     // 4
    INDEX_LOCATION,
    INDEX_WEIGHT,
    INDEX_HEIGHT,
    INDEX_IMG_URL,  // 8
};



@interface PersonalInformationViewController () <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSUserDefaults *userDef;
    NSMutableArray *_userData;
    BOOL bIsWeightPicker;
    
    NSString *fname;
    NSString *lname;
    NSString *smm;
    NSString *sdd;
    NSString *syyyy;
    NSString *location;
    NSString *weight;
    NSString *height;
    NSString *imageURL;
    int      *gender;
    
    UIDatePicker *datePicker;
    UIPickerView *weightHeightPicker;
    
    NSMutableArray *ftArray;
    NSMutableArray *inchArray;
    NSMutableArray *cmArray;
    NSMutableArray *lbArray;
    NSMutableArray *kgArray;
    NSMutableArray *heightMetricArray;
    NSMutableArray *weightMetricArray;
    UIButton* weight_metric;
    UIButton* height_metric;
    
    KreyosFacebookController *fbCntrler;
    
    u_int m_heightData;
    u_int m_weightData;
    
    BOOL m_didSwitch;
    BOOL m_didSwitchWeight;
}

@property (nonatomic, strong) UIScrollView* scroll_view;
@property (nonatomic) float scroll_view_height;

@end

@implementation PersonalInformationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    m_didSwitch         = NO;
    m_didSwitchWeight   = NO;
    
    userDef     = [NSUserDefaults standardUserDefaults];
    fbCntrler   = [KreyosFacebookController sharedInstance];
    
    fname       = @"";
    lname       = @"";
    smm         = @"";
    sdd         = @"";
    syyyy       = @"";
    location    = @"";
    weight      = DEFAULT_WEIGHT;
    height      = DEFAULT_HEIGHT;
    imageURL    = @"";
    
    _userData = [[NSMutableArray alloc] init];
    [_userData insertObject:fname 		atIndex:INDEX_F_NAME];      // 0
    [_userData insertObject:lname 		atIndex:INDEX_L_NAME];
    [_userData insertObject:smm 		atIndex:INDEX_MM];
    [_userData insertObject:sdd 		atIndex:INDEX_DD];
    [_userData insertObject:syyyy		atIndex:INDEX_YYYY];        // 4
    [_userData insertObject:location 	atIndex:INDEX_LOCATION];
    [_userData insertObject:weight 		atIndex:INDEX_WEIGHT];
    [_userData insertObject:height 		atIndex:INDEX_HEIGHT];
    [_userData insertObject:imageURL 	atIndex:INDEX_IMG_URL];     // 8
    
    //~~~Update Defaults
    for (uint indx = 0 ; indx < [_userData count]; indx++)
    {
        NSString* strIndex  = [NSString stringWithFormat:@"info_%i", indx];
        NSString* dataValue = [userDef objectForKey:strIndex];
        
        if (dataValue == nil)
        {
            [userDef setObject:(NSString*)_userData[indx] forKey:strIndex];
            continue;
        }

        if ( [dataValue isKindOfClass:[NSString class]] &&  ![dataValue length])
        {
            [userDef setObject:(NSString*)_userData[indx] forKey:strIndex];
            continue;
        }
        else if ([dataValue isKindOfClass:[NSNumber class]])
        {
            [userDef setObject:_userData[indx] forKey:strIndex];
            continue;
        }
    }
    
    float headerHeight          = 0;
    float bound_width           = 296.0f;
    float button_wrap_height    = 54.0f;
    float sync_wrap_height      = 45.0f;
    float table_row_height      = 32.0f;
    float table_line_padding    = 12.0f;
    float table_left_x          = 10.0f;
    float table_left_text_x     = 15.0f;
    float table_right_x         = 100.0f;
    float table_right_width     = 175.0f;
    float table_y               = button_wrap_height;
    float sync_y                = button_wrap_height + table_row_height*6 + table_line_padding*6;
    float posy                  = [DeviceManager IS_IPhone4S] ? 50.0f + headerHeight : 16.0f + headerHeight;
    float bound_height          = [DeviceManager IS_IPhone4S] ? sync_y + sync_wrap_height + 30.5f :  sync_y + sync_wrap_height + 60.5f;
    
    self.scroll_view = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scroll_view.alwaysBounceVertical = YES;
    self.scroll_view.canCancelContentTouches = NO;
    
    //ADD SHADOW VIEW
    CGRect container_frame = CGRectMake((self.view.frame.size.width-bound_width) / 2,
                                        posy,
                                        bound_width,
                                        bound_height);
    
    KreyosShadowView *container = [[KreyosShadowView alloc] initWithFrame:container_frame];
    
    float avail_width = [container getAvailBound].size.width;
    
    // top
    CGSize button_size = CGSizeMake(268.0f, 43.0f);
    import_btn = [[UIButton alloc] initWithFrame:CGRectMake((avail_width-button_size.width)/2, (button_wrap_height-button_size.height)/2, button_size.width, button_size.height)];
    [import_btn setTitle:@"Import from Facebook" forState:UIControlStateNormal];
    [import_btn setFont:FONT_BEBAS(20)];
    [import_btn setBackgroundImage:[UIImage imageNamed:@"btn_import_fb"] forState:UIControlStateNormal];
    [import_btn setBackgroundImage:[UIImage imageNamed:@"btn_import_fb_highlight"] forState:UIControlStateHighlighted];
    [import_btn addTarget:self action:@selector(populateData:) forControlEvents:UIControlEventTouchDown];
    
    UIView* top_line = [[UIView alloc] initWithFrame:CGRectMake(0, button_wrap_height-1, bound_width, 0.5)];
    top_line.backgroundColor = MAKE_RGB_UI_COLOR(231, 235, 238);
    
    // middle form
    
    // fonts
    UIFont* left_font = FONT_BEBAS(14.03f);
    UIFont* right_font = [UIFont systemFontOfSize:12.92f];
    // color
    UIColor* left_color = MAKE_RGB_UI_COLOR(95, 109, 113);
    UIColor* right_color_light = MAKE_RGB_UI_COLOR(197, 200, 203);
    UIColor* right_color = MAKE_RGB_UI_COLOR(134, 144, 147);
    CGColorRef border_color = MAKE_RGB_UI_COLOR(198, 207, 209).CGColor;
    #pragma unused(right_color)
    
    table_y += table_line_padding;
    UIImageView* avatar = [[UIImageView alloc] initWithFrame:CGRectMake(table_left_x, table_y, table_row_height*2, table_row_height*2)];
    avatar.backgroundColor = MAKE_RGB_UI_COLOR(238, 242, 243);
    avatar.layer.borderWidth = 0.5f;
    avatar.layer.borderColor = border_color;
    avatar.layer.cornerRadius = 5.0f;
    avatar.layer.masksToBounds = YES;
    
    avatar_add_bg = [UIImage imageNamed:@"defaultphoto"];
    [avatar_add setBackgroundImage:avatar_add_bg forState:UIControlStateNormal];
    //[avatar_add setBackgroundImage:[UIImage imageNamed:@"btn_add_photo_highlight"] forState:UIControlStateHighlighted];
    
    avatar_add = [UIButton buttonWithType:UIButtonTypeCustom];
    avatar_add.backgroundColor = MAKE_RGB_UI_COLOR(238, 242, 243);
    avatar_add.layer.borderWidth = 0.5f;
    avatar_add.layer.borderColor = border_color;
    avatar_add.layer.cornerRadius = 5.0f;
    avatar_add.layer.masksToBounds = YES;
    
    imageUrl = [userDef objectForKey:@"info_8"];
    [avatar_add setBackgroundImage:avatar_add_bg forState:UIControlStateNormal];
    avatar_add.frame = avatar.frame;
    //avatar_add.frame = CGRectMake((avatar.frame.size.width-avatar_add_bg.size.width)/2, (avatar.frame.size.height-avatar_add_bg.size.height)/2, avatar_add_bg.size.width, avatar_add_bg.size.height);
    avatar.userInteractionEnabled = YES;
    
    // avarta and name
    KreyosInnerShadowView* name_container = [[KreyosInnerShadowView alloc] initWithFrame:CGRectMake(table_right_x, table_y, table_right_width, table_row_height*2)];
    
    first_name = [[KreyosBaseTextField alloc] initWithFrame:CGRectMake(0, 0, table_right_width, table_row_height)];
    first_name.placeholder = @"FIRST NAME";
    first_name.text = _userData[INDEX_F_NAME];
    first_name.tintColor = BLUE;
    
    last_name = [[KreyosBaseTextField alloc] initWithFrame:CGRectMake(0, table_row_height, table_right_width, table_row_height)];
    last_name.placeholder = @"LAST NAME";
    last_name.text = _userData[INDEX_L_NAME];
    last_name.tintColor = BLUE;
    
    UIView* name_line = [[UIView alloc] initWithFrame:CGRectMake(0, table_row_height-0.5f, table_right_width, 0.5f)];
    name_line.backgroundColor = MAKE_RGB_UI_COLOR(198, 207, 209);
    
    [name_container addSubview:first_name];
    [name_container addSubview:name_line];
    [name_container addSubview:last_name];
    
    // Birthday
    table_y += table_row_height*2 + table_line_padding;
    UILabel* birthday_hint = [[UILabel alloc] initWithFrame:CGRectMake(table_left_text_x, table_y, table_row_height*2, table_row_height)];
    birthday_hint.text = @"Birthday";
    birthday_hint.font = left_font;
    birthday_hint.textColor = left_color;
    

    dd = [[KreyosTextField alloc] initWithFrame:CGRectMake(table_right_x, table_y, 45, table_row_height)];
    dd.placeholder = @"DD";
    dd.textAlignment = UITextAlignmentCenter;
    dd.leftViewMode = UITextFieldViewModeNever;
    dd.text = _userData[INDEX_DD];
    dd.tintColor = BLUE;

    UILabel* mm_dash = [[UILabel alloc] initWithFrame:CGRectMake(table_right_x+45, table_y, 15, table_row_height)];
    mm_dash.text = @"-";
    mm_dash.textAlignment = UITextAlignmentCenter;
    mm_dash.textColor = right_color_light;
    
    mm = [[KreyosTextField alloc] initWithFrame:CGRectMake(table_right_x + 60, table_y, 45, table_row_height)];
    mm.placeholder = @"MM";
    mm.leftViewMode = UITextFieldViewModeNever;
    mm.textAlignment = UITextAlignmentCenter;
    mm.text = _userData[INDEX_MM];
    mm.tintColor = BLUE;

    
    UILabel* dd_dash = [[UILabel alloc] initWithFrame:CGRectMake(table_right_x+45+60, table_y, 15, table_row_height)];
    dd_dash.text = @"-";
    dd_dash.textAlignment = UITextAlignmentCenter;
    dd_dash.textColor = right_color_light;
    
    yyyy = [[KreyosTextField alloc] initWithFrame:CGRectMake(table_right_x+60*2, table_y, 55, table_row_height)];
    yyyy.placeholder = @"YYYY";
    yyyy.textAlignment = UITextAlignmentCenter;
    yyyy.leftViewMode = UITextFieldViewModeNever;
    yyyy.text = _userData[INDEX_YYYY];
    yyyy.tintColor = BLUE;

    datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker setDate:DateFromString(dd.text, mm.text, yyyy.text)];
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    mm.clearsOnBeginEditing = TRUE;
    dd.clearsOnBeginEditing = TRUE;
    yyyy.clearsOnBeginEditing = TRUE;
    
    mm.delegate = dd.delegate = yyyy.delegate = self;
    
    [mm setInputView:datePicker];
    [dd setInputView:datePicker];
    [yyyy setInputView:datePicker];
    
    // gender
    table_y += table_row_height + table_line_padding;
    UILabel* gender_hint = [[UILabel alloc] initWithFrame:CGRectMake(table_left_text_x, table_y, table_row_height*2, table_row_height)];
    gender_hint.text        = @"Gender";
    gender_hint.font        = left_font;
    gender_hint.textColor   = left_color;
    
    KreyosInnerShadowView* gender_seg_container = [[KreyosInnerShadowView alloc] initWithFrame:CGRectMake(table_right_x, table_y, table_right_width, table_row_height)];
    
    //gender_seg = [[SVSegmentedControl alloc] initWithSectionTitles:[[NSArray alloc] initWithObjects:@"MALE",@"FEMALE", nil]];
    gender_seg = [[UISegmentedControl alloc] initWithItems:[[NSArray alloc] initWithObjects:@"MALE", @"FEMALE", nil]];
    gender_seg.frame = CGRectMake(0, 0, table_right_width, table_row_height);
    [gender_seg_container addSubview:gender_seg];
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : left_color} forState:UIControlStateSelected];
    
    UIColor *selectedColor  = right_color_light;
    UIColor *deselectedColor = right_color_light;
    
    for (id subview in [gender_seg subviews]) {
        if ([subview isSelected])
            [subview setTintColor:selectedColor];
        else
            [subview setTintColor:deselectedColor];
    }
    
    //~~~Update gender's defaulf value
    [gender_seg setSelectedSegmentIndex:[self genderFromUserData]];
    
    // location
    table_y += table_row_height + table_line_padding;
    location_hint = [[UILabel alloc] initWithFrame:CGRectMake(table_left_text_x, table_y, table_row_height*2, table_row_height)];
    location_hint.text      = @"Location";
    location_hint.font      = left_font;
    location_hint.textColor = left_color;
    location_hint.hidden    = YES;
    
    location_tf = [[KreyosTextField alloc] initWithFrame:CGRectMake(table_right_x, table_y, table_right_width, table_row_height)];
    location_tf.placeholder = @"Use my current location";
    UIImageView* location_image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 27, 27)];
    [location_image setImage:[UIImage imageNamed:@"icon_location"]];
    location_tf.leftView    = location_image;
    location_tf.text        = _userData[INDEX_LOCATION];
    location_tf.tintColor   = BLUE;
    location_tf.hidden      = YES;
    
    //~~~Use the position of the location
    //height
    //table_y += table_row_height + table_line_padding;
    UILabel* height_hint = [[UILabel alloc] initWithFrame:CGRectMake(table_left_text_x, table_y, table_row_height*2, table_row_height)];
    height_hint.text = @"Height";
    height_hint.font = left_font;
    height_hint.textColor = left_color;
    
    height_tf = [[KreyosTextField alloc] initWithFrame:CGRectMake(table_right_x, table_y, table_right_width, table_row_height)];
    height_tf.text = [NSString stringWithFormat:@"%@", _userData[INDEX_HEIGHT]];
    height_tf.tintColor = BLUE;
    
    height_metric = [UIButton buttonWithType:UIButtonTypeCustom];
    height_metric.frame = CGRectMake(0, 0, 75, table_row_height);
    height_metric.backgroundColor = MAKE_RGB_UI_COLOR(240, 245, 248);
    [height_metric setTitle:@"CM" forState:UIControlStateNormal];
    [height_metric setTitleColor:MAKE_RGB_UI_COLOR(163, 188, 193) forState:UIControlStateNormal];
    [height_metric setImage:[UIImage imageNamed:@"icon_down_gray"] forState:UIControlStateNormal];
    height_metric.titleEdgeInsets = UIEdgeInsetsMake(0, -height_metric.imageView.frame.size.width, 0, height_metric.imageView.frame.size.width);
    height_metric.imageEdgeInsets = UIEdgeInsetsMake(0, height_metric.titleLabel.frame.size.width, 0, -height_metric.titleLabel.frame.size.width);
    height_metric.titleLabel.font = right_font;
    
    UIView* vert_line2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.5, table_row_height)];
    vert_line2.backgroundColor = MAKE_RGB_UI_COLOR(163, 188, 193);
    [height_metric addSubview:vert_line2];
    
    height_tf.rightView = height_metric;
    height_tf.rightViewMode = UITextFieldViewModeAlways;

    // weight
    table_y += table_row_height + table_line_padding;
    UILabel* weight_hint = [[UILabel alloc] initWithFrame:CGRectMake(table_left_text_x, table_y, table_row_height*2, table_row_height)];
    weight_hint.text        = @"Weight";
    weight_hint.font        = left_font;
    weight_hint.textColor   = left_color;
    
    weight_tf = [[KreyosTextField alloc] initWithFrame:CGRectMake(table_right_x, table_y, table_right_width, table_row_height)];
    weight_tf.text = [NSString stringWithFormat:@"%@", _userData[INDEX_WEIGHT]];
    weight_tf.tintColor = BLUE;
    
    weight_metric = [UIButton buttonWithType:UIButtonTypeCustom];
    weight_metric.frame = CGRectMake(0, 0, 75, table_row_height);
    weight_metric.backgroundColor = MAKE_RGB_UI_COLOR(240, 245, 248);
    [weight_metric setTitle:@"LBS" forState:UIControlStateNormal];
    [weight_metric setTitleColor:MAKE_RGB_UI_COLOR(163, 188, 193) forState:UIControlStateNormal];
    [weight_metric setImage:[UIImage imageNamed:@"icon_down_gray"] forState:UIControlStateNormal];
    weight_metric.titleEdgeInsets = UIEdgeInsetsMake(0, -weight_metric.imageView.frame.size.width, 0, weight_metric.imageView.frame.size.width);
    weight_metric.imageEdgeInsets = UIEdgeInsetsMake(0, weight_metric.titleLabel.frame.size.width, 0, -weight_metric.titleLabel.frame.size.width);
    weight_metric.titleLabel.font = right_font;
    
    UIView* vert_line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.5, table_row_height)];
    vert_line.backgroundColor = MAKE_RGB_UI_COLOR(163, 188, 193);
    [weight_metric addSubview:vert_line];
    
    weight_tf.rightView = weight_metric;
    weight_tf.rightViewMode = UITextFieldViewModeAlways;
    
    //~~~Double the increment of the button position y
    //   Increment 2  if not 4s one if 4s
    //   button
    if (![DeviceManager IS_IPhone4S])
    {
        table_y += table_row_height + table_line_padding;
    }
    
    table_y += table_row_height + table_line_padding;
    UIButton *updateBtn = [[UIButton alloc] initWithFrame:CGRectMake((avail_width - button_size.width)/2, table_y, button_size.width, button_size.height)];
    [updateBtn setTitle:@"Update My Information" forState:UIControlStateNormal];
    [updateBtn setFont:FONT_BEBAS(20)];
    [updateBtn setBackgroundColor:BLUE];
    [updateBtn addTarget:self action:@selector(updateInformation:) forControlEvents:UIControlEventTouchDown];
    
    //Weight And Height Picker
    weightHeightPicker = [[UIPickerView alloc] init];
    [weightHeightPicker setDelegate:self];
    [weight_tf setInputView:weightHeightPicker];
    [height_tf setInputView:weightHeightPicker];
    
    //SET DELEGATES TO TEXTFIELD
    first_name.delegate = last_name.delegate = location_tf.delegate = weight_tf.delegate = height_tf.delegate = mm.delegate = dd.delegate = yyyy.delegate = self;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeDatePicker:)];
    [self.view addGestureRecognizer:tap];
    
    [self populateArray];
    
    [container addSubview:import_btn];
    [container addSubview:top_line];
    [container addSubview:avatar_add];
    [container addSubview:name_container];
    [container addSubview:birthday_hint];
    [container addSubview:mm];
    [container addSubview:mm_dash];
    [container addSubview:dd];
    [container addSubview:dd_dash];
    [container addSubview:yyyy];
    [container addSubview:gender_hint];
    [container addSubview:location_hint];
    [container addSubview:location_tf];
    [container addSubview:weight_hint];
    [container addSubview:weight_tf];
    [container addSubview:height_hint];
    [container addSubview:height_tf];
    [container addSubview:gender_seg_container];
    [container addSubview:updateBtn];
   
    [self.scroll_view addSubview:container];
    ADD_TO_ROOT_VIEW(self.scroll_view);
    
    
    //POPULATE INFORMATION DATA IF CONNECTED USING FB
    if ([KreyosDataManager sharedInstance].IsConnectedUsingFB)
    {
        [self populateData:self];
    }else
    {
        [self updateInformationFromWeb];
    }
}
#pragma GCC diagnostic pop

- (void) populateArray
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
    
        [heightMetricArray addObject:@"CM"];
    [heightMetricArray addObject:@"FT.IN"];
    [weightMetricArray addObject:@"LBS"];
    [weightMetricArray addObject:@"KG"];

}

- (void)closeDatePicker:(id)sender
{
    [first_name resignFirstResponder];
    [last_name resignFirstResponder];
    [mm resignFirstResponder];
    [dd resignFirstResponder];
    [yyyy resignFirstResponder];
    [weight_tf resignFirstResponder];
    [height_tf resignFirstResponder];
    
    //~~~reload birthdate display
    [self reloadBirthdayDisplay:[datePicker date]];
    
    //~~~Reload label display
    [self reloadLabel:first_name    withDisplay:_userData[INDEX_F_NAME]];
    [self reloadLabel:last_name     withDisplay:_userData[INDEX_L_NAME]];
    [self reloadLabel:location_tf   withDisplay:_userData[INDEX_LOCATION]];
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:weight_tf])
    {
        bIsWeightPicker = YES;
        
        [weightHeightPicker reloadAllComponents];
        [self MovePicker:lbArray value:m_weightData component:0];
    }
    else if ( [textField isEqual:height_tf])
    {
        bIsWeightPicker = NO;
        
        [weightHeightPicker reloadAllComponents];
        [self MovePicker:cmArray value:m_heightData component:1];
    }
}

#pragma mark DATEPICKER DELEGATE

-(void)datePickerValueChanged:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)sender;
    [self reloadBirthdayDisplay:[picker date]];
}

-(void)reloadBirthdayDisplay:(NSDate*)p_date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd"];
    
    //Optionally for time zone converstions
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    NSString *day = [formatter stringFromDate:p_date];
    [formatter setDateFormat:@"MM"];
    NSString *month = [formatter stringFromDate:p_date];
    [formatter setDateFormat:@"yyyy"];
    NSString *year = [formatter stringFromDate:p_date];
    
    dd.text     = day;
    mm.text     = month;
    yyyy.text   = year;
}

-(void)reloadLabel:(KreyosBaseTextField*)p_label
       withDisplay:(NSString*)p_display
{
    if (!p_label.text || ![p_label.text length])
    {
        p_label.text = p_display;
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        if ([userDef objectForKey:USERDEF_PHOTO]) {
            [avatar_add setBackgroundImage:[UIImage imageWithData:[userDef objectForKey:USERDEF_PHOTO]] forState:UIControlStateNormal];
        }
        else
        {
            if ([imageURL length])
            {
                [avatar_add setBackgroundImage:imageUrl == nil ? avatar_add_bg : [ self getImageByUrlString:imageUrl ] forState:UIControlStateNormal];
            }
        }
    });
}

#pragma mark POPULATE DATA FB
-(void)populateData:(id)sender
{
    NSLog(@"FBUser %@", [[KreyosFacebookController sharedInstance] getUserName]);
    
    if ( [fbCntrler FbUser] == nil)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You're not connected with facebook" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
        return;
    }
    
    first_name.text = [fbCntrler getFirstName];
    last_name.text = [fbCntrler getSurName];
    
    NSString *bday = [fbCntrler getBirthday];
    mm.text = [NSString stringWithFormat:@"%c%c", [bday characterAtIndex:0], [bday characterAtIndex:1]];
    dd.text = [NSString stringWithFormat:@"%c%c", [bday characterAtIndex:3], [bday characterAtIndex:4]];
    yyyy.text = [NSString stringWithFormat:@"%c%c%c%c", [bday characterAtIndex:6], [bday characterAtIndex:7],[bday characterAtIndex:8], [bday characterAtIndex:9]];
    
    imageUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", (NSDictionary<FBGraphUser> *)[fbCntrler getUserID]];
    
    location_tf.text = [((id<FBGraphPlace>)[fbCntrler getLocation]) name];
    
    [avatar_add setBackgroundImage:[self getImageByUrlString:imageUrl] forState:UIControlStateNormal];
    
    
    int genderInt = [self genderFromFBGender:fbCntrler];
    
    //[gender_seg moveThumbToIndex:[ genderStr isEqualToString:@"male"] ? 0 : 1 animate:YES];
    [gender_seg setSelectedSegmentIndex:genderInt];
}

- (int) genderFromFBGender:(KreyosFacebookController*)p_fbData
{
    //~~~Male:0 Female:1
    NSString* genderStr = [p_fbData getGender];
    genderStr           = [genderStr lowercaseString];
    return [genderStr isEqualToString:KEY_GENDER_MALE] ? 0 : 1;
}

- (int) genderFromUserData
{
    //~~~Male:0 Female:1
    id genderData = [userDef objectForKey:@"info_9"];
    if ([genderData isKindOfClass:[NSString class]])
    {
        genderData = [genderData lowercaseString];
        return [genderData isEqualToString:KEY_GENDER_MALE] ? 0 : 1;
    }
    //~~~else..
    //      unknown gender.. setting value to male by default
    else
    {
        //~~~info_9 is the gender_key
        [userDef setObject:[NSNumber numberWithInt:0] forKey:@"info_9"];
    }
    
    return 0;
}

- (void) updateInformationFromWeb
{
    NSString* firstName     = [userDef objectForKey:@"info_0"];
    NSString* lastName      = [userDef objectForKey:@"info_1"];
    NSString* month         = [userDef objectForKey:@"info_2"];
    NSString* day           = [userDef objectForKey:@"info_3"];
    NSString* year          = [userDef objectForKey:@"info_4"];
    id userWeight           = [userDef objectForKey:@"info_6"];
    id userHeight           = [userDef objectForKey:@"info_7"];
    
    first_name.text         = firstName     ? firstName : _userData[INDEX_F_NAME];
    last_name.text          = lastName      ? lastName  : _userData[INDEX_L_NAME];
    mm.text                 = month         ? month     : _userData[INDEX_MM];
    dd.text                 = day           ? day       : _userData[INDEX_DD];
    yyyy.text               = year          ? year      : _userData[INDEX_YYYY];
    weight_tf.text          = userWeight    ? [NSString stringWithFormat:@"%@",userWeight] : _userData[INDEX_WEIGHT];
    height_tf.text          = userHeight    ? [NSString stringWithFormat:@"%@",userHeight] : _userData[INDEX_HEIGHT];
    
    m_weightData        = [weight_tf.text intValue];
    if (userHeight)
    {
        float cm        = [(NSString*)userHeight floatValue];
        height_tf.text  = [NSString stringWithFormat:@"%.02f",cm];
        m_heightData    = cm;
    }
    else
    {
        height_tf.text  = @"";
        m_heightData    = 60;
    }
    

    int genderInt = [self genderFromUserData];
    
    [gender_seg setSelectedSegmentIndex: genderInt];
    //[gender_seg moveThumbToIndex:genderInt animate:YES];
    
}

- (void) updateInformation : (id)sender
{
    //~~~Sanity Checking
    [self checkInvalidData];
    
    if ([KreyosDataManager sharedInstance].IsConnectedUsingFB)
    {
        [userDef setObject:[NSNumber numberWithInt:[self genderFromFBGender:fbCntrler]]     forKey:@"info_9"];
    }
    else
    {
        [userDef setObject:[NSNumber numberWithInt:gender_seg.selectedSegmentIndex]         forKey:@"info_9"];
    }
    
    //Save to DB
    NSString *oath      = [KreyosDataManager getUserDefaultOath];
    NSString *email     = [KreyosDataManager getUserDefaultEmail];
    #pragma unused(oath)
    #pragma unused(email)
    NSString *bday      = @"";
    NSString *genderStr;
    
    if ([mm.text length] > 0)
    {
        bday      = [NSString stringWithFormat:@"%@/%@/%@", dd.text, mm.text, yyyy.text ];
    }
    
    genderStr = (gender_seg.selectedSegmentIndex == 0 ? @"Male" : @"Female");
    
    NSMutableDictionary* mUserDataDict = [[NSMutableDictionary alloc] init];
    
    [mUserDataDict setObject:[KreyosDataManager getUserDefaultEmail] forKey:@"email"];
    [mUserDataDict setObject:[KreyosDataManager getUserDefaultOath] forKey:@"auth_token"];
    
    NSMutableDictionary *userParam = [[NSMutableDictionary alloc] init];
    
    [userParam setObject:first_name.text forKey:@"first_name"];
    [userParam setObject:last_name.text forKey:@"last_name"];
    [userParam setObject:bday forKey:@"birthday"];
    [userParam setObject:genderStr forKey:@"gender"];
    
    
    NSString* weightData;
    //Conversion, need to pass LBS value always
    if ([[[ weight_metric titleLabel] text] isEqualToString:@"LBS"])
    {
        [userParam setObject:weight_tf.text forKey:@"weight"];
        weightData = weight_tf.text;
    }
    else
    {
        float weightVal = [[weight_tf text] intValue];
        weightVal       *= 2.204f;
        weightData      = [NSString stringWithFormat:@"%.02f", weightVal];
        [userParam setObject:weightData forKey:@"weight"];
    }
    
    //Conversion, need to pass CM value always
    NSString* heightData;
    if ([[[height_metric titleLabel] text] isEqualToString:@"CM"])
    {
        [userParam setObject:height_tf.text forKey:@"height"];
        heightData = height_tf.text;
    }
    else
    {
        float heightVal = [[height_tf text] intValue];
        heightVal *= 30.480f;
        heightData = [NSString stringWithFormat:@"%.02f", heightVal];
        [userParam setObject:heightData forKey:@"height"];
    }
    
    [mUserDataDict setObject:userParam forKey:@"user"];
    
    //SAVE TO USERDEFAULTS
    [userDef setObject:first_name.text          forKey:@"info_0"];
    [userDef setObject:last_name.text           forKey:@"info_1"];
    [userDef setObject:mm.text                  forKey:@"info_2"];
    [userDef setObject:dd.text                  forKey:@"info_3"];
    [userDef setObject:yyyy.text                forKey:@"info_4"];
    [userDef setObject:location_tf.text         forKey:@"info_5"];
    [userDef setObject:weightData               forKey:@"info_6"];
    [userDef setObject:heightData               forKey:@"info_7"];
    [userDef setObject:imageUrl                 forKey:@"info_8"];
    
    [userDef synchronize];
    
    NSString* string = [userDef objectForKey:@"info_0"];
    NSLog(@"%@", string);
    
    
#ifndef OFFLINE_BUILD
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:mUserDataDict options:NSJSONWritingPrettyPrinted error:&err];
    NSString * dataString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"DATA STRING %@:",dataString);
    
    [[RequestManager rm] sendRequestPutMethod:kServerUpdateUserProfile withPutData:dataString target:self selector:@selector(tryUpdateInformation:)];
#endif
}

- (void)checkInvalidData
{
    if ( ![self isValid:first_name.text] )       { first_name.text   = _userData[INDEX_F_NAME]; }
    if ( ![self isValid:last_name.text] )        { last_name.text    = _userData[INDEX_L_NAME]; }
    if ( ![self isValid:mm.text] )               { mm.text           = _userData[INDEX_MM]; }
    if ( ![self isValid:dd.text] )               { dd.text           = _userData[INDEX_DD]; }
    if ( ![self isValid:yyyy.text] )             { yyyy.text         = _userData[INDEX_YYYY]; }
    if ( ![self isValid:location_tf.text] )      { location_tf.text  = _userData[INDEX_LOCATION]; }
    if ( ![self isValid:weight_tf.text] )        { weight_tf.text    = _userData[INDEX_WEIGHT]; }
    if ( ![self isValid:height_tf.text] )        { height_tf.text    = _userData[INDEX_HEIGHT]; }
    if ( ![self isValid:imageUrl] )              { imageUrl          = _userData[INDEX_IMG_URL]; }
}

- (BOOL) isValid:(NSString*)p_data
{
    if (!p_data) { return NO; }
    NSString* str   = [p_data lowercaseString];
    str             = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (![str length]) { return NO; }
    return YES;
}

- (void)tryUpdateInformation:(NSData*)responseData
{
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
    if ([[json objectForKey:@"status"] intValue] == 201)
    {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Congratulations"
                                                            message:@"Your profile information is now updated"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}


- (UIImage*) getImageByUrlString : (NSString*) str
{
    NSURL *url      = [NSURL URLWithString:str];
    NSData *data    = [NSData dataWithContentsOfURL:url];
    UIImage *img    = [[UIImage alloc] initWithData:data];
    
    return img;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark PICKER DELEGATE
- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return bIsWeightPicker ? 2 : 3;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(bIsWeightPicker)
    {
        NSInteger rowInComponent1;
        rowInComponent1 = [pickerView selectedRowInComponent:1];
        
        switch (component)
        {
            case 0:
                return rowInComponent1 == 0 ? [lbArray count] : [kgArray count];
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
        NSInteger rowInComponent1   = [pickerView selectedRowInComponent:2];
        BOOL IS_CM                  = rowInComponent1 == 0 ? YES : NO;
        
        switch (component)
        {
            case 0:
                
                NSLog(@"Component 0");
                if(IS_CM)
                {
                    NSLog(@"FT COUNT %i", [ftArray count]);
                }
                else
                {
                    NSLog(@"0");
                }
                break;
                
            case 1:
                return IS_CM ? [cmArray count] : [inchArray count];
                
                NSLog(@"Component 1");
                if(IS_CM)
                {
                    NSLog(@"CM COUNT %i", [cmArray count]);
                }
                else
                {
                    NSLog(@"INCH COUNT %i", [inchArray count]);
                }
                break;
            case 2:
                return [heightMetricArray count];
                break;
            default:
                break;
        }
        
        switch (component)
        {
            case 0:
                return IS_CM ? 0 : [ftArray count];
                break;
                
            case 1:
                return IS_CM ? [cmArray count] : [inchArray count];
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
        NSInteger rowInComponent1 = [pickerView selectedRowInComponent:1];
        switch (component)
        {
            case 0:
                returnValue = (NSNumber*)(rowInComponent1 == 0 ? lbArray[row] : kgArray[row]);
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
        NSInteger rowInComponent2   = [pickerView selectedRowInComponent:2];
        BOOL IS_CM                  = rowInComponent2 == 0 ? YES : NO;
        switch (component)
        {
            case 0:
                if(row > [ftArray count])return @"";
                returnValue = IS_CM ? @"" : [ftArray objectAtIndex:row];
                break;
                
            case 1:
                if (IS_CM)
                {
                    if(row > [cmArray count])return @"";
                    returnValue = [cmArray objectAtIndex:row];
                    
    
                }
                else
                {
                    if(row > [inchArray count])return @"";
                    returnValue = [inchArray objectAtIndex:row];
                }
                break;
            case 2:
                return heightMetricArray[row];
                break;
                
            default:
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
        NSInteger rowInComponent1   = [pickerView selectedRowInComponent:1];
        BOOL IS_LBS                 = rowInComponent1 == 0;
        switch (component)
        {
            case 1:
            {
                [weightHeightPicker reloadAllComponents];
                [weight_metric setTitle:[NSString stringWithFormat:@"%@", weightMetricArray[rowInComponent1]] forState:UIControlStateNormal];
            
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    [self performSelector:@selector(pickerWeight:) withObject:[NSNumber numberWithBool:IS_LBS] afterDelay:0.05f];
                });
                
            }
            break;
            default:
            {
                value           = (NSNumber*)(rowInComponent1 == 0 ? lbArray[row] : kgArray[row]);
                weight_tf.text  = [NSString stringWithFormat:@"%@", value];
                
                if (!IS_LBS)
                {
                    m_weightData = GetLbsFromKilogram([value integerValue]);
                }
                else
                {
                    m_weightData = [value integerValue];
                }
            }
            break;
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger rowInComponent0   = [weightHeightPicker selectedRowInComponent:0];
        NSInteger rowInComponent1   = [weightHeightPicker selectedRowInComponent:1];
        NSInteger rowInComponent2   = [weightHeightPicker selectedRowInComponent:2];
        BOOL IS_CM                  = rowInComponent2 == 0 ? YES : NO;
        
        switch (component)
        {
            case 2:
            {
                [weightHeightPicker reloadAllComponents];
                [height_metric setTitle:[NSString stringWithFormat:@"%@", heightMetricArray[rowInComponent2]] forState:UIControlStateNormal];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSelector:@selector(pickerSel:) withObject:[NSNumber numberWithBool:IS_CM] afterDelay:0.05f];
                });
                
                m_didSwitch = YES;
            }
            default:
            {
                if (m_didSwitch)
                {
                    m_didSwitch = NO;
                    return;
                }
                
                if (IS_CM)
                {
                    if(rowInComponent1 > [cmArray count])return;
                    height_tf.text      = [NSString stringWithFormat:@"%@", cmArray[rowInComponent1]];
                    m_heightData        = [cmArray[rowInComponent1] intValue];
                }
                else
                {
                    if(rowInComponent0 > [ftArray count])   return;
                    if(rowInComponent1 > [inchArray count]) return;
                    height_tf.text  = [NSString stringWithFormat:@"%@'%@", ftArray[rowInComponent0], inchArray[rowInComponent1]];
                    m_heightData    = GetCmFromFTIN([ftArray[rowInComponent0] integerValue],
                                                    [inchArray[rowInComponent1] integerValue]);
                    
                }
            }
                break;
        }
            });
    }
                       
}

-(void)pickerWeight:(NSNumber*)p_num
{
    BOOL num = [p_num boolValue];
    if (num)
    {
        [self MovePicker:lbArray value:m_weightData component:0];
        weight_tf.text   = [NSString stringWithFormat:@"%i", m_weightData];
    }
    else
    {
        u_int kg        = m_weightData / 2.2;
        weight_tf.text  = [NSString stringWithFormat:@"%i", kg];
        [self MovePicker:kgArray value:kg component:0];
    }
}
-(void)pickerSel:(NSNumber*)p_num
{
    BOOL num = [p_num boolValue];
    [self converPickerVal:num];
}

-(void)converPickerVal:(BOOL)p_isCm
{
    if (p_isCm)
    {
        [self MovePicker:cmArray value:m_heightData component:1];
        height_tf.text   = [NSString stringWithFormat:@"%i", m_heightData];
    }
    else
    {
        u_int raw   = m_heightData * 0.3937008;
        double ft   = raw / 12;
        u_int mod   = raw % 12;
        
        [self MovePicker:ftArray    value:ft    component:0];
        [self MovePicker:inchArray  value:mod   component:1];
        
        height_tf.text   = [NSString stringWithFormat:@"%i'%i", (u_int)ft , mod];
    }
}

-(void)MovePicker:(NSArray*)p_arr value:(u_int)p_val component:(u_int)p_comp
{
    u_int i = 0;
    for (; i < [p_arr count]; i++)
    {
        if ([p_arr[i] integerValue] == p_val)
        {
            [weightHeightPicker selectRow:i inComponent:p_comp animated:YES];
            break;
        }
    }

}

u_int GetCmFromFTIN(unsigned int p_ft, unsigned int p_in)
{
    u_int raw       = (p_ft * 12) + p_in;
    u_int cm        = raw * 2.54;
    return cm;
}

u_int GetLbsFromKilogram(unsigned int p_kilo)
{
    u_int lbs = p_kilo * 2.2;
    return lbs;
}



@end

