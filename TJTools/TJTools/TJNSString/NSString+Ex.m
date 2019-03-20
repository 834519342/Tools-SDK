//
//  NSString+Ex.m
//  TJTools
//
//  Created by xt on 2018/11/1.
//  Copyright © 2018年 TJ. All rights reserved.
//

#import "NSString+Ex.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

#import "TJ_RSA.h"

@implementation NSString (Ex)

- (NSString *)TJ_HexStrConvertToStr
{
    if (!self || [self length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([self length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [self length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [self substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    NSString *string = [[NSString alloc]initWithData:hexData encoding:NSUTF8StringEncoding];
    return string;
}

- (NSString *)TJ_StrConvertToHexStr
{
    if (!self || [self length] == 0) {
        return nil;
    }
    NSData *hex_data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[hex_data length]];
    
    [hex_data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}

- (NSString *)TJ_Base64_encode
{
    if (!self || [self length] == 0) {
        return nil;
    }
    
    NSData *base64_data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encodeStr = [base64_data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return encodeStr;
}

- (NSString *)TJ_Base64_decode
{
    if (!self || [self length] == 0) {
        return nil;
    }
    
    NSData *base64_data = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSString *decodeStr = [[NSString alloc] initWithData:base64_data encoding:NSUTF8StringEncoding];
    return decodeStr;
}

- (NSString *)TJ_MD5
{
    if(self == nil || [self length] == 0)
        return nil;
    
    const char *value = [self UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    return outputString;
}

- (NSString *)TJ_SHA1
{
    if(self == nil || [self length] == 0)
        return nil;
    
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *SHA1_data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(SHA1_data.bytes, (uint32_t)SHA1_data.length, digest);
    
    NSMutableString *SHA1_str = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [SHA1_str appendFormat:@"%02x", digest[i]];
    }
    return SHA1_str;
}

- (NSString *)TJ_HmacSHA256_WithKey:(NSString *)HMAC_KEY
{
    if(self == nil || [self length] == 0)
        return nil;
    
    NSData *hash_data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char *digest;
    digest = malloc(CC_SHA256_DIGEST_LENGTH);
    const char *cKey = [HMAC_KEY cStringUsingEncoding:NSUTF8StringEncoding];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), [hash_data bytes], [hash_data length], digest);
//    NSData *data = [NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];

    NSMutableString *hmac_str = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hmac_str appendFormat:@"%02x", digest[i]];
    }
    free(digest);
    return hmac_str;
}

- (NSString *)TJ_AES256_EncryptWithKey:(NSString *)AES_KEY
{
    if(self == nil || [self length] == 0)
        return nil;
    
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [AES_KEY getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSData *sourceData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [sourceData length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus status = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding | kCCOptionECBMode, keyPtr, kCCBlockSizeAES128, NULL, [sourceData bytes], dataLength, buffer, bufferSize, &numBytesEncrypted);
    
    if (status == kCCSuccess) {
        NSData *encryptData = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        //base64编码
        return [encryptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }else {
        free(buffer);
        return nil;
    }
}

- (NSString *)TJ_AES256_DecryptWithKey:(NSString *)AES_KEY
{
    if(self == nil || [self length] == 0)
        return nil;
    
    //base64解码
    NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [AES_KEY getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [decodeData length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus status = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding | kCCOptionECBMode, keyPtr, kCCBlockSizeAES128, NULL, [decodeData bytes], dataLength, buffer, bufferSize, &numBytesDecrypted);
    if (status == kCCSuccess) {
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }else {
        free(buffer);
        return nil;
    }
}

- (NSString *)TJ_RSAEncryptWithPublicKey:(NSString *)publicKey
{
    return [[TJ_RSA new] RSA_EncryptString:self publickey:publicKey];
}

- (NSString *)TJ_RSADecryptWithPrivateKey:(NSString *)privateKey
{
    return [[TJ_RSA new] RSA_DecryptString:self privateKey:privateKey];
}

+ (NSString *)getCurrentTimesWithFormatter:(NSString *)formatterStr
{
    //时间格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (formatterStr) {
        [formatter setDateFormat:formatterStr];
    }else {
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    }
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    NSLog(@"现在时间:%@",currentTimeString);
    return currentTimeString;
}

+ (NSString *)getNowTimeTimestampWithFormatter:(NSString *)formatterStr
{
    //时间格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (formatterStr) {
        //自定义格式
        [formatter setDateFormat:formatterStr];
    }else {
        //设置日期系统格式
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        //设置时间系统格式
        [formatter setTimeStyle:NSDateFormatterShortStyle];
    }
    //设置已知时区
//    NSLog(@"%@",[NSTimeZone knownTimeZoneNames]); //打印所有已知时区
//    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Pacific/Pago_Pago"];
    //设置本地时区
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:timeZone];
    
    NSDate *dateNow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld",(long)[dateNow timeIntervalSince1970]];
    NSLog(@"现在时间戳:%@",timeSp);
//    NSLog(@"现在时间戳:%ld",time(NULL));
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[dateNow timeIntervalSince1970]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    NSLog(@"时间戳转时间:%@",confromTimespStr);
    
    return timeSp;
}

@end
