//
//  GetCashRecordViewController.m
//  疯狂洗车车场
//
//  Created by cts on 15/12/30.
//  Copyright © 2015年 龚杰洪. All rights reserved.
//

#import "GetCashRecordViewController.h"
#import "GetCashRecordListCell.h"
#import "GetCashRecordModel.h"
#import "MJRefresh.h"
#import "WebServiceHelper.h"
#import "MBProgressHUD+Add.h"

@interface GetCashRecordViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    
    IBOutlet UITableView *_listTableView;
    
    NSMutableArray       *_dataArray;
    
    NSInteger             _pageIndex;
    
    int                   _pageSize;
    
    BOOL                  _canLoadMore;
    
    int                   _totalCount;
}

@end

@implementation GetCashRecordViewController

static NSString *GetCashRecordListCellIdentifier = @"GetCashRecordListCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setTitle:@"提现明细"];
    
    _dataArray = [NSMutableArray array];
    
    [_listTableView registerNib:[UINib nibWithNibName:GetCashRecordListCellIdentifier
                                                  bundle:[NSBundle mainBundle]]
            forCellReuseIdentifier:GetCashRecordListCellIdentifier];
    
    [_listTableView addHeaderWithTarget:self
                                 action:@selector(startTableHeaderAnimation)];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shouldUpdateList)
                                                 name:kShouldUpdateList
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_dataArray.count == 0)
    {
        [_listTableView headerBeginRefreshing];
    }
}

- (void)shouldUpdateList
{
    [_listTableView headerBeginRefreshing];
}

- (void)startTableHeaderAnimation
{
    _pageIndex = 1;
    _pageSize = 20;
    _canLoadMore = YES;
    
    [self loadDataFromService];
}

- (void)startTableFooterAnimation
{
    if (_canLoadMore)
    {
        [self loadDataFromService];
    }
}

- (void)loadDataFromService
{
    NSDictionary *submitDic = @{@"car_wash_id":_userInfo.car_wash_id,
                                @"page_index":@(_pageIndex),
                                @"page_size":@(_pageSize)};
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.view.userInteractionEnabled = NO;
    
    [WebService requestJsonArrayOperationWithParam:submitDic
                                            action:@"account/service/extractList"
                                        modelClass:[GetCashRecordModel class]
                                    normalResponse:^(NSString *status, id data, NSMutableArray *array)
     {
         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
         self.view.userInteractionEnabled = YES;
         if (_pageIndex == 1)
         {
             if (_dataArray.count > 0)
             {
                 [_dataArray removeAllObjects];
             }
             [_listTableView headerEndRefreshing];
         }
         if (array.count > 0 && _totalCount == 0)
         {
             GetCashRecordModel *model = [array lastObject];
             
             _totalCount = model.total_counts.intValue;
         }
         if (array.count >= _pageSize)
         {
             _pageIndex++;
             _canLoadMore = YES;
         }
         else
         {
             _canLoadMore = NO;
         }
         [_dataArray addObjectsFromArray:array];
         if (_dataArray.count >= _totalCount && _canLoadMore)
         {
             _canLoadMore = NO;
         }
         [_listTableView reloadData];
    }
                                 exceptionResponse:^(NSError *error) {
                                     [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                     self.view.userInteractionEnabled = YES;
                                     [MBProgressHUD showError:[error domain]
                                                       toView:self.view];
                                     if (_pageIndex == 1)
                                     {
                                         [_listTableView headerEndRefreshing];
                                     }
    }];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GetCashRecordListCell *cell = [tableView dequeueReusableCellWithIdentifier:GetCashRecordListCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[GetCashRecordListCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:GetCashRecordListCellIdentifier];
    }
    
    [cell setDisplayInfo:_dataArray[indexPath.row]];
    
    return cell;
}




#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.row == _dataArray.count-1) && _canLoadMore)
    {
        [self loadDataFromService];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShouldUpdateList object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
