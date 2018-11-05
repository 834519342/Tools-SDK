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

#pragma mark iOS10以上推送

+ (UNUserNotificationCenter *)pushCenter
{
    return [UNUserNotificationCenter currentNotificationCenter];
}

+ (void)registLocalNotificationWithDelegate:(id<UNUserNotificationCenterDelegate>)delegate withCompletionHandler:(void(^)(BOOL granted, NSError *error))completionHandler
{
    if (delegate) {
        //监听代理
        [TJLocalPush pushCenter].delegate = delegate;
        
        UNAuthorizationOptions options = (UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge);
        
        [[TJLocalPush pushCenter] requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if(completionHandler) {
                completionHandler(granted, error);
            }
        }];
    }else {
        if(completionHandler) {
            completionHandler(NO, nil);
        }
    }
}

+ (void)addLocalPushWithModel:(TJNotificationModel *)pushModel PushModel:(void(^)(TJNotificationModel *pushModel))pushBlock withCompletionHandler:(void(^)(NSError *error))completionHandler
{
    //创建<UNMutableNotificationContent>可变对象,注意不是<UNNotificationContent>,此对象不可变.
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    //标题
    if (pushModel.title) {
        content.title = [NSString localizedUserNotificationStringForKey:pushModel.title arguments:nil];
    }
    //内容
    if (pushModel.body) {
        content.body = [NSString localizedUserNotificationStringForKey:pushModel.body arguments:nil];
    }
    //详细内容
    if (pushModel.subtitle) {
        content.subtitle = pushModel.subtitle;
    }
    //附带信息
    if (pushModel.userInfo) {
        content.userInfo = pushModel.userInfo;
    }
    //附带媒体信息
    if (pushModel.attachments) {
        content.attachments = pushModel.attachments;
    }
    //启动图
    if (pushModel.launchImageName) {
        content.launchImageName = pushModel.launchImageName;
    }
    //推送声音
    if (pushModel.sound) {
        content.sound = [UNNotificationSound soundNamed:pushModel.sound];
    }else {
        content.sound = [UNNotificationSound defaultSound];
    }
    //设置拓展ID
    if (pushModel.launchImageName) {
        content.launchImageName = pushModel.launchImageName;
    }
    //通知角标
    content.badge = [NSNumber numberWithInt:pushModel.badge];
    //categoryIdentifier
    if (pushModel.categoryIdentifier) {
        content.categoryIdentifier = pushModel.categoryIdentifier;
    }else {
        content.categoryIdentifier = @"requestIdentifier";
        pushModel.categoryIdentifier = content.categoryIdentifier;
    }
    //延迟推送,repeats:是否重复
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:content.categoryIdentifier content:content trigger:[TJLocalPush defaultCalendarNotificationTrigger]];
    //如果是更新先移除
    if (pushModel.type == TJPushMessageTypeUpdate) {
        [[TJLocalPush pushCenter] removeDeliveredNotificationsWithIdentifiers:@[content.categoryIdentifier]];
    }
    //添加推送
    [[TJLocalPush pushCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            if (completionHandler) {
                completionHandler(error);
            }
        }else {
            if (pushBlock) {
                pushBlock(pushModel);
            }
        }
    }];
}

+ (void)removeLocalPushWithCategoryId:(NSString *)categoryIdentifier withCompletionHandler:(void(^)(NSError *error))completionHandler
{
    //获取通知中心所有的通知对象,遍历查找
    [[TJLocalPush pushCenter] getNotificationCategoriesWithCompletionHandler:^(NSSet<UNNotificationCategory *> * _Nonnull categories) {
        NSError *error;
        NSEnumerator *enumerator = [categories objectEnumerator];
        for (UNNotificationCategory *object in enumerator) {
            if ([object.identifier isEqualToString:categoryIdentifier]) {
                [[TJLocalPush pushCenter] setNotificationCategories:[NSSet setWithObjects:[UNNotificationCategory categoryWithIdentifier:categoryIdentifier actions:@[] intentIdentifiers:@[] options:UNNotificationCategoryOptionNone], nil]];
                error = nil;
                if (completionHandler) {
                    completionHandler(error);
                }
            }else {
                error = [[NSError alloc] initWithDomain:@"没有匹配的通知对象" code:100 userInfo:nil];
                if (completionHandler) {
                    completionHandler(error);
                }
            }
        }
    }];
}

//默认的延时推送触发时机
+ (UNTimeIntervalNotificationTrigger *)defaultTimeIntervalNotificationTrigger API_AVAILABLE(ios(10.0))
{
    return [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:10 repeats:NO];
}

//日历推送时间
+ (UNCalendarNotificationTrigger *)defaultCalendarNotificationTrigger API_AVAILABLE(ios(10.0))
{
    NSDateComponents *dateCompents = [NSDateComponents new];
    dateCompents.hour = 18;
    dateCompents.minute = 57;
    return [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateCompents repeats:YES];
}














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
//        NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
        //定时通知
//        NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
//        dateComponents.hour = model.hour;
//        dateComponents.minute = model.minute;
//        dateComponents.minute = model.second;
//        NSDate *fireDate = [calendar dateFromComponents:dateComponents];
        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:model.second];
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
