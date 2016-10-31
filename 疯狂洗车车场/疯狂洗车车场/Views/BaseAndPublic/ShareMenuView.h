//
//  ShareMenuView.h
//  OldErp4iOS
//
//  Created by Darsky on 14/11/8.
//  Copyright (c) 2014年 HFT_SOFT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"


@interface ShareMenuView : UIView<UIGestureRecognizerDelegate>
{    
    UIView              *_menuView;
    
    UIPageControl       *_pageControl;
    
    UIButton            *_cancelButton;
    
    UIImage             *_shareImage;
    
    NSString            *_contentString;
    
    NSString            *_urlString;
        
    NSDictionary        *_shareTencentDic;
}


@property (strong, nonatomic) UIViewController *target;



+ (void)showShareMenuViewAtTarget:(UIViewController*)controller
                      withContent:(NSString*)contentString
                        withImage:(UIImage*)shareImage
                          withUrl:(NSString*)urlString;

+ (void)hideAllShareMenuView;

@end
