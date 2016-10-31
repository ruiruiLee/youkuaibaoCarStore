//
//  OpreationConditionsListCell.h
//  疯狂洗车车场
//
//  Created by cts on 15/12/29.
//  Copyright © 2015年 龚杰洪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpreationElementModel.h"

@interface OpreationConditionsListCell : UITableViewCell
{
    
    IBOutlet UILabel *_serviceNameLabel;
    
    IBOutlet UILabel *_serviceCountLabel;
    
    IBOutlet UILabel *_servicePriceLabel;
}

- (void)setDisplayInfo:(OpreationElementModel*)model;


@end
