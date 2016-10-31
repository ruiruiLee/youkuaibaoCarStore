//
//  AppDelegate.h
//  美车帮车场
//
//  Created by 龚杰洪 on 15/1/31.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    BOOL _isFirstTime;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIWindow *loginWindow;

- (void)resetSuperPasswordStatus;



@end

