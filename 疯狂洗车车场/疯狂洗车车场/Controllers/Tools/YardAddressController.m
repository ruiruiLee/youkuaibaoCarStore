//
//  YardAddressController.m
//  美车帮车场
//
//  Created by 龚杰洪 on 15/1/31.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "YardAddressController.h"
#import "MBProgressHUD+Add.h"
#import "WebServiceHelper.h"
#import "UIView+Toast.h"
#import <MapKit/MapKit.h>

const double a = 6378245.0;
const double ee = 0.00669342162296594323;
const double pi = 3.14159265358979324;

@interface YardAddressController () <CLLocationManagerDelegate>
{
    CLLocationManager   *_locationManager;
}

@end

@implementation YardAddressController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"地址"];
    
    [[_submitBtn layer] setCornerRadius:5.0];
    [[_submitBtn layer] setMasksToBounds:YES];
    
    _inputView.layer.masksToBounds = YES;
    _inputView.layer.cornerRadius = 5;
    _inputView.layer.borderWidth = 1;
    _inputView.layer.borderColor = [UIColor colorWithRed:204/255.0
                                                   green:204/255.0
                                                    blue:204/255.0
                                                   alpha:1.0].CGColor;
    
    [_addressTextView setPlaceholder:@"请输入车场地址"];
    [_addressTextView setText:_yardInfo.address];
    
//    _locationManager = [[CLLocationManager alloc] init];
//    _locationManager.delegate = self;
//    _locationManager.distanceFilter = 1000.0f;
//    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0)
//    {
//        [_locationManager requestWhenInUseAuthorization];
//    }
//    [_locationManager startUpdatingLocation];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sumitInfo:(id)sender
{
    if ([_addressTextView.text isEqualToString:@""] || !_addressTextView.text)
    {
        [self.view makeToast:@"请先输入车场地址后保存！"];
        return;
    }
    [self submitInfo];
}

- (void)submitInfo
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableDictionary *paramDic = [[_yardInfo convertToDictionary] mutableCopy];
    [paramDic setValue:@"update" forKey:@"op_type"];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:kLocationKey])
    {
        [paramDic addEntriesFromDictionary:[[NSUserDefaults standardUserDefaults] valueForKey:kLocationKey]];
    }
    [paramDic setValue:_addressTextView.text forKey:@"address"];
    [paramDic setValue:@"" forKey:@"logo"];
    UserInfo *userinfo = [[UserInfo alloc] initWithCacheKey:kUserInfoKey];
    [paramDic setValue:userinfo.car_wash_id forKey:@"car_wash_id"];
    [WebService requestJsonOperationWithParam:paramDic
                                       action:@"carWash/service/manage"
                               normalResponse:^(NSString *status, id data)
     {
         _yardInfo.address = _addressTextView.text;
         [MBProgressHUD hideHUDForView:self.view animated:NO];
         [MBProgressHUD showSuccess:@"修改成功" toView:self.navigationController.view];
         [self.navigationController popViewControllerAnimated:YES];
     }
                            exceptionResponse:^(NSError *error)
     {
         [MBProgressHUD hideHUDForView:self.view animated:NO];
         [self.view makeToast:[[error userInfo] valueForKey:@"msg"]];
     }];
}



- (void)locationAddressWithCLLocation:(CLLocation*)locationGps
{
    
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = locations[0];
    
    CLLocationCoordinate2D adjustLoc;
    if([self isLocationOutOfChina:location.coordinate]){
        adjustLoc = location.coordinate;
    }else{
        double adjustLat = [self transformLatWithX:location.coordinate.longitude - 105.0 withY:location.coordinate.latitude - 35.0];
        double adjustLon = [self transformLonWithX:location.coordinate.longitude - 105.0 withY:location.coordinate.latitude - 35.0];
        double radLat = location.coordinate.latitude / 180.0 * pi;
        double magic = sin(radLat);
        magic = 1 - ee * magic * magic;
        double sqrtMagic = sqrt(magic);
        adjustLat = (adjustLat * 180.0) / ((a * (1 - ee)) / (magic * sqrtMagic) * pi);
        adjustLon = (adjustLon * 180.0) / (a / sqrtMagic * cos(radLat) * pi);
        adjustLoc.latitude = location.coordinate.latitude + adjustLat;
        adjustLoc.longitude = location.coordinate.longitude + adjustLon;
    }
    
    NSDictionary *dic = @{@"latitude": [NSNumber numberWithDouble:adjustLoc.latitude],
                          @"longitude": [NSNumber numberWithDouble:adjustLoc.longitude]};
    
    
    [[NSUserDefaults standardUserDefaults] setObject:dic
                                              forKey:kLocationKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error){
                       
                       for (CLPlacemark *place in placemarks)
                       {
                           NSLog(@"name,%@",place.name);                       // 位置名
                           NSLog(@"thoroughfare,%@",place.thoroughfare);       // 街道
                           NSLog(@"subThoroughfare,%@",place.subThoroughfare); // 子街道
                           NSLog(@"locality,%@",place.locality);               // 市
                           NSLog(@"subLocality,%@",place.subLocality);         // 区
                           NSLog(@"country,%@",place.country);                 // 国家
                           _addressTextView.text = [NSString stringWithFormat:@"%@%@%@%@",
                                                 place.locality,
                                                 place.subLocality,
                                                 place.thoroughfare,
                                                 place.subThoroughfare];
                       }
                       
                   }];
}

- (BOOL)isLocationOutOfChina:(CLLocationCoordinate2D)location
{
    if (location.longitude < 72.004 || location.longitude > 137.8347 || location.latitude < 0.8293 || location.latitude > 55.8271)
        return YES;
    return NO;
}

- (double)transformLatWithX:(double)x withY:(double)y
{
    double lat = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x));
    lat += (20.0 * sin(6.0 * x * pi) + 20.0 *sin(2.0 * x * pi)) * 2.0 / 3.0;
    lat += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0;
    lat += (160.0 * sin(y / 12.0 * pi) + 3320 * sin(y * pi / 30.0)) * 2.0 / 3.0;
    return lat;
}

- (double)transformLonWithX:(double)x withY:(double)y
{
    double lon = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(abs(x));
    lon += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    lon += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0;
    lon += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0;
    return lon;
}

#pragma mark - closeKeyBoard

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self closeKeyBoard];
}

- (void)closeKeyBoard
{
    [[self findFirstResponder:self.view]resignFirstResponder];
}

- (UIView *)findFirstResponder:(UIView*)view
{
    for ( UIView *childView in view.subviews )
    {
        if ([childView respondsToSelector:@selector(isFirstResponder)] && [childView isFirstResponder])
        {
            return childView;
        }
        UIView *result = [self findFirstResponder:childView];
        if (result) return result;
    }
    return nil;
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
