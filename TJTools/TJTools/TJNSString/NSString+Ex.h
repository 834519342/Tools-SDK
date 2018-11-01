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

 @return NSString
 */
- (NSString *)convertHexStrToString;

/**
 NSString转换成十六进制的字符串

 @return 十六进制字符串
 */
- (NSString *)convertStringToHexStr;

/**
 MD5

 @return 加密串
 */
- (NSString *)MD5;

@end
