//
//  TJLocalPush.m
//  TJTools
//
//  Created by xt on 2018/11/2.
//  Copyright © 2018年 TJ. All rights reserved.
//

#import "TJLocalPush.h"
#import "TJNotificationModel.h"

@implementation TJLocalPush

#pragma mark iOS10以下推送
//注册通知
+ (BOOL)registLocalNotificationResult:(void(^)(BOOL result, NSError *error))resultBlock
{
    //判断是否已授权通知功能
    if ([UIApplication sharedApplication].currentUserNotificationSettings.types == UIUserNotificationTypeNone) {
        UIUserNotificationType type = (UIUserNotificationTypeAlert |
                                       UIUserNotificationTypeBadge |
                                       UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        if (resultBlock) {
            resultBlock(YES,nil);
        }
        return YES;
    }
    if (resultBlock) {
        resultBlock(NO,nil);
    }
    return NO;
}

//添加通知
+ (void)pushLocalNotificationWithModel:(TJNotificationModel *)model ResultInfo:(void(^)(BOOL result,UILocalNotification *localNotification))resultBlock
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    if (notification) {
        // 使用本地时区
        notification.timeZone = [NSTimeZone defaultTimeZone];
        //日历
        NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
        //定时通知
        NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
        dateComponents.hour = model.hour;
        dateComponents.minute = model.minute;
        dateComponents.minute = model.second;
        NSDate *fireDate = [calendar dateFromComponents:dateComponents];
        notification.fireDate = fireDate;
        //重复提示间隔
        notification.repeatInterval = model.calendarUnit;
        //通知标题
        notification.alertTitle = model.title;
        //通知内容
        notification.alertBody = model.body;
        //通知角标
        notification.applicationIconBadgeNumber += model.badge;
        //锁屏界面滑动提示
        notification.alertAction = @"打开应用";
        //点击通知打开应用启动图
        if (model.launchImageName) {
            notification.alertLaunchImage = model.launchImageName;
        }
        //通知声音
        if (model.sound) {
            notification.soundName = model.sound;
        }else {
            notification.soundName = UILocalNotificationDefaultSoundName;
        }
        //通知附加信息
        if (model.userInfo) {
            notification.userInfo = model.userInfo;
        }
        //添加通知
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        if (resultBlock) {
            resultBlock(YES,notification);
        }
    }else {
        resultBlock(NO,nil);
    }
}

//移除指定通知
+ (void)removeLocalNotification:(UILocalNotification *)notification
{
    if (notification) {
        [[UIApplication sharedApplication] cancelLocalNotification:notification];
        notification = nil;
    }
}

//移除所有通知
+ (void)removeAllLocalNotification
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

@end
