//
//  OrderListModel.h
//  美车帮
//
//  Created by 龚杰洪 on 15/1/29.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "JsonBaseModel.h"

@interface OrderListModel : JsonBaseModel
{
    
}



@property (nonatomic, copy) NSString *if_evaluationed;
@property (nonatomic, copy) NSString *create_time;
@property (nonatomic, copy) NSString *server_time;
@property (nonatomic, copy) NSString *pay_type;
@property (nonatomic, copy) NSString *pay_money;
@property (nonatomic, copy) NSString *order_id;
@property (nonatomic, copy) NSString *order_state;
@property (nonatomic, copy) NSString *car_id;
@property (nonatomic, copy) NSString *car_no;
@property (nonatomic, copy) NSString *car_type;
@property (nonatomic, copy) NSString *car_brand;
@property (strong ,nonatomic) NSString *paid_status;//



@property (nonatomic, copy) NSString *if_finished;
@property (nonatomic, copy) NSString *member_id;
@property (nonatomic, copy) NSString *car_wash_id;
@property (nonatomic, copy) NSString *car_wash_name;
@property (nonatomic, copy) NSString *car_wash_address;

@property (nonatomic, copy) NSString *average_score;
@property (nonatomic, copy) NSString *evaluation_counts;
@property (nonatomic, copy) NSString *total_counts;
@property (nonatomic, copy) NSString *member_phone;
@property (nonatomic, copy) NSString *out_trade_no;

@property (nonatomic, copy) NSString *evaluation_id;

@property (strong, nonatomic) NSString *service_id;
@property (strong, nonatomic) NSString *order_type;
@property (strong, nonatomic) NSString *service_type;

@property (strong, nonatomic) NSString *code_id;//
@property (strong, nonatomic) NSString *consume_type;//
@property (strong, nonatomic) NSString *code_name;//

@property (strong, nonatomic) NSString *member_price;//
@end
