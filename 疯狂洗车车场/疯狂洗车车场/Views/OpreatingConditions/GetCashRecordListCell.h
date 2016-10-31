//
//  GetCashRecordListCell.h
//  疯狂洗车车场
//
//  Created by cts on 16/1/4.
//  Copyright © 2016年 龚杰洪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetCashRecordModel.h"

@interface GetCashRecordListCell : UITableViewCell
{
    IBOutlet UILabel *_cardNumberlabel;
    
    IBOutlet UILabel *_cardPriceLabel;
    
    IBOutlet UILabel *_timeLabel;
    
    IBOutlet UILabel *_statusLabel;
}

- (void)setDisplayInfo:(GetCashRecordModel*)model;

@end
