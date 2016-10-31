//
//  OpreationHeaderView.m
//  疯狂洗车车场
//
//  Created by cts on 15/12/29.
//  Copyright © 2015年 龚杰洪. All rights reserved.
//

#import "OpreationHeaderView.h"

@implementation OpreationHeaderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)setDisplayInfoWithModel:(OpreationElementGroupModel*)model
{
    _headerNameLabel.text = model.elementGroupName;
    
    _headerContentLabel.text = [NSString stringWithFormat:@"%.2f元",model.elementGroupPrice.floatValue];
}

@end
