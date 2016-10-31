//
//  OpreationTopCell.h
//  疯狂洗车车场
//
//  Created by cts on 15/12/29.
//  Copyright © 2015年 龚杰洪. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OpreationTopCellDelegate;

@interface OpreationTopCell : UITableViewCell
{
    IBOutlet UILabel *_remainderLabel;
    
    IBOutlet UILabel *_avilabelLabel;
    
    IBOutlet UIButton *_opreationButton;
}

@property (assign, nonatomic) id <OpreationTopCellDelegate> delegate;

- (void)setDisplayInfo:(StatisticsModel*)model;

@end


@protocol OpreationTopCellDelegate <NSObject>

- (void)didTopOpreationButtonTouched;

@end