//
//  TJTools.h
//  TJTools
//
//  Created by xt on 2018/10/30.
//  Copyright © 2018年 TJ. All rights reserved.
//
/*
 version 英 ['vɜːʃ(ə)n] n. 版本；译文；倒转术
 crash 英 [kræʃ] n. 撞碎；坠毁；破产；轰隆声；睡觉
 alert 英 [ə'lɜːt] n. 警戒，警惕；警报
 tooltip 英 [tuːl] 英 [tɪp] n. 工具提示；提示信息；提示框；提示文本
 local 英 ['ləʊk(ə)l] n. [计] 局部；当地居民；本地新闻
 push 英 [pʊʃ] n. 推，决心；大规模攻势；矢志的追求
 notification 英 [,nəʊtɪfɪ'keɪʃn] n. 通知；通告；[法] 告示
 model 英 ['mɒdl] n. 模型；典型；模范；模特儿；样式
 apple 英 ['æp(ə)l] n. 苹果
 access 英 ['ækses] n. 进入；使用权；通路
 */

#import <UIKit/UIKit.h>
#import "TJDefine.h"    // 自定义功能宏
#import "TJVersion.h"   // 获取应用版本信息
#import "TJCrash.h" // 崩溃信息获取
#import "TJAlert.h" // 系统提示框：居中提示选项，上拉提示选项
#import "NSString+Ex.h" // 字符串操作：格式、加密
#import "TJToolTip.h"   // 提示：加载器，文字提醒框
#import "TJLocalPush.h" // 本地通知
#import "TJAppleZF.h"   // 苹果支付
#import "TJAccess.h"    // 自定义效率功能
#import "TJKeychain.h"  // 钥匙串本地持久化
#import "TJDeviceInfo.h"    // 获取设备信息
#import "TJLocation.h"  // 获取设备定位信息
#import "TJAppleCode.h" // 苹果自带功能：App Store下载界面，应用评价功能(五星弹框,App Store评价页)，系统粘贴板
#import "TJSandBoxPath.h"   // 系统文件路径管理

//! Project version number for TJTools.
FOUNDATION_EXPORT double TJToolsVersionNumber;

//! Project version string for TJTools.
FOUNDATION_EXPORT const unsigned char TJToolsVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <TJTools/PublicHeader.h>


