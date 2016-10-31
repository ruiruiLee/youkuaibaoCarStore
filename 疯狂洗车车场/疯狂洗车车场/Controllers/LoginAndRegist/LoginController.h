//
//  LoginController.h
//  美车帮
//
//  Created by tanglulu on 15-1-24.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "BaseViewController.h"

@interface LoginController : BaseViewController
{
    IBOutlet UITextField    *_phoneNumField;
    IBOutlet UITextField    *_passwordField;
    IBOutlet UIView         *_phoneNumBg;
    IBOutlet UIButton       *_submitBtn;
}

@end
