//
//  GetCashRecordModel.h
//  疯狂洗车车场
//
//  Created by cts on 16/1/4.
//  Copyright © 2016年 龚杰洪. All rights reserved.
//

#import "JsonBaseModel.h"

@interface GetCashRecordModel : JsonBaseModel

@property (strong, nonatomic) NSString *extract_id;

@property (strong, nonatomic) NSString *extract_no;

@property (strong, nonatomic) NSString *apply_time;

@property (strong, nonatomic) NSString *extract_type;

@property (strong, nonatomic) NSString *extract_amount;

@property (strong, nonatomic) NSString *settle_time;

@property (strong, nonatomic) NSString *extract_status;

@property (strong, nonatomic) NSString *bank_id;

@property (strong, nonatomic) NSString *bank_no;

@property (strong, nonatomic) NSString *bank_name;

@property (strong, nonatomic) NSString *total_counts;

@end



