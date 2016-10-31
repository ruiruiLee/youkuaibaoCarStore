//
//  ImageUploadView.m
//  OldErp4iOS
//
//  Created by Darsky on 5/28/14.
//  Copyright (c) 2014 HFT_SOFT. All rights reserved.
//

#import "ImageUploadView.h"
#import "WebServiceHelper.h"
#import "MBProgressHUD+Add.h"

@implementation ImageUploadView


- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
           }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    if (_imagesArray.count <= 0)
    {
        _imagesArray = [NSMutableArray array];
        _itemWidth = (SCREEN_WIDTH - 50)/4.0;
        UploadImageNetworkItem *item = [[UploadImageNetworkItem alloc] initWithFrame:CGRectMake(10, 10, _itemWidth, _itemWidth)];
        item.tag = 0;
        item.deletage = self;
        [self addSubview:item];
        [_imagesArray addObject:item];
        _deleteItem = item;
    }
}

- (void)resetScrollView
{
    if (_imagesArray.count <= 0)
    {
        UploadImageNetworkItem *item = [[UploadImageNetworkItem alloc] initWithFrame:CGRectMake(10, 10, _itemWidth, _itemWidth)];
        item.tag = 0;
        item.deletage = self;
        [self addSubview:item];
        [_imagesArray addObject:item];

    }
    else
    {
        for (int x = 0; x<_imagesArray.count; x++)
        {
            UploadImageNetworkItem *item = _imagesArray[x];
            item.tag = x;
            NSLog(@"reset tag %d",x);
        }
    }
}

- (void)addImageItem
{
    if (_imagesArray.count<8)
    {
        UploadImageNetworkItem *item = nil;
        
        if (_imagesArray.count <4)
        {
            item = [[UploadImageNetworkItem alloc] initWithFrame:CGRectMake(10+_imagesArray.count*(_itemWidth+10), 10, _itemWidth, _itemWidth)];
        }
        else
        {
            item = [[UploadImageNetworkItem alloc] initWithFrame:CGRectMake(10+(_imagesArray.count-4)*(_itemWidth+10), 20+_itemWidth, _itemWidth, _itemWidth)];
        }
        item.tag = _imagesArray.count;
        item.deletage = self;
        [self addSubview:item];
        [_imagesArray addObject:item];
        [self resetScrollView];
    }
}

- (void)didUploadImageDelete:(UIView *)deleteItem
{
    _deleteItem = (UploadImageNetworkItem*)deleteItem;
    
    [Constants showMessage:@"删除这张图片？"
                  delegate:self
                       tag:77
              buttonTitles:@"取消",@"确定", nil];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 77 && buttonIndex == 1)
    {
        if (_deleteItem == nil)
        {
            [Constants showMessage:@"数据错误，操作失败"];
            return;
        }
        else if (_deleteItem.isNew)
        {
            [self startUploadImageDeleteAnimation];
        }
        else
        {
            UIWindow *window = [UIApplication sharedApplication].keyWindow;
            window.userInteractionEnabled = NO;
            [MBProgressHUD showHUDAddedTo:window animated:YES];
            NSDictionary *submitDic = @{@"car_wash_id":_userInfo.car_wash_id,
                                        @"photo_id":_deleteItem.model.photo_id};
            [WebService requestJsonOperationWithParam:submitDic
                                               action:@"carWash/service/delphoto"
                                       normalResponse:^(NSString *status, id data)
             {
                 [MBProgressHUD hideAllHUDsForView:window animated:YES];
                 window.userInteractionEnabled = YES;
                 [self startUploadImageDeleteAnimation];
             }
                                    exceptionResponse:^(NSError *error) {
                                        [MBProgressHUD hideAllHUDsForView:window animated:YES];
                                        window.userInteractionEnabled = YES;

                                    }];
            

        }
    }
}

- (void)startUploadImageDeleteAnimation
{
    [UIView beginAnimations:@"DeleteUploadImage" context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDidStopSelector:@selector(deleteUploadImage)];
    [UIView setAnimationDelegate:self];
    
    for (int x = (int)_deleteItem.tag+1; x < _imagesArray.count; x++)
    {
        UploadImageNetworkItem *item = _imagesArray[x];
        if (x<=3)
        {
            item.frame = CGRectMake(item.frame.origin.x - (_itemWidth+10), 10, _itemWidth, _itemWidth);
        }
        else if (x == 4)
        {
            item.frame =CGRectMake(10+3*(_itemWidth+10), 10, _itemWidth, _itemWidth);
        }
        else
        {
            item.frame =CGRectMake(item.frame.origin.x - (_itemWidth+10), 20+_itemWidth, _itemWidth, _itemWidth);
        }
    }
    
    _deleteItem.frame = CGRectMake(_deleteItem.frame.origin.x,
                                   _deleteItem.frame.origin.y+300,
                                   _deleteItem.frame.size.width,
                                   _deleteItem.frame.size.height);
    [UIView commitAnimations];
    
    [_deleteItem removeFromSuperview];
    
}

- (void)didUploadImageAdd:(UIView *)deleteItem
{
    _deleteItem = (UploadImageNetworkItem*)deleteItem;
    if ([self.delegate respondsToSelector:@selector(didNeedAddShowImagePicker)])
    {
        [self.delegate didNeedAddShowImagePicker];
    }
}

- (void)didUploadImageEdit:(UIView *)deleteItem
{
    _deleteItem = (UploadImageNetworkItem*)deleteItem;
    if ([self.delegate respondsToSelector:@selector(didNeedEditShowImagePicker)])
    {
        [self.delegate didNeedEditShowImagePicker];
    }
}

- (void)setUploadImageItem:(UIImage*)image
{
    [_deleteItem setUploadImage:image];
    
    for (UploadImageNetworkItem *item in _imagesArray)
    {
        if (item.displayImageView.highlighted)
        {
            return;
        }
    }

    [self addImageItem];
}


- (void)setUploadImageItems:(NSArray*)images
{
    for (int x = 0; x<images.count; x++)
    {
        [_deleteItem setUploadImage:images[x]];
        
        if (_imagesArray.count<8)
        {
            UploadImageNetworkItem *item = nil;
            
            if (_imagesArray.count <4)
            {
                item = [[UploadImageNetworkItem alloc] initWithFrame:CGRectMake(10+_imagesArray.count*(_itemWidth+10), 10, _itemWidth, _itemWidth)];
            }
            else
            {
                item = [[UploadImageNetworkItem alloc] initWithFrame:CGRectMake(10+(_imagesArray.count-4)*(_itemWidth+10), 20+_itemWidth, _itemWidth, _itemWidth)];
            }
            item.tag = _imagesArray.count;
            item.deletage = self;
            [self addSubview:item];
            _deleteItem = item;
            [_imagesArray addObject:item];
        }
    }
    [self resetScrollView];
}

- (void)setUploadUrlImageItems:(NSArray*)images
{
    for (int x = 0; x<images.count; x++)
    {
        [_deleteItem setModel:images[x]];
        
        if (_imagesArray.count<8)
        {
            UploadImageNetworkItem *item = nil;
            
            if (_imagesArray.count <4)
            {
                item = [[UploadImageNetworkItem alloc] initWithFrame:CGRectMake(10+_imagesArray.count*(_itemWidth+10), 10, _itemWidth, _itemWidth)];
            }
            else
            {
                item = [[UploadImageNetworkItem alloc] initWithFrame:CGRectMake(10+(_imagesArray.count-4)*(_itemWidth+10), 20+_itemWidth, _itemWidth, _itemWidth)];
            }
            item.tag = _imagesArray.count;
            item.deletage = self;
            [self addSubview:item];
            _deleteItem = item;
            [_imagesArray addObject:item];
        }
    }
    [self resetScrollView];

}


- (void)deleteUploadImage
{
    [_imagesArray removeObjectAtIndex:_deleteItem.tag];
    UploadImageModel *model = nil;
    if (!_deleteItem.isNew || _deleteItem != nil)
    {
        model = _deleteItem.model;
    }
    _deleteItem = nil;
    [self resetScrollView];
    UploadImageNetworkItem *lastItem = [_imagesArray lastObject];
    
    if (!lastItem.displayImageView.highlighted && _imagesArray.count<8)
    {
        UploadImageNetworkItem *item = nil;
        
        if (_imagesArray.count <4)
        {
            item = [[UploadImageNetworkItem alloc] initWithFrame:CGRectMake(10+_imagesArray.count*(_itemWidth+10), 10, _itemWidth, _itemWidth)];
        }
        else
        {
            item = [[UploadImageNetworkItem alloc] initWithFrame:CGRectMake(10+(_imagesArray.count-4)*(_itemWidth+10), 20+_itemWidth, _itemWidth, _itemWidth)];
        }
        item.tag = _imagesArray.count;
        item.deletage = self;
        [self addSubview:item];
        [_imagesArray addObject:item];
        
    }
    if (model == nil)
    {
        if ([self.delegate respondsToSelector:@selector(didImageUploadViewDelegateImage)])
        {
            [self.delegate didImageUploadViewDelegateImage];
        }
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(didImageUploadViewDelegateOnlineImage:)])
        {
            [self.delegate didImageUploadViewDelegateOnlineImage:model];
        }
    }

}
- (void)removeAllImages
{
    for (UploadImageNetworkItem *item in _imagesArray)
    {
        [item removeFromSuperview];
    }
    [_imagesArray removeAllObjects];
    [self resetScrollView];
}

- (NSArray*)getAllImage
{
    NSMutableArray *resultArray = [NSMutableArray array];
    for (UploadImageNetworkItem *item in _imagesArray)
    {
        if (!item.displayImageView.highlighted)
        {
            [resultArray addObject:[item retureUploadImage]];
        }
    }
    return resultArray;
}

- (NSArray*)getAllImageData
{
    NSMutableArray *resultArray = [NSMutableArray array];
    for (UploadImageNetworkItem *item in _imagesArray)
    {
        if (!item.displayImageView.highlighted)
        {
            [resultArray addObject:[item retureUploadImageData]];
        }
    }
    return resultArray;
}

- (NSArray*)getAllUploadImageData
{
    NSMutableArray *resultArray = [NSMutableArray array];
    for (UploadImageNetworkItem *item in _imagesArray)
    {
        if (!item.displayImageView.highlighted && item.isNew)
        {
            [resultArray addObject:[item retureUploadImageData]];
        }
    }
    return resultArray;
}
//- (void)didImageButtibn
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
