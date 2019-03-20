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

- (NSString *)RSA_EncryptString:(NSString *)str publickey:(NSString *)pubKey;

- (NSString *)RSA_DecryptString:(NSString *)str privateKey:(NSString *)privKey;

@end

NS_ASSUME_NONNULL_END
