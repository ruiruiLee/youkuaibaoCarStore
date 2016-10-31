//
//  YardOperateController.m
//  美车帮车场
//
//  Created by 龚杰洪 on 15/2/1.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "YardOperateController.h"
#import "MBProgressHUD+Add.h"
#import "WebServiceHelper.h"
#import "UIView+Toast.h"

@interface YardOperateController () <UIPickerViewDataSource, UIPickerViewDelegate>
{
    UIPickerView *_picker;
    
    NSInteger _selectTimeIndex;
}

@end

@implementation YardOperateController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"营业时间"];
    
    [[_submitBtn layer] setCornerRadius:5.0];
    [[_submitBtn layer] setMasksToBounds:YES];
    
    [_startTimeLabel setText:_yardInfo.business_hours_from == nil?@"8:00":_yardInfo.business_hours_from];
    [_endTImeLabel setText:_yardInfo.business_hours_to == nil?@"20:00":_yardInfo.business_hours_to];
    
    [_switch setOn:[_yardInfo.if_opening boolValue]];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyBoard)];
    [self.view addGestureRecognizer:tap];
    
    
    _picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-64, SCREEN_WIDTH, 250)];
    [_picker setDelegate:self];
    [_picker setDataSource:self];
    [_picker setBackgroundColor:[UIColor whiteColor]];
    _picker.hidden = YES;
    
    [self.view addSubview:_picker];
//
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _startTimeLabel)
    {
        _selectTimeIndex = 0;
        [self showOrHideDataPickerView:YES];
    }
    else if (textField == _endTImeLabel)
    {
        _selectTimeIndex = 1;
        [self showOrHideDataPickerView:YES];
    }
    return NO;
}

- (IBAction)submitInfo:(id)sender
{
    [self judgeTimeCorrect:^{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSMutableDictionary *paramDic = [[_yardInfo convertToDictionary] mutableCopy];
        [paramDic setValue:@"update" forKey:@"op_type"];
        [paramDic setValue:_startTimeLabel.text forKey:@"business_hours_from"];
        [paramDic setValue:_endTImeLabel.text forKey:@"business_hours_to"];
        [paramDic setValue:@"" forKey:@"logo"];
        [paramDic setValue:[NSString stringWithFormat:@"%d", _switch.isOn] forKey:@"if_opening"];
        UserInfo *userinfo = [[UserInfo alloc] initWithCacheKey:kUserInfoKey];
        [paramDic setValue:userinfo.car_wash_id forKey:@"car_wash_id"];
        [WebService requestJsonOperationWithParam:paramDic
                                           action:@"carWash/service/manage"
                                   normalResponse:^(NSString *status, id data)
         {
             _yardInfo.business_hours_from = _startTimeLabel.text;
             _yardInfo.business_hours_to = _endTImeLabel.text;
             _yardInfo.if_opening = [NSString stringWithFormat:@"%d", _switch.isOn];
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
               failRespone:^(NSString *errorString) {
        [Constants showMessage:errorString];
        return ;
    }];

}

- (void)judgeTimeCorrect:(void(^)(void))successRespone
             failRespone:(void(^)(NSString *errorString))failRespone
{
    int beginHour = 0;
    int beginMin = 0;
    int beginTime = 0;
    NSArray *tmpArray = [_startTimeLabel.text componentsSeparatedByString:@":"];
    beginHour = [tmpArray[0] intValue];
    beginMin = [tmpArray[1] intValue];
    beginTime = beginHour * 60+beginMin;
    
    
    int endHour = 0;
    int endMin = 0;
    int endTime = 0;
    NSArray *tmpArray2 = [_endTImeLabel.text componentsSeparatedByString:@":"];
    endHour = [tmpArray2[0] intValue];
    endMin = [tmpArray2[1] intValue];
    endTime = endHour * 60+endMin;
    
    if (beginTime > endTime)
    {
        failRespone(@"营业开始时间不能晚于营业结束时间");
        return;
    }
    else if (beginTime == endTime)
    {
        failRespone(@"营业开始时间不能等于营业结束时间");
        return;
    }
    else
    {
        successRespone();
        return;
    }
}

- (void)showOrHideDataPickerView:(BOOL)shouldShow
{
    if (shouldShow && _picker.hidden)
    {
        _picker.hidden = NO;
        self.view.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.3
                         animations:^{
                             _picker.transform = CGAffineTransformMakeTranslation(0, -250);
        }
                         completion:^(BOOL finished) {
                             if (finished)
                             {
                                 self.view.userInteractionEnabled = YES;
                             }
        }];
    }
    else if (!shouldShow && !_picker.hidden)
    {
        self.view.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.3
                         animations:^{
                             _picker.transform = CGAffineTransformIdentity;
                         }
                         completion:^(BOOL finished) {
                             if (finished)
                             {
                                 _picker.hidden = YES;
                                 self.view.userInteractionEnabled = YES;
                             }
                         }];
    }
}

#pragma mark - closeKeyBoard

- (void)closeKeyBoard
{
    [self showOrHideDataPickerView:NO];
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

#pragma mark - picker

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component)
    {
        case 0:
            return 24;
            break;
        case 1:
            return 60;
            break;
        default:
            return 0;
            break;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 44.0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%@", (long)row < 10 ?[NSString stringWithFormat:@"0%ld", (long)row] :
            [NSString stringWithFormat:@"%ld", (long)row]];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (_selectTimeIndex == 0)
    {
        [_startTimeLabel setText:[NSString stringWithFormat:@"%@:%@", [NSString stringWithFormat:@"%@", (long)[pickerView selectedRowInComponent:0] < 10 ?[NSString stringWithFormat:@"0%ld", (long)[pickerView selectedRowInComponent:0]] :
                                                             [NSString stringWithFormat:@"%ld", (long)[pickerView selectedRowInComponent:0]]],[NSString stringWithFormat:@"%@", (long)[pickerView selectedRowInComponent:1] < 10 ?[NSString stringWithFormat:@"0%ld", (long)[pickerView selectedRowInComponent:1]] :
                                                                                                                                               [NSString stringWithFormat:@"%ld", (long)[pickerView selectedRowInComponent:1]]] ]];
    }
    else if (_selectTimeIndex == 1)
    {
        [_endTImeLabel setText:[NSString stringWithFormat:@"%@:%@", [NSString stringWithFormat:@"%@", (long)[pickerView selectedRowInComponent:0] < 10 ?[NSString stringWithFormat:@"0%ld", (long)[pickerView selectedRowInComponent:0]] :
                                                             [NSString stringWithFormat:@"%ld", (long)[pickerView selectedRowInComponent:0]]],[NSString stringWithFormat:@"%@", (long)[pickerView selectedRowInComponent:1] < 10 ?[NSString stringWithFormat:@"0%ld", (long)[pickerView selectedRowInComponent:1]] :
                                                                                                                                               [NSString stringWithFormat:@"%ld", (long)[pickerView selectedRowInComponent:1]]] ]];
    }
}

@end
