//
//  FeedBackController.h
//  美车帮
//
//  Created by 龚杰洪 on 15/1/28.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "BaseViewController.h"
#import "GCPlaceholderTextView.h"

@interface FeedBackController : BaseViewController <UITextViewDelegate>
{
    IBOutlet UIView                 *_feedBackTextViewBg;
    IBOutlet GCPlaceholderTextView  *_feedBackTextView;
    IBOutlet UIButton               *_submitBtn;
}

@end
