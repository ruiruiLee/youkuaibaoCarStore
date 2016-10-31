//
//  OpreationTopCell.m
//  疯狂洗车车场
//
//  Created by cts on 15/12/29.
//  Copyright © 2015年 龚杰洪. All rights reserved.
//

#import "OpreationTopCell.h"

@implementation OpreationTopCell

- (void)awakeFromNib {
    // Initialization code
    
    _opreationButton.layer.masksToBounds = YES;
    _opreationButton.layer.cornerRadius = 15;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setDisplayInfo:(StatisticsModel*)model
{
    _avilabelLabel.text = [NSString stringWithFormat:@"%.2f",model.account_amount.floatValue];
    
    _remainderLabel.text = [NSString stringWithFormat:@"%.2f",model.account_remainder.floatValue];
}
- (IBAction)didTopOpreationButtonTouch:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didTopOpreationButtonTouched)])
    {
        [self.delegate didTopOpreationButtonTouched];
    }
}

@end
