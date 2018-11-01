//
//  TJCrash.m
//  TJTools
//
//  Created by xt on 2018/11/1.
//  Copyright © 2018年 TJ. All rights reserved.
//

#import "TJCrash.h"

#define CrashLog @"CrashLog"
#define DevelopEmail @"775124946@qq.com"

@interface TJCrash ()<MFMailComposeViewControllerDelegate>

@end

@implementation TJCrash

+ (instancetype)sharedCrash
{
    static TJCrash *ex = nil;
    if (ex == nil) {
        ex = [[TJCrash alloc] init];
        NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    }
    return ex;
}

//监控崩溃日志
void UncaughtExceptionHandler(NSException *exception) {
    
    NSString *name = [exception name];
    NSString *reason = [exception reason];
    NSArray *callStackSymbols = [exception callStackSymbols];
    //崩溃消息
    NSString *exceptionInfo = [NSString stringWithFormat:@"%@Exception_Crash:\nName:%@\nReason:%@\nCallStackSymbols:%@",[[TJCrash sharedCrash] getAppInfo],name,reason,callStackSymbols];
    NSLog(@"\n%@",exceptionInfo);
    //保存崩溃信息
    [[TJCrash sharedCrash] saveCrashLog:exceptionInfo];
}

//存储崩溃信息到本地
- (void)saveCrashLog:(NSString *)crashLog
{
    [[NSUserDefaults standardUserDefaults] setObject:crashLog forKey:CrashLog];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//读取本地存储的崩溃信息
- (NSString *)getCrashLog
{
    NSString *crashLog = [[NSUserDefaults standardUserDefaults] objectForKey:CrashLog];
    return crashLog;
}

//整理当前APP信息
- (NSString *)getAppInfo
{
    //应用信息
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    
    NSString *app_name = [infoDic objectForKey:@"CFBundleDisplayName"];
    NSString *app_version = [infoDic objectForKey:@"CFBundleShortVersionString"];
    
    //手机信息
    NSString *phone_system_version = [[UIDevice currentDevice] systemVersion];
    
    NSString *infoStr = [NSString stringWithFormat:@"应用名称:%@(%@)\n系统版本:iOS(%@)\n\n",app_name,app_version,phone_system_version];
    
    return infoStr;
}

//发送邮件
- (void)sendCrashInfoToEMail
{
    if ([self getCrashLog])
    {
        MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
        [mailCompose setMailComposeDelegate:self];
        //收件人
        [mailCompose setToRecipients:@[DevelopEmail]];
        //邮件主题
        [mailCompose setSubject:[NSString stringWithFormat:@"【崩溃信息】%@",[self getAppInfo]]];
        //邮件正文
        [mailCompose setMessageBody:[self getCrashLog] isHTML:NO];
        //弹出邮箱界面
        if ([[TJAlert sharedAlert] getCurrentVC]) {
            [[[TJAlert sharedAlert] getCurrentVC] presentViewController:mailCompose animated:YES completion:nil];
        }
    }
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"用户取消发送");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"用户保存邮件");
            break;
        case MFMailComposeResultSent:
            NSLog(@"用户点击发送");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"用户尝试保存或发送邮件失败");
            break;
        default:
            break;
    }
    [[[TJAlert sharedAlert] getCurrentVC] dismissViewControllerAnimated:YES completion:^{
        NSLog(@"提示一次之后清除崩溃日志");
        [self saveCrashLog:nil];
    }];
}

@end
