//
//  OpreationConditionsListCell.m
//  疯狂洗车车场
//
//  Created by cts on 15/12/29.
//  Copyright © 2015年 龚杰洪. All rights reserved.
//

#import "OpreationConditionsListCell.h"

@implementation OpreationConditionsListCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDisplayInfo:(OpreationElementModel*)model
{
    _serviceNameLabel.text = [NSString stringWithFormat:@"%@",model.service_name];
    
    _serviceCountLabel.text = [NSString stringWithFormat:@"%d次",model.all_count.intValue];
    
    _servicePriceLabel.text = [NSString stringWithFormat:@"%.2f元",model.all_sum.floatValue];
}

@end
