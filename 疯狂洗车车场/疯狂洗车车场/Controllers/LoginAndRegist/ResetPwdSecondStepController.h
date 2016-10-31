//
//  RegistSecondStepController.h
//  美车帮
//
//  Created by 龚杰洪 on 15/1/27.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "BaseViewController.h"

@interface ResetPwdSecondStepController : BaseViewController
{
    IBOutlet UIView         *_phoneNumBg;
    
    IBOutlet UITextField    *_phoneNumField;
    
    IBOutlet UIButton       *_showPwdBtn;
    
    IBOutlet UIButton       *_submitButton;
}

@property (nonatomic, strong) NSString *phoneNum;

@property (nonatomic, strong) NSString *verifyCode;

@end
