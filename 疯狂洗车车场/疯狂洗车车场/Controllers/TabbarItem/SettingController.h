//
//  SettingController.h
//  美车帮车场
//
//  Created by 龚杰洪 on 15/1/31.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "BaseViewController.h"

@interface SettingController : BaseViewController<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView  *_menuTable;
}


@end
