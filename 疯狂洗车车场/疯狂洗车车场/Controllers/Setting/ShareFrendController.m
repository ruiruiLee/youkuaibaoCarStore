//
//  ShareFrendController.m
//  美车帮
//
//  Created by 龚杰洪 on 15/1/28.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "ShareFrendController.h"
#import <ShareSDK/ShareSDK.h>
#import "ShareInfoViewDelegate.h"
#import "QRCodeBuilder.h"
#import "QRCodeGenerator.h"
#import "ShareMenuView.h"


@interface ShareFrendController ()

@end

@implementation ShareFrendController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"告诉好友"];
    
    [_phoneLabel makeConstraints:^(MASConstraintMaker *make)
    {
        make.centerX.equalTo(self.view).offset(15);
    }];
    
    [[_shareBtn layer] setCornerRadius:3.0];
    [[_shareBtn layer] setMasksToBounds:YES];
    
    UIImage *towCode = [QRCodeGenerator qrImageForString:kDownloadUrl
                                               imageSize:360];
    _qrCodeView.image = towCode;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)shareToFrends:(id)sender
{
    [ShareMenuView showShareMenuViewAtTarget:self
                                 withContent:@"不办卡, 也优惠。30多个城市，2000多家优质车场，随时随地，想洗就洗。关注疯狂汽车微信，可领优惠券。APP下载：http://t.cn/Rwjwb0D"
                                   withImage:[UIImage imageNamed:@"img_share_icon"]
                                     withUrl:kDownloadUrl];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
