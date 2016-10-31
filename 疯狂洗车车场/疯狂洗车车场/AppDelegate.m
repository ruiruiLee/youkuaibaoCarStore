//
//  AppDelegate.m
//  美车帮车场
//
//  Created by 龚杰洪 on 15/1/31.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "AppDelegate.h"
#import "RDVTabBarController.h"
#import "WXApi.h"
#import <ShareSDK/ShareSDK.h>
#import <QZoneConnection/ISSQZoneApp.h>
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WebServiceHelper.h"
#import "MTA.h"
#import "KGStatusBar.h"
#import "OrderController.h"
#import "CustomLaunchView.h"


@interface AppDelegate ()<RDVTabBarControllerDelegate, UIAlertViewDelegate, CustomLaunchViewDelegate>
{
    SSInterfaceOrientationMask _interfaceOrientationMask;
    
    CustomLaunchView  *_customLaunchImageView;
    
    NSInteger _targetIndex;
    
    NSString *_httpsDownloadUrlString;
    
    int       _shouldFourceUpdate;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    application.applicationIconBadgeNumber = 0;

    
    _isFirstTime = YES;
    
    [UIApplication sharedApplication].idleTimerDisabled=YES;

    [self registNotification:application];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:kUserInfoKey] && [[NSUserDefaults standardUserDefaults] valueForKey:kAutoLogin])
    {
        [self updateUserInfo];
    }
    
//    if ([[NSUserDefaults standardUserDefaults]  valueForKey:@"isFirstTime"])
//    {
//        _isFirstTime = NO;
//    }

    [[UIDevice currentDevice].identifierForVendor UUIDString];
    
    [self installNotifications];
    
    //1.初始化ShareSDK应用,字符串"4a88b2fb067c"换成你申请的ShareSDK应用的Appkey
    [ShareSDK registerApp:kShareSDKAppKey];
    
    //2. 初始化社交平台
    //2.1 代码初始化社交平台的方法
    [self initializePlat];
    
    [self updateProjectSplashImage];
    
    [MTA startWithAppkey:@"ITU1GYE4R98Q"];
    _interfaceOrientationMask = SSInterfaceOrientationMaskPortrait;
    
    
    //开启QQ空间网页授权开关
    id<ISSQZoneApp> app =(id<ISSQZoneApp>)[ShareSDK getClientWithType:ShareTypeQQSpace];
    [app setIsAllowWebAuthorize:YES];
    
    [WXApi registerApp:kWeixinAppKey];
    
    [self loginIfNeed];
    
    [self checkHttpsServiceAvilabel];

     // Override point for customization after application launch.
    return YES;
}

- (void)checkHttpsServiceAvilabel
{
    NSDictionary *tmpDic=[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]];
    NSString *versonNumber = [NSString stringWithFormat:@"%d",(int)([[tmpDic valueForKey:@"CFBundleShortVersionString"]floatValue]*10)];
    NSDictionary *submitDic = @{@"app_type":@"2",
                                @"code":versonNumber};
    [WebService requestJsonOperationWithParam:submitDic
                                       action:@"system/service/checkBUpdate"
                               normalResponse:^(NSString *status, id data)
    {
        if ([[data objectForKey:@"status"] intValue] > 0)
        {
            _shouldFourceUpdate = [[data objectForKey:@"if_forced_update"]intValue];

            
            [Constants showMessage:[data objectForKey:@"update_content"]
                          delegate:self
                               tag:200
                      buttonTitles:@"取消",@"好的", nil];
            _httpsDownloadUrlString = [data objectForKey:@"cur_ver_url"];
        }
    }
                            exceptionResponse:^(NSError *error) {
        
    }];
}

- (void)installNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:)
                                                 name:kLoginSuccessNotifaction
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutSuccess:)
                                                 name:kLogoutSuccessNotifaction
                                               object:nil];
    
}

- (void)initializePlat
{
    /**
     连接新浪微博开放平台应用以使用相关功能，此应用需要引用SinaWeiboConnection.framework
     http://open.weibo.com上注册新浪微博开放平台应用，并将相关信息填写到以下字段
     **/
    [ShareSDK connectSinaWeiboWithAppKey:kWeiboAppKey
                               appSecret:kWeiboAppSecret
                             redirectUri:@"http://"];
    
    
    
    /**
     连接微信应用以使用相关功能，此应用需要引用WeChatConnection.framework和微信官方SDK
     http://open.weixin.qq.com上注册应用，并将相关信息填写以下字段
     **/
    //    [ShareSDK connectWeChatWithAppId:@"wx4868b35061f87885" wechatCls:[WXApi class]];
    [ShareSDK connectWeChatWithAppId:kWeixinAppKey
                           appSecret:kWeixinAppSecret
                           wechatCls:[WXApi class]];
    
    /**
     连接QQ应用以使用相关功能，此应用需要引用QQConnection.framework和QQApi.framework库
     http://mobile.qq.com/api/上注册应用，并将相关信息填写到以下字段
     **/
    //旧版中申请的AppId（如：QQxxxxxx类型），可以通过下面方法进行初始化
    //    [ShareSDK connectQQWithAppId:@"QQ075BCD15" qqApiCls:[QQApi class]];
    
    [ShareSDK connectQQWithQZoneAppKey:kQQAppKey
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];
}


- (void)logoutSuccess:(NSNotification *)notification
{
    _isFirstTime = YES;
    [self.window resignKeyWindow];
    self.window = nil;
    [self loginIfNeed];
}

- (void)loginSuccess:(NSNotification *)notification
{
    _isFirstTime = YES;
    [self loginIfNeed];
}

- (void)loginIfNeed
{
    if (![[NSUserDefaults standardUserDefaults] valueForKey:kUserInfoKey])
    {
        self.loginWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [self.loginWindow setBackgroundColor:[UIColor whiteColor]];
        
        id controller = ALLOC_WITH_CLASSNAME(@"LoginController");
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:controller];
        [navi setNavigationBarHidden:YES];
        [self.loginWindow setRootViewController:navi];
        [self.loginWindow makeKeyAndVisible];
    }
    else
    {
        if (!self.window)
        {
            self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            [self.window setBackgroundColor:[UIColor whiteColor]];
            [self.window makeKeyAndVisible];
        }
        RDVTabBarController *tabBarController = [[RDVTabBarController alloc]init];
        
        UIViewController *homePage = ALLOC_WITH_CLASSNAME(@"OrderController");
        UINavigationController *homeNavi = [[UINavigationController alloc] initWithRootViewController:homePage];
        
        UIViewController *message = ALLOC_WITH_CLASSNAME(@"OperatingConditionsController");
        UINavigationController *messageNavi = [[UINavigationController alloc] initWithRootViewController:message];
        
        UIViewController *community = ALLOC_WITH_CLASSNAME(@"ToolsController");
        UINavigationController *communityNavi = [[UINavigationController alloc] initWithRootViewController:community];
        
        UIViewController *erpTool = ALLOC_WITH_CLASSNAME(@"SettingController");
        UINavigationController *erpToolNavi = [[UINavigationController alloc] initWithRootViewController:erpTool];
        
        [tabBarController setViewControllers:@[homeNavi,
                                               messageNavi,
                                               communityNavi,
                                               erpToolNavi]];

        [tabBarController setDelegate:self];
        [self.window setRootViewController:tabBarController];
        [self.window makeKeyAndVisible];
        
        [self customizeTabBarForController:tabBarController];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kCustomLaunch])
        {
            _customLaunchImageView = [[NSBundle mainBundle] loadNibNamed:@"CustomLaunchView"
                                                                   owner:self
                                                                 options:nil][0];
            _customLaunchImageView.frame = [UIScreen mainScreen].bounds;
            _customLaunchImageView.delegate = self;
            [self.window addSubview:_customLaunchImageView];
            [self.window bringSubviewToFront:_customLaunchImageView];
            [_customLaunchImageView startCustomLaunchRefrishTimer];
        }
        
        [self performSelector:@selector(resignLoginWindow) withObject:nil afterDelay:2.0];
    }

}

- (void)didShouldHideCustomLaunchView
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [_customLaunchImageView hideMainAdvView];
}

- (void)updateUserInfo
{
    NSDictionary *tmpDic=[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]];
    NSDictionary *autoLogin = [[NSUserDefaults standardUserDefaults] objectForKey:kAutoLogin];
    if (!autoLogin ||![autoLogin objectForKey:@"login_name"]||![autoLogin objectForKey:@"login_password"])
    {
        [Constants showMessage:@"登录信息失效，请重新登录"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAutoLogin];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserInfoKey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLoginToken];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self logoutSuccess:nil];
        return;
    }
    NSDictionary *submitDic = @{@"login_name":[autoLogin objectForKey:@"login_name"],
                                @"login_password":[autoLogin objectForKey:@"login_password"],
                                @"app_type":@"2",
                                @"user_type":@"2",
                                @"app_version":[NSString stringWithFormat:@"%.2f",[[tmpDic valueForKey:@"CFBundleShortVersionString"] floatValue]],
                                @"client_id":_notificationDeviceToken == nil?@"":_notificationDeviceToken};
    [WebService requestJsonModelWithParam:submitDic
                                   action:@"member/service/login"
                               modelClass:[UserInfo class]
                           normalResponse:^(NSString *status, id data, JsonBaseModel *model)
     {
         if (status.intValue > 0)
         {
             _userInfo = (UserInfo*)model;
             [[NSUserDefaults standardUserDefaults] setObject:[_userInfo convertToDictionary]
                                                       forKey:kUserInfoKey];
             [[NSUserDefaults standardUserDefaults] setObject:_userInfo.token
                                                       forKey:kLoginToken];
             [[NSUserDefaults standardUserDefaults] synchronize];
         }
         else
         {
             [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAutoLogin];
             [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserInfoKey];
             [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLoginToken];
             [[NSUserDefaults standardUserDefaults] synchronize];
             [self logoutSuccess:nil];
         }
     }
                        exceptionResponse:^(NSError *error) {
                            
                            [Constants showMessage:[error domain]];
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAutoLogin];
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserInfoKey];
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLoginToken];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            [self logoutSuccess:nil];
                        }];
}

- (void)customizeTabBarForController:(RDVTabBarController *)tabBarController
{
    NSArray *tabBarItemImages = @[@"tab_order", @"tab_operate", @"tab_tool", @"tab_setting"];
    NSArray *tabBarItemTitle = @[@"订单", @"经营状况", @"功能", @"设置"];
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[tabBarController tabBar] items])
    {
        [item setTitle:tabBarItemTitle[index]];
        
        [item setSelectedTitleAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12],
                                           NSForegroundColorAttributeName: [UIColor whiteColor]}];
        [item setUnselectedTitleAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12],
                                            NSForegroundColorAttributeName: [UIColor colorWithRed:222/255.0
                                                                                            green:47/255.0
                                                                                             blue:6/255.0
                                                                                            alpha:1.0]}];
        [item setBackgroundSelectedImage:[UIImage imageNamed:@"tab_selected_bg"]
                     withUnselectedImage:nil];
        [item setBadgeTextColor:[UIColor orangeColor]];
        
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@",
                                                      [tabBarItemImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_s",
                                                        [tabBarItemImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedimage
           withFinishedUnselectedImage:unselectedimage];
        
        index++;
    }
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    lineLabel.backgroundColor  = [UIColor colorWithRed:178.0/255.0
                                                 green:178.0/255.0
                                                  blue:178.0/255.0
                                                 alpha:0.5];
    [[tabBarController tabBar] addSubview:lineLabel];
    [[tabBarController tabBar] setBackgroundColor:[UIColor colorWithRed:250.0/255.0
                                                                  green:250.0/255.0
                                                                   blue:250.0/255.0
                                                                  alpha:1.0]];
}

#pragma mark - push notification

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"DeviceToken: {%@}",deviceToken);
    NSString *deviceTokenString = [NSString stringWithFormat:@"%@",deviceToken];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@"<" withString:@""];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@">" withString:@""];
    [[NSUserDefaults standardUserDefaults] setObject:deviceTokenString
                                              forKey:kDeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _notificationDeviceToken = deviceTokenString;
    if ([[NSUserDefaults standardUserDefaults] valueForKey:kUserInfoKey] && [[NSUserDefaults standardUserDefaults] valueForKey:kAutoLogin])
    {
        [self updateUserInfo];
       // [Constants showMessage:[NSString stringWithFormat:@"注册推送成功 ，deviceToken is :%@",deviceToken]];
    }

    //这里进行的操作，是将Device Token发送到服务端
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    application.applicationIconBadgeNumber = 0;
    NSLog(@"\n\ndidReceiveRemoteNotification：%@",userInfo);
    
    [self showStatusMessageAlertWithTitle:@"您收到一条新消息"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShouldUpdateList
                                                        object:nil];
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Register Remote Notifications error:{%@}", [error localizedDescription]);
    _notificationDeviceToken = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //    [Utility showMessage:[error localizedDescription]];
}

- (void)showStatusMessageAlertWithTitle:(NSString *)titleString
{
    [KGStatusBar showWithStatus:titleString];
    [self performSelector:@selector(hideStatusMessageAlert)
               withObject:nil
               afterDelay:5.0];
    
    return;
}

- (void)hideStatusMessageAlert
{
    [KGStatusBar dismiss];
    return;
    
}


- (void)updateProjectSplashImage
{
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserInfoKey])
    {
        _startInfo = [[StartInfoModel alloc] initWithCacheKey:kStartInfoKey];
    }
    
    NSString *pixelsString = nil;
    
    if (SCREEN_WIDTH < 375)
    {
        if (SCREEN_HEIGHT < 568)
        {
            pixelsString = @"640*960";
        }
        else
        {
            pixelsString = @"640*1136";
        }
    }
    else if (SCREEN_WIDTH > 375)
    {
        pixelsString = @"1242*2208";
    }
    else
    {
        pixelsString = @"750*1334";
    }
    
    NSDictionary *submitdDic = @{@"app_type":@"2",
                                 @"pixels":pixelsString,
                                 @"user_type":@"2"};
    [WebService requestJsonModelWithParam:submitdDic
                                   action:@"system/service/startinfo"
                               modelClass:[StartInfoModel class]
                           normalResponse:^(NSString *status, id data, JsonBaseModel *model)
     {
         _startInfo = (StartInfoModel*)model;
         [[NSUserDefaults standardUserDefaults] setObject:[_startInfo convertToDictionary]
                                                   forKey:kStartInfoKey];
         [[NSUserDefaults standardUserDefaults] synchronize];
         if (![_startInfo.app_splash_img isEqualToString:@""] && _startInfo.app_splash_img != nil)
         {
             [WebService downloadImageFromServiceWithUrl:_startInfo.app_splash_img
                                                 forName:kCustomLaunch
                                            andMediaType:@""];
             
         }
         
     }
                        exceptionResponse:^(NSError *error) {
                            
                        }];
}




- (void)resignLoginWindow
{
    [self.loginWindow resignKeyWindow];
    self.loginWindow = nil;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)tabBarController:(RDVTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if (_isFirstTime)
    {
        BOOL shouldShow = NO;
        for (int x = 0; x<tabBarController.viewControllers.count; x++)
        {
            id controller = tabBarController.viewControllers[x];
            if (controller == viewController)
            {
                if (x != 0)
                {
                    shouldShow = YES;
                    _targetIndex = x;
                    break;
                }
                else
                {
                    
                }

            }
        }
        if (shouldShow)
        {
            [self inputPassword];
            return NO;
        }
        else
        {
            return YES;
        }

    }
    return YES;
}

- (void)inputPassword
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入高级密码"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    alert.tag            = 1024;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100 && buttonIndex != alertView.cancelButtonIndex) // 密码错误的alertview
    {
        [self inputPassword];
    }
    if (alertView.tag == 200) // 密码错误的alertview
    {
        if (buttonIndex == 0)
        {
            if (_shouldFourceUpdate > 0)
            {
                exit(0);
            }
        }
        else
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_httpsDownloadUrlString]];
        }
    }
    
    else if (alertView.tag == 1024) // 输入密码的alertview
    {
        // 点击取消 直接返回
        if (buttonIndex == 0)
        {
            return;
        }
        
        UITextField *field = [alertView textFieldAtIndex:0];
        [field resignFirstResponder];
        UserInfo *userinfo = [[UserInfo alloc] initWithCacheKey:kUserInfoKey];
        
        NSDictionary *submitdDic = @{@"admin_id":userinfo.admin_id,
                                     @"super_password":field.text};
        self.window.userInteractionEnabled = NO;
        [WebService requestJsonOperationWithParam:submitdDic
                                           action:@"member/service/superpassword"
                                   normalResponse:^(NSString *status, id data)
        {
            self.window.userInteractionEnabled = YES;
            if (status.intValue > 0)
            {
                _isFirstTime = NO;

                [[NSUserDefaults standardUserDefaults] setBool:_isFirstTime forKey:@"isFirstTime"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                message:@"验证成功"
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"确定", nil];
                [alert show];
                
                if (_targetIndex != 0)
                {
                    RDVTabBarController *tabBarController = (RDVTabBarController*)self.window.rootViewController;
                    
                    [tabBarController setSelectedIndex:_targetIndex];
                }


            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                message:@"您输入的高级密码不正确，请重新输入！"
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"重新输入", nil];
                alert.tag = 100;
                [alert show];
            }


        }
                                exceptionResponse:^(NSError *error)
        {
            self.window.userInteractionEnabled = YES;
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                                    message:@"您输入的高级密码不正确，请重新输入！"
                                                                                   delegate:self
                                                                          cancelButtonTitle:@"取消"
                                                                          otherButtonTitles:@"重新输入", nil];
                                    alert.tag = 100;
                                    [alert show];
        }];
    }
    
    // 其他alertview都不处理
}

- (void)resetSuperPasswordStatus
{
    _isFirstTime = YES;
    
    [[NSUserDefaults standardUserDefaults] setBool:_isFirstTime forKey:@"isFirstTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _targetIndex = 0;
    RDVTabBarController *tabBarController = (RDVTabBarController*)self.window.rootViewController;
    
    [tabBarController setSelectedIndex:_targetIndex];

}

- (void)registNotification:(UIApplication *)application
{
    UIRemoteNotificationType types = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
    UIUserNotificationType typesForiOS8 = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)])
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:typesForiOS8
                                                                                        categories:nil]];
        [application registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:types];
    }
}

#pragma mark - 检查更新



@end
