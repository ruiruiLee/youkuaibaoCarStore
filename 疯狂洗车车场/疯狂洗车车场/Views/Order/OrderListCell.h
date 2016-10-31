//
//  OrderListCell.h
//  美车帮车场
//
//  Created by 龚杰洪 on 15/1/31.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderListCell : UITableViewCell
{
    
}

@property (nonatomic, strong) IBOutlet UILabel *carNoLabel;

@property (nonatomic, strong) IBOutlet UILabel *userInfoLabel;

@property (nonatomic, strong) IBOutlet UILabel *stateLabel;

@property (nonatomic, strong) IBOutlet UILabel *timeLabel;

@property (strong, nonatomic) IBOutlet UILabel *serviceTypeLabel;

@end
