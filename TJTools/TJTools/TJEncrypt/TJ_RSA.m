//
//  TJ_RSA.m
//  iOSEncryption-Demo
//
//  Created by xt on 2019/3/18.
//  Copyright © 2019 TJ. All rights reserved.
//

#import "TJ_RSA.h"
#import <CommonCrypto/CommonCrypto.h>   // SHA

// base64编码
static NSString *base64_encode_data(NSData *data){
    data = [data base64EncodedDataWithOptions:0];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return ret;
//    return [data base64EncodedStringWithOptions:0];
}

// base64解码
static NSData *base64_decode(NSString *str){
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return data;
}

@interface TJ_RSA ()<NSCopying>

@end

@implementation TJ_RSA

+ (instancetype)sharedInstance
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (manager == nil) {
            manager = [[super allocWithZone:NULL] init];
        }
    });
    return manager;
}
// 规避创建新的单例
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}
// 规避创建新的单例
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

// --------------------- RSA加密 -------------------------
- (SecKeyRef)addPublicKey:(NSString *)key
{
    NSRange spos = [key rangeOfString:@"-----BEGIN PUBLIC KEY-----"];
    NSRange epos = [key rangeOfString:@"-----END PUBLIC KEY-----"];
    if (spos.location != NSNotFound && epos.location != NSNotFound) {
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e-s);
        key = [key substringWithRange:range];
    }
    key = [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSData *data = base64_decode(key);
    data = [self stripPublicKeyHeader:data];
    if (!data) {
        return nil;
    }
    
    NSString *tag = @"RSAUtil_PubKey";
    NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];
    
    NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
    [publicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [publicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [publicKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)publicKey);
    
    [publicKey setObject:data forKey:(__bridge id)kSecValueData];
    [publicKey setObject:(__bridge id)kSecAttrKeyClassPublic forKey:(__bridge id)kSecAttrKeyClass];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnPersistentRef];
    
    CFTypeRef persistKey = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)publicKey, &persistKey);
    if (persistKey != nil) {
        CFRelease(persistKey);
    }
    if ((status != noErr) && (status != errSecDuplicateItem)) {
        return nil;
    }
    
    [publicKey removeObjectForKey:(__bridge id)kSecValueData];
    [publicKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [publicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    SecKeyRef keyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)publicKey, (CFTypeRef *)&keyRef);
    if (status != noErr) {
        return nil;
    }
    return keyRef;
}

- (NSData *)stripPublicKeyHeader:(NSData *)d_key
{
    if (d_key == nil) return(nil);
    
    unsigned long len = [d_key length];
    if (!len) return(nil);
    
    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int idx = 0;
    
    if (c_key[idx++] != 0x30) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    static unsigned char seqiod[] = {0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00};
    if (memcmp(&c_key[idx], seqiod, 15)) return(nil);
    
    idx += 15;
    
    if (c_key[idx++] != 0x03) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    if (c_key[idx++] != '\0') return(nil);
    
    return([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}

- (NSString *)RSA_EncryptString:(NSString *)str publickey:(NSString *)pubKey
{
    NSData *data = [self encryptData:[str dataUsingEncoding:NSUTF8StringEncoding] publicKey:pubKey];
    NSString *ret = base64_encode_data(data);
    return ret;
}

- (NSData *)encryptData:(NSData *)data publicKey:(NSString *)pubKey
{
    if (!data || !pubKey) {
        return nil;
    }
    SecKeyRef keyRef = [self addPublicKey:pubKey];
    if (!keyRef) {
        return nil;
    }
    return [self encryptData:data withKeyRef:keyRef];
}

- (NSData *)encryptData:(NSData *)data withKeyRef:(SecKeyRef)keyRef
{
    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
    size_t srclen = (size_t)data.length;
    
    size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    void *outbuf = malloc(block_size);
    size_t src_block_size = block_size - 11;
    
    NSMutableData *ret = [[NSMutableData alloc] init];
    for (int idx = 0; idx < srclen; idx += src_block_size) {
        size_t data_len = srclen - idx;
        if (data_len > src_block_size) {
            data_len = src_block_size;
        }
        
        size_t outlen = block_size;
        OSStatus status = noErr;
        status = SecKeyEncrypt(keyRef, kSecPaddingPKCS1, srcbuf + idx, data_len, outbuf, &outlen);
        
        if (status != 0) {
            NSLog(@"SecKeyEncrypt fail. Error Code: %d", (int)status);
            ret = nil;
            break;
        }else {
            [ret appendBytes:outbuf length:outlen];
        }
    }
    
    free(outbuf);
    CFRelease(keyRef);
    return ret;
}

// ----------------------- RSA解密 ------------------------
- (SecKeyRef)addPrivateKey:(NSString *)key
{
    NSRange spos = [key rangeOfString:@"-----BEGIN PRIVATE KEY-----"];
    NSRange epos = [key rangeOfString:@"-----END PRIVATE KEY-----"];
    if (spos.location != NSNotFound && epos.location != NSNotFound) {
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s , e-s);
        key = [key substringWithRange:range];
    }
    key = [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSData *data = base64_decode(key);
    data = [self stripPrivateKeyHeader:data];
    if (!data) {
        return nil;
    }
    
    NSString *tag = @"RSAUtil_PrivKey";
    NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];
    
    NSMutableDictionary *privateKey = [[NSMutableDictionary alloc] init];
    [privateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [privateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [privateKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)privateKey);
    
    [privateKey setObject:data forKey:(__bridge id)kSecValueData];
    [privateKey setObject:(__bridge id)kSecAttrKeyClassPrivate forKey:(__bridge id)kSecAttrKeyClass];
    [privateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnPersistentRef];
    
    CFTypeRef persistKey = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)privateKey, &persistKey);
    if (persistKey != nil) {
        CFRelease(persistKey);
    }
    if ((status != noErr) && (status != errSecDuplicateItem)) {
        return nil;
    }
    
    [privateKey removeObjectForKey:(__bridge id)kSecValueData];
    [privateKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [privateKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [privateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    SecKeyRef keyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)privateKey, (CFTypeRef *)&keyRef);
    if (status != noErr) {
        return nil;
    }
    return keyRef;
}

- (NSData *)stripPrivateKeyHeader:(NSData *)d_key
{
    if (d_key == nil) return nil;
    
    unsigned long len = [d_key length];
    if (!len) {
        return nil;
    }
    
    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int idx = 22;
    
    if (0x04 != c_key[idx++]) {
        return nil;
    }
    
    unsigned int c_len = c_key[idx++];
    int det = c_len & 0x80;
    if (!det) {
        c_len = c_len & 0x7f;
    }else {
        int byteCount = c_len & 0x7f;
        if (byteCount + idx > len) {
            return nil;
        }
        
        unsigned int accum = 0;
        unsigned char *ptr = &c_key[idx];
        idx += byteCount;
        while (byteCount) {
            accum = (accum << 8) + *ptr;
            ptr++;
            byteCount--;
        }
        c_len = accum;
    }
    
    return [d_key subdataWithRange:NSMakeRange(idx, c_len)];
}

- (NSString *)RSA_DecryptString:(NSString *)str privateKey:(NSString *)privKey
{
    if(!str) return nil;
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:0];
    data = [self decryptData:data privateKey:privKey];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return ret;
}

- (NSData *)decryptData:(NSData *)data privateKey:(NSString *)privKey
{
    if (!data || !privKey) {
        return nil;
    }
    SecKeyRef keyRef = [self addPrivateKey:privKey];
    if (!keyRef) {
        return nil;
    }
    return [self decryptData:data withKeyRef:keyRef];
}

- (NSData *)decryptData:(NSData *)data withKeyRef:(SecKeyRef)keyRef
{
    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
    size_t srclen = (size_t)data.length;
    
    size_t block_size = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    UInt8 *outbuf = malloc(block_size);
    size_t src_block_size = block_size;
    
    NSMutableData *ret = [[NSMutableData alloc] init];
    for (int idx = 0; idx < srclen; idx += src_block_size) {
        size_t data_len = srclen - idx;
        if (data_len > src_block_size) {
            data_len = src_block_size;
        }
        
        size_t outlen = block_size;
        OSStatus status = noErr;
        status = SecKeyDecrypt(keyRef, kSecPaddingNone, srcbuf + idx, data_len, outbuf, &outlen);
        
        if (status != 0) {
            NSLog(@"SecKeyEncrypt fail. Error Code: %d", (int)status);
            ret = nil;
            break;
        }else {
            int idxFirstZero = -1;
            int idxNextZero = (int)outlen;
            for (int i = 0; i < outlen; i++) {
                if (outbuf[i] == 0) {
                    if (idxFirstZero < 0) {
                        idxFirstZero = i;
                    }else {
                        idxNextZero = i;
                        break;
                    }
                }
            }
            
            [ret appendBytes:&outbuf[idxFirstZero + 1] length:idxNextZero - idxFirstZero - 1];
        }
    }
    
    free(outbuf);
    CFRelease(keyRef);
    return ret;
}

// ---------------------- RSA加签+验签 -----------------------
// SHA算法
- (NSData *)SHA_256:(NSString *)str
{
    const void *data = [str cStringUsingEncoding:NSUTF8StringEncoding];
    CC_LONG len = (CC_LONG)strlen(data);
    uint8_t *md = malloc(CC_SHA256_DIGEST_LENGTH * sizeof(uint8_t));
    CC_SHA256(data, len, md);
    NSData *resultData = [NSData dataWithBytes:md length:CC_SHA256_DIGEST_LENGTH];
    free(md);
    return resultData;
}

//签名
- (NSString *)RSA_Sign:(NSString *)originStr withPrivate:(NSString *)privateKey
{
    SecKeyRef privateKeyRef = [self addPrivateKey:privateKey]; // 私钥对象
    if (!privateKeyRef)
    {
        NSLog(@"add private key error.");
        return nil;
    }
    NSData *originData = [self SHA_256:originStr];  // 获取原始数据的哈希值
    unsigned char *sig = (unsigned char *)malloc(256);
    size_t sig_len;
    //签名
    OSStatus status = SecKeyRawSign(privateKeyRef, kSecPaddingPKCS1SHA256, originData.bytes, originData.length, sig, &sig_len);
    if (status != noErr) {
        NSLog(@"sign error:%d", (int)status);
        return nil;
    }
    NSData *outdata = [NSData dataWithBytes:sig length:sig_len];
    free(sig);
    return base64_encode_data(outdata);
}

// 验签
- (BOOL)RSA_Verify:(NSString *)originStr Signatrue:(NSString *)signStr withPublicKey:(NSString *)publicKey
{
    SecKeyRef publicKeyRef = [self addPublicKey:publicKey]; // 公钥对象
    if (!publicKeyRef) {
        NSLog(@"add public key error.");
        return NO;
    }
    NSData *originData = [self SHA_256:originStr];  // 获取原始数据哈希值
    NSData *signData = [[NSData alloc] initWithBase64EncodedString:signStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
    if (!originData || !signData) {
        NSLog(@"data is nil.");
        return NO;
    }
    // 验签
    OSStatus status = SecKeyRawVerify(publicKeyRef, kSecPaddingPKCS1SHA256, originData.bytes, originData.length, signData.bytes, signData.length);
    if (status == noErr) {
        return YES;
    }else {
        NSLog(@"verify sign error:%d", (int)status);
        return NO;
    }
}

@end
