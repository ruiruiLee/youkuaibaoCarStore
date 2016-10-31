//
//  BankCardModel.h
//  疯狂洗车车场
//
//  Created by cts on 15/12/30.
//  Copyright © 2015年 龚杰洪. All rights reserved.
//

#import "JsonBaseModel.h"

@interface BankCardModel : JsonBaseModel

@property (strong, nonatomic) NSString *bank_id;
@property (strong, nonatomic) NSString *bank_no;
@property (strong, nonatomic) NSString *bank_name;
@property (strong, nonatomic) NSString *user_name;
@property (strong, nonatomic) NSString *max_extract_money;
@property (strong, nonatomic) NSString *min_extract_money;

@end
