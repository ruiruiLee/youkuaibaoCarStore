//
//  UserInfo.h
//  美车帮
//
//  Created by 龚杰洪 on 15/1/27.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "JsonBaseModel.h"

@interface UserInfo : JsonBaseModel
{
    
}

/*
 "login_password":"123456",
 "member_phone":"15208306029",
 "member_address":"",
 "member_name":"15208306029",
 "member_birthday":"",
 "member_age":"",
 "login_name":"15208306029",
 "member_level":"1",
 "member_sfzh":"",
 "member_id":"42",
 "member_sex":""
 */

@property (nonatomic, copy) NSString *login_password;
@property (nonatomic, copy) NSString *car_wash_id;
@property (nonatomic, copy) NSString *admin_name;
@property (nonatomic, copy) NSString *admin_id;

@property (nonatomic, copy) NSString *if_chain;

@property (nonatomic, copy) NSString *login_name;
@property (nonatomic, copy) NSString *supper_password;
@property (nonatomic, copy) NSString *super_password;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *member_name;




@end
