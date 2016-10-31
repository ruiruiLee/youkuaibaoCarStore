//
//  OperatingConditionsController.m
//  美车帮车场
//
//  Created by 龚杰洪 on 15/1/31.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "OperatingConditionsController.h"
#import "WebServiceHelper.h"
#import "MBProgressHUD+Add.h"
#import "UIView+Toast.h"
#import "GetCashViewController.h"
#import "OpreationElementGroupModel.h"
#import "OpreationTopCell.h"
#import "OpreationHeaderView.h"
#import "OpreationConditionsListCell.h"
#import "BankCardModel.h"
#import "BankCardBiddingViewController.h"
#import "GetCashRecordViewController.h"
#import "MJRefresh.h"


@interface OperatingConditionsController ()<UITableViewDataSource,UITableViewDelegate,OpreationTopCellDelegate,UIAlertViewDelegate>
{
    UIButton                    *_rightButton;
    
    IBOutlet UITableView        *_contextTableView;
    
    NSMutableArray              *_dataArray;
}

@property (strong, nonatomic) StatisticsModel *targetModel;

@end

@implementation OperatingConditionsController

static NSString *OpreationTopCellIdentifier = @"OpreationTopCell";

static NSString *OpreationConditionsListCellIdentifier = @"OpreationConditionsListCell";



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"经营状况"];
    
    _dataArray = [NSMutableArray array];
    
    _rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 36)];
    [_rightButton setTitle:@"提现明细" forState:UIControlStateNormal];
    _rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_rightButton setTitleColor:[UIColor colorWithRed:235.0/255.0
                                                green:  84.0/255.0
                                                 blue:   1.0/255.0
                                                alpha:1.0] forState:UIControlStateNormal];
    _rightButton.exclusiveTouch = YES;
    
    [_rightButton addTarget:self action:@selector(didRightButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:_rightButton];
    [self.navigationItem setRightBarButtonItem:rightItem];
    
    [_contextTableView registerNib:[UINib nibWithNibName:OpreationTopCellIdentifier
                                                  bundle:[NSBundle mainBundle]]
            forCellReuseIdentifier:OpreationTopCellIdentifier];
    
    [_contextTableView registerNib:[UINib nibWithNibName:OpreationConditionsListCellIdentifier
                                                  bundle:[NSBundle mainBundle]]
            forCellReuseIdentifier:OpreationConditionsListCellIdentifier];
    
    [_contextTableView addHeaderWithTarget:self
                                    action:@selector(obtainInfo)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(obtainInfo)
                                                 name:kShouldUpdateList
                                               object:nil];
    [self obtainInfo];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)obtainInfo
{
    /*
     11.统计
     地址：http://118.123.249.87/service/car_wash_statistics.aspx
     参数:
     admin_id：车场管理员id号
     
     */
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    [WebService requestJsonModelWithParam:@{@"car_wash_id":_userInfo.car_wash_id}
                                   action:@"report/service/stationService"
                               modelClass:[StatisticsModel class]
                           normalResponse:^(NSString *status, id data, JsonBaseModel *model)
     {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         self.view.userInteractionEnabled = YES;
         [_contextTableView headerEndRefreshing];
         StatisticsModel *info = (StatisticsModel *)model;
         self.targetModel = info;
         [self refreshInfo:self.targetModel];
     }
                        exceptionResponse:^(NSError *error)
     {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         self.view.userInteractionEnabled = YES;
         [MBProgressHUD showError:[error domain] toView:self.view];
         [_contextTableView headerEndRefreshing];
         
     }];
}

- (void)refreshInfo:(StatisticsModel *)model
{
    if (_dataArray.count > 0)
    {
        [_dataArray removeAllObjects];
        [_contextTableView reloadData];
    }
    OpreationElementGroupModel *todayModel = [[OpreationElementGroupModel alloc] init];
    todayModel.elementGroupName = @"今日收益：";
    float todayTotalPrice = 0;
    for (int x = 0; x<model.today_count.count; x++)
    {
        OpreationElementModel *elementModel = model.today_count[x];
        todayTotalPrice += elementModel.all_sum.floatValue;

    }
    todayModel.elementGroupPrice = [NSString stringWithFormat:@"%.2f",todayTotalPrice];
    
    
    //本月
    OpreationElementGroupModel *monthModel = [[OpreationElementGroupModel alloc] init];
    monthModel.elementGroupName = @"本月收益：";
    float monthTotalPrice = 0;
    for (int x = 0; x<model.month_count.count; x++)
    {
        OpreationElementModel *elementModel = model.month_count[x];
        monthTotalPrice += elementModel.all_sum.floatValue;
        
    }
    monthModel.elementGroupPrice = [NSString stringWithFormat:@"%.2f",monthTotalPrice];

    
    
    OpreationElementGroupModel *totalModel = [[OpreationElementGroupModel alloc] init];
    totalModel.elementGroupName = @"总营业额：";
    float totalPrice = 0;
    for (int x = 0; x<model.total_count.count; x++)
    {
        OpreationElementModel *elementModel = model.total_count[x];
        totalPrice += elementModel.all_sum.floatValue;
        
    }
    totalModel.elementGroupPrice = [NSString stringWithFormat:@"%.2f",totalPrice];

    
    [_dataArray addObjectsFromArray:@[todayModel,monthModel,totalModel]];
    [_contextTableView reloadData];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.targetModel)
    {
        return 0;
    }
    else
    {
        return 4;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else
    {
        if (!self.targetModel)
        {
            return 0;
        }
        else if (section == 1)
        {
            return self.targetModel.today_count.count;
        }
        else if (section == 2)
        {
            return self.targetModel.month_count.count;
        }
        else
        {
            return self.targetModel.total_count.count;
        }
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0;
    }
    else
    return 80;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return nil;
    }
    else
    {
        OpreationHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"OpreationHeaderView"];
        if (view == nil)
        {
            view = [[NSBundle mainBundle] loadNibNamed:@"OpreationHeaderView"
                                                 owner:nil
                                               options:nil][0];
            
        }
        
        OpreationElementGroupModel *model = _dataArray[section-1];
        [view setDisplayInfoWithModel:model];
        return view;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0)
    {
        return 97;
    }
    else
    return 44;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        OpreationTopCell *cell = [tableView dequeueReusableCellWithIdentifier:OpreationTopCellIdentifier];
        
        if (cell == nil)
        {
            cell = [[OpreationTopCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:OpreationTopCellIdentifier];
        }
        
        if (self.targetModel)
        {
            [cell setDisplayInfo:self.targetModel];
        }
        
        cell.delegate = self;
        
        return cell;
    }
    else
    {
        OpreationConditionsListCell *cell = [tableView dequeueReusableCellWithIdentifier:OpreationConditionsListCellIdentifier];
        
        
        if (cell == nil)
        {
            cell = [[OpreationConditionsListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                      reuseIdentifier:OpreationConditionsListCellIdentifier];
        }
        
        OpreationElementModel *model = nil;
        if (indexPath.section == 1)
        {
            model = self.targetModel.today_count[indexPath.row];
        }
        else if (indexPath.section == 2)
        {
            model = self.targetModel.month_count[indexPath.row];
        }
        else
        {
            model = self.targetModel.total_count[indexPath.row];
        }

        [cell setDisplayInfo:model];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate
#pragma mark - OpreationTopCellDelegate
- (void)didTopOpreationButtonTouched
{
    if (self.targetModel == nil)
    {
        [Constants showMessage:@"数据错误"];
        return;
    }
    else if (self.targetModel.account_amount.floatValue == 0)
    {
        [Constants showMessage:@"您的可提现金额不足"];
        return;
    }
    else if (self.targetModel.account_amount.floatValue < 0)
    {
        [Constants showMessage:@"可提现金额异常\n请联系客服" delegate:self tag:404 buttonTitles:@"取消",@"联系客服", nil];
        return;
    }
    NSDictionary *submitDic = @{@"car_wash_id":_userInfo.car_wash_id};
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    [WebService requestJsonArrayOperationWithParam:submitDic
                                            action:@"account/service/bankList"
                                        modelClass:[BankCardModel class]
                                    normalResponse:^(NSString *status, id data, NSMutableArray *array)
    {
        [MBProgressHUD hideAllHUDsForView:self.view
                                 animated:YES];
        self.view.userInteractionEnabled = YES;
        if (status.intValue > 0)
        {
            if (array.count > 0)
            {
                GetCashViewController *viewController = [[GetCashViewController alloc] initWithNibName:@"GetCashViewController"
                                                                                                bundle:nil];
                viewController.targetModel = self.targetModel;
                viewController.bankCardArray = array;
                
                [self.navigationController pushViewController:viewController
                                                     animated:YES];
            }
            else
            {
                [Constants showMessage:@"您还没有绑定银行卡\n请联系客服" delegate:self tag:404 buttonTitles:@"取消",@"联系客服", nil];
            }
        }
        else
        {
            [Constants showMessage:@"获取账户信息失败"];
        }
    }
                                 exceptionResponse:^(NSError *error) {
                                     [MBProgressHUD hideAllHUDsForView:self.view
                                                              animated:YES];
                                     self.view.userInteractionEnabled = YES;
                                     [MBProgressHUD showError:[error domain]
                                                       toView:self.view];
                                 }];
}

- (void)didRightButtonTouch
{
    GetCashRecordViewController *viewController = [[GetCashRecordViewController alloc] initWithNibName:@"GetCashRecordViewController"
                                                                                                bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 404 && buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:4000803939"]];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShouldUpdateList object:nil];
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
