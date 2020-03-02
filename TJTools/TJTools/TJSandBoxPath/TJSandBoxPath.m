//
//  TJFileManager.m
//  TJTools
//
//  Created by admin on 2020/2/27.
//  Copyright © 2020 TJ. All rights reserved.
//

#import "TJSandBoxPath.h"

@interface TJSandBoxPath ()<NSCopying>

@end

@implementation TJSandBoxPath

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
// 规避创建新的单例
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}
// 规避创建新的单例
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (NSString *)getFilePathWithType:(DocPath)type
{
    NSString *path;
    switch (type) {
        case HomePath:
            path = NSHomeDirectory();
            break;
        case DocumentPath:
            path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
            break;
        case CachesPath:
            path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
            break;
        case PreferencePanesPath:
            path = NSSearchPathForDirectoriesInDomains(NSPreferencePanesDirectory, NSUserDomainMask, YES).firstObject;
            break;
        case Application_SupportPath:
            path = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES).firstObject;
            break;
        case tmpPath:
            path = NSTemporaryDirectory();
            break;
        default:
            path = @"";
            break;
    }
    return path;
}

@end
