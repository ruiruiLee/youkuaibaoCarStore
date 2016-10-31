//
//  YardAddressController.m
//  美车帮车场
//
//  Created by 龚杰洪 on 15/1/31.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "YardSummaryController.h"
#import "MBProgressHUD+Add.h"
#import "WebServiceHelper.h"
#import "UIView+Toast.h"

@interface YardSummaryController ()

@end

@implementation YardSummaryController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"简介"];
    
    [[_submitBtn layer] setCornerRadius:5.0];
    [[_submitBtn layer] setMasksToBounds:YES];
    
    [[_textViewBg layer] setCornerRadius:5.0];
    [[_textViewBg layer] setMasksToBounds:YES];
    [[_textViewBg layer] setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:.3] CGColor]];
    [[_textViewBg layer] setBorderWidth:1.0];
    
    [_addressField setPlaceholder:@"请输入车场简介"];
    [_addressField setText:_yardInfo.introduction];
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
        [self.view makeToast:@"请先输入车场简介后保存！"];
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
    [paramDic setValue:_addressField.text forKey:@"introduction"];
    UserInfo *userinfo = [[UserInfo alloc] initWithCacheKey:kUserInfoKey];
    [paramDic setValue:userinfo.car_wash_id forKey:@"car_wash_id"];
    [WebService requestJsonOperationWithParam:paramDic
                                       action:@"carWash/service/manage"
                               normalResponse:^(NSString *status, id data)
     {
         [MBProgressHUD hideHUDForView:self.view animated:NO];
         [MBProgressHUD showSuccess:@"修改成功" toView:self.navigationController.view];
         _yardInfo.introduction = _addressField.text;
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
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
