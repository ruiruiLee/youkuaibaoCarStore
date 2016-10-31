//
//  OrderController.m
//  美车帮车场
//
//  Created by 龚杰洪 on 15/1/31.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "OrderController.h"
#import "MBProgressHUD+Add.h"
#import "WebServiceHelper.h"
#import "MJRefresh.h"
#import "UIView+Toast.h"
#import "OrderListCell.h"

@interface OrderController ()//<OrderListCellDelegate>
{
    NSMutableArray  *_dataArray;
    NSInteger        _pageIndex;
    NSInteger        _pageSize;
    BOOL             _canLoadMore;
    UISearchBar             *_searchBar;
    
    UISearchDisplayController   *_searchDisplayController;
    
    NSMutableArray              *_searchResultArray;
    
    NSString       *_keyWord;
}

@end

static NSString *OrderListCellReuse = @"OrderListCell";

@implementation OrderController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"订单"];
    
    
    
    _pageIndex = 1;
    _pageSize = 20;
    
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44.0)];
    [_searchBar setPlaceholder:@"请输入车主车牌"];
    _searchBar.returnKeyType = UIReturnKeyDone;
    [_searchBar setBackgroundImage:[UIImage imageNamed:@"searchbar_bg"]];
    [_searchBar setBackgroundImage:[UIImage imageNamed:@"searchbar_bg"]];
    [_searchBar setDelegate:self];
    
    _userInfo = [[UserInfo alloc] initWithCacheKey:kUserInfoKey];
    
    _listTable.tableHeaderView = _searchBar;
    
    _searchResultArray = [NSMutableArray array];

    _searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar
                                                                 contentsController:self];
    [_searchDisplayController setDelegate:self];
    [_searchDisplayController.searchResultsTableView setDelegate:self];
    [_searchDisplayController.searchResultsTableView setDataSource:self];
    [_searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:OrderListCellReuse
                                                                                bundle:[NSBundle mainBundle]]
                                          forCellReuseIdentifier:OrderListCellReuse];
    _searchDisplayController.searchResultsTableView.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1.0];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [_listTable registerNib:[UINib nibWithNibName:OrderListCellReuse
                                           bundle:[NSBundle mainBundle]]
     forCellReuseIdentifier:OrderListCellReuse];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shouldUpdateList)
                                                 name:kShouldUpdateList
                                               object:nil];
    [_listTable addHeaderWithTarget:self action:@selector(obtainOrderList)];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_dataArray.count == 0)
    {
        [_listTable headerBeginRefreshing];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)shouldUpdateList
{
    [_listTable headerBeginRefreshing];
}
#pragma mark - 获取数据

- (void)obtainOrderList
{

    _pageIndex = 1;
    _canLoadMore = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    [WebService requestJsonArrayOperationWithParam:@{@"car_wash_id": _userInfo.car_wash_id,
                                                     @"page_index": [NSNumber numberWithInteger:_pageIndex],
                                                     @"page_size": [NSNumber numberWithInteger:_pageSize]}
                                            action:@"order/service/list"
                                        modelClass:[OrderListModel class]
                                    normalResponse:^(NSString *status, id data, NSMutableArray *array)
     {
         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
         self.view.userInteractionEnabled = YES;
         NSMutableArray *tmpArray = [NSMutableArray array];
         
         for (int x = 0; x<array.count; x++)
         {
             OrderListModel *model = array[x];
             model.car_no = [model.car_no uppercaseString];
             [tmpArray addObject:model];
         }
         
         _dataArray = tmpArray;
         [_listTable headerEndRefreshing];
         if ([_dataArray count] < _pageSize * _pageIndex)
         {
             _canLoadMore = NO;
         }
         else
         {
             _pageIndex += 1;
             _canLoadMore = YES;
         }
         [_listTable reloadData];
     }
                                 exceptionResponse:^(NSError *error)
     {
         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
         self.view.userInteractionEnabled = YES;
         [_listTable headerEndRefreshing];
         [self.view makeToast:@"暂无数据"];
     }];
}

#pragma mark - 加载更多

- (void)loadMoreInfo
{
    [MBProgressHUD showHUDAddedTo:self.view  animated:YES];
    self.view.userInteractionEnabled = NO;
    [WebService requestJsonArrayOperationWithParam:@{@"car_wash_id": _userInfo.car_wash_id,
                                                     @"page_index": [NSNumber numberWithInteger:_pageIndex],
                                                     @"page_size": [NSNumber numberWithInteger:_pageSize]}
                                            action:@"order/service/list"
                                        modelClass:[OrderListModel class]
                                    normalResponse:^(NSString *status, id data, NSMutableArray *array)
     {
         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
         self.view.userInteractionEnabled = YES;
         NSMutableArray *tmpArray = [NSMutableArray array];
         
         for (int x = 0; x<array.count; x++)
         {
             OrderListModel *model = array[x];
             model.car_no = [model.car_no uppercaseString];
             [tmpArray addObject:model];
         }
         [_dataArray addObjectsFromArray:tmpArray];
         if ([_dataArray count] < _pageSize * _pageIndex)
         {
             _canLoadMore = NO;
         }
         else
         {
             _pageIndex += 1;
             _canLoadMore = YES;
         }
         [_listTable reloadData];
     }
                                 exceptionResponse:^(NSError *error)
     {
         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
         self.view.userInteractionEnabled = YES;
         [self.view makeToast:@"没有更多数据了！"];
     }];
}

#pragma mark - table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _listTable)
    {
        return _dataArray.count;
    }
    else
    {
        return _searchResultArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:OrderListCellReuse];
    if (nil == cell)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:@"OrderListCell"
                                             owner:nil
                                           options:nil][0];
    }
    OrderListModel *model = tableView == _listTable? _dataArray[indexPath.row]:_searchResultArray[indexPath.row];
    [[cell carNoLabel] setText:[NSString stringWithFormat:@"【%@】%@", ([model.car_type integerValue] == 1 ? @"轿车" : @"SUV"), model.car_no]];
    [[cell userInfoLabel] setText:@""];
    [cell.timeLabel setText:model.create_time];
    [cell.userInfoLabel setText:[NSString stringWithFormat:@"车主: %@", model.member_phone]];
    
    if ([model.service_type isEqualToString:@"1"])
    {
        [cell.serviceTypeLabel setText:@"保养"];
    }
    else if ([model.service_type isEqualToString:@"2"])
    {
        [cell.serviceTypeLabel setText:@"划痕"];
    }
    else if ([model.service_type isEqualToString:@"3"])
    {
        [cell.serviceTypeLabel setText:@"美容"];
    }
    else if ([model.service_type isEqualToString:@"4"])
    {
        [cell.serviceTypeLabel setText:@"救援"];
    }
    else if ([model.service_type isEqualToString:@"5"])
    {
        [cell.serviceTypeLabel setText:@"车保姆"];
    }
    else if ([model.service_type isEqualToString:@"6"])
    {
        [cell.serviceTypeLabel setText:@"速援"];
    }
    else
    {
        [cell.serviceTypeLabel setText:@"洗车"];
    }

    
    if ([model.order_state isEqualToString:@"2"])
    {
        [cell.stateLabel setText:@"交易/评价完成"];
        [cell.stateLabel setTextColor:[UIColor lightGrayColor]];
    }
    else if ([model.order_state isEqualToString:@"1"])
    {
        [cell.stateLabel setText:@"交易完成"];
        [cell.stateLabel setTextColor:[UIColor lightGrayColor]];
    }
    else if ([model.order_state isEqualToString:@"0"])
    {
        [cell.stateLabel setText:@"已支付"];
        [cell.stateLabel setTextColor:kNormalTintColor];
        
    }
    else if ([model.order_state isEqualToString:@"-1"])
    {
        [cell.stateLabel setText:@"订单取消中"];
        [cell.stateLabel setTextColor:kNormalTintColor];
        
    }
    else
    {
        [cell.stateLabel setText:@"订单已取消"];
        [cell.stateLabel setTextColor:kNormalTintColor];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _dataArray.count - 1 && tableView == _listTable)
    {
        if (_canLoadMore)
        {
            [self loadMoreInfo];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)nowAddComment:(OrderListModel *)info
{
    
}

- (void)cancelOrder:(OrderListModel *)info
{
    
}

#pragma mark -
#pragma mark UISearchBar and UISearchDisplayController Delegate Methods

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    searchBar.text = [searchText uppercaseString];
    [self searchContact:searchBar.text];
}

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
}

- (void) searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{

}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
}


#pragma mark -
#pragma mark - 搜索

- (void)searchContact:(NSString*)text
{
    [WebService requestJsonArrayOperationWithParam:@{@"car_wash_id": _userInfo.car_wash_id,
                                                     @"page_index" : @1,
                                                     @"page_size"  : @50,
                                                     @"car_no":text}
                                            action:@"order/service/list"
                                        modelClass:[OrderListModel class]
                                    normalResponse:^(NSString *status, id data, NSMutableArray *array)
     {
         for (int x = 0; x<array.count; x++)
         {
             OrderListModel *model = array[x];
             model.car_no = [model.car_no uppercaseString];
         }
         _searchResultArray = array;
         [_searchDisplayController.searchResultsTableView reloadData];
     }
                                 exceptionResponse:^(NSError *error)
     {
         [self.view makeToast:@"暂无数据"];
     }];
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
