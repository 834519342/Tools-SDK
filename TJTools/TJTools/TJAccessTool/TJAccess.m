//
//  TJAccess.m
//  TJTools
//
//  Created by xt on 2019/2/15.
//  Copyright © 2019 TJ. All rights reserved.
//

#import "TJAccess.h"

@implementation TJAccess

// 获取当前VC视图层
+ (UIViewController *)getCurrentVC
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    
    return currentVC;
}

+ (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC
{
    UIViewController *currentVC;
    
    //视图层是被presented出来的
    if ([rootVC presentedViewController]) {
        rootVC = [rootVC presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        //根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
        
    }else if ([rootVC isKindOfClass:[UINavigationController class]]) {
        //根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        //根视图为非导航类
        currentVC = rootVC;
    }
    return currentVC;
}

// 获取显示的windows
+ (UIWindow *)lastWindow
{
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (UIWindow *window in [windows reverseObjectEnumerator]) {
        if ([windows isKindOfClass:[UIWindow class]] && CGRectEqualToRect(window.bounds, [UIScreen mainScreen].bounds)) {
            return window;
        }
    }
    return [UIApplication sharedApplication].keyWindow;
}

// 字典 -> JSONStr
+ (NSString *)dictToJsonStr:(NSDictionary *)dict
{
    if (dict == nil) {
        NSLog(@"字典是空的.");
        return nil;
    }
    //判断字典是否可转成json数据
    if (![NSJSONSerialization isValidJSONObject:dict]) {
        NSLog(@"字典无法转成json数据");
        return nil;
    }
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&err];
    if (err) {
        NSLog(@"json转换失败：%@", err);
    }
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonStr;
}

//JSONStr -> 字典
+ (NSDictionary *)jsonStrToDict:(NSString *)jsonStr
{
    if (jsonStr == nil) {
        return nil;
    }
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&err];
    if (err) {
        NSLog(@"json解析失败：%@", err);
        return nil;
    }
    return dict;
}

// 十六进制的字符串转换成NSString
+ (NSString *)TJ_HexStrConvertToStr:(NSString *)str
{
    if (!self || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
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

// NSString转换成十六进制的字符串
+ (NSString *)TJ_StrConvertToHexStr:(NSString *)str
{
    if (!self || [str length] == 0) {
        return nil;
    }
    NSData *hex_data = [str dataUsingEncoding:NSUTF8StringEncoding];
    
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

// 获取当前时间
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

// 获取当前时间戳
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
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[dateNow timeIntervalSince1970]];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    NSLog(@"时间戳转时间:%@",confromTimespStr);
    
    NSString *timeSp = [NSString stringWithFormat:@"%ld",(long)[dateNow timeIntervalSince1970]];
        NSLog(@"现在时间戳:%@",timeSp);
    //    NSLog(@"现在时间戳:%ld",time(NULL));
    
    return timeSp;
}

@end
