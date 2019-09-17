//
//  TJAlert.m
//  TJTools
//
//  Created by xt on 2018/11/1.
//  Copyright © 2018年 TJ. All rights reserved.
//

#import "TJAlert.h"
#import "TJAccess.h"

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
    if ([TJAccess getCurrentVC]) {
        [[TJAccess getCurrentVC] presentViewController:alert animated:YES completion:nil];
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
    if ([TJAccess getCurrentVC]) {
        [[TJAccess getCurrentVC] presentViewController:alert animated:YES completion:nil];
    }
    return alert;
}

@end
