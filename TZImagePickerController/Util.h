//
//  Util.h
//  COMP
//
//  Copyright (c) 2015年 admin. All rights reserved.
//

#ifndef COMP_Util_h
#define COMP_Util_h

#define K_SYSTEM_MSG_UNREAD         @"k_system_msg_unread"
#define K_SYSTEM_MSG_BEREAD         @"k_system_msg_beread"
#define K_OPERATON_TASK_UNDO        @"k_operation_task_undo"
#define UPDATE_MYACTIVITY_NUMBER    @"updateMyActivityNumber"
#define CANCEL_COLLECT_ACTIVITY     @"CANCELCOLLECTACTIVITY"
#define DELETE_ACTIVITY             @"DELETEACTIVITY"

#define kNavigationBarTitleFontSize  18.0f
#define kNaviUIBarButtonItemWidth    23.5f
#define kNaviUIBarButtonItemHeight   25.0f

#pragma mark - Colors
///---------------------------------------------------------------------------
/// @name Creating colors
///---------------------------------------------------------------------------

/**
 Create a UIColor with r,g,b values between 0.0 and 1.0.
 */
#define RGBCOLOR(r,g,b) \
[UIColor colorWithRed:r/256.f green:g/256.f blue:b/256.f alpha:1.f]

/**
 Create a UIColor with r,g,b,a values between 0.0 and 1.0.
 */
#define RGBACOLOR(r,g,b,a) \
[UIColor colorWithRed:r/256.f green:g/256.f blue:b/256.f alpha:a]

/**
 Create a UIColor from a hex value.
 
 For example, `UIColorFromRGB(0xFF0000)` creates a `UIColor` object representing
 the color red.
 */
#define UIColorFromRGB(rgbValue) \
[UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:1.0]

/**
 Create a UIColor with an alpha value from a hex value.
 
 For example, `UIColorFromRGBA(0xFF0000, .5)` creates a `UIColor` object
 representing a half-transparent red.
 */
#define UIColorFromRGBA(rgbValue, alphaValue) \
[UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:alphaValue]

#define kWXAPP_ID           @"wx901a16bca1927a8d"
#define kWXAPP_SECRET       @"103f3330f4858f2d420e9cc7f884e673"
#define kQQAppId            @"1105392352"
#define kQQAPP_SECRET       @"i5qJGWUulHAyw8nS"
#define kShareAPP_Key       @"110d464e48740"
#define kRCIM_APP_Key       @"n19jmcy59zxm9" 
#define PGY_APP_ID          @"e5b8307fbbcdec8e1e0ca0c853937463"
static NSString *kAuthScope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
static NSString *kAuthOpenID = @"0c806938e2413ce73eef92cc3";
static NSString *kAuthState = @"xxx";


#define KSCREENSIZE      [UIScreen mainScreen].bounds.size
#define KBACKGROUNDCOLOR [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0f]



#endif
