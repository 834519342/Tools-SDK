//
//  TJNotificationModel.m
//  TJLocalPush
//
//  Created by 谭杰 on 2017/1/13.
//  Copyright © 2017年 谭杰. All rights reserved.
//

#import "TJNotificationModel.h"

@implementation TJNotificationModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.title = nil;
        self.body = nil;
        self.subtitle = nil;
        self.hour = 0;
        self.minute = 0;
        self.second = 0;
        self.categoryIdentifier = nil;
        self.launchImageName = nil;
        self.sound = nil;
        self.badge = 1;
        self.userInfo = nil;
        self.attachments = nil;
//        self.calendarUnit = NSCalendarUnitYear;
    }
    return self;
}

@end
