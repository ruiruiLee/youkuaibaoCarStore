//
//  RegistSecondStepController.m
//  美车帮
//
//  Created by 龚杰洪 on 15/1/27.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "ResetPwdSecondStepController.h"
#import "UIView+Toast.h"
#import "MBProgressHUD+Add.h"
#import "WebServiceHelper.h"

@interface ResetPwdSecondStepController () <UIAlertViewDelegate>
{
}


@end

@implementation ResetPwdSecondStepController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"找回密码"];
    
    _submitButton.layer.masksToBounds = YES;
    _submitButton.layer.cornerRadius = 5;
    
    [[_phoneNumBg layer] setCornerRadius:5.0];
    [[_phoneNumBg layer] setMasksToBounds:YES];
    [[_phoneNumBg layer] setBorderWidth:1.0];
    [[_phoneNumBg layer] setBorderColor:[[UIColor colorWithRed:204/255.0
                                                         green:204/255.0
                                                          blue:204/255.0
                                                         alpha:1.0] CGColor]];

    
    // Do any additional setup after loading the view from its nib.
}



- (IBAction)didSubmitButtonTouch:(id)sender
{
    [self nextStep:nil];
}

- (void)nextStep:(id)sender
{
    if ([_phoneNumField.text isEqualToString:@""] || !_phoneNumField.text)
    {
        [self.view makeToast:@"请输入您的密码！"];
        return;
    }
    if ([_phoneNumField.text length] < 6)
    {
        [self.view makeToast:@"密码不能少于6个字符！"];
        return;
    }

    [self closeKeyBoard];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [WebService requestJsonOperationWithParam:@{@"phone": _phoneNum,
                                                @"new_password": _phoneNumField.text,
                                                @"op_type": @"find_back",
                                                @"user_type":@"2"}
                                       action:@"member/service/change"
                               normalResponse:^(NSString *status, id data)
     {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         [Constants showMessage:@"恭喜您，密码重置成功！"
                       delegate:self];

     }
                            exceptionResponse:^(NSError *error)
     {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         [self.view makeToast:[error.userInfo valueForKey:@"msg"]];
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (IBAction)showOrHidePwd:(id)sender
{
    if ([_phoneNumField isSecureTextEntry])
    {
        [_phoneNumField setSecureTextEntry:NO];
        [sender setSelected:YES];
    }
    else
    {
        [_phoneNumField setSecureTextEntry:YES];
        [sender setSelected:NO];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self closeKeyBoard];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
