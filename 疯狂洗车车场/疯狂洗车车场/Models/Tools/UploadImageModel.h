//
//  UploadImageModel.h
//  
//
//  Created by cts on 15/8/25.
//
//

#import "JsonBaseModel.h"

@interface UploadImageModel : JsonBaseModel

@property (strong, nonatomic) NSString *photo_id;

@property (strong, nonatomic) NSString *photo_type;

@property (strong, nonatomic) NSString *photo_addr;

@property (strong, nonatomic) NSString *is_top;



@end
