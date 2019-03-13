//
//  NSString+Ex.h
//  TJTools
//
//  Created by xt on 2018/11/1.
//  Copyright © 2018年 TJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (Ex)

/**
 十六进制的字符串转换成NSString
 */
- (NSString *)convertHexStrToString;

/**
 NSString转换成十六进制的字符串
 */
- (NSString *)convertStringToHexStr;

/**
 base64 字符串加密
 */
- (NSString *)base64_encodeStr;

/**
 base64 字符串解密
 */
- (NSString *)base64_decodeStr;

/**
 MD5加密
 */
- (NSString *)MD5;

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
