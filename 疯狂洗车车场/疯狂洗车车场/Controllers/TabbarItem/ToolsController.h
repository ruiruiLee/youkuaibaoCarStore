//
//  ToolsController.h
//  美车帮车场
//
//  Created by 龚杰洪 on 15/1/31.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "BaseViewController.h"

@interface ToolsController : BaseViewController
{
    IBOutlet UIImageView    *_yardImageView;
    IBOutlet UILabel        *_imageCountLabel;
    IBOutlet UILabel        *_yardNameLabel;
    IBOutlet UILabel        *_yardAddressLabel;
    IBOutlet UILabel        *_yardContactPhoneLabel;
    IBOutlet UILabel        *_yardSummaryLabel;
    IBOutlet UILabel        *_jiaochaPriceLabel;
    IBOutlet UILabel        *_suvPriceLabel;
    IBOutlet UIButton       *_operateTimeBtn;
    IBOutlet UISwitch       *_isOperatedSwitch;
}

@end
