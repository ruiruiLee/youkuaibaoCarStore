//
//  GetCashRecordListCell.m
//  疯狂洗车车场
//
//  Created by cts on 16/1/4.
//  Copyright © 2016年 龚杰洪. All rights reserved.
//

#import "GetCashRecordListCell.h"

@implementation GetCashRecordListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDisplayInfo:(GetCashRecordModel*)model
{
    _cardNumberlabel.text = [NSString stringWithFormat:@"%@(尾号%@)",model.bank_name,model.bank_no];
    _cardPriceLabel.text = [NSString stringWithFormat:@"-%.2f",model.extract_amount.floatValue];
    
    _timeLabel.text = [NSString stringWithFormat:@"%@",model.apply_time];
    
    if (model.extract_status.intValue == 1)
    {
        _statusLabel.text = @"申请中";
    }
    else if (model.extract_status.intValue == 2)
    {
        _statusLabel.text = @"正在处理";
    }
    else if (model.extract_status.intValue == 3)
    {
        _statusLabel.text = @"已完成";
    }
    else if (model.extract_status.intValue == 4)
    {
        _statusLabel.text = @"已拒绝";
    }
    else
    {
        _statusLabel.text = @"等待审核";
    }
}

@end
