//
//  TJCrash.h
//  TJTools
//
//  Created by xt on 2018/11/1.
//  Copyright © 2018年 TJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TJCrashDelegate <NSObject>

/// 崩溃监听回调
/// @param crashLogs 所有的崩溃缓存
- (void)TJMonitorCrashLogs:(NSArray <NSDictionary *> *)crashLogs;

@end

@interface TJCrash : NSObject

/// 实例化
+ (instancetype)sharedInstance;

/// 开始监听
- (void)TJStartWithDelegate:(id<TJCrashDelegate>)delegate;

/// 清除已处理过的崩溃缓存
/// @param crashLogDic 单个崩溃日志
- (void)TJCleanCrashLog:(NSDictionary *)crashLogDic;

@end

NS_ASSUME_NONNULL_END
