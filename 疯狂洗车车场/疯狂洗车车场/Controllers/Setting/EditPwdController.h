//
//  EditPwdController.h
//  美车帮
//
//  Created by 龚杰洪 on 15/1/28.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "BaseViewController.h"

@interface EditPwdController : BaseViewController <UITextFieldDelegate>
{
    IBOutlet UIView         *_oldPwdView;
    IBOutlet UITextField    *_oldPwdField;
    
    IBOutlet UIView         *_newPwdView;
    IBOutlet UITextField    *_newPwdField;
    
    IBOutlet UIButton       *_showPwdBtn;
    
    
    IBOutlet UIButton       *_submitButton;
}

@property (assign, nonatomic) BOOL isFowSuper;

@end
