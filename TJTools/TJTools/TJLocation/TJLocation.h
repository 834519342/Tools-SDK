//
//  TJLocation.h
//  TJTools
//
//  Created by LM on 2019/8/13.
//  Copyright © 2019 TJ. All rights reserved.
//
/*
 <key>NSLocationUsageDescription</key>
 <string>App需要您的同意,才能访问位置</string>
 <key>NSLocationWhenInUseUsageDescription</key>
 <string>App需要您的同意,才能在使用期间访问位置</string>
 <key>NSLocationAlwaysUsageDescription</key>
 <string>App需要您的同意,才能始终访问位置</string>
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TJLocation : NSObject

/**
 单例

 @return 实例
 */
+ (instancetype)shareInstance;

/**
 获取更新的位置信息

 @param callback 位置信息
 */
- (void)startUpdatingLocation:(void (^)(NSDictionary * _Nonnull resultDic))callback;

/**
 停止更新位置信息
 */
- (void)stopUpdatingLocation;

/**
 一次性获取定位信息，速度很慢

 @param callback 位置信息
 */
- (void)requestLocation:(void (^)(NSDictionary * _Nonnull resultDic))callback;

@end

NS_ASSUME_NONNULL_END
