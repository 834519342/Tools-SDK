//
//  NSString+Ex.h
//  TJTools
//
//  Created by xt on 2018/11/1.
//  Copyright © 2018年 TJ. All rights reserved.
//
/*
 编码：Base64编码
 算法：MD5、SHA、RSA
 标准：DES、AES
 */

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
 base64 字符串编码
 Base64是网络上最常见的用于传输8Bit字节代码的编码方式之一。Base64编码可用于在HTTP环境下传递较长的标识信息。采用Base64编码具有不可读性，即所编码的数据不会被人用肉眼所直接看到。
 */
- (NSString *)base64_encodeStr;

/**
 base64 字符串解码
 */
- (NSString *)base64_decodeStr;

/**
 MD5 算法加密
 
 MD5即Message-Digest Algorithm 5（信息-摘要算法5），用于确保信息传输完整一致。是计算机广泛使用的杂凑算法之一（又译摘要算法、哈希算法）。
 MD5算法具有以下特点：
 （1）压缩性：任意长度的数据，算出的MD5值长度都是固定的。
 （2）容易计算：从原数据计算出MD5值很容易。
 （3）抗修改性：对原数据进行任何改动，哪怕只修改1个字节，所得到的MD5值都有很大区别。
 （4）强抗碰撞：已知原数据和其MD5值，想找到一个具有相同MD5值的数据（即伪造数据）是非常困难的。
 */
- (NSString *)MD5_Str;

/**
 SHA1 算法加密

 SHA即Secure Hash Algorithm（安全哈希算法），主要适用于数字签名标准（Digital Signature Standard DSS）里面定义的数字签名算法（Digital Signature Algorithm DSA）。对于长度小于2^64位的消息，SHA1会产生一个160位的消息摘要。
 */
- (NSString *)SHA1_Str;

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
