//
//  HFTLoginTextField.m
//  OldErp4iOS
//
//  Created by Darsky on 14-4-11.
//  Copyright (c) 2014年 HFT_SOFT. All rights reserved.
//

#import "HFTLoginTextField.h"

@implementation HFTLoginTextField


- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setNeedsDisplay];
}

- (void)drawPlaceholderInRect:(CGRect)rect
{
    [[UIColor whiteColor] set];
    [[self placeholder] drawInRect:CGRectMake(rect.size.width/2 - self.placeholder.length*14/2, bIsiOS7?12:0, rect.size.width, rect.size.height) withFont:[UIFont systemFontOfSize:14]];
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0)
    {
        self.tintColor = [UIColor whiteColor];
    }
}
- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectMake(0, 0, bounds.size.width, bounds.size.height);
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextMoveToPoint(context, 0 , self.frame.size.height);
    CGContextAddLineToPoint(context, self.frame.size.width,self.frame.size.height);
    CGContextStrokePath(context);
}
@end
