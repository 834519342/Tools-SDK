//
//  TJAlert.m
//  TJTools
//
//  Created by xt on 2018/11/1.
//  Copyright © 2018年 TJ. All rights reserved.
//

#import "TJAlert.h"

@interface TJAlert ()<NSCopying>

@end

@implementation TJAlert

+ (instancetype)sharedInstance
{
    static TJAlert *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[super allocWithZone:NULL] init];
        }
    });
    return instance;
}
//
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}
//
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (UIAlertController *)showAlertViewWithTitle:(NSString *)title message:(NSString *)message actionText:(NSArray<NSString *> *)actions resultAction:(void(^)(NSString *actionTitle))actionBlock
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    for (NSString *text in actions) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:text style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (actionBlock) {
                actionBlock(action.title);
            }
        }];
        [alert addAction:action];
    }
    //弹出
    if ([TJAlert getCurrentVC]) {
        [[TJAlert getCurrentVC] presentViewController:alert animated:YES completion:nil];
    }
    return alert;
}

- (UIAlertController *)showActionSheetViewWithTitle:(NSString *)title message:(NSString *)message actionText:(NSArray<NSString *> *)actions resultAction:(void(^)(NSString *actionTitle))actionBlock
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSString *text in actions) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:text style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (actionBlock) {
                actionBlock(action.title);
            }
        }];
        [alert addAction:action];
    }
    //弹出
    if ([TJAlert getCurrentVC]) {
        [[TJAlert getCurrentVC] presentViewController:alert animated:YES completion:nil];
    }
    return alert;
}

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

@end
