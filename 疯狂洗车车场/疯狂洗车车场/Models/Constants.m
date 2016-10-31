//
//  Constants.m
//  GoHouseApp
//
//  Created by apple on 12-6-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"
#import "WebServiceHelper.h"
#import "Reachability.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/sockio.h>
#include <net/if.h>
#include <errno.h>
#include <net/if_dl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <net/ethernet.h>

#define min(a,b)    ((a) < (b) ? (a) : (b))
#define max(a,b)    ((a) > (b) ? (a) : (b))

#define BUFFERSIZE  4000

#define MAXADDRS    32
char *if_names[MAXADDRS];
char *ip_names[MAXADDRS];
char *hw_addrs[MAXADDRS];
unsigned long ip_addrs[MAXADDRS];

static int   nextAddr = 0;

void InitAddresses()
{
    int i;
    for (i=0; i<MAXADDRS; ++i)
    {
        if_names[i] = ip_names[i] = hw_addrs[i] = NULL;
        ip_addrs[i] = 0;
    }
}

void FreeAddresses()
{
    int i;
    for (i=0; i<MAXADDRS; ++i)
    {
        if (if_names[i] != 0) free(if_names[i]);
        if (ip_names[i] != 0) free(ip_names[i]);
        if (hw_addrs[i] != 0) free(hw_addrs[i]);
        ip_addrs[i] = 0;
    }
    InitAddresses();
}

void GetIPAddresses()
{
    int                 i, len, flags;
    char                buffer[BUFFERSIZE], *ptr, lastname[IFNAMSIZ], *cptr;
    struct ifconf       ifc;
    struct ifreq        *ifr, ifrcopy;
    struct sockaddr_in  *sin;
    
    char temp[80];
    
    int sockfd;
    
    for (i=0; i<MAXADDRS; ++i)
    {
        if_names[i] = ip_names[i] = NULL;
        ip_addrs[i] = 0;
    }
    
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0)
    {
        perror("socket failed");
        return;
    }
    
    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;
    
    if (ioctl(sockfd, SIOCGIFCONF, &ifc) < 0)
    {
        perror("ioctl error");
        return;
    }
    
    lastname[0] = 0;
    
    for (ptr = buffer; ptr < buffer + ifc.ifc_len; )
    {
        ifr = (struct ifreq *)ptr;
        len = max(sizeof(struct sockaddr), ifr->ifr_addr.sa_len);
        ptr += sizeof(ifr->ifr_name) + len;  // for next one in buffer
        
        if (ifr->ifr_addr.sa_family != AF_INET)
        {
            continue;   // ignore if not desired address family
        }
        
        if ((cptr = (char *)strchr(ifr->ifr_name, ':')) != NULL)
        {
            *cptr = 0;      // replace colon will null
        }
        
        if (strncmp(lastname, ifr->ifr_name, IFNAMSIZ) == 0)
        {
            continue;   /* already processed this interface */
        }
        
        memcpy(lastname, ifr->ifr_name, IFNAMSIZ);
        
        ifrcopy = *ifr;
        ioctl(sockfd, SIOCGIFFLAGS, &ifrcopy);
        flags = ifrcopy.ifr_flags;
        if ((flags & IFF_UP) == 0)
        {
            continue;   // ignore if interface not up
        }
        
        if_names[nextAddr] = (char *)malloc(strlen(ifr->ifr_name)+1);
        if (if_names[nextAddr] == NULL)
        {
            return;
        }
        strcpy(if_names[nextAddr], ifr->ifr_name);
        
        sin = (struct sockaddr_in *)&ifr->ifr_addr;
        strcpy(temp, inet_ntoa(sin->sin_addr));
        
        ip_names[nextAddr] = (char *)malloc(strlen(temp)+1);
        if (ip_names[nextAddr] == NULL)
        {
            return;
        }
        strcpy(ip_names[nextAddr], temp);
        
        ip_addrs[nextAddr] = sin->sin_addr.s_addr;
        
        ++nextAddr;
    }
    
    close(sockfd);
}

void GetHWAddresses()
{
    struct ifconf ifc;
    struct ifreq *ifr;
    int i, sockfd;
    char buffer[BUFFERSIZE], *cp, *cplim;
    char temp[80];
    
    for (i=0; i<MAXADDRS; ++i)
    {
        hw_addrs[i] = NULL;
    }
    
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0)
    {
        perror("socket failed");
        return;
    }
    
    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;
    
    if (ioctl(sockfd, SIOCGIFCONF, (char *)&ifc) < 0)
    {
        perror("ioctl error");
        close(sockfd);
        return;
    }
    
    ifr = ifc.ifc_req;
    
    cplim = buffer + ifc.ifc_len;
    
    for (cp=buffer; cp < cplim; )
    {
        ifr = (struct ifreq *)cp;
        if (ifr->ifr_addr.sa_family == AF_LINK)
        {
            struct sockaddr_dl *sdl = (struct sockaddr_dl *)&ifr->ifr_addr;
            int a,b,c,d,e,f;
            int i;
            
            strcpy(temp, (char *)ether_ntoa(LLADDR(sdl)));
            sscanf(temp, "%x:%x:%x:%x:%x:%x", &a, &b, &c, &d, &e, &f);
            sprintf(temp, "%02X:%02X:%02X:%02X:%02X:%02X",a,b,c,d,e,f);
            
            for (i=0; i<MAXADDRS; ++i)
            {
                if ((if_names[i] != NULL) && (strcmp(ifr->ifr_name, if_names[i]) == 0))
                {
                    if (hw_addrs[i] == NULL)
                    {
                        hw_addrs[i] = (char *)malloc(strlen(temp)+1);
                        strcpy(hw_addrs[i], temp);
                        break;
                    }
                }
            }
        }
        cp += sizeof(ifr->ifr_name) + max(sizeof(ifr->ifr_addr), ifr->ifr_addr.sa_len);
    }
    
    close(sockfd);
}



const NSString * KWebviewReload = @"webviewReload";


NSString *const kForceExitNotifaction = @"kForceExitNotifaction";
NSString *const kLoginSuccessNotifaction = @"kLoginSuccessNotifaction";
NSString *const kLogoutSuccessNotifaction = @"kLogoutSuccessNotifaction";
NSString *const kPaySuccessNotification = @"kPaySuccessNotification";

NSString *const kCustomLaunch = @"CustomLaunch";

NSString *const kStartInfoKey = @"StartInfo";

NSString *const kDeviceToken = @"DeviceToken";

//微博

NSString *const kWeiboAppKey = @"730978518";
NSString *const kWeiboAppSecret = @"bd075eed15fc0ae88f52f9490655baf5";

//微信

NSString *const kWeixinAppKey = @"wx76540b111d9e400f";
NSString *const kWeixinAppSecret= @"6dc649501c42c01b67d6c761ea27b3d6";

//QQ

NSString *const kQQAppKey = @"1103440101";
NSString *const kQQAppSecret = @"7H5qsTdoamvlyFmR";

NSString *const kShareSDKAppKey = @"585a85027456";

NSString *const kAutoLogin = @"AutoLogin";

NSString *const kLoginToken = @"token";

NSString *const kUserInfoKey = @"UserInfo";

NSString *const kDownloadUrl = @"https://itunes.apple.com/cn/app/feng-kuang-xi-che/id899405519?mt=8";

NSString *const kLocationKey = @"LocationKey";

NSString *const kShouldUpdateList = @"ShouldUpdateList";

NSString *const kAppDomainUrl = @"AppDomainUrl";

NSString *const kSpareAppDomainUrl = @"SpareAppDomainUrl";




@implementation Constants

+ (UIAlertView *)showMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil];
    [alertView show];
    return  alertView;
}


- (NSString*)getPlist:(NSString *) key
{
    NSArray *myPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *myDocPath = [myPaths objectAtIndex:0];
    NSString *filename = [myDocPath stringByAppendingPathComponent:@"properties.plist"];
    NSDictionary *dict = [[NSDictionary alloc]initWithContentsOfFile:filename];
    return [dict objectForKey: key] ;
}

- (void)setPlist:(NSString *)key andValue:(NSString*)value
{
    NSArray *myPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *myDocPath = [myPaths objectAtIndex:0];
    NSString *filename = [myDocPath stringByAppendingPathComponent:@"properties.plist"];
    NSDictionary *dict = [[NSDictionary alloc]initWithContentsOfFile:filename];
    [dict setValue:value forKey:key];
    [dict writeToFile:filename atomically:YES];
}

- (BOOL)netWork
{
    Reachability *r = [Reachability reachabilityWithHostName:[self getPlist:@"checkNet"]];
    switch ([r currentReachabilityStatus])
    {
        case NotReachable:
            // 没有网络连接
            NSLog(@"没有网络");
            return YES;
        case ReachableViaWWAN:
            // 使用3G网络
            NSLog(@"正在使用3G网络");
            break;
        case ReachableViaWiFi:
            // 使用WiFi网络
            NSLog(@"正在使用wifi网络");
            break;
    }
    return NO;
}

+ (void)showMessage:(NSString *)message
           delegate:(id)delegate
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                        message:message
                                                       delegate:delegate
                                              cancelButtonTitle:@"好的"
                                              otherButtonTitles:nil];
    [alertView show];
}

+ (void)showMessage:(NSString *)message
           delegate:(id)delegate
                tag:(int)tag
       buttonTitles:(NSString *)otherButtonTitles, ...
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                        message:message
                                                       delegate:delegate
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
    va_list args;
    va_start(args, otherButtonTitles);
    for (NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString*))
    {
        [alertView addButtonWithTitle:arg];
    }
    va_end(args);
    [alertView show];
    alertView.tag = tag;
}

+ (NSString *)deviceIPAdress
{
    InitAddresses();
    GetIPAddresses();
    GetHWAddresses();
    
    return [NSString stringWithFormat:@"%s", ip_names[5]];
}

+ (NSString *)devicePublicIPAdress
{
    //http://20140507.ip138.com/ic.asp
    //http://int.dpool.sina.com.cn/iplookup/iplookup.php?format=js
    NSError *error = nil;
    NSString *ipString = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://20140507.ip138.com/ic.asp"]
                                                  encoding:NSUTF8StringEncoding
                                                     error:&error];
    if (error)
    {
        return nil;
    }
    return ipString;
}

+ (BOOL)canMakePhoneCall
{
    NSString *deviceType = [UIDevice currentDevice].model;
    return  !([deviceType  isEqualToString:@"iPod touch"]||
              [deviceType  isEqualToString:@"iPad"]||
              [deviceType  isEqualToString:@"iPhone Simulator"]);
}

- (void)showAlter:(NSString*)msg
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"提示"
                          message:msg
                          delegate:self
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil];
    [alert show];
}

- (NSUInteger)indexOf:(NSString*)str1 msg:(NSString*)str2{
    NSRange range = [str1 rangeOfString:str2];
    return range.length;
}

- (NSString *)getNowTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    return [formatter stringFromDate:[NSDate date]];
}


- (NSString*)sbjson:(NSDictionary*)dic msg:(NSString*)key
{
    @try
    {
        if([dic objectForKey:key])
        {
            return [dic objectForKey:key];
        }
        else
        {
            return @"";
        }
    }
    @catch (NSException *exception)
    {
        return @"";
    }
}

+ (NSString *)distanceBetweenOrderBy:(double)lat1
                                :(double)lat2
                                :(double)lng1
                                :(double)lng2
{
    double dd = M_PI/180;
    double x1=lat1*dd,x2=lat2*dd;
    double y1=lng1*dd,y2=lng2*dd;
    double R = 6371004;
    double distance = (2*R*asin(sqrt(2-2*cos(x1)*cos(x2)*cos(y1-y2) - 2*sin(x1)*sin(x2))/2));
    if (distance > 1000)
    {
        return  [NSString stringWithFormat:@"%.2f千米", distance*1000];
    }
    //km  返回
    //     return  distance*1000;
    
    //返回 m
    return   [NSString stringWithFormat:@"%f米", distance];
    
}

+(NSString *)LantitudeLongitudeDist:(double)lon1
                          other_Lat:(double)lat1
                           self_Lon:(double)lon2
                           self_Lat:(double)lat2
{
    double er = 6378137; // 6378700.0f;
    //ave. radius = 6371.315 (someone said more accurate is 6366.707)
    //equatorial radius = 6378.388
    //nautical mile = 1.15078
    double radlat1 = M_PI*lat1/180.0f;
    double radlat2 = M_PI*lat2/180.0f;
    //now long.
    double radlong1 = M_PI*lon1/180.0f;
    double radlong2 = M_PI*lon2/180.0f;
    if( radlat1 < 0 ) radlat1 = M_PI/2 + fabs(radlat1);// south
    if( radlat1 > 0 ) radlat1 = M_PI/2 - fabs(radlat1);// north
    if( radlong1 < 0 ) radlong1 = M_PI*2 - fabs(radlong1);//west
    if( radlat2 < 0 ) radlat2 = M_PI/2 + fabs(radlat2);// south
    if( radlat2 > 0 ) radlat2 = M_PI/2 - fabs(radlat2);// north
    if( radlong2 < 0 ) radlong2 = M_PI*2 - fabs(radlong2);// west
    //spherical coordinates x=r*cos(ag)sin(at), y=r*sin(ag)*sin(at), z=r*cos(at)
    //zero ag is up so reverse lat
    double x1 = er * cos(radlong1) * sin(radlat1);
    double y1 = er * sin(radlong1) * sin(radlat1);
    double z1 = er * cos(radlat1);
    double x2 = er * cos(radlong2) * sin(radlat2);
    double y2 = er * sin(radlong2) * sin(radlat2);
    double z2 = er * cos(radlat2);
    double d = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)+(z1-z2)*(z1-z2));
    //side, side, side, law of cosines and arccos
    double theta = acos((er*er+er*er-d*d)/(2*er*er));
    double dist  = theta*er;
    if (dist > 1000)
    {
        return  [NSString stringWithFormat:@"%.2f千米", dist*1000];
    }
    //km  返回
    //     return  distance*1000;
    
    //返回 m
    return   [NSString stringWithFormat:@"%f米", dist];
}

+ (NSString*)getCrazyCarWashImageDirestory
{
    NSArray *libraryPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *imageDirectory = [libraryPaths objectAtIndex:0];
    NSString *resultDirectory = [imageDirectory stringByAppendingFormat:@"/CrazyCarWashImages"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:resultDirectory ])
    {
        [fileManager createDirectoryAtPath:resultDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return resultDirectory;
}


@end
