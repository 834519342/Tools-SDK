//
//  TJ_RSA.h
//  iOSEncryption-Demo
//
//  Created by xt on 2019/3/18.
//  Copyright © 2019 TJ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TJ_RSA : NSObject

+ (instancetype)sharedInstance;

/// 加密
/// @param str 需要加密的字符串
/// @param pubKey 公钥
- (NSString *)RSA_EncryptString:(NSString *)str publickey:(NSString *)pubKey;

/// 解密
/// @param str 需要解密的字符串
/// @param privKey 私钥
- (NSString *)RSA_DecryptString:(NSString *)str privateKey:(NSString *)privKey;

/// 签名
/// @param originStr 需要签名的字符串
/// @param privateKey 私钥
- (NSString *)RSA_Sign:(NSString *)originStr withPrivate:(NSString *)privateKey;

/// 验签
/// @param originStr 原数据
/// @param signStr 签名
/// @param publicKey 公钥
- (BOOL)RSA_Verify:(NSString *)originStr Signatrue:(NSString *)signStr withPublicKey:(NSString *)publicKey;

@end

NS_ASSUME_NONNULL_END
