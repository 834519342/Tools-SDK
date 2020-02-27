//
//  TJFileManager.m
//  TJTools
//
//  Created by admin on 2020/2/27.
//  Copyright © 2020 TJ. All rights reserved.
//

#import "TJSandBoxPath.h"

@implementation TJSandBoxPath

+ (instancetype)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    });
    return instance;
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
