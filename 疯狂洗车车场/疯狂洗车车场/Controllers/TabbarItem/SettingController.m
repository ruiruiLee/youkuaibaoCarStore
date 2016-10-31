//
//  SettingController.m
//  美车帮车场
//
//  Created by 龚杰洪 on 15/1/31.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "SettingController.h"
#import "SettingCell.h"
#import "EditPwdController.h"
#import "WebServiceHelper.h"
#import "MBProgressHUD+Add.h"


@interface SettingController ()<UIActionSheetDelegate>
{
    NSArray *_titleArray;
    NSArray *_imagesArray;
    NSArray *_controllersArray;
}

@end

static NSString *SettingCellReuse = @"SettingCell";

@implementation SettingController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"设置"];
    
    _titleArray = @[@"修改登录密码",@"修改高级密码", @"意见反馈", @"退出登录"];
    _imagesArray = @[@"more_edit_pwd_icon",@"more_edit_spwd_icon", @"more_feedback", @"more_exit_icon"];
    _controllersArray = @[@"EditPwdController",@"EditPwdController", @"FeedBackController", @"ShareFrendController"];
    
    [_menuTable registerNib:[UINib nibWithNibName:@"SettingCell" bundle:[NSBundle mainBundle]]
     forCellReuseIdentifier:SettingCellReuse];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 3;
    }
    else
    {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingCellReuse];
    if (nil == cell)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:@"SettingCell"
                                             owner:nil
                                           options:nil][0];
    }
    
    if (indexPath.section == 0)
    {
        [cell.iconView setImage:[UIImage imageNamed:_imagesArray[indexPath.row]]];
        [cell.titleLabel setText:_titleArray[indexPath.row]];
    }
    else
    {
        [cell.iconView setImage:[UIImage imageNamed:_imagesArray[_imagesArray.count - 1]]];
        [cell.titleLabel setText:_titleArray[_titleArray.count - 1]];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0)
    {
        if (indexPath.row <= 1)
        {
            EditPwdController *viewController = [[EditPwdController alloc] initWithNibName:@"EditPwdController" bundle:nil];
            viewController.isFowSuper = indexPath.row == 0?NO:YES;
            [self.navigationController pushViewController:viewController animated:YES];
        }
        else
        {
            id controller = ALLOC_WITH_CLASSNAME(_controllersArray[indexPath.row]);
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
    else
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"退出后不会删除任何历史数据，下次登录仍然可以使用本账号。"
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"退出登录", nil];
        [actionSheet showInView:self.view];
    }

}

#pragma mark - actionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
        {
            self.view.userInteractionEnabled = NO;
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            NSDictionary *submitDic = @{@"member_id":_userInfo.admin_id,
                                        @"user_type":@"2"};
            
            [WebService requestJsonOperationWithParam:submitDic
                                               action:@"member/service/logout"
                                       normalResponse:^(NSString *status, id data)
             {
                 [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                 self.view.userInteractionEnabled = YES;
                 [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserInfoKey];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 [Constants showMessage:@"退出成功！"];
                 [[NSNotificationCenter  defaultCenter] postNotificationName:kLogoutSuccessNotifaction
                                                                      object:nil];
            }
                                    exceptionResponse:^(NSError *error)
            {
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                self.view.userInteractionEnabled = YES;
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserInfoKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [Constants showMessage:@"退出成功！"];
                [[NSNotificationCenter  defaultCenter] postNotificationName:kLogoutSuccessNotifaction
                                                                     object:nil];
                [WebService requestJsonOperationWithParam:submitDic
                                                   action:@"member/service/logout"
                                           normalResponse:^(NSString *status, id data)
                 {

                 }
                                        exceptionResponse:^(NSError *error)
                 {
                     
                 }];

                

            }];

        }
            break;
            
        default:
            break;
    }
}


@end
