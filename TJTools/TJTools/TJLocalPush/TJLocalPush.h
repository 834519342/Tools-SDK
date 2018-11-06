//
//  TJLocalPush.h
//  TJTools
//
//  Created by xt on 2018/11/2.
//  Copyright © 2018年 TJ. All rights reserved.
//  参考资料:https://www.2cto.com/kf/201610/552256.html

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@class TJNotificationModel;

NS_ASSUME_NONNULL_BEGIN

@interface TJLocalPush : NSObject

#pragma mark iOS10以上推送
/**
 通知中心

 @return 通知中心对象
 */
+ (UNUserNotificationCenter *)pushCenter API_AVAILABLE(ios(10.0));

/**
 注册通知

 @param delegate 通知代理
 @param completionHandler 注册结果
 */
+ (void)registLocalNotificationWithDelegate:(id<UNUserNotificationCenterDelegate>)delegate withCompletionHandler:(void(^)(BOOL granted, NSError *error))completionHandler API_AVAILABLE(ios(10.0));

/**
 添加本地通知

 @param pushModel 推送信息
 @param pushBlock 添加成功返回推送信息
 @param completionHandler 添加失败返回错误信息
 */
+ (void)addLocalPushWithModel:(TJNotificationModel *)pushModel PushModel:(void(^)(TJNotificationModel *pushModel))pushBlock withCompletionHandler:(void(^)(NSError *error))completionHandler API_AVAILABLE(ios(10.0));

/**
 清除通知

 @param categoryIdentifier 推送id
 @param completionHandler 清除结果
 */
+ (void)removeLocalPushWithCategoryId:(NSString *)categoryIdentifier withCompletionHandler:(void(^)(NSError *error))completionHandler API_AVAILABLE(ios(10.0));

/**
 获取当前推送对象属性设置,只读,不能更改

 @param completionHandler 回调
 */
+ (void)getNotificationSettingsWithCompletionHandler:(void(^)(UNNotificationSettings *settings))completionHandler API_AVAILABLE(ios(10.0));

@end

NS_ASSUME_NONNULL_END
