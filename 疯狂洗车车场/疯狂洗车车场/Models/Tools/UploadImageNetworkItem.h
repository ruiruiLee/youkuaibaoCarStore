/*!
 @header UploadImageNetworkItem.h
 @abstract 经纪天地发帖/回帖选择后的图片控件类
 @author Darsky
 @version 0.80 2014/05/29 Creation
 */
#import <UIKit/UIKit.h>
#import "UploadImageModel.h"

/*!
 @protocol UploadImageItemDelegate
 @abstract 这个UploadImageItem类的一个protocol
 @discussion 在对图片进行操作后调用
 */
@protocol UploadImageNetworkItemDelegate <NSObject>

/*!
 @method didUploadImageDelete:
 @abstract 进行图片删除操作后触发的方法
 @discussion 进行图片删除操作后触发的方法。
 @param deleteItem 删除对象
 @result void 进行图片删除操作后设置后触发的方法，会得到删除对象
 */
- (void)didUploadImageDelete:(UIView*)deleteItem;

/*!
 @method didUploadImageDelete:
 @abstract 点击添加图片操作后触发的方法
 @discussion 点击添加图片操作后触发的方法。
 @param deleteItem 添加对象
 @result void 击添加图片操作后触发的方法得到添加的目标对象
 */
- (void)didUploadImageAdd:(UIView*)deleteItem;

- (void)didUploadImageEdit:(UIView*)deleteItem;


@end

/*!
 @class UploadImageItem
 @abstract 经纪天地发帖/回帖选择后的图片控件类
 */

@interface UploadImageNetworkItem : UIView
{
    UIButton *_imageButton;
    
    UIButton *_deleteBtn;
    
   
    
    UILabel     *_newLabel;
    
    UILabel     *_firstLabel;
}

/*!
 @method setUploadImage:
 @abstract 设置该控件图片
 @discussion 设置该控件图片。
 @param image 设置的图片
 @result void 设置控件图片
 */
- (void)setUploadImage:(UIImage*)image;



/*!
 @method retureUploadImage:
 @abstract 获得该控件的图片，若无设置是不会返回默认图片的
 @discussion 获得该控件的图片，若无设置是不会返回默认图片的
 @result UIImage 获得该控件的图片
 */

- (NSData*)retureUploadImageData;

- (UIImage*)retureUploadImage;

/*!
 @property delegate
 @abstract 这是UploadImageItemDelegate的delegate
 */
@property (assign, nonatomic) id <UploadImageNetworkItemDelegate> deletage;

@property (strong, nonatomic) UIImageView *displayImageView;

@property (assign, nonatomic) BOOL isNew;

@property (strong, nonatomic) UploadImageModel *model;

@end
