//
//  TJToolTip.h
//  TJTools
//
//  Created by xt on 2018/11/1.
//  Copyright © 2018年 TJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ClickToolTipBlock)(NSString *message);

@interface TJToolTip : NSObject

/**
 单例

 @return 管理者
 */
+ (instancetype)sharedToolTip;

/**
 显示加载器
 */
+ (void)showActivity;

/**
 关闭加载器
 */
+ (void)hideActivity;

/**
 居中提示

 @param message 提示内容
 @param duration 显示时间
 @param block 有点击事件触发block
 */
+ (void)showToolTipOnCenterWithMessage:(NSString *)message duration:(CGFloat)duration clickToolTipBlock:(ClickToolTipBlock)block;

/**
 顶端提示

 @param message 提示内容
 @param duration 显示时间
 @param block 有点击事件触发block
 */
+ (void)showToolTipOnTopWithMessage:(NSString *)message duration:(CGFloat)duration clickToolTipBlock:(ClickToolTipBlock)block;

@end

NS_ASSUME_NONNULL_END
