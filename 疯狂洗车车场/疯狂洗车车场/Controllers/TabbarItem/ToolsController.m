//
//  ToolsController.m
//  美车帮车场
//
//  Created by 龚杰洪 on 15/1/31.
//  Copyright (c) 2015年 龚杰洪. All rights reserved.
//

#import "ToolsController.h"
#import "YardAddressController.h"
#import "YardNameController.h"
#import "YardPhoneController.h"
#import "YardSummaryController.h"
#import "WebServiceHelper.h"
#import "MBProgressHUD+Add.h"
#import "UIImageView+WebCache.h"
#import "UIView+Toast.h"
#import "YardOperateController.h"
#import "WashYardImageViewController.h"
#import "UploadImageModel.h"

@interface ToolsController ()<UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIActionSheetDelegate,WashYardImageDelegate>
{
    NSMutableDictionary *_infoDic;
    CarWashModel        *_carWashInfo;
    NSString            *_logoPath;
}

@end

@implementation ToolsController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"功能"];
    
    [self obtainYardInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 获取和刷新数据

- (void)obtainYardInfo
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [WebService requestJsonModelWithParam:@{@"car_wash_id": _userInfo.car_wash_id}
                                   action:@"carWash/service/detail"
                               modelClass:[CarWashModel class]
                           normalResponse:^(NSString *status, id data, JsonBaseModel *model)
     {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         _carWashInfo = (CarWashModel *)model;
         _infoDic = [[_carWashInfo convertToDictionary] mutableCopy];
         [self refreshInfo];
     }
                        exceptionResponse:^(NSError *error)
     {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_carWashInfo)
    {
        [self refreshInfo];
    }
}

- (void)refreshInfo
{
    if (_carWashInfo)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.view.userInteractionEnabled = NO;
        [self getCarWashImageListFromService];
        [_yardNameLabel setText:_carWashInfo.name];
        [_yardAddressLabel setText:_carWashInfo.address];
        [_yardContactPhoneLabel setText:_carWashInfo.phone];
        [_yardSummaryLabel setText:_carWashInfo.introduction];
        [_jiaochaPriceLabel setText:[NSString stringWithFormat:@"%@元", _carWashInfo.car_agreement_price]];
        [_suvPriceLabel setText:[NSString stringWithFormat:@"%@元", _carWashInfo.suv_agreement_price]];
        _operateTimeBtn.selected = _carWashInfo.if_opening.intValue > 0?YES:NO;
        [_operateTimeBtn setTitle:[NSString stringWithFormat:@"%@-%@", _carWashInfo.business_hours_from == nil?@"8:00":_carWashInfo.business_hours_from, _carWashInfo.business_hours_to == nil?@"20:00":_carWashInfo.business_hours_to]
                         forState:UIControlStateNormal];
        [_isOperatedSwitch setOn:[_carWashInfo.if_opening boolValue]];
    }
}

- (void)getCarWashImageListFromService
{
    if (_carWashInfo)
    {
        NSDictionary *submitDic = @{@"car_wash_id":_carWashInfo.car_wash_id};
        [WebService requestJsonArrayOperationWithParam:submitDic
                                                action:@"carWash/service/photolist"
                                            modelClass:[UploadImageModel class]
                                        normalResponse:^(NSString *status, id data, NSMutableArray *array)
        {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            self.view.userInteractionEnabled = YES;
            if (array.count > 0)
            {
                _carWashInfo.imageArray = [array mutableCopy];
                for (int x = 0;x<_carWashInfo.imageArray.count ; x++)
                {
                    UploadImageModel *model = _carWashInfo.imageArray[x];
                    if (model.is_top.intValue > 0)
                    {
                        [_yardImageView sd_setImageWithURL:[NSURL URLWithString:model.photo_addr]
                                          placeholderImage:[UIImage imageNamed:@"car_wash_list_default_image"]];
                        break;
                    }
                }
                _imageCountLabel.text = [NSString stringWithFormat:@"共%d张",(int)_carWashInfo.imageArray.count];
            }
            else
            {
                [_carWashInfo.imageArray removeAllObjects];
                [_yardImageView setImage:[UIImage imageNamed:@"car_wash_list_default_image"]];
                _imageCountLabel.text = [NSString stringWithFormat:@"共0张"];

            }
        }
                                     exceptionResponse:^(NSError *error) {
                                         [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                                         self.view.userInteractionEnabled = YES;
                                         [_carWashInfo.imageArray removeAllObjects];
                                         [_yardImageView setImage:[UIImage imageNamed:@"car_wash_list_default_image"]];
                                         _imageCountLabel.text = [NSString stringWithFormat:@"共0张"];
                                         
        }];
    }
    else
    {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        self.view.userInteractionEnabled = YES;
    }
}

#pragma mark - 修改数据

- (IBAction)changeYardImage:(UIButton *)sender
{
    NSLog(@"%@",_carWashInfo.photo_addrs);
    
    WashYardImageViewController *viewController = [[WashYardImageViewController alloc] initWithNibName:@"WashYardImageViewController"
                                                                                                bundle:nil];
    viewController.delegate = self;
    if (_carWashInfo.imageArray.count > 0)
    {
        viewController.uploadImageArray = _carWashInfo.imageArray;
    }
    [self.navigationController pushViewController:viewController animated:YES];

//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择来源"
//                                                             delegate:self
//                                                    cancelButtonTitle:@"取消"
//                                               destructiveButtonTitle:nil
//                                                    otherButtonTitles:@"相机拍摄",@"相册选择" , nil];
//    actionSheet.tag = 100;
//    [actionSheet showInView:self.view];
}

- (IBAction)editYardName:(UIButton *)sender
{
    YardNameController *controller = ALLOC_WITH_CLASSNAME(@"YardNameController");
    controller.yardInfo = _carWashInfo;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)editYardAddress:(id)sender
{
    YardAddressController *controller = ALLOC_WITH_CLASSNAME(@"YardAddressController");
    controller.yardInfo = _carWashInfo;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)editYardPhone:(id)sender
{
    YardPhoneController *controller = ALLOC_WITH_CLASSNAME(@"YardPhoneController");
    controller.yardInfo = _carWashInfo;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)editYardSummary:(id)sender
{
    YardSummaryController *controller = ALLOC_WITH_CLASSNAME(@"YardSummaryController");
    controller.yardInfo = _carWashInfo;
    [self.navigationController pushViewController:controller animated:YES];
}



- (IBAction)_editYardOperateTime:(id)sender
{
    YardOperateController *controller = ALLOC_WITH_CLASSNAME(@"YardOperateController");
    controller.yardInfo = _carWashInfo;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)didEditYardPriceButtonTouch:(id)sender
{
    
}

- (IBAction)isBusiness:(UISwitch *)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _carWashInfo.if_opening = [NSString stringWithFormat:@"%d", sender.isOn];
    NSMutableDictionary *paramDic = [[_carWashInfo convertToDictionary] mutableCopy];
    [paramDic setValue:@"update" forKey:@"op_type"];
    [WebService requestJsonOperationWithParam:paramDic
                                       action:@"carWash/service/manage"
                               normalResponse:^(NSString *status, id data)
     {
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

#pragma mark - 选择图片来源

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag)
    {
        case 100:
        {
            switch (buttonIndex)
            {
                case 0:
                {
                    [self chooseFromCarama:nil];

                }
                    break;
                case 1:
                {
                    [self chooseFromAlbum:nil];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - 摄像头选择图片

- (IBAction)chooseFromCarama:(id)sender
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = sourceType;
    picker.allowsEditing = YES;
    [self presentViewController:picker
                       animated:YES
                     completion:^{}];
}

#pragma mark - 相册选择图片

- (IBAction)chooseFromAlbum:(id)sender
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = sourceType;
    picker.allowsEditing = YES;
    [self presentViewController:picker
                       animated:YES
                     completion:^{}];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES
                               completion:^{}];
    
    if ([[info valueForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"])
    {
        NSString *filename = [self createUpFileName];
        UIImage *tmpImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        NSString *documentsDirectory =  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        
        NSString *imageName = [NSString stringWithFormat:@"%@.jpg",filename];
        NSString *filepath = [documentsDirectory stringByAppendingPathComponent:imageName];
        if([UIImageJPEGRepresentation(tmpImage, 0.3) writeToFile:filepath
                                                      atomically:YES])
        {
            _logoPath = filepath;
            [self uploadImage];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES
                               completion:^{}];
}

-  (NSString*)createUpFileName
{
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSUInteger unitFlags  = NSYearCalendarUnit|
    NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSHourCalendarUnit |
    NSMinuteCalendarUnit |
    kCFCalendarUnitSecond;
    
    NSDateComponents* dayComponents = [calendar components:(unitFlags) fromDate:date];
    NSUInteger year = [dayComponents year];
    NSUInteger month =  [dayComponents month];
    NSUInteger day =  [dayComponents day];
    NSInteger hour =  [dayComponents hour];
    NSInteger minute =  [dayComponents minute];
    double second = [dayComponents second];
    
    NSString *strMonth;
    NSString *strDay;
    NSString *strHour;
    NSString *strMinute;
    NSString *strSecond;
    if (month < 10) {
        strMonth = [NSString stringWithFormat:@"0%lu",(unsigned long)month];
    }
    else {
        strMonth = [NSString stringWithFormat:@"%lu",(unsigned long)month];
    }
    //NSLog(@"%@",strMonth.description);
    if (day < 10) {
        strDay = [NSString stringWithFormat:@"0%lu",(unsigned long)day];
    }
    else {
        strDay = [NSString stringWithFormat:@"%lu",(unsigned long)day];
    }
    
    if (hour < 10) {
        strHour = [NSString stringWithFormat:@"0%ld",(long)hour];
    }
    else {
        strHour = [NSString stringWithFormat:@"%ld",(long)hour];
    }
    
    if (minute < 10) {
        strMinute = [NSString stringWithFormat:@"0%ld",(long)minute];
    }
    else {
        strMinute = [NSString stringWithFormat:@"%ld",(long)minute];
    }
    
    if (second < 10) {
        strSecond = [NSString stringWithFormat:@"0%0.f",second];
    }
    else {
        strSecond = [NSString stringWithFormat:@"%0.f",second];
    }
    
    
    NSString *str = [NSString stringWithFormat:@"%ld%@%@%@%@%@%@",
                     (unsigned long)year,strMonth,strDay,strHour,strMinute,strSecond,[self myUUID]];
    
    NSLog(@"%@",[self myUUID]);
    
    return str;
}

- (NSString*) myUUID
{
    CFUUIDRef newUniqueID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef newUniqueIDString = CFUUIDCreateString(kCFAllocatorDefault, newUniqueID);
    NSString *guid = (__bridge NSString *)newUniqueIDString;
    CFRelease(newUniqueIDString);
    CFRelease(newUniqueID);
    return([guid lowercaseString]);
}

#pragma mark - 上传图片

- (void)uploadImage
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [WebService uploadImageWithParam:@{}
                              action:@"upload/service/photo"
                           imagePath:_logoPath
                            imageKey:[_logoPath lastPathComponent]
                      normalResponse:^(NSString *status, id data)
     {
         NSMutableDictionary *paramDic = [[_carWashInfo convertToDictionary] mutableCopy];
         [paramDic setValue:[data valueForKey:@"photoAddrs"] forKey:@"logo"];
         [paramDic setValue:@"update" forKey:@"op_type"];
         [WebService requestJsonOperationWithParam:paramDic
                                            action:@"carWash/service/manage"
                                    normalResponse:^(NSString *status, id data)
          {
              _carWashInfo.logo = [paramDic valueForKey:@"logo"];
              [self refreshInfo];
              _infoDic = [[_carWashInfo convertToDictionary] mutableCopy];
              [self.view makeToast:@"数据更新成功！"];
              [MBProgressHUD hideHUDForView:self.view animated:YES];
          }
                                 exceptionResponse:^(NSError *error)
          {
              [self.view makeToast:@"数据更新失败！"];
              [MBProgressHUD hideHUDForView:self.view animated:YES];
          }];
     }
                   exceptionResponse:^(NSError *error)
     {
         [self.view makeToast:@"上传图片失败！"];
         [MBProgressHUD hideHUDForView:self.view animated:YES];
     }];
}


@end
