//
//  TJCrash.h
//  TJTools
//
//  Created by xt on 2018/11/1.
//  Copyright © 2018年 TJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface TJCrash : NSObject

/**
 激活崩溃监控功能
 
 @return 监控单例
 */
+ (instancetype)sharedCrash;

/**
 获取存储本地的崩溃信息
 
 @return 崩溃信息
 */
- (NSString *)getCrashLog;

/**
 发送崩溃信息到开发者邮箱
 */
- (void)sendCrashInfoToEMail;

@end
