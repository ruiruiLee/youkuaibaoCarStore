//
//  BaseViewController.m
//  康吾康
//
//  Created by 龚杰洪 on 14/12/29.
//  Copyright (c) 2014年 龚杰洪. All rights reserved.
//

#import "BaseViewController.h"
#import "RESideMenu.h"
#import "RDVTabBarController.h"
#import "MTA.h"
#include <objc/runtime.h>


@interface BaseViewController () <UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSArray *viewControllerNameArray;


@end

@implementation BaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_bg"]
                                                  forBarMetrics:0];
    
    self.viewControllerNameArray = [self getAllViewControllersName];

    if ([self.navigationController.viewControllers count] > 1)
    {
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [backBtn setImage:[UIImage imageNamed:@"back_btn"]
                 forState:UIControlStateNormal];
        [backBtn setFrame:CGRectMake(0, 7, 50, 30)];
        [backBtn addTarget:self
                    action:@selector(backBtnPre:)
          forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        [self.navigationItem setLeftBarButtonItem:backItem];
    }
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [titleLabel setFont:[UIFont systemFontOfSize:20]];
    [titleLabel setTextColor:[UIColor colorWithRed:37/255.0 green:37/255.0 blue:37/255.0 alpha:1.0]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    self.navigationItem.titleView = titleLabel;
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    // Do any additional setup after loading the view.
}

- (void)backBtnPre:(id)sender
{
    if ([[[self navigationController] viewControllers] count] > 1)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self presentLeftMenuViewController:nil];
    }
}

- (void)setTitle:(NSString *)title
{
    UILabel *titleLabel = (UILabel *)[self.navigationItem titleView];
    [titleLabel setText:title];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel sizeToFit]; // ???
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.navigationController.viewControllers count] == 1)
    {
        NSLog(@"%@",NSStringFromCGRect(self.rdv_tabBarController.tabBar.frame));
        [self.rdv_tabBarController.tabBar removeFromSuperview];
        [self.rdv_tabBarController.tabBar setFrame:CGRectMake(0, self.view.bounds.size.height - 49, SCREEN_WIDTH, 49)];
        [self.view addSubview:self.rdv_tabBarController.tabBar];
    }
}


- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([[[UIDevice currentDevice] systemVersion]floatValue] >= 6.0)
    {
        NSArray *arrayChildClass = [self findAllOf: [self  class]];
        [self startThisClass:[NSString stringWithCString:object_getClassName([arrayChildClass lastObject])
                                                encoding:NSUTF8StringEncoding]];
    }
    
    if ([self.navigationController.viewControllers count] > 1)
    {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    else
    {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 6.0)
    {
        NSArray *arrayChildClass = [self findAllOf: [self  class]];
        [self endThisClass:[NSString stringWithCString:object_getClassName([arrayChildClass lastObject])
                                              encoding:NSUTF8StringEncoding]];
    }
}


#pragma mark - MTA

- (void)startThisClass:(NSString*)className
{
    for (NSDictionary *childClass in self.viewControllerNameArray)
    {
        if ([[childClass objectForKey:@"Class"] isEqualToString:className])
        {
            NSLog(@"开始%@",[childClass objectForKey:@"describe"]);
            [MTA trackPageViewBegin:[childClass objectForKey:@"describe"]];
        }
    }
}

- (void)endThisClass:(NSString*)className
{
    for (NSDictionary *childClass in self.viewControllerNameArray)
    {
        if ([[childClass objectForKey:@"Class"] isEqualToString:className])
        {
            NSLog(@"结束%@",[childClass objectForKey:@"describe"]);
            [MTA trackPageViewEnd:[childClass objectForKey:@"describe"]];
        }
    }
}

- (NSArray *)findAllOf:(Class)defaultClass

{
    int count = objc_getClassList(NULL, 0);
    if (count <= 0)
    {
        return [NSArray arrayWithObject:defaultClass];
    }
    
    NSMutableArray *output = [NSMutableArray arrayWithObject:defaultClass];
    Class *classes = (Class *) malloc(sizeof(Class) * count);
    objc_getClassList(classes, count);
    for (int i = 0; i < count; ++i)
    {
        if (defaultClass == class_getSuperclass(classes[i]))//子类
        {
            [output addObject:classes[i]];
        }
    }
    
    free(classes);
    
    return [NSArray arrayWithArray:output];
}


- (NSArray*)getAllViewControllersName
{
    NSArray *names = @[@{@"describe":@"登陆",@"Class":@"LoginController"},
                       @{@"describe":@"订单",@"Class":@"OrderController"},
                       @{@"describe":@"设置",@"Class":@"SettingController"},
                       @{@"describe":@"车场统计",@"Class":@"OperatingConditionsController"},
                       @{@"describe":@"车场管理",@"Class":@"ToolsController"},
                       @{@"describe":@"充值密码",@"Class":@"ResetPwdController"},
                       @{@"describe":@"修改密码",@"Class":@"EditPwdController"},
                       @{@"describe":@"分享好友",@"Class":@"ShareFrendController"},
                       @{@"describe":@"意见反馈",@"Class":@"FeedBackController"}];
    
    return names;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
