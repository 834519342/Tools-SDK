//
//  TJAppleCode.h
//  LMGame
//
//  Created by LM on 2019/9/10.
//  Copyright © 2019 tj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShareModel.h"
#import "ReviewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TJAppleCode : NSObject

// 单例
+ (instancetype _Nonnull )sharedInstance;

/**
 打开下载界面

 @param appId 苹果应用ID
 */
- (void)openInStoreProductViewControllerForAppId:(NSString *_Nonnull)appId;

/**
 打开评价页
 
 @param reviewModel 评价设置
 */
+ (void)openReview:(ReviewModel *)reviewModel completionHandler:(void(^_Nullable)(NSDictionary *_Nonnull resultDic))handler;

/**
 苹果自带分享模块

 @param shareModel 分享内容
 @param vc 基础视图
 @param handler 结果处理
 */
+ (void)systemShareWithModel:(ShareModel *_Nonnull)shareModel withViewController:(UIViewController *_Nullable)vc completionHandler:(void(^_Nullable)(NSDictionary * _Nonnull resultDic))handler;

/**
 复制到粘贴板

 @param pasteStr 复制的值
 */
+ (void)CopyStrToPasteboard:(NSString *)pasteStr;

@end

NS_ASSUME_NONNULL_END
