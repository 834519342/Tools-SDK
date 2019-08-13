//
//  TJDeviceInfo.m
//  TJTools
//
//  Created by LM on 2019/8/12.
//  Copyright © 2019 TJ. All rights reserved.
//

#import "TJDeviceInfo.h"
#import <sys/utsname.h>  // 获取设备机型
#import <UIKit/UIKit.h>  // 获取系统版本
#import "TJKeychain.h"  // 保存UUID
#import <AdSupport/AdSupport.h>  // 获取IDFA
#import "Reachability/Reachability.h"  // 获取网络状态
#import <CoreTelephony/CTCarrier.h>  // 获取网络运营商
#import <CoreTelephony/CTTelephonyNetworkInfo.h>  // 获取网络运营商

@interface TJDeviceInfo ()

@end

static TJDeviceInfo *deviceManager;
@implementation TJDeviceInfo

+ (instancetype)shareInstance
{
    if (deviceManager == nil) {
        deviceManager = [[TJDeviceInfo alloc] init];
    }
    return deviceManager;
}

- (void)getDeviceInfoDic:(void (^)(NSDictionary * _Nonnull))result
{
    if (result) {
        result(@{
                 @"DeviceType": [self getDeviceType],
                 @"SystemVersion": [self getSystemVersion],
                 @"UDID": [self getUDID],
                 @"IDFA": [self getIDFA],
                 @"NetWorkType": [self getNetWorkType],
                 @"System": @"iOS",
                 @"Channel": @"App Store",
                 @"BundleName": [self getBundleName],
                 @"NetWorkOperator": [self getNetworkOperator],
                 @"SDKVersion": @"1.0.0"
                 });
    }
}

- (NSString *)getDeviceType
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    // iPhone机型
    if ([deviceString isEqualToString:@"iPhone5,1"] || [deviceString isEqualToString:@"iPhone5,2"])
        return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"] || [deviceString isEqualToString:@"iPhone5,4"])
        return @"iPhone 5c";
    if ([deviceString isEqualToString:@"iPhone6,1"] || [deviceString isEqualToString:@"iPhone6,2"])
        return @"iPhone 5s";
    if ([deviceString isEqualToString:@"iPhone7,2"])
        return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone7,1"])
        return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone8,1"])
        return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])
        return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])
        return @"iPhone SE";
    if ([deviceString isEqualToString:@"iPhone9,1"] || [deviceString isEqualToString:@"iPhone9,3"])
        return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"] || [deviceString isEqualToString:@"iPhone9,4"])
        return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone10,1"] || [deviceString isEqualToString:@"iPhone10,4"])
        return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,2"] || [deviceString isEqualToString:@"iPhone10,5"])
        return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,3"] || [deviceString isEqualToString:@"iPhone10,6"])
        return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone11,8"])
        return @"iPhone XR";
    if ([deviceString isEqualToString:@"iPhone11,2"])
        return @"iPhone XS";
    if ([deviceString isEqualToString:@"iPhone11,6"])
        return @"iPhone XS Max";
    
    // iPad机型
    if ([deviceString isEqualToString:@"iPad1,1"])
        return @"iPad";
    if ([deviceString isEqualToString:@"iPad2,1"] || [deviceString isEqualToString:@"iPad2,2"] || [deviceString isEqualToString:@"iPad2,3"] || [deviceString isEqualToString:@"iPad2,4"])
        return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad3,1"] || [deviceString isEqualToString:@"iPad3,2"] || [deviceString isEqualToString:@"iPad3,3"])
        return @"iPad (3rd generation)";
    if ([deviceString isEqualToString:@"iPad3,4"] || [deviceString isEqualToString:@"iPad3,5"] || [deviceString isEqualToString:@"iPad3,6"])
        return @"iPad (4th generation)";
    if ([deviceString isEqualToString:@"iPad4,1"] || [deviceString isEqualToString:@"iPad4,2"] || [deviceString isEqualToString:@"iPad4,3"])
        return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad5,3"] || [deviceString isEqualToString:@"iPad5,4"])
        return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad6,7"] || [deviceString isEqualToString:@"iPad6,8"])
        return @"iPad Pro (12.9-inch)";
    if ([deviceString isEqualToString:@"iPad6,3"] || [deviceString isEqualToString:@"iPad6,4"])
        return @"iPad Pro (9.7-inch)";
    if ([deviceString isEqualToString:@"iPad6,11"] || [deviceString isEqualToString:@"iPad6,12"])
        return @"iPad (5th generation)";
    if ([deviceString isEqualToString:@"iPad7,1"] || [deviceString isEqualToString:@"iPad7,2"])
        return @"iPad Pro (12.9-inch) (2nd generation)";
    if ([deviceString isEqualToString:@"iPad7,3"] || [deviceString isEqualToString:@"iPad7,4"])
        return @"iPad Pro (10.5-inch)";
    if ([deviceString isEqualToString:@"iPad7,5"] || [deviceString isEqualToString:@"iPad7,6"])
        return @"iPad (6th generation)";
    if ([deviceString isEqualToString:@"iPad8,1"] || [deviceString isEqualToString:@"iPad8,2"] || [deviceString isEqualToString:@"iPad8,3"] || [deviceString isEqualToString:@"iPad8,4"])
        return @"iPad Pro (11-inch)";
    if ([deviceString isEqualToString:@"iPad8,5"] || [deviceString isEqualToString:@"iPad8,6"] || [deviceString isEqualToString:@"iPad8,7"] || [deviceString isEqualToString:@"iPad8,8"])
        return @"iPad Pro (12.9-inch) (3rd generation)";
    if ([deviceString isEqualToString:@"iPad11,3"] || [deviceString isEqualToString:@"iPad11,4"])
        return @"iPad Air (3rd generation)";
    
    // iPad mini
    if ([deviceString isEqualToString:@"iPad2,5"] || [deviceString isEqualToString:@"iPad2,6"] || [deviceString isEqualToString:@"iPad2,7"])
        return @"iPad mini";
    if ([deviceString isEqualToString:@"iPad4,4"] || [deviceString isEqualToString:@"iPad4,5"] || [deviceString isEqualToString:@"iPad4,6"])
        return @"iPad mini 2";
    if ([deviceString isEqualToString:@"iPad4,7"] || [deviceString isEqualToString:@"iPad4,8"] || [deviceString isEqualToString:@"iPad4,9"])
        return @"iPad mini 3";
    if ([deviceString isEqualToString:@"iPad5,1"] || [deviceString isEqualToString:@"iPad5,2"])
        return @"iPad mini 4";
    if ([deviceString isEqualToString:@"iPad11,1"] || [deviceString isEqualToString:@"iPad11,2"])
        return @"iPad mini (5th generation)";
    
    return deviceString;
}

- (NSString *)getSystemVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

- (NSString *)getMacAddress
{
    return @"iOS7以后苹果对于sysctl和ioctl进行了技术处理，MAC地址返回的都是02:00:00:00:00:00";
}

- (NSString *)getUDID
{
    NSString *udid = [TJKeychain valueForKey:@"UDID" forAccessGroup:[[NSBundle mainBundle] bundleIdentifier]];
    if (!udid) {
        udid = [NSString stringWithFormat:@"%@", [UIDevice currentDevice].identifierForVendor.UUIDString];
        [TJKeychain setValue:udid forKey:@"UDID" forAccessGroup:[[NSBundle mainBundle] bundleIdentifier]];
    }
    return udid;
}

- (NSString *)getIDFA
{
    if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
        NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        return idfa;
    }
    return @"";
}

- (NSString *)getNetWorkType
{
    NSString *networkType = @"";
    
    NSString *remoteHostName = @"www.apple.com";
    Reachability *reachability = [Reachability reachabilityWithHostName:remoteHostName];
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    switch (netStatus) {
        case NotReachable:
            networkType = @"no network";
            break;
        case ReachableViaWiFi:
            networkType = @"WIFI";
            break;
        case ReachableViaWWAN:
        {
            // 获取手机网络类型
            CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
            NSString *currentStatus = info.currentRadioAccessTechnology;
            networkType = currentStatus;
            if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {
                networkType = @"GPRS";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]) {
                networkType = @"2.75G EDGE";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]) {
                networkType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]) {
                networkType = @"3.5G HSDPA";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]) {
                networkType = @"2G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"] ||
                      [currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"] ||
                      [currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]) {
                networkType = @"3G";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]) {
                networkType = @"HRPD";
            }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]) {
                networkType = @"4G";
            }
        }
            break;
        default:
            break;
    }
    return networkType;
}

- (NSString *)getBundleName
{
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    return [info valueForKey:(NSString *)kCFBundleNameKey];
}

- (NSString *)getNetworkOperator
{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [info subscriberCellularProvider];
    NSLog(@"[carrier carrierName] = %@", [carrier carrierName]);    // 运营商名称
    NSLog(@"[carrier mobileCountryCode] = %@", [carrier mobileCountryCode]);    // 国家码
    NSLog(@"[carrier mobileNetworkCode] = %@", [carrier mobileNetworkCode]);    //网络码
    NSLog(@"[carrier isoCountryCode] = %@", [carrier isoCountryCode]);  // 国家代码字符串
    NSLog(@"[carrier allowsVOIP] = %d", [carrier allowsVOIP]);
    
    //isp = mcc + mnc
    NSString *name = [carrier carrierName];
    return name;
}

@end
