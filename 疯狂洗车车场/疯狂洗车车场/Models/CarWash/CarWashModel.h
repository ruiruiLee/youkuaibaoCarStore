//
//  CarWashModel.h
//  美车帮
//
//  Created by 龚杰洪 on 15/1/29.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "JsonBaseModel.h"

@interface CarWashModel : JsonBaseModel
{
    
}

/*
 "suv_member_price":"1",
 "city_id":"",
 "evaluation_counts":"2",
 "average_score":"2.5",
 "suv_agreement_price":"1",
 "province_id":"",
 "total_score":"5",
 "if_verified":"",
 "business_hours_from":"08:30:00",
 "suv_original_price":"1",
 "car_wash_id":"1",
 "admin_id":"1",
 "car_agreement_price":"1",
 "business_hours_to":"21:00:00",
 "car_member_price":"1",
 "account_remainder":"0",
 "longitude":"1.0000000000",
 "car_original_price":"1",
 "latitude":"1.0000000000",
 "phone":"1",
 "address":"111111",
 "logo":"http://118.123.249.87/car_wash/car_wash_default.png",
 "if_opening":"1",
 "name":"5",
 "area_id":""
 */

@property (nonatomic, copy) NSString *account_remainder;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *area_id;
@property (nonatomic, copy) NSString *business_hours_from;
@property (nonatomic, copy) NSString *admin_id;
@property (nonatomic, copy) NSString *business_hours_to;
@property (nonatomic, copy) NSString *car_agreement_price;

@property (nonatomic, copy) NSString *car_member_price;
@property (nonatomic, copy) NSString *car_original_price;
@property (nonatomic, copy) NSString *car_wash_id;
@property (nonatomic, copy) NSString *city_id;
@property (nonatomic, copy) NSString *evaluation_counts;
@property (nonatomic, copy) NSString *if_opening;
@property (nonatomic, copy) NSString *logo;

@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *longitude;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *province_id;
@property (nonatomic, copy) NSString *suv_agreement_price;
@property (nonatomic, copy) NSString *suv_member_price;
@property (nonatomic, copy) NSString *suv_original_price;
@property (nonatomic, copy) NSString *average_score;
@property (nonatomic, copy) NSString *total_score;
@property (nonatomic, copy) NSString *if_verified;
@property (nonatomic, copy) NSString *introduction;
@property (nonatomic, copy) NSString *short_name;

@property (nonatomic, strong) NSString *photo_addrs;
@property (strong, nonatomic) NSMutableArray *imageArray;

@end
