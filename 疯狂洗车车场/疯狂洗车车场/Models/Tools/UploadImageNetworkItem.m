//
//  UploadImageNetworkItem.m
//  OldErp4iOS
//
//  Created by Darsky on 5/29/14.
//  Copyright (c) 2014 HFT_SOFT. All rights reserved.
//

#import "UploadImageNetworkItem.h"
#import "UIImageView+WebCache.h"

@implementation UploadImageNetworkItem

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        _displayImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [_displayImageView setHighlightedImage:[UIImage imageNamed:@"btn_b_pic_only"]];
        _displayImageView.contentMode = UIViewContentModeScaleAspectFill;
        _displayImageView.clipsToBounds = YES;
        _displayImageView.highlighted = YES;
        
        [self addSubview:_displayImageView];
        
        _imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _imageButton.frame = self.bounds;
        [_imageButton addTarget:self
                         action:@selector(didAddItemPressed)
               forControlEvents:UIControlEventTouchDown];
        [self addSubview:_imageButton];
        
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.frame = CGRectMake(self.frame.size.width-22 , -10, 30, 30);
        _deleteBtn.tag = 10;
        [_deleteBtn setImage:[UIImage imageNamed:@"deleteUpImage"]
                    forState:UIControlStateNormal];

        [_deleteBtn addTarget:self
                       action:@selector(didDeleteImagePressed)
             forControlEvents:UIControlEventTouchDown];
        [self addSubview:_deleteBtn];
        _deleteBtn.hidden = YES;
        
        _newLabel = [[UILabel alloc] initWithFrame:CGRectMake(-5, -5, 30, 20)];
        _newLabel.text = @"New";
        _newLabel.layer.masksToBounds = YES;
        _newLabel.layer.cornerRadius = 10;
        _newLabel.textAlignment = NSTextAlignmentCenter;
        _newLabel.textColor = [UIColor whiteColor];
        _newLabel.backgroundColor = [UIColor colorWithRed:29/255.0 green:185/255.0 blue:84/255.0 alpha:1.0];
        _newLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_newLabel];
        _newLabel.hidden = YES;
        
        _firstLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-20, self.frame.size.width, 20)];
        _firstLabel.text = @"首图";
        _firstLabel.textAlignment = NSTextAlignmentCenter;
        _firstLabel.textColor = [UIColor whiteColor];
        _firstLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        _firstLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:_firstLabel];
        _firstLabel.hidden = YES;
    }
    return self;
}

- (void)setModel:(UploadImageModel *)model
{
    _model = model;
    [_displayImageView setHighlightedImage:[UIImage imageNamed:@"img_imageDowloading"]];
    [_displayImageView sd_setImageWithURL:[NSURL URLWithString:_model.photo_addr]
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {
        if (error == nil)
        {
            [_displayImageView setImage:image];
            _displayImageView.highlighted = NO;
            _displayImageView.layer.borderWidth = 0.7;
            _displayImageView.layer.borderColor = [UIColor colorWithRed:96/255.0 green:96/255.0 blue:96/255.0 alpha:0.5].CGColor;
        }
        else
        {
            [_displayImageView setImage:[UIImage imageNamed:@"img_imageDowloading_error"]];
            _displayImageView.highlighted = NO;
            _displayImageView.layer.borderWidth = 0.7;
            _displayImageView.layer.borderColor = [UIColor colorWithRed:96/255.0 green:96/255.0 blue:96/255.0 alpha:0.5].CGColor;
        }
    }];
    if (model.is_top.intValue > 0)
    {
        _firstLabel.hidden = NO;
    }
    else
    {
        _firstLabel.hidden = YES;
    }
    self.isNew = NO;
    _newLabel.hidden = YES;
    _deleteBtn.hidden = NO;
}



- (void)setUploadImage:(UIImage*)image
{
    [_displayImageView setImage:image];
    
    _displayImageView.highlighted = NO;
    
    _deleteBtn.hidden  = NO;
    _firstLabel.hidden = YES;
    self.isNew = YES;
    _newLabel.hidden = NO;
    
}

- (void)didAddItemPressed
{
    if (self.displayImageView.highlighted)
    {
        if ([self.deletage respondsToSelector:@selector(didUploadImageAdd:)])
        {
            [self.deletage didUploadImageAdd:self];
        }
    }
    else
    {
        if ([self.deletage respondsToSelector:@selector(didUploadImageEdit:)])
        {
            [self.deletage didUploadImageEdit:self];
        }
    }

}
- (void)didDeleteImagePressed
{
    if ([self.deletage respondsToSelector:@selector(didUploadImageDelete:)])
    {
        [self.deletage didUploadImageDelete:self];
    }
}

- (UIImage*)retureUploadImage
{
    if (!self.displayImageView.highlighted)
    {
        NSData *uploadImageData = UIImageJPEGRepresentation(_displayImageView.image, 0.5);
        return [UIImage imageWithData:uploadImageData];
    }
    else
        return nil;
}

- (NSData*)retureUploadImageData
{
    if (!self.displayImageView.highlighted && self.isNew)
    {
        NSData *uploadImageData = UIImageJPEGRepresentation(_displayImageView.image, 0.5);
        if (uploadImageData.length > 40000)
        {
            return UIImageJPEGRepresentation(_displayImageView.image, 0.1);;
        }
        else
        {
            return uploadImageData;
        }
    }
    else
        return nil;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
