//
//  FeedBackController.m
//  美车帮
//
//  Created by 龚杰洪 on 15/1/28.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "FeedBackController.h"
#import "UIView+Toast.h"
#import "WebServiceHelper.h"
#import "MBProgressHUD+Add.h"

@interface FeedBackController ()
{
}

@end

@implementation FeedBackController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"意见反馈"];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"提交"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(submitFeedBack:)];
    
    [rightItem setTintColor:kNormalTintColor];
    [rightItem setTitle:@"提交"];
    [self.navigationItem setRightBarButtonItem:rightItem];

    
    [_feedBackTextView setPlaceholder:@"有什么意见和建议，请告诉我们……"];
    
    [[_submitBtn layer] setCornerRadius:3.0];
    [[_submitBtn layer] setMasksToBounds:YES];
    
    [[_feedBackTextViewBg layer] setCornerRadius:5.0];
    [[_feedBackTextViewBg layer] setMasksToBounds:YES];
    [[_feedBackTextViewBg layer] setBorderColor:[[UIColor colorWithRed:195/255.0
                                                                green:195/255.0
                                                                 blue:195/255.0
                                                                alpha:1.0] CGColor]];
    [[_feedBackTextViewBg layer] setBorderWidth:1.0];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)submitFeedBack:(id)sender
{
    [_feedBackTextView resignFirstResponder];
    if ([_feedBackTextView.text isEqualToString:@""] || !_feedBackTextView.text)
    {
        [self.view makeToast:@"说点您的意见或建议吧……"];
        return;
    }
    if (_feedBackTextView.text.length > 100)
    {
        [self.view makeToast:@"您输入的信息过长，请控制在100字以内哦！"];
        return;
    }
    /*
     7.意见反馈
     地址：http://118.123.249.87/service/ feedback.aspx
     参数:
     if_admin    (0:一般会员,1:车场老板或车场管理员)
     member_id  (if_amdin=0时必须输入,会员id)
     admin_id    (if_amdin=1时必须输入,车场管理员id)
     feedback_content (反馈内容,100个汉字以内)
     */
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *submitDic = @{@"if_admin": @"1",
                                @"user_id": _userInfo.admin_id,
                                @"feedback_content": _feedBackTextView.text};
    self.view.userInteractionEnabled = NO;
    [WebService requestJsonOperationWithParam:submitDic
                                       action:@"feedback/service/create"
                               normalResponse:^(NSString *status, id data)
     {
         self.view.userInteractionEnabled = YES;
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         [Constants showMessage:@"感谢您的宝贵意见和建议！"];
         [self.navigationController popViewControllerAnimated:YES];
     }
                            exceptionResponse:^(NSError *error)
     {
         self.view.userInteractionEnabled = YES;
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         [self.view makeToast:[error.userInfo valueForKey:@"msg"]];
     }];
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
