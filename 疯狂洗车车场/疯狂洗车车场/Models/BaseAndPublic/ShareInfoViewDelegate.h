//
//  ShareInfoViewDelegate.h
//  康吾康
//
//  Created by 龚杰洪 on 15/1/18.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShareSDK/ShareSDK.h>

@interface ShareInfoViewDelegate : NSObject <ISSShareViewDelegate, ISSViewDelegate>
{
    
}

+ (instancetype)defaultDelegate;

@end
