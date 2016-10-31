//
//  ShareMenuView.m
//  OldErp4iOS
//
//  Created by Darsky on 14/11/8.
//  Copyright (c) 2014年 HFT_SOFT. All rights reserved.
//

#import "ShareMenuView.h"
#import <ShareSDK/ShareSDK.h>




@implementation ShareMenuView

+ (id)sharedShareMenuView
{
    static ShareMenuView *shareMenuView = nil;
    //
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{shareMenuView = [[ShareMenuView alloc] initWithFrame:[UIScreen mainScreen].bounds];});
    //
    return shareMenuView;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        float width = self.frame.size.width;
        float height = 222;
        
        _menuView = [[UIView alloc] initWithFrame:CGRectMake(5, self.frame.size.height+10, width-10, height+20)];
        _menuView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_menuView];
        _menuView.layer.masksToBounds = YES;
        _menuView.layer.cornerRadius = 5;
        
        
        NSArray *shareItemsArray = [self getShareItemList];
        
        float itemWidth = 46*[UIScreen mainScreen].bounds.size.width/320;
        
        float padding = (_menuView.frame.size.width - itemWidth*shareItemsArray.count)/(shareItemsArray.count+1);
        
        
        for (int x = 0; x<shareItemsArray.count; x++)
        {
            NSDictionary *shareDic = shareItemsArray[x];
            UIButton *shareItem = [UIButton buttonWithType:UIButtonTypeCustom];
            shareItem.frame = CGRectMake(padding+(itemWidth+padding)*x,
                                         20,
                                         itemWidth,
                                         itemWidth);
            [shareItem setImage:[UIImage imageNamed:[shareDic objectForKey:@"image"]]
                       forState:UIControlStateNormal];

            [shareItem addTarget:self
                          action:@selector(didShareItemTouch:)
                forControlEvents:UIControlEventTouchUpInside];
            shareItem.tag = x;
            UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(shareItem.frame.origin.x-5, shareItem.frame.origin.y+shareItem.frame.size.height+5, shareItem.frame.size.width+10, 14)];
            itemLabel.textAlignment = NSTextAlignmentCenter;
            itemLabel.text = [shareDic objectForKey:@"title"];
            itemLabel.font = [UIFont systemFontOfSize:12];
            [_menuView addSubview:shareItem];
            [_menuView addSubview:itemLabel];

        }
        
        
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(27,
                                        _menuView.frame.size.height-84,
                                        _menuView.frame.size.width-54,
                                        40);
        [cancelButton setTitle:@"取  消" forState:UIControlStateNormal];
        cancelButton.layer.borderWidth = 1;
        cancelButton.layer.masksToBounds = YES;
        cancelButton.layer.cornerRadius = 3;
        cancelButton.layer.borderColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0].CGColor;
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [cancelButton setTitleColor:[UIColor darkGrayColor]
                           forState:UIControlStateNormal];
        [cancelButton setBackgroundColor:[UIColor clearColor]];
        [cancelButton addTarget:self
                         action:@selector(hideShareMenuView)
               forControlEvents:UIControlEventTouchUpInside];
        [_menuView addSubview:cancelButton];
        cancelButton.userInteractionEnabled = NO;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(hideShareMenuView)];
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

#pragma mark - didShareItemTouch

- (void)didShareItemTouch:(UIButton*)sender
{
    if (sender.tag == 0)
    {
        [self hideShareMenuView];
        [self shareAppToWeixinfriends];

        
    }
    else if (sender.tag == 1)
    {
        [self hideShareMenuView];
        [self shareAppToWeixin];

        
    }
    else if (sender.tag == 2)
    {
        [self hideShareMenuView];
        [self shareAppToQQ];

    }
    else
    {
        [self hideShareMenuView];
        [self shareAppToSina];

    }

}

#pragma mark - AppShare

+ (void)showShareMenuViewAtTarget:(UIViewController *)controller withContent:(NSString *)contentString withImage:(UIImage *)shareImage withUrl:(NSString *)urlString
{
    [[ShareMenuView sharedShareMenuView] showShareMenuViewAtTarget:controller
                                                       withContent:contentString
                                                         withImage:shareImage
                                                           withUrl:urlString];
}

- (void)showShareMenuViewAtTarget:(UIViewController *)controller withContent:(NSString *)contentString withImage:(UIImage *)shareImage withUrl:(NSString *)urlString
{
    self.target = controller;
    _shareImage = shareImage;
    _contentString = contentString;
    _urlString = urlString;
    [self showShareMenuView];
}


+ (void)showShareMenuViewWithTarget:(UIViewController*)controller
{
    [[ShareMenuView sharedShareMenuView] showShareMenuViewWithTarget:controller];
}

- (void)showShareMenuViewWithTarget:(UIViewController*)controller
{
    self.target = controller;
    [self showShareMenuView];
}


- (void)showShareMenuView
{
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                           [window addSubview:self];
                           [self exChangeOutdur:0.3];
                       });

}


- (void)hideShareMenuView
{
    [UIView animateWithDuration:0.3
                     animations:^{
        _menuView.transform = CGAffineTransformIdentity;
    }
                     completion:^(BOOL finished)
     {
        if (finished)
        {
            [self removeFromSuperview];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"shareAppHide"
                                                                object:nil];
        }
    }];

    
}


-(void)exChangeOutdur:(CFTimeInterval)dur
{
    if (self.target != nil)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shareAppShow"
                                                            object:nil];
        _menuView.hidden = NO;
        [UIView beginAnimations:@"showMenuView" context:nil];
        [UIView setAnimationDuration:dur];
        _menuView.transform = CGAffineTransformMakeTranslation(0, -_menuView.frame.size.height);
        
        [UIView commitAnimations];
    }

    return;
}

-(void)exChangeIndur:(CFTimeInterval)dur
{
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = dur;
    animation.delegate = self;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.7, 0.7, 0.7)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 0.5)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 0.1)]];
    animation.values = values;
    animation.timingFunction = [CAMediaTimingFunction functionWithName: @"easeInEaseOut"];
    [_menuView.layer addAnimation:animation forKey:nil];
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag)
    {
        self.hidden = YES;
    }
}

- (void)shareAppToSina
{
    id<ISSContent> publishContent = [ShareSDK content:[NSString stringWithFormat:@"%@",_contentString]
                                       defaultContent:_contentString
                                                image:[ShareSDK pngImageWithImage:_shareImage]
                                                title:@"疯狂车场"
                                                  url:_urlString
                                          description:@"疯狂车场"
                                            mediaType:SSPublishContentMediaTypeNews];
    [publishContent addSinaWeiboUnitWithContent:[NSString stringWithFormat:@"%@~%@",_contentString,_urlString]
                                          image:[ShareSDK pngImageWithImage:_shareImage]];
    [ShareSDK shareContent:publishContent
                      type:ShareTypeSinaWeibo
               authOptions:nil
             statusBarTips:YES
                    result:^(ShareType type,
                             SSResponseState state,
                             id<ISSPlatformShareInfo> statusInfo,
                             id<ICMErrorInfo> error,
                             BOOL end)
     {
         if (state == SSResponseStateFail)
         {
             NSLog(@"%@",error);
         }
     }];

    
}

- (void)shareAppToWeixin
{
    
    id<ISSContent> publishContent = [ShareSDK content:[NSString stringWithFormat:@"%@",_contentString]
                                       defaultContent:_contentString
                                                image:[ShareSDK pngImageWithImage:_shareImage]
                                                title:@"疯狂车场"
                                                  url:_urlString
                                          description:@"疯狂车场"
                                            mediaType:SSPublishContentMediaTypeNews];
    [publishContent addWeixinSessionUnitWithType:[NSNumber numberWithInt:2]
                                         content:[NSString stringWithFormat:@"%@",_contentString]
                                           title:@"疯狂车场"
                                             url:_urlString
                                      thumbImage:[ShareSDK pngImageWithImage:_shareImage]
                                           image:[ShareSDK pngImageWithImage:_shareImage]
                                    musicFileUrl:nil
                                         extInfo:nil
                                        fileData:nil
                                    emoticonData:nil];
    [ShareSDK shareContent:publishContent
                      type:ShareTypeWeixiSession
               authOptions:nil
             statusBarTips:YES
                    result:^(ShareType type,
                             SSResponseState state,
                             id<ISSPlatformShareInfo> statusInfo,
                             id<ICMErrorInfo> error,
                             BOOL end)
     {
         if (state == SSResponseStateFail)
         {
             NSLog(@"%@",[error errorDescription]);
         }
     }];

}

- (void)shareAppToWeixinfriends
{
    id<ISSContent> publishContent = [ShareSDK content:[NSString stringWithFormat:@"%@",_contentString]
                                       defaultContent:_contentString
                                                image:[ShareSDK pngImageWithImage:_shareImage]
                                                title:@"疯狂车场"
                                                  url:_urlString
                                          description:@"疯狂车场"
                                            mediaType:SSPublishContentMediaTypeNews];
    [publishContent addWeixinSessionUnitWithType:[NSNumber numberWithInt:2]
                                         content:[NSString stringWithFormat:@"%@",_contentString]
                                           title:@"疯狂洗车车场版"
                                             url:_urlString
                                      thumbImage:[ShareSDK pngImageWithImage:_shareImage]
                                           image:[ShareSDK pngImageWithImage:_shareImage]
                                    musicFileUrl:nil
                                         extInfo:nil
                                        fileData:nil
                                    emoticonData:nil];
    [ShareSDK shareContent:publishContent
                      type:ShareTypeWeixiTimeline
               authOptions:nil
             statusBarTips:YES
                    result:^(ShareType type,
                             SSResponseState state,
                             id<ISSPlatformShareInfo> statusInfo,
                             id<ICMErrorInfo> error,
                             BOOL end)
     {
         if (state == SSResponseStateFail)
         {
             NSLog(@"%@",error);
         }
     }];
}

- (void)shareAppToQQ
{
    id<ISSContent> publishContent = [ShareSDK content:[NSString stringWithFormat:@"%@",_contentString]
                                       defaultContent:_contentString
                                                image:[ShareSDK pngImageWithImage:_shareImage]
                                                title:@"疯狂车场"
                                                  url:_urlString
                                          description:@"疯狂车场"
                                            mediaType:SSPublishContentMediaTypeNews];
    [publishContent addQQUnitWithType:[NSNumber numberWithInt:2]
                              content:_contentString
                                title:@"疯狂车场"
                                  url:_urlString
                                image:[ShareSDK pngImageWithImage:_shareImage]];
    [ShareSDK shareContent:publishContent
                      type:ShareTypeQQ
               authOptions:nil
             statusBarTips:YES
                    result:^(ShareType type,
                             SSResponseState state,
                             id<ISSPlatformShareInfo> statusInfo,
                             id<ICMErrorInfo> error,
                             BOOL end)
     {
         
     }];
}


+ (void)hideAllShareMenuView
{
    [[ShareMenuView sharedShareMenuView] hideAllShareMenuView];
}

- (void)hideAllShareMenuView
{
    self.target = nil;
}


#pragma mark - Other Method

- (NSArray*)getShareItemList
{
    NSArray *imageList = @[@"btn_share_timeseccion",@"btn_share_weChat",@"btn_share_QQ",@"btn_share_sina"];
    NSArray *titleList = @[@"微信朋友圈",@"微信好友",@"QQ好友",@"新浪微博"];
    NSMutableArray *shareItems = [NSMutableArray array];
    for (int x = 0; x<imageList.count; x++)
    {
        NSDictionary *itemDic = @{@"title":titleList[x],
                                  @"image":imageList[x]};
        [shareItems addObject:itemDic];
    }
    
    return shareItems;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
