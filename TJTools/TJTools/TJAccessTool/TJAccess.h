//
//  TJAccess.h
//  TJTools
//
//  Created by xt on 2019/2/15.
//  Copyright © 2019 TJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//NS_ASSUME_NONNULL_BEGIN

@interface TJAccess : NSObject

// 获取当前VC视图层
+ (UIViewController *)getCurrentVC;

// 获取显示的windows
+ (UIWindow *)lastWindow;

// 字典 -> JSONStr
+ (NSString *)dictToJsonStr:(NSDictionary *)dict;

//JSONStr -> 字典
+ (NSDictionary *)jsonStrToDict:(NSString *)jsonStr;

/**
 十六进制的字符串转换成NSString
 */
+ (NSString *)TJ_HexStrConvertToStr:(NSString *)str;

/**
 NSString转换成十六进制的字符串
 */
+ (NSString *)TJ_StrConvertToHexStr:(NSString *)str;

/**
 获取当前时间
 @param formatterStr 自定义时间格式,为空则使用系统格式
 @return 默认格式:YYYY-MM-dd HH:mm:ss (hh:12小时制,HH:24小时制)
 */
+ (NSString *)getCurrentTimesWithFormatter:(NSString *)formatterStr;

/**
 获取当前时间戳
 @param formatterStr 自定义时间格式,为空则使用系统格式
 @return 时间戳(秒)
 */
+ (NSString *)getNowTimeTimestampWithFormatter:(NSString *)formatterStr;

@end

//NS_ASSUME_NONNULL_END
