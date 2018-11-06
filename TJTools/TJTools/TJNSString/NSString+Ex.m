//
//  NSString+Ex.m
//  TJTools
//
//  Created by xt on 2018/11/1.
//  Copyright © 2018年 TJ. All rights reserved.
//

#import "NSString+Ex.h"

@implementation NSString (Ex)

- (NSString *)convertHexStrToString
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

- (NSString *)convertStringToHexStr
{
    if (!self || [self length] == 0) {
        return @"";
    }
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
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

- (NSString *)MD5
{
    if(self == nil || [self length] == 0)
        return nil;
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[16];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < 16; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
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
