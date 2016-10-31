//
//  LoginController.m
//  美车帮
//
//  Created by tanglulu on 15-1-24.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "LoginController.h"
#import "UIView+Toast.h"
#import "WebServiceHelper.h"
#import "MBProgressHUD+Add.h"
#import "ResetPwdController.h"

@interface LoginController () <UITextFieldDelegate, UINavigationControllerDelegate>
{
    
}

@end

@implementation LoginController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[_phoneNumBg layer] setBorderWidth:1.0];
    [[_phoneNumBg layer] setBorderColor:[[UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0] CGColor]];
    
    // Do any additional setup after loading the view from its nib.
    
    [[_submitBtn layer] setCornerRadius:5.0];
    [[_submitBtn layer] setMasksToBounds:YES];
    
    [self.navigationController setDelegate:self];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)checkInfoAndLogin:(id)sender
{
    [self closeKeyBoard];

    if (!_phoneNumField.text || [_phoneNumField.text length] == 0)
    {
        [self.view makeToast:@"请输入您的手机号！"];
        return;
    }
    if (!_passwordField.text || [_passwordField.text length] == 0)
    {
        [self.view makeToast:@"请输入您的密码！"];
        return;
    }
    if (_phoneNumField.text.length < 11)
    {
        [self.view makeToast:@"手机号码格式不正确！"];
        return;
    }
    [self loginToServer];
}

- (void)loginToServer
{
    NSDictionary *tmpDic=[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info"
                                                                                                    ofType:@"plist"]];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [WebService requestJsonModelWithParam:@{@"login_name": _phoneNumField.text,
                                            @"login_password": _passwordField.text,
                                            @"user_type" :@"2",
                                            @"app_type"  :@"2",
                                            @"app_version":[NSString stringWithFormat:@"%.2f",[[tmpDic valueForKey:@"CFBundleShortVersionString"] floatValue]],
                                            @"client_id" :_notificationDeviceToken == nil?@"":_notificationDeviceToken}
                                   action:@"member/service/login"
                               modelClass:[UserInfo class]
                           normalResponse:^(NSString *status, id data, JsonBaseModel *model)
     {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         if (status.intValue > 0)
         {
             _userInfo = (UserInfo*)model;
             [[NSUserDefaults standardUserDefaults] setObject:@{@"login_name":_phoneNumField.text,
                                                                @"login_password":_passwordField.text}
                                                       forKey:kAutoLogin];
             
             [[NSUserDefaults standardUserDefaults] setObject:_userInfo.token
                                                       forKey:kLoginToken];

             
             [[NSUserDefaults standardUserDefaults] setObject:[_userInfo convertToDictionary]
                                                       forKey:kUserInfoKey];
             [[NSUserDefaults standardUserDefaults] synchronize];
             [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessNotifaction
                                                                 object:nil];
         }
         else
         {
             [self.view makeToast:data];
         }

         
     }
                        exceptionResponse:^(NSError *error)
     {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         [self.view makeToast:[error.userInfo valueForKey:@"msg"]];
     }];
}



- (IBAction)resetPassword:(id)sender
{
    ResetPwdController *controller = ALLOC_WITH_CLASSNAME(@"ResetPwdController");
    [self.navigationController pushViewController:controller animated:YES];
}

/*手机号码验证 MODIFIED BY HELENSONG*/
- (BOOL)isMobileNumber:(NSString *)mobileNum
{
    NSString *regex = @"^((13[0-9])|(14[0-9])|(15[^4,\\D])|(17[0-9])|(18[0-9]))\\d{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:mobileNum];
    if(isMatch)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self closeKeyBoard];
}

#pragma mark - 解决滑动pop的bug

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    if(![viewController isKindOfClass:[LoginController class]])
    {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if ([_phoneNumField.text isEqualToString:@""] || _phoneNumField == nil)
    {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kAutoLogin])
        {
            NSDictionary *autoLogin = [[NSUserDefaults standardUserDefaults] objectForKey:kAutoLogin];
            _phoneNumField.text = [autoLogin objectForKey:@"login_name"];
        }
    }
}

#pragma mark - closeKeyBoard

- (void)closeKeyBoard
{
    [[self findFirstResponder:self.view]resignFirstResponder];
}

- (UIView *)findFirstResponder:(UIView*)view
{
    for ( UIView *childView in view.subviews )
    {
        if ([childView respondsToSelector:@selector(isFirstResponder)] && [childView isFirstResponder])
        {
            return childView;
        }
        UIView *result = [self findFirstResponder:childView];
        if (result) return result;
    }
    return nil;
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    if ([textField.text length] >= 11 && textField == _phoneNumField)
    {
        if ([string isEqualToString:@""])
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
