//
//  TJCrash.m
//  TJTools
//
//  Created by xt on 2018/11/1.
//  Copyright © 2018年 TJ. All rights reserved.
//

#import "TJCrash.h"
#import "TJAccess.h"

#define CrashLog @"TJCrashLog"

@interface TJCrash ()<NSCopying>

// 代理委托
@property (nonatomic, nullable, weak) id<TJCrashDelegate> delegate;

@end

@implementation TJCrash

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[super allocWithZone:NULL] init];
        }
    });
    return instance;
}
// 规避创建一个新的单例
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}
// 规避创建一个新的单例
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

static NSUncaughtExceptionHandler *previousHandler;
- (void)TJStartWithDelegate:(id<TJCrashDelegate>)delegate
{
    self.delegate = delegate;
    // 获取之前的监听方法
    previousHandler = NSGetUncaughtExceptionHandler();
    // 注册监听方法
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    // 回传缓存中的崩溃信息
    [self.delegate TJMonitorCrashLogs:[self getCrashLogs]];
}

// 监听崩溃日志
void UncaughtExceptionHandler(NSException *exception) {
    
    NSMutableArray *crashLogs = [NSMutableArray arrayWithArray:[[TJCrash sharedInstance] getCrashLogs]];  // 缓存多个崩溃日志
    NSMutableDictionary *crashLogDic = [NSMutableDictionary dictionaryWithDictionary:[[TJCrash sharedInstance] getAppInfo]];
    [crashLogDic setValue:[exception name] forKey:@"crash_name"]; // 崩溃类型
    [crashLogDic setValue:[exception reason] forKey:@"crash_reason"]; // 崩溃说明
    [crashLogDic setValue:[exception callStackSymbols] forKey:@"crash_stackSymbols"]; // 崩溃堆栈信息
    [crashLogDic setValue:@"1.0" forKey:@"sdk_ver"];
    [crashLogDic setValue:[NSString stringWithFormat:@"%ld", time(NULL)] forKey:@"timestamp"]; // 时间戳
    [crashLogs addObject:crashLogDic];
    // 缓存崩溃信息
    [[TJCrash sharedInstance] saveCrashLogs:crashLogs];
    // 返回崩溃信息
    [[TJCrash sharedInstance].delegate TJMonitorCrashLogs:crashLogs];
    // 给之前的监听方法抛出异常
    if (previousHandler) {
        previousHandler(exception);
    }
}

// 存储崩溃信息到本地
- (void)saveCrashLogs:(NSArray *)crashLogs
{
    [[NSUserDefaults standardUserDefaults] setObject:crashLogs forKey:CrashLog];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 读取本地崩溃信息
- (NSArray *)getCrashLogs
{
    NSArray *crashLogs = [[NSUserDefaults standardUserDefaults] objectForKey:CrashLog];
    if (crashLogs == nil) {
        crashLogs = [NSArray array];
    }
    return crashLogs;
}

// 清理已处理的崩溃缓存
- (void)TJCleanCrashLog:(NSDictionary *)crashLogDic
{
    NSMutableArray *crashLogArr = [NSMutableArray arrayWithArray:[self getCrashLogs]];  // 缓存多个崩溃日志
    for (NSDictionary *dic in crashLogArr) {
        if ([[dic valueForKey:@"timestamp"] isEqualToString:[crashLogDic valueForKey:@"timestamp"]]) {
            [crashLogArr removeObject:dic];
            break;
        }
    }
    // 缓存崩溃信息
    [self saveCrashLogs:crashLogArr];
}

//整理当前APP信息
- (NSDictionary *)getAppInfo
{
    //应用信息
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *app_name = [infoDic valueForKey:@"CFBundleDisplayName"];
    if (!app_name) {
        app_name = @"null";
    }
    NSString *app_version = [infoDic valueForKey:@"CFBundleShortVersionString"];
    if (!app_version) {
        app_version = @"null";
    }
    //手机信息
    NSString *system_version = [[UIDevice currentDevice] systemVersion];
    if (!system_version) {
        system_version = @"null";
    }
    NSDictionary *appInfo = @{
        @"app_name": app_name,
        @"app_version": app_version,
        @"system_version": system_version,
    };
    return appInfo;
}

@end
