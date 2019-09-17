//
//  TJAppleCode.m
//  LMGame
//
//  Created by LM on 2019/9/10.
//  Copyright © 2019 tj. All rights reserved.
//

#import "TJAppleCode.h"
#import <StoreKit/StoreKit.h>
#import "TJAccess.h"

@interface TJAppleCode ()<SKStoreProductViewControllerDelegate>

@end

@implementation TJAppleCode

+ (instancetype)shareInstance
{
    static TJAppleCode *instance = nil;
    if (instance == nil) {
        instance = [[TJAppleCode alloc] init];
    }
    return instance;
}

// 打开App Store
- (void)openInStoreProductViewControllerForAppId:(NSString *)appId
{
    SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc] init];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:appId forKey:SKStoreProductParameterITunesItemIdentifier];
    storeProductVC.delegate = self;
    [storeProductVC loadProductWithParameters:dict completionBlock:^(BOOL result, NSError * _Nullable error) {
        if (result) {
            [[TJAccess getCurrentVC] presentViewController:storeProductVC animated:YES completion:nil];
        }
    }];
}

#pragma mark SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

//打开评价页
+ (void)openReview:(ReviewModel *)reviewModel completionHandler:(void (^)(NSDictionary * _Nonnull))handler
{
    
    if (reviewModel.type == FiveStar) {
        if (@available(iOS 10.3, *)) {
            [SKStoreReviewController requestReview];
        } else {
            // Fallback on earlier versions
            reviewModel.type = StoreReview;
            [TJAppleCode openReview:reviewModel completionHandler:handler];
        }
    }else if (reviewModel.type == StoreReview) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/app/id%@?action=write-review", reviewModel.AppID]];
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                if (success) {
                    if (handler) {
                        handler(@{@"ret": [NSNumber numberWithBool:success], @"message": @"open success"});
                    }
                }else {
                    if (handler) {
                        handler(@{@"ret": [NSNumber numberWithBool:success], @"message": @"open failed"});
                    }
                }
            }];
        } else {
            // Fallback on earlier versions
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
                if (handler) {
                    handler(@{@"ret": [NSNumber numberWithBool:YES], @"message": @"open success"});
                }
            }else {
                if (handler) {
                    handler(@{@"ret": [NSNumber numberWithBool:NO], @"message": @"open failed"});
                }
            }
        }
    }
}

// 系统分享
+ (void)systemShareWithModel:(ShareModel *)shareModel withViewController:(UIViewController *)vc completionHandler:(void(^)(NSDictionary *))handler
{
    shareModel.shareType = ShareLink;
    NSMutableArray *arr = [NSMutableArray array];
    if (shareModel.title) {
        [arr addObject:shareModel.title];
    }
    if (shareModel.URL) {
        [arr addObject:[NSURL URLWithString:shareModel.URL]];
    }
    if (shareModel.photoImages.count) {
        for (UIImage *image in shareModel.photoImages) {
            [arr addObject:UIImageJPEGRepresentation(image, 1.f)];
        }
    }else if (shareModel.photoDatas.count) {
        for (NSData *data in shareModel.photoDatas) {
            [arr addObject:data];
        }
    }
    if (vc == nil) {
        vc = [TJAccess getCurrentVC];
    }
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:arr applicationActivities:nil];
    // 关闭不要的项目
    NSMutableArray *ActivityTypes = [NSMutableArray array];
    if (@available(iOS 9.0, *)) {
        [ActivityTypes addObjectsFromArray:@[UIActivityTypePostToWeibo,UIActivityTypeMessage,UIActivityTypeMail,UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList,UIActivityTypePostToFlickr,UIActivityTypePostToVimeo,UIActivityTypePostToTencentWeibo,UIActivityTypeAirDrop,UIActivityTypeOpenInIBooks]];
    }
    if (@available(iOS 11.0, *)) {
        [ActivityTypes addObjectsFromArray:@[UIActivityTypeMarkupAsPDF]];
    }
    activityVC.excludedActivityTypes = ActivityTypes;
    [vc presentViewController:activityVC animated:YES completion:nil];
    activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        TJLog(@"分享平台:%@", [[activityType componentsSeparatedByString:@"."] lastObject]);
        if (completed) {
            if (handler) {
                NSDictionary *resultDic = @{@"ret": @1, @"message": @"Share Success"};
                handler(resultDic);
            }
        }else {
            if ([[[activityType componentsSeparatedByString:@"."] lastObject] isEqualToString:@"PostToFacebook"]) {
                // FaceBook分享
//                [[LMFacebook shareInstance] FBShareWithModel:shareModel withViewController:vc completionHandler:^(NSDictionary * _Nullable resultDic) {
//                    if (handler) {
//                        handler(resultDic);
//                    }
//                }];
            }else if ([[[activityType componentsSeparatedByString:@"."] lastObject] isEqualToString:@"PostToTwitter"]) {
                // 推特分享
//                [[LMTwitter shareInstance] TwitterShareWithModel:shareModel withViewController:vc completionHandler:^(NSDictionary * _Nullable resultDic) {
//                    if (handler) {
//                        handler(resultDic);
//                    }
//                }];
            }else if (handler) {
                NSDictionary *resultDic = @{@"ret": @0, @"message": @"Share Cancel"};
                handler(resultDic);
            }
        }
        if (activityError) {
            if (handler) {
                NSDictionary *resultDic = @{@"ret": @-1, @"message": @"Share Failed"};
                handler(resultDic);
            }
        }
    };
}

// 粘贴板功能
+ (void)CopyStrToPasteboard:(NSString *)pasteStr
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = pasteStr;
}

@end
