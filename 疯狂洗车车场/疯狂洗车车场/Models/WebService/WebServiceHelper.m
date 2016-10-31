//
//  WebServiceHelper.m
//  康吴康
//
//  Created by 龚杰洪 on 14/12/26.
//  Copyright (c) 2014年 龚杰洪. All rights reserved.
//

#import "WebServiceHelper.h"
#import "AFNetworking.h"


#define MAIN_SERVECE_BASE_STR @"http://118.123.249.69:8080/"

//#define MAIN_SERVECE_BASE_STR @"http://118.123.249.69:8081/" //测试用正式服

//#define MAIN_SERVECE_BASE_STR @"http://118.123.249.87:8080/"

@implementation WebServiceHelper

+ (id)sharedWebServiceHelper
{
    static WebServiceHelper *webServiceHandler = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{webServiceHandler = [[WebServiceHelper alloc] initSingleton];});
    
    return webServiceHandler;
}

- (id)init
{
    NSAssert(NO, @"Cannot create instance of Singleton");
    
    return nil;
}

- (id)initSingleton
{
    self = [super init];
    
    if (self != nil)
    {
    }
    
    return self;
}




- (void)getAvailableUrlFromeServiceResponse:(void(^)(void))normalResponse
                          exceptionResponse:(void(^)(void))exceptionResponse;
{
    if (_availableUrlString == nil || [_availableUrlString isEqualToString:@""])
    {
        _availableUrlString = MAIN_SERVECE_BASE_STR;
        normalResponse();
        return;
    }
    else
    {
        normalResponse();
        return;
    }
}


#pragma marl - 切回出场服务器

- (void)changeDomainUrlToDefault
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAppDomainUrl];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSpareAppDomainUrl];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _doaminUrlCheckOver = YES;
    _availableUrlString = MAIN_SERVECE_BASE_STR;
}



- (void)requestJsonOperationWithInfo:(NSDictionary *)info
                         serviceType:(NSString *)serviceType
                              action:(NSString *)action
                      normalResponse:(void(^)(NSString *status, id data))normalResponse
                   exceptionResponse:(void(^)(NSError *error))exceptionResponse
{
    
    [self getAvailableUrlFromeServiceResponse:^{
        NSString *requestStr = [NSString stringWithFormat:@"%@%@", _availableUrlString, action];
        
        NSMutableDictionary *infoWithLoginToken = [NSMutableDictionary dictionaryWithDictionary:info];
        //
        NSString *loginToken = [[NSUserDefaults standardUserDefaults] objectForKey:kLoginToken];
        if (loginToken != nil)
        {
            [infoWithLoginToken setObject:loginToken
                                   forKey:kLoginToken];
        }
        
        
        NSMutableURLRequest *request = nil;
        request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST"
                                                                URLString:requestStr
                                                               parameters:infoWithLoginToken
                                                                    error:nil];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                    completionHandler:
                                          ^(NSData *data, NSURLResponse *response, NSError *error)
                                          {
                                              if (error == nil)
                                              {
                                                  
                                                  NSError *jsonError = nil;
                                                  NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                                                  NSData * ndata = [receiveStr dataUsingEncoding:NSUTF8StringEncoding];
                                                  NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:ndata
                                                                                                           options:NSJSONReadingMutableContainers
                                                                                                             error:&jsonError];
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      if ([jsonDict valueForKey:@"state"])
                                                      {
                                                          if ([[jsonDict valueForKey:@"state"] intValue] == 1)
                                                          {
                                                              normalResponse([jsonDict valueForKey:@"state"], [jsonDict valueForKey:@"data"]);
                                                              return ;
                                                          }
                                                          else
                                                          {
                                                              NSError *exceptionError  = [[NSError alloc] initWithDomain:[jsonDict valueForKey:@"msg"] code:0 userInfo:jsonDict];
                                                              exceptionResponse(exceptionError);
                                                              return ;
                                                          }
                                                      }
                                                  });
                                              }
                                              else
                                              {
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      NSError *error = [[NSError alloc] initWithDomain:@"服务器无法连接，请稍后再试"
                                                                                                  code:0
                                                                                              userInfo:nil];
                                                      exceptionResponse(error);
                                                      return;
                                                  });
                                                  
                                              }
                                          }];
        // 使用resume方法启动任务
        [dataTask resume];
    } exceptionResponse:^{
       NSError *error = [[NSError alloc] initWithDomain:@"服务器无法连接，请稍后再试" code:0 userInfo:nil];

        exceptionResponse(error);
    }];
   }

- (void)requestJsonOperationWithModel:(NSDictionary *)param
                               action:(NSString *)action
                       normalResponse:(void(^)(NSString *status, id data))normalResponse
                    exceptionResponse:(void(^)(NSError *error))exceptionResponse;
{
    [self requestJsonOperationWithInfo:param
                           serviceType:@""
                                action:action
                        normalResponse:^(NSString *status, id data)
     {
         normalResponse(status, data);
     }
                     exceptionResponse:^(NSError *error)
     {
         exceptionResponse(error);
     }];
}

- (void)requestJsonModelWithParam:(NSDictionary *)param
                           action:(NSString *)action
                       modelClass:(Class)modelClass
                   normalResponse:(void(^)(NSString *status, id data, JsonBaseModel *model))normalResponse
                exceptionResponse:(void(^)(NSError *error))exceptionResponse
{
    [self requestJsonOperationWithInfo:param
                           serviceType:@""
                                action:action
                        normalResponse:^(NSString *status, id data)
     {
         if (data)
         {
             normalResponse(status, data, [[modelClass alloc] initWithDictionary:data]);
         }
         else
         {
             exceptionResponse([NSError errorWithDomain:@""
                                                   code:0
                                               userInfo:@{@"data": @"服务器数据为空！"}]);
         }
     }
                     exceptionResponse:^(NSError *error)
     {
         exceptionResponse(error);
     }];
}

- (void)requestJsonArrayOperationWithParam:(NSDictionary *)param
                                    action:(NSString *)action
                                modelClass:(Class)modelClass
                            normalResponse:(void(^)(NSString *status, id data, NSMutableArray *array))normalResponse
                         exceptionResponse:(void(^)(NSError *error))exceptionResponse
{
    [self requestJsonOperationWithInfo:param
                           serviceType:@""
                                action:action
                        normalResponse:^(NSString *status, id data)
     {
         if ([data isKindOfClass:[NSArray class]])
         {
             NSMutableArray *returnArr = [NSMutableArray array];
             for (id dic in data)
             {
                 [returnArr addObject:[[modelClass alloc] initWithDictionary:dic]];
             }
             normalResponse(status, data, returnArr);
         }
         else
         {
             normalResponse(status, data, [@[] mutableCopy]);
         }
     }
                     exceptionResponse:^(NSError *error)
     {
         exceptionResponse(error);
     }];
}

- (void)requestJsonOperationWithParam:(NSDictionary *)param
                               action:(NSString *)action
                       normalResponse:(void(^)(NSString *status, id data))normalResponse
                    exceptionResponse:(void(^)(NSError *error))exceptionResponse
{
    [self requestJsonOperationWithInfo:param
                           serviceType:@""
                                action:action
                        normalResponse:^(NSString *status, id data)
     {
         normalResponse(status, data);
     }
                     exceptionResponse:^(NSError *error)
     {
         exceptionResponse(error);
     }];
}

- (void)uploadImageWithParam:(NSDictionary *)param
                      action:(NSString *)action
                  imageDatas:(NSArray *)imageDatas
                    imageKey:(NSString *)imageKey
              normalResponse:(void (^)(NSString *status, id data))normalResponse
           exceptionResponse:(void (^)(NSError *error))exceptionRespons
{
    if (_availableUrlString == nil || [_availableUrlString isEqualToString:@""])
    {
        _availableUrlString = MAIN_SERVECE_BASE_STR;
    }
    NSString *requestStr = [NSString stringWithFormat:@"%@%@?", _availableUrlString, action];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:requestStr
       parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData)
     {
         for (int x = 0; x<imageDatas.count; x++)
         {
             NSData * imageData = imageDatas[x];
             UIImage *uploadImage = [UIImage imageWithData:imageData];
             NSUInteger sizeOriginKB = [imageData length]/1000;
             if (sizeOriginKB > 120)
             {
                 float a = 120.00;
                 float b = (float)sizeOriginKB;
                 float q = sqrtf(a / b);
                 
                 CGSize sizeImage = uploadImage.size;
                 CGFloat widthSmall = sizeImage.width * q;
                 CGFloat heighSmall = sizeImage.height * q;
                 CGSize sizeImageSmall = CGSizeMake(widthSmall, heighSmall);
                 
                 UIGraphicsBeginImageContext(sizeImageSmall);
                 CGRect smallImageRect = CGRectMake(0, 0, sizeImageSmall.width, sizeImageSmall.height);
                 [uploadImage drawInRect:smallImageRect];
                 UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
                 UIGraphicsEndImageContext();
                 
                 imageData = UIImagePNGRepresentation(smallImage);
                 
             }
             [formData appendPartWithFileData:imageData
                                         name:[NSString stringWithFormat:@"imageKey%d",x+1]
                                     fileName:@"jpg"
                                     mimeType:@"image/jpeg"];
         }
         
     }
         progress:^(NSProgress * _Nonnull uploadProgress)
     {
         NSLog(@"%f",uploadProgress.fractionCompleted);
     }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         
         if ([responseObject valueForKey:@"state"])
         {
             if ([[responseObject valueForKey:@"state"] integerValue] == 1)
             {
                 normalResponse([responseObject valueForKey:@"state"], [responseObject valueForKey:@"data"]);
             }
             else
             {
                 NSError  *exceptionError = [[NSError alloc] initWithDomain:@"" code:0 userInfo:responseObject];
                 exceptionRespons(exceptionError);
             }
         }
         
     }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         exceptionRespons(error);
         return;
     }];

}

- (void)uploadImageWithParam:(NSDictionary *)param
                      action:(NSString *)action
                   imagePath:(NSString *)imagePath
                    imageKey:(NSString *)imageKey
              normalResponse:(void(^)(NSString *status, id data))normalResponse
           exceptionResponse:(void(^)(NSError *error))exceptionRespons
{
    [self uploadFileWithInfo:param
                 serviceType:@""
                      action:action
                    filePath:imagePath
                     fileKey:imageKey
              normalResponse:^(NSString *status, id data)
     {
         normalResponse(status, data);
     }
           exceptionResponse:^(NSError *error)
     {
         exceptionRespons(error);
     }];
}

- (void)uploadFileWithInfo:(NSDictionary *)info
               serviceType:(NSString *)serviceType
                    action:(NSString *)action
                  filePath:(NSString *)filePath
                   fileKey:(NSString *)fileKey
            normalResponse:(void(^)(NSString *status, id data))normalResponse
         exceptionResponse:(void(^)(NSError *error))exceptionResponse
{
    if (_availableUrlString == nil || [_availableUrlString isEqualToString:@""])
    {
        _availableUrlString = MAIN_SERVECE_BASE_STR;
    }
    NSString *requestStr = [NSString stringWithFormat:@"%@%@?", _availableUrlString, action];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:requestStr
       parameters:info constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData)
     {
         
         [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:fileKey error:nil];
     }
         progress:^(NSProgress * _Nonnull uploadProgress)
     {
         NSLog(@"%f",uploadProgress.fractionCompleted);
     }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         
         if ([responseObject valueForKey:@"state"])
         {
             if ([[responseObject valueForKey:@"state"] integerValue] == 1)
             {
                 normalResponse([responseObject valueForKey:@"state"], [responseObject valueForKey:@"data"]);
             }
             else
             {
                 NSError  *exceptionError = [[NSError alloc] initWithDomain:@"" code:0 userInfo:responseObject];
                 exceptionResponse(exceptionError);
             }
         }
         
     }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         exceptionResponse(error);
         return;
     }];
}

- (void)downloadImageFromServiceWithUrl:(NSString*)targetUrl
                                forName:(NSString*)imageName
                           andMediaType:(NSString*)mediaType
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:targetUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSString *imageDirectory = [Constants getCrazyCarWashImageDirestory];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request
                                                                     progress:nil
                                                                  destination:^NSURL *(NSURL *targetPath, NSURLResponse *response)
                                              {
                                                  NSString *path = nil;
                                                  path = [NSString stringWithFormat:@"%@/%@",imageDirectory,imageName];
                                                  
                                                  return [NSURL fileURLWithPath:path];
                                              }
                                                            completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error)
                                              {
                                                  NSLog(@"File downloaded to: %@", filePath);
                                                  if (error == nil)
                                                  {
                                                      if ([imageName isEqualToString:kCustomLaunch])
                                                      {
                                                          [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kCustomLaunch];
                                                          [[NSUserDefaults standardUserDefaults] synchronize];
                                                      }
                                                  }
                                                  else
                                                  {
                                                      NSLog(@"%@图片下载完成",imageName);
                                                      if ([imageName isEqualToString:kCustomLaunch])
                                                      {
                                                          [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kCustomLaunch];
                                                          [[NSUserDefaults standardUserDefaults] synchronize];
                                                      }
                                                      
                                                  }
                                              }];
    [downloadTask resume];
}



@end
