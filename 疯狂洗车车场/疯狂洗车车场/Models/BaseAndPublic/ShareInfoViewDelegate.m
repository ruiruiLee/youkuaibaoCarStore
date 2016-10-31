//
//  ShareInfoViewDelegate.m
//  康吾康
//
//  Created by 龚杰洪 on 15/1/18.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "ShareInfoViewDelegate.h"


@implementation ShareInfoViewDelegate 

static ShareInfoViewDelegate *defaultDelegate;

+ (instancetype)defaultDelegate
{
    if (!defaultDelegate)
    {
        defaultDelegate = [[ShareInfoViewDelegate alloc] init];
    }
    return defaultDelegate;
}

#pragma mark - share views delegate

- (id<ISSContent>)view:(UIViewController *)viewController
    willPublishContent:(id<ISSContent>)content
{
    [viewController.view setBackgroundColor:[UIColor whiteColor]];
    [viewController.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_bg"]
                                                            forBarMetrics:UIBarMetricsDefault];
    if ([viewController isKindOfClass:NSClassFromString(@"SSModalAuthViewController")])
    {
        [viewController.navigationItem setRightBarButtonItem:nil];
    }
    return  content;
}


- (id<ISSContent>)view:(UIViewController *)viewController
    willPublishContent:(id<ISSContent>)content
             shareList:(NSArray *)shareList
{
    [viewController.view setBackgroundColor:[UIColor whiteColor]];
    [viewController.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_bg"]
                                                            forBarMetrics:UIBarMetricsDefault];
    if ([viewController isKindOfClass:NSClassFromString(@"SSModalAuthViewController")])
    {
        [viewController.navigationItem setRightBarButtonItem:nil];
    }
    return  content;
}


- (void)viewOnCancelPublish:(UIViewController *)viewController
{
    [viewController.view setBackgroundColor:[UIColor whiteColor]];
    [viewController.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_bg"]
                                                            forBarMetrics:UIBarMetricsDefault];
    if ([viewController isKindOfClass:NSClassFromString(@"SSModalAuthViewController")])
    {
        [viewController.navigationItem setRightBarButtonItem:nil];
    }
}

- (void)viewOnWillDisplay:(UIViewController *)viewController
                shareType:(ShareType)shareType
{
    [viewController.view setBackgroundColor:[UIColor whiteColor]];
    [viewController.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_bg"]
                                                            forBarMetrics:UIBarMetricsDefault];
    if ([viewController isKindOfClass:NSClassFromString(@"SSModalAuthViewController")])
    {
        [viewController.navigationItem setRightBarButtonItem:nil];
    }
}


- (void)viewOnWillDismiss:(UIViewController *)viewController
                shareType:(ShareType)shareType
{
    [viewController.view setBackgroundColor:[UIColor whiteColor]];
    [viewController.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_bg"]
                                                            forBarMetrics:UIBarMetricsDefault];
    if ([viewController isKindOfClass:NSClassFromString(@"SSModalAuthViewController")])
    {
        [viewController.navigationItem setRightBarButtonItem:nil];
    }
}


- (void)view:(UIViewController *)viewController
autorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
   shareType:(ShareType)shareType
{
    [viewController.view setBackgroundColor:[UIColor whiteColor]];
    [viewController.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_bg"]
                                                            forBarMetrics:UIBarMetricsDefault];
    if ([viewController isKindOfClass:NSClassFromString(@"SSModalAuthViewController")])
    {
        [viewController.navigationItem setRightBarButtonItem:nil];
    }
}

@end
