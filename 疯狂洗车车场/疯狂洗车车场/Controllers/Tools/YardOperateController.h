//
//  YardOperateController.h
//  美车帮车场
//
//  Created by 龚杰洪 on 15/2/1.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "BaseViewController.h"

@interface YardOperateController : BaseViewController <UITextFieldDelegate>
{
    IBOutlet UITextField    *_startTimeLabel;
    IBOutlet UITextField    *_endTImeLabel;
    IBOutlet UISwitch   *_switch;
    IBOutlet UIButton   *_submitBtn;
}

@property (nonatomic, assign) CarWashModel *yardInfo;

@end
