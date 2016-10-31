//
//  OpreationElementModel.h
//  疯狂洗车车场
//
//  Created by cts on 15/12/30.
//  Copyright © 2015年 龚杰洪. All rights reserved.
//

#import "JsonBaseModel.h"

@interface OpreationElementModel : JsonBaseModel

@property (strong, nonatomic) NSString *service_name;

@property (strong, nonatomic) NSString *all_count;

@property (strong, nonatomic) NSString *all_sum;

@property (strong, nonatomic) NSString *car_type;


@end
