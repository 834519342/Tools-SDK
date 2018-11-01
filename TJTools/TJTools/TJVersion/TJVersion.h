//
//  TJVersion.h
//  TJVersion
//
//  Created by 谭杰 on 2016/12/14.
//  Copyright © 2016年 谭杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TJAppInfo;

typedef void(^NewVersionBlock)(TJAppInfo *appInfo);

@interface TJVersion : NSObject

//创建一个单例
+ (TJVersion *)shardManger;

/**
 *  检测新版本(使用默认提示框)
 */
+ (void)checkNewVersion;


/**
 *  检查新版本(自定义提醒)
 *
 *  @param newVersion 新版本信息回调
 */
+ (void)checkNewVersionAndCustomAlert:(NewVersionBlock)newVersion;

/**
 *  在应用内打开下载页面
 *  @param appId 应用id
 */
+ (void)openInStoreProductViewControllerForAppId:(NSString *)appId;


/**
 判断是否有新版本

 @param newVersion 新版本号
 @param currentVersion 当前版本号
 @return 结果
 */
- (BOOL)newVersion:(NSString *)newVersion moreThanCurrentVersion:(NSString *)currentVersion;

@end
