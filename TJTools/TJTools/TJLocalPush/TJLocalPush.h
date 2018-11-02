//
//  TJLocalPush.h
//  TJTools
//
//  Created by xt on 2018/11/2.
//  Copyright © 2018年 TJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TJNotificationModel;

NS_ASSUME_NONNULL_BEGIN

@interface TJLocalPush : NSObject

#pragma mark iOS10以下推送
/**
 注册通知

 @param resultBlock 注册结果
 @return 注册错误
 */
+ (BOOL)registLocalNotificationResult:(void(^)(BOOL result, NSError *error))resultBlock;

/**
 添加本地通知

 @param model 通知内容
 @param resultBlock 添加结果
 */
+ (void)pushLocalNotificationWithModel:(TJNotificationModel *)model ResultInfo:(void(^)(BOOL result,UILocalNotification *localNotification))resultBlock;

/**
 移除指定通知

 @param notification 通知对象
 */
+ (void)removeLocalNotification:(UILocalNotification *)notification;

/**
 移除所有通知
 */
+ (void)removeAllLocalNotification;

@end

NS_ASSUME_NONNULL_END
