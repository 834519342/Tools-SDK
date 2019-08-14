//
//  TJDeviceInfo.h
//  TJTools
//
//  Created by LM on 2019/8/12.
//  Copyright © 2019 TJ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TJDeviceInfo : NSObject

/**
 单例对象

 @return 实例
 */
+ (instancetype)shareInstance;

/**
 把所有信息组合成一个字典返回

 @param result 字典
 */
- (void)getDeviceInfoDic:(void(^)(NSDictionary *resultDic))result;

/**
 获取设备机型

 @return 机型
 */
- (NSString *)getDeviceType;

/**
 获取系统版本

 @return 版本号
 */
- (NSString *)getSystemVersion;

/**
 获取设备MAC地址

 @return MAC地址
 */
- (NSString *)getMacAddress;

/**
 获取UDID，利用UUID的本地持久化代替

 @return UDID
 */
- (NSString *)getUDID;

/**
 获取IDFA

 @return IDFA
 */
- (NSString *)getIDFA;

/**
 获取网络类型

 @return 网络类型：WIFI/2G/3G/4G
 */
- (NSString *)getNetWorkType;

/**
 获取APP名字

 @return APP名字
 */
- (NSString *)getBundleName;

/**
 获取网络运营商

 @return 运营商
 */
- (NSString *)getNetworkOperator;

/**
 判断是否越狱

 @return 越狱/非越狱
 */
- (NSString *)isJailBreak;

@end

NS_ASSUME_NONNULL_END
