//
//  OpreationHeaderView.h
//  疯狂洗车车场
//
//  Created by cts on 15/12/29.
//  Copyright © 2015年 龚杰洪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpreationElementGroupModel.h"

@interface OpreationHeaderView : UITableViewHeaderFooterView
{
    IBOutlet UILabel *_headerNameLabel;
    
    IBOutlet UILabel *_headerContentLabel;
}

- (void)setDisplayInfoWithModel:(OpreationElementGroupModel*)model;
@end
