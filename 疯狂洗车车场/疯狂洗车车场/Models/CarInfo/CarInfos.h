//
//  CarInfos.h
//  美车帮
//
//  Created by 龚杰洪 on 15/1/27.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "JsonBaseModel.h"

@interface CarInfos : JsonBaseModel
{
    
}

@property (nonatomic, copy) NSString *car_id;
@property (nonatomic, copy) NSString *member_id;
@property (nonatomic, copy) NSString *car_no;
@property (nonatomic, copy) NSString *car_type;
@property (nonatomic, copy) NSString *car_brand;
@property (nonatomic, copy) NSString *car_kuanshi;
@property (nonatomic, copy) NSString *car_xilie;

@property (nonatomic, copy) NSString *total_counts;

@end
