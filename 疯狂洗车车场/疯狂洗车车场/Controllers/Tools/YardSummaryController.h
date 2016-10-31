//
//  YardAddressController.h
//  美车帮车场
//
//  Created by 龚杰洪 on 15/1/31.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "BaseViewController.h"
#import "GCPlaceholderTextView.h"


@interface YardSummaryController : BaseViewController <UITextViewDelegate>
{
    IBOutlet GCPlaceholderTextView   *_addressField;
    IBOutlet UIButton       *_submitBtn;
    IBOutlet UIView         *_textViewBg;
}

@property (nonatomic, assign) CarWashModel *yardInfo;

@end
