//
//  TJLocalPush.m
//  TJTools
//
//  Created by xt on 2018/11/2.
//  Copyright © 2018年 TJ. All rights reserved.
//

#import "TJLocalPush.h"

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
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:content.categoryIdentifier content:content trigger:[TJLocalPush getCalendarTriggerWith:pushModel]];
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

//延时推送
+ (UNTimeIntervalNotificationTrigger *)getTimeIntervalTriggerWith:(TJNotificationModel *)pushModel API_AVAILABLE(ios(10.0))
{
    if(pushModel)
    {
        return [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:pushModel.second repeats:NO];
    }
    return [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:10 repeats:NO];
}

//日历推送
+ (UNCalendarNotificationTrigger *)getCalendarTriggerWith:(TJNotificationModel *)pushModel API_AVAILABLE(ios(10.0))
{
    if(pushModel)
    {
        NSDateComponents *dateCompents = [NSDateComponents new];
        dateCompents.hour = pushModel.hour;
        dateCompents.minute = pushModel.minute;
        dateCompents.second = pushModel.second;
        return [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateCompents repeats:YES];
    }
    return nil;
}

+ (void)getNotificationSettingsWithCompletionHandler:(void(^)(UNNotificationSettings *settings))completionHandler
{
    [[TJLocalPush pushCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if (completionHandler) {
            completionHandler(settings);
        }
    }];
}

@end
