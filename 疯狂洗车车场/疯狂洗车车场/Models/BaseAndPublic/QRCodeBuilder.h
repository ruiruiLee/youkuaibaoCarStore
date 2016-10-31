//
//  QRCodeBuilder.h
//  美车帮
//
//  Created by 龚杰洪 on 15/1/29.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QRCodeBuilder : NSObject
{
    
}

+ (UIImage *)qrImageForString:(NSString *)string imageSize:(CGFloat)size;
+ (UIImage *)twoDimensionCodeImage:(UIImage *)twoDimensionCode withAvatarImage:(UIImage *)avatarImage;

@end
