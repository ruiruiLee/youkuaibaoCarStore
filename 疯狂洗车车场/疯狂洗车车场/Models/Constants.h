
#import "UserInfo.h"
#import "CarInfos.h"
#import "CarWashModel.h"
#import "OrderListModel.h"
#import "StatisticsModel.h"
#import "StartInfoModel.h"

#define kNormalTintColor [UIColor colorWithRed:235/255.0 green:84/255.0 blue:1/255.0 alpha:1.0]


extern NSString *const kForceExitNotifaction;
extern NSString *const kLoginSuccessNotifaction;
extern NSString *const kLogoutSuccessNotifaction;
extern NSString *const kPaySuccessNotification;

extern NSString *const kCustomLaunch;

extern NSString *const kStartInfoKey;

extern NSString *const kDeviceToken;

extern NSString *const kWeiboAppKey;
extern NSString *const kWeiboAppSecret;

extern NSString *const kWeixinAppKey;
extern NSString *const kWeixinAppSecret;

extern NSString *const kQQAppKey;
extern NSString *const kQQAppSecret;

extern NSString *const kShareSDKAppKey;

extern NSString *const kUserInfoKey;

extern NSString *const kLoginToken;

extern NSString *const kAutoLogin;


extern NSString *const kDownloadUrl;

extern NSString *const kLocationKey;

extern NSString *const kShouldUpdateList;

extern NSString *const kAppDomainUrl;

extern NSString *const kSpareAppDomainUrl;



UserInfo               *_userInfo;

StartInfoModel         *_startInfo;


NSString               *_notificationDeviceToken;

@interface Constants : NSObject


+ (UIAlertView *)showMessage:(NSString *)message;

/*!
 @method
 @abstract 通过需要提示的信息和代理显示一个alert
 @discussion 默认标题为“温馨提示” ，默认dismiss button title为好的
 @param message alert需要显示的内容
 @param delegate alert的代理
 @result void
 */
+ (void)showMessage:(NSString *)message
           delegate:(id)delegate;

/*!
 @method
 @abstract 通过需要提示的信息，代理，tag和多个button显示一个alert
 @discussion 默认标题为“温馨提示”
 @param message alert需要显示的内容
 @param delegate alert的代理
 @param tag 用于区分弹出的多个alert
 @param otherButtonTitles 多个按钮的名字
 @result void
 */
+ (void)showMessage:(NSString *)message
           delegate:(id)delegate
                tag:(int)tag
       buttonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

/*!
 @method
 @abstract 获取本机IP地址
 @discussion 默认为获取内网地址，现在默认返回的是IP中心地址
 @result NSString *
 */
+ (NSString *)deviceIPAdress;

+ (NSString*)getCrazyCarWashImageDirestory;


/*!
 @method
 @abstract 获取外网IP地址
 @discussion 此方法有网络请求，会卡线程，不建议使用
 @result NSString *
 */
+ (NSString *)devicePublicIPAdress;

+ (BOOL)canMakePhoneCall;


+ (NSString *)distanceBetweenOrderBy:(double)lat1
                                :(double)lat2
                                :(double)lng1
                                :(double)lng2;

+(NSString *)LantitudeLongitudeDist:(double)lon1
                          other_Lat:(double)lat1
                           self_Lon:(double)lon2
                           self_Lat:(double)lat2;
@end
