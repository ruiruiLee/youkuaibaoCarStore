//
//  YardAddressController.m
//  美车帮车场
//
//  Created by 龚杰洪 on 15/1/31.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "YardPhoneController.h"
#import "MBProgressHUD+Add.h"
#import "WebServiceHelper.h"
#import "UIView+Toast.h"

@interface YardPhoneController ()

@end

@implementation YardPhoneController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"电话"];
    
    [[_submitBtn layer] setCornerRadius:5.0];
    [[_submitBtn layer] setMasksToBounds:YES];
    
    [_addressField setText:_yardInfo.phone];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sumitInfo:(id)sender
{
    if ([_addressField.text isEqualToString:@""] || !_addressField.text)
    {
        [self.view makeToast:@"请先输入车场联系电话后保存！"];
        return;
    }
    [self submitInfo];
}

- (void)submitInfo
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableDictionary *paramDic = [[_yardInfo convertToDictionary] mutableCopy];
    [paramDic setValue:@"update" forKey:@"op_type"];
    [paramDic setValue:@"" forKey:@"logo"];
    [paramDic setValue:_addressField.text forKey:@"phone"];
    UserInfo *userinfo = [[UserInfo alloc] initWithCacheKey:kUserInfoKey];
    [paramDic setValue:userinfo.car_wash_id forKey:@"car_wash_id"];
    [WebService requestJsonOperationWithParam:paramDic
                                       action:@"carWash/service/manage"
                               normalResponse:^(NSString *status, id data)
     {
         _yardInfo.phone = _addressField.text;
         [MBProgressHUD hideHUDForView:self.view animated:NO];
         [MBProgressHUD showSuccess:@"修改成功" toView:self.navigationController.view];
         [self.navigationController popViewControllerAnimated:YES];
     }
                            exceptionResponse:^(NSError *error)
     {
         [MBProgressHUD hideHUDForView:self.view animated:NO];
         [self.view makeToast:[[error userInfo] valueForKey:@"msg"]];
     }];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_addressField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length>=20)
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
    else
    {
        return YES;
    }
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
