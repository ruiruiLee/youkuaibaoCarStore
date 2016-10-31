//
//  GetCashViewController.m
//  疯狂洗车车场
//
//  Created by cts on 15/12/29.
//  Copyright © 2015年 龚杰洪. All rights reserved.
//

#import "GetCashViewController.h"
#import "BankCardModel.h"
#import "WebServiceHelper.h"
#import "MBProgressHUD+Add.h"
#import "GetCashRecordViewController.h"


@interface GetCashViewController ()<UITextFieldDelegate>
{
    
    IBOutlet UILabel *_cardNameLabel;
    
    IBOutlet UITextField *_getCashPriceField;
    
    IBOutlet UIButton *_submitButton;
    
    BankCardModel *_selectedBankCardModel;
}

@end

@implementation GetCashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setTitle:@"提现"];
    _submitButton.layer.masksToBounds = YES;
    _submitButton.layer.cornerRadius = 5;
    
    if (self.bankCardArray.count > 0)
    {
        _selectedBankCardModel = self.bankCardArray[0];
    }
    
    _getCashPriceField.placeholder = [NSString stringWithFormat:@"可提现金额(%.2f)元",self.targetModel.account_amount.floatValue];
    _cardNameLabel.text = [NSString stringWithFormat:@"%@(尾号%@)",_selectedBankCardModel.bank_name,[_selectedBankCardModel.bank_no substringWithRange:NSMakeRange(_selectedBankCardModel.bank_no.length - 4, 4)]];
    
}
- (IBAction)didSubmitButtonTouch:(id)sender
{
    if ([_getCashPriceField.text isEqualToString:@""] || _getCashPriceField.text == nil)
    {
        [Constants showMessage:@"请输入提现金额"];
    }
    else if (_getCashPriceField.text.floatValue > _selectedBankCardModel.max_extract_money.floatValue)
    {
        NSString *alertString = [NSString stringWithFormat:@"每日最高提现金额%.2f元",_selectedBankCardModel.max_extract_money.floatValue];
        [Constants showMessage:alertString];
    }
    else if (_getCashPriceField.text.floatValue < _selectedBankCardModel.min_extract_money.floatValue)
    {
        NSString *alertString = [NSString stringWithFormat:@"最小提现金额为%.2f元",_selectedBankCardModel.min_extract_money.floatValue];
        [Constants showMessage:alertString];
    }
    else
    {
        [self startSubmitGetCashOrderToService];
    }
}

- (void)startSubmitGetCashOrderToService
{
    NSString *extract_amountString = [NSString stringWithFormat:@"%.2f",_getCashPriceField.text.floatValue];

    NSDictionary *submitDic = @{@"car_wash_id":_userInfo.car_wash_id,
                                @"extract_amount":extract_amountString,
                                @"bank_id":_selectedBankCardModel.bank_id};
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    [WebService requestJsonOperationWithParam:submitDic
                                       action:@"account/service/applyExtract"
                               normalResponse:^(NSString *status, id data)
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        self.view.userInteractionEnabled = YES;
        if (status.intValue> 0)
        {
            [Constants showMessage:@"提现申请提交成功"];
            
            NSMutableArray *controllers = [self.navigationController.viewControllers mutableCopy];
            
            GetCashRecordViewController *viewController = [[GetCashRecordViewController alloc] initWithNibName:@"GetCashRecordViewController"
                                                                                                        bundle:nil];
            [controllers removeLastObject];
            [controllers addObject:viewController];
            [self.navigationController setViewControllers:controllers animated:YES];
        }
        else
        {
            [Constants showMessage:@"提现申请提交失败"];
        }
    }
                            exceptionResponse:^(NSError *error) {
                                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                self.view.userInteractionEnabled = YES;
                                [MBProgressHUD showError:[error domain] toView:self.view];
    }];
}

#pragma mark- UITextFieldDelegate Method 

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL isHaveDian = NO;
    if ([textField.text rangeOfString:@"."].location == NSNotFound)
    {
        isHaveDian = NO;
    }
    else
    {
        isHaveDian = YES;
    }
    if ([string length] > 0) {
        
        unichar single = [string characterAtIndex:0];//当前输入的字符
        if ((single >= '0' && single <= '9') || single == '.') {//数据格式正确
            
            //首字母不能为0和小数点
            if([textField.text length] == 0){
                if(single == '.') {
                    [Constants showMessage:@"亲，第一个数字不能为小数点"];
                    [textField.text stringByReplacingCharactersInRange:range withString:@""];
                    return NO;
                }
                if (single == '0') {
                    [Constants showMessage:@"亲，第一个数字不能为0"];
                    [textField.text stringByReplacingCharactersInRange:range withString:@""];
                    return NO;
                }
            }
            
            //输入的字符是否是小数点
            if (single == '.') {
                if(!isHaveDian)//text中还没有小数点
                {
                    isHaveDian = YES;
                    return YES;
                    
                }else{
                    [Constants showMessage:@"亲，您已经输入过小数点了"];
                    [textField.text stringByReplacingCharactersInRange:range withString:@""];
                    return NO;
                }
            }else{
                if (isHaveDian) {//存在小数点
                    
                    //判断小数点的位数
                    NSRange ran = [textField.text rangeOfString:@"."];
                    if (range.location - ran.location <= 2) {
                        return YES;
                    }else{
                        [Constants showMessage:@"亲，您最多输入两位小数"];
                        return NO;
                    }
                }else{
                    return YES;
                }
            }
        }else{//输入的数据格式不正确
            [Constants showMessage:@"亲，您输入的格式不正确"];
            [textField.text stringByReplacingCharactersInRange:range withString:@""];
            return NO;
        }
    }
    else
    {
        return YES;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self closeKeyBoard];
}

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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
