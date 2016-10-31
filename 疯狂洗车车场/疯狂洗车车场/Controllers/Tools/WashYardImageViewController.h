//
//  WashYardImageViewController.h
//  疯狂汽车
//
//  Created by cts on 15/7/20.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "BaseViewController.h"
#import "ImageUploadView.h"

@protocol WashYardImageDelegate <NSObject>

- (void)didFinishWasyYardImageSelect:(NSArray*)imageArray;

@end

@interface WashYardImageViewController : BaseViewController<ImageUploadViewDelegate>
{
    
    IBOutlet ImageUploadView *_imageUploadView;
}

@property (assign, nonatomic) id <WashYardImageDelegate> delegate;

@property (strong ,nonatomic) NSMutableArray *uploadImageArray;

@end
