//
//  StatisticsModel.h
//  美车帮车场
//
//  Created by 龚杰洪 on 15/2/3.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "JsonBaseModel.h"
#import "month_count.h"
#import "today_count.h"
#import "total_count.h"

@interface StatisticsModel : JsonBaseModel
{
    
}
@property (nonatomic, copy) NSString *max_extract_money;
@property (nonatomic, copy) NSString *account_remainder;

@property (nonatomic, strong) NSArray *month_count;

@property (nonatomic, strong) NSArray *today_count;

@property (nonatomic, copy) NSString *min_extract_money;

@property (nonatomic, strong) NSArray *total_count;

@property (nonatomic, copy) NSString *account_status;

@property (nonatomic, copy) NSString *account_amount;




@end
/*
 "account_remainder":"-155",
 "today_car_wash_times":"0",
 "car_agreement_price":"1",
 "today_car_income":"0",
 "today_suv_wash_times":"3",
 "suv_agreement_price":"1",
 "today_suv_income":"3",
 "today_income":"3",
 "today_wash_times":"3",
 "this_month_car_wash_times":"114",
 "this_month_car_income":"114",
 "this_month_suv_wash_times":"3",
 "this_month_suv_income":"35",
 "this_month_income":"149",
 "this_month_wash_times":"149",
 "total_car_wash_times":"120",
 "total_suv_wash_times":"35",
 "total_car_income":"120",
 "total_suv_income":"35",
 "total_income":"155",
 "total_wash_times":"155"
 */