//
//  TJVersion.m
//  TJVersion
//
//  Created by 谭杰 on 2016/12/14.
//  Copyright © 2016年 谭杰. All rights reserved.
//

#import "TJVersion.h"
#import <StoreKit/StoreKit.h>

#import "TJAppInfo.h"
#import "TJVersionRequest.h"

@interface TJVersion ()<SKStoreProductViewControllerDelegate>

@property (nonatomic, strong) TJAppInfo *appInfo;

@end

@implementation TJVersion

//检测新版本(使用默认提示框)
+ (void)checkNewVersion {
    
    [[TJVersion shardManger] checkNewVersion];
}

//检查新版本(自定义提醒)
+ (void)checkNewVersionAndCustomAlert:(NewVersionBlock)newVersion {
    
    [[TJVersion shardManger] checkNewVersionAndCustomAlert:^(TJAppInfo *appInfo) {
        if (newVersion) {
            newVersion(appInfo);
        }
    }];
}

//创建一个单例
+ (TJVersion *)shardManger {
    
    static TJVersion *instance = nil;
    //只执行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[TJVersion alloc] init];
        
    });
    return instance;
}

//新版本信息提示,默认提示
- (void)checkNewVersion {
    
    [self requestVersion:^(TJAppInfo *appInfo) {
        if (appInfo) {
            NSString *updateMsg = [NSString stringWithFormat:@"%@",appInfo.releaseNotes];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"发现新版本" message:updateMsg preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self openInAppStoreForAppURL:self.appInfo.trackViewUrl];
            }]];
            
            [[self window].rootViewController presentViewController:alert animated:YES completion:nil];
        }
    }];
}

//获取window
- (UIWindow *)window {
    
    UIWindow *window = nil;
    id<UIApplicationDelegate> delegate = [UIApplication sharedApplication].delegate;
    //respondsToSelector是实例方法也是类方法，用于判断某个类／实例是否能处理某个方法（包括基类方法）
    if ([delegate respondsToSelector:@selector(window)]) {
        window = [delegate performSelector:@selector(window)];
    }else {
        window = [[UIApplication sharedApplication] keyWindow];
    }
    
    return window;
}

//打开下载链接
- (void)openInAppStoreForAppURL:(NSString *)appURL
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_10_0
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appURL]];
#endif

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_10_0
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appURL] options:@{} completionHandler:^(BOOL success) {
    }];
#endif
}

//在应用内打开下载页面
+ (void)openInStoreProductViewControllerForAppId:(NSString *)appId {
    
    [[TJVersion shardManger] openInStoreProductViewControllerForAppId:appId];
}

/**
 *  从iOS6以后苹果提供了在应用内部打开AppStore中某一个应用下载页面的方式，
 *  提供了一个SKStoreProductViewController的类对该功能进行支持
 *
 *  首先，需要导入#import <StoreKit/StoreKit.h>
 *  其次，需要遵守<SKStoreProductViewControllerDelegate>这个协议
 *  最后，在该类中写入以下代码即可
 */

- (void)openInStoreProductViewControllerForAppId:(NSString *)appId {
    
    SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc] init];
    NSDictionary *dict = [NSDictionary dictionaryWithObject:appId forKey:SKStoreProductParameterITunesItemIdentifier];
    storeProductVC.delegate = self;
    /**
     *  //App的AppID，该Key所关联的值是一个NSNumber类型。支持iOS6以后的系统版本。
     *  SK_EXTERN NSString * const SKStoreProductParameterITunesItemIdentifier NS_AVAILABLE_IOS(6_0);
     *
     *  //附属令牌，该Key所关联的值是NSString类型。例如在iBook中app的ID，是iOS8中新添加的，支持iOS8以后的系统版本。
     *  SK_EXTERN NSString * const SKStoreProductParameterAffiliateToken NS_AVAILABLE_IOS(8_0);
     *
     *  //混合令牌，该Key所关联的值是一个40byte的NSString类型，使用这个令牌，你能看到点击和销售的数据报告。支持iOS8以后的系统版本。
     *  SK_EXTERN NSString * const SKStoreProductParameterCampaignToken NS_AVAILABLE_IOS(8_0);
     *
     *  //分析提供商令牌 (NSString)
     *  SK_EXTERN NSString * const SKStoreProductParameterProviderToken NS_AVAILABLE_IOS(8_3);
     *
     *  //广告合作伙伴令牌 (NSString)
     *  SK_EXTERN NSString * const SKStoreProductParameterAdvertisingPartnerToken NS_AVAILABLE_IOS(9_3);
     *
     */
    [storeProductVC loadProductWithParameters:dict completionBlock:^(BOOL result, NSError * _Nullable error) {
        if (result) {
            
            [[self window].rootViewController presentViewController:storeProductVC animated:YES completion:nil];
        }
    }];
    
}
#pragma mark SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

//检查新版本(自定义提醒)
- (void)checkNewVersionAndCustomAlert:(NewVersionBlock)newVersion {
    
    [self requestVersion:^(TJAppInfo *appInfo) {
        if (newVersion) {
            newVersion(appInfo);
        }
    }];
}

//获取新版本信息
- (void)requestVersion:(NewVersionBlock)newVersion {
    
    [TJVersionRequest requestVersionInfoSuccess:^(NSDictionary *responseDict) {
        
        NSInteger resultCount = [responseDict[@"resultCount"] integerValue];
        self.appInfo.resultCount = [NSString stringWithFormat:@"%ld",resultCount];
        //判断是否发布
        if (resultCount == 1)
        {
            NSArray *resultArray = responseDict[@"results"];
            NSDictionary *result = resultArray.firstObject;
            TJAppInfo *appInfo = [[TJAppInfo alloc] initWithResult:result];
            appInfo.resultCount = [NSString stringWithFormat:@"%ld",resultCount];
            NSString *version = appInfo.version;
            self.appInfo = appInfo;
            if ([self isNewVersion:version])
            {//新版本
                if (newVersion) {
                    newVersion(self.appInfo);
                }
            }else { //当前版本
                if (newVersion) {
                    newVersion(self.appInfo);
                }
            }
        }else {
            //没发布
            if (newVersion) {
                newVersion(self.appInfo);
            }
        }
        
    } failure:^(NSError *error) {
    }];
}

//判断新版本
- (BOOL)isNewVersion:(NSString *)newVersion {
    
    return [self newVersion:newVersion moreThanCurrentVersion:[self currentVersion]];
}

//获取已安装版本
- (NSString *)currentVersion {
    
    NSString *currentVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    return currentVersion;
}

//比较版本字符串大小
- (BOOL)newVersion:(NSString *)newVersion moreThanCurrentVersion:(NSString *)currentVersion {
    //按里面的数字顺序比较
    if ([currentVersion compare:newVersion options:NSNumericSearch] == NSOrderedAscending)
    {
        return YES;
    }
    
    return NO;
}

@end
