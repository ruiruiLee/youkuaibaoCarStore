//
//  LoginController.m
//  美车帮
//
//  Created by tanglulu on 15-1-24.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "ResetPwdController.h"
#import "UIView+Toast.h"
#import "WebServiceHelper.h"
#import "MBProgressHUD+Add.h"
#import "ResetPwdSecondStepController.h"

@interface ResetPwdController () <UITextFieldDelegate>
{
    NSInteger seconds;
    
    IBOutlet UIButton *_submitButton;
}

@end

@implementation ResetPwdController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"找回密码"];
    
    [[_phoneNumBg layer] setCornerRadius:5.0];
    [[_phoneNumBg layer] setMasksToBounds:YES];
    [[_phoneNumBg layer] setBorderWidth:1.0];
    [[_phoneNumBg layer] setBorderColor:[[UIColor colorWithRed:205/255.0
                                                         green:205/255.0
                                                          blue:205/255.0
                                                         alpha:1.0] CGColor]];
    
    [[_passwordBg layer] setCornerRadius:5.0];
    [[_passwordBg layer] setMasksToBounds:YES];
    [[_passwordBg layer] setBorderWidth:1.0];
    [[_passwordBg layer] setBorderColor:[[UIColor colorWithRed:205/255.0
                                                         green:205/255.0
                                                          blue:205/255.0
                                                         alpha:1.0] CGColor]];
    // Do any additional setup after loading the view from its nib.
    
    _submitButton.layer.masksToBounds = YES;
    _submitButton.layer.cornerRadius = 5;
    
    [[_verifyCodeBtn layer] setCornerRadius:3.0];
    [[_verifyCodeBtn layer] setMasksToBounds:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)obtainVerifyCode:(id)sender
{
    if (!_phoneNumField.text || [_phoneNumField.text length] == 0)
    {
        [self.view makeToast:@"请输入您的手机号！"];
        return;
    }
    if (_phoneNumField.text.length < 11)
    {
        [self.view makeToast:@"手机号码格式不正确！"];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [WebService requestJsonOperationWithParam:@{@"phone": _phoneNumField.text,
                                                @"verify_type": @"2",
                                                @"user_type":@"2"}
                                       action:@"code/service/get"
                               normalResponse:^(NSString *status, id data)
     {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         [MBProgressHUD showSuccess:@"验证码发送成功" toView:self.view];

         seconds = 60;
         [_verifyCodeBtn setEnabled:NO];
         _verifyTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                         target:self
                                                       selector:@selector(changeBtnTitle)
                                                       userInfo:nil
                                                        repeats:YES];
     }
                            exceptionResponse:^(NSError *error)
     {
         [MBProgressHUD hideHUDForView:self.view animated:NO];
         [MBProgressHUD showError:@"验证码获取失败！" toView:self.view];
     }];

}

- (void)changeBtnTitle
{
    if (seconds == 0)
    {
        [_verifyCodeBtn setEnabled:YES];
        [_verifyTimer invalidate];
        seconds = 30;
        return;
    }
    
    [_verifyCodeBtn setTitle:[NSString stringWithFormat:@"%ld秒后重试",(long)seconds]
                    forState:UIControlStateDisabled];
    seconds -= 1;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)didSubmitButtonTouch:(id)sender
{
    [self nextStep:nil];
}

- (void)nextStep:(id)sender
{
    if (!_phoneNumField.text || [_phoneNumField.text length] == 0)
    {
        [self.view makeToast:@"请输入您的手机号！"];
        return;
    }
    if (_phoneNumField.text.length < 11)
    {
        [self.view makeToast:@"手机号码格式不正确！"];
        return;
    }
    if (!_passwordField.text || [_passwordField.text length] == 0)
    {
        [self.view makeToast:@"请输入您收到的验证码！"];
        return;
    }

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self closeKeyBoard];

    [WebService requestJsonOperationWithParam:@{@"phone": _phoneNumField.text,
                                                @"verify_code": _passwordField.text,
                                                @"verify_type": @"2",
                                                @"user_type":@"2"}
                                       action:@"code/service/check"
                               normalResponse:^(NSString *status, id data)
     {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         
         ResetPwdSecondStepController *controller = [[ResetPwdSecondStepController alloc] initWithNibName:@"ResetPwdSecondStepController" bundle:nil];
         [controller setVerifyCode:_passwordField.text];
         [controller setPhoneNum:_phoneNumField.text];
         [self.navigationController pushViewController:controller animated:YES];
     }
                            exceptionResponse:^(NSError *error)
     {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         [self.view makeToast:@"验证码效验失败！"];
     }];
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
    [self closeKeyBoard];
}

#pragma mark - closeKeyBoard

- (void)closeKeyBoard
{
    [[self findFirstResponder:self.view] resignFirstResponder];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
