//
//  TJNotificationModel.h
//  TJLocalPush
//
//  Created by TJ on 2017/1/13.
//  Copyright © 2017年 TJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>


//由于iOS10推送的可更新性，还新增了一个枚举，当然，本来是不需要的，但为了测试才有的这个枚举类型
typedef NS_ENUM(NSUInteger, TJPushMessageType)
{
    TJPushMessageTypeNew = 0,     /**<默认为推送新的推送通知*/
    TJPushMessageTypeUpdate = 1,  /**<更新当前的推送通知*/
};

@interface TJNotificationModel : NSObject

@property (nonatomic, readwrite) TJPushMessageType type;

//推送标题
@property (nonatomic, copy) NSString *title;

//推送内容
@property (nonatomic, copy) NSString *body;

//推送详细内容
@property (nonatomic, copy) NSString *subtitle;

//附带自定义信息
@property (nonatomic, copy) NSDictionary *userInfo;

//定时(小时)
@property (nonatomic, assign) int hour;

//定时(分)
@property (nonatomic, assign) int minute;

//定时(秒)
@property (nonatomic, assign) int second;

//附带媒体信息
@property (nonatomic, copy) NSArray<UNNotificationAttachment *> *attachments API_AVAILABLE(ios(10.0));

//启动图
@property (nonatomic, copy) NSString *launchImageName;

//推送声音
@property (nonatomic, copy) NSString *sound;

//拓展ID
@property (nonatomic, copy) NSString *categoryIdentifier;

//通知数量
@property (nonatomic, assign) int badge;

@end
