//
//  TJAlert.m
//  TJTools
//
//  Created by xt on 2018/11/1.
//  Copyright © 2018年 TJ. All rights reserved.
//

#import "TJAlert.h"

@implementation TJAlert

+ (instancetype)sharedAlert
{
    static TJAlert *alert = nil;
    if (alert == nil) {
        alert = [[TJAlert alloc] init];
    }
    return alert;
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
    if ([self getCurrentVC]) {
        [[self getCurrentVC] presentViewController:alert animated:YES completion:nil];
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
    if ([self getCurrentVC]) {
        [[self getCurrentVC] presentViewController:alert animated:YES completion:nil];
    }
    return alert;
}

- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal){
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows){
            if (tmpWin.windowLevel == UIWindowLevelNormal){
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    if (result) {
        return result;
    }else {
        return [[[UIApplication sharedApplication].windows lastObject] rootViewController];
    }
}

@end
