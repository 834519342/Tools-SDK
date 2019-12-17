//
//  ViewController.m
//  TJToolsDemo
//
//  Created by xt on 2018/10/30.
//  Copyright © 2018年 TJ. All rights reserved.
//

#define public_Key @"-----BEGIN PUBLIC KEY-----MFwwDQYJKoZIhvcNAQEBBQADSwAwSAJBAL9TnR4/yVpJnYUGoHHTjaupCwqmplPD1unjG82ePAQu/5Ccs4IppJlB062x6X1YloisVhP3rBBFjSHZJDDmNhsCAwEAAQ==-----END PUBLIC KEY-----"
#define private_Key @"-----BEGIN PRIVATE KEY-----MIIBVQIBADANBgkqhkiG9w0BAQEFAASCAT8wggE7AgEAAkEAv1OdHj/JWkmdhQagcdONq6kLCqamU8PW6eMbzZ48BC7/kJyzgimkmUHTrbHpfViWiKxWE/esEEWNIdkkMOY2GwIDAQABAkEAheEZaYhS+lXW3rXzYZMaaEtCibJxYt4ALeuYkfounvGZCdt0yyAbeixcidbNyLUKkYVIUhIJF/aHejDKtM1NGQIhAPN10PBgn/yimwvxGXQQ9ic1fAV/gQOslHIeYdi6/ICnAiEAyS5hruW8GxeD+0nTmCo5RlpldwpLFjdWNL0Mi2LX+W0CIQCDPAvvtzYmWYSYUFN3JDl78zGySQPDdkDirwvxZwH7WwIgBa9l20dqtWlItYU0kYw/6hkL3P1ReeM+cGcXP6kfaVECIDkTEdmhyfnL0k8W1Zc6kOwUO3QQ3TV+q3A/iYGNthsR-----END PRIVATE KEY-----"

#import "ViewController.h"
#import <TJTools/TJTools.h>

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,TJCrashDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *arr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.arr = @[@"TJVersion",@"TJCrash",@"TJAlert",@"TJNSString",@"TJToolTip",@"iOS10Push",@"showActivity",@"TJAppleZF",@"TJKeychain",@"TJDeviceInfo",@"TJLocation",@"TJAppleCode"];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    //崩溃信息
    [[TJCrash sharedInstance] startWithDelegate:self];

    TJLog(@"%@", @"测试啊");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = self.arr[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        if (rand()%2) {
            [TJVersion checkNewVersion];
        }else {
            [TJVersion checkNewVersionAndCustomAlert:^(TJAppInfo *appInfo) {
                NSLog(@"应用信息:%@",appInfo);
            }];
        }
    }
    if (indexPath.row == 1) {
        NSLog(@"%@",self.arr[100]);
    }
    if (indexPath.row == 2) {
        if (rand()%2) {
            [[TJAlert sharedAlert] showAlertViewWithTitle:@"TJAlert" message:@"测试" actionText:@[@"按钮1",@"按钮2",@"按钮3"] resultAction:^(NSString *actionTitle) {
                NSLog(@"点击%@",actionTitle);
            }];
        }else {
            [[TJAlert sharedAlert] showActionSheetViewWithTitle:@"TJActionSheet" message:@"测试" actionText:@[@"按钮1",@"按钮2",@"按钮3"]  resultAction:^(NSString *actionTitle) {
                NSLog(@"点击%@",actionTitle);
            }];
        }
    }
    if (indexPath.row == 3) {
        NSString *str = @"woshiyuanchuan";
        NSString *str1 = [str TJ_StrConvertToHexStr];
        
        NSLog(@"十六进制字符串: str = %@, str1 = %@",[str1 TJ_HexStrConvertToStr], str1);
        
        str1 = [str TJ_Base64_encode];
        NSLog(@"base64: str = %@, str1 = %@", [str1 TJ_Base64_decode], str1);
        
        NSLog(@"MD5: str = %@, str1 = %@",str, [str TJ_MD5]);
        
        NSLog(@"SHA1: str = %@, str1 = %@", str, [str TJ_SHA1]);
        
        NSLog(@"Hmac-SHA256: str = %@, str1 = %@", str, [str TJ_HmacSHA256_WithKey:str]);
        
        str1 = [str TJ_AES256_EncryptWithKey:@"key"];
        NSLog(@"AES256:str = %@, str1 = %@", [str1 TJ_AES256_DecryptWithKey:@"key"], str1);
        
        str1 = [str TJ_RSAEncryptWithPublicKey:public_Key];
        NSLog(@"RSA:str = %@, str1 = %@", [str1 TJ_RSADecryptWithPrivateKey:private_Key], str1);
        
        str1 = [str TJ_RSASignWithPrivate:private_Key];
        NSLog(@"RSA_Sign:str1 = %@", str1);
        if (str1) {
            BOOL status = [str TJ_RSAVerifyWithSignatrue:str1 PublicKey:public_Key];
            if (status) {
                NSLog(@"RSA_Verify:验签成功");
            }else {
                NSLog(@"RSA_Verify:验签失败");
            }
        }
        
        [NSString getCurrentTimesWithFormatter:nil];
        [NSString getNowTimeTimestampWithFormatter:nil];
    }
    if (indexPath.row == 4) {
        if (rand()%2) {
            [TJToolTip showToolTipOnCenterWithMessage:@"测试" duration:0 clickToolTipBlock:^(NSString * _Nonnull message) {
                NSLog(@"%@",message);
            }];
        }else {
            [TJToolTip showToolTipOnTopWithMessage:@"测试" duration:5 clickToolTipBlock:^(NSString * _Nonnull message) {
                NSLog(@"%@",message);
            }];
        }
    }
    if (indexPath.row == 5) {
        TJNotificationModel *model = [[TJNotificationModel alloc] init];
        model.title = @"iOS10推送：上班打卡";
        model.body = @"上班打卡";
        model.userInfo = @{@"push":@"上班打卡"};
        //解析当前时间
//        NSArray *arr = [[NSString getCurrentTimesWithFormatter:@"HH:mm:ss"] componentsSeparatedByString:@":"];
        model.hour = 9;
        model.minute = 29;
        model.second = 0;
        model.categoryIdentifier = @"shangbandaka";
        
        TJNotificationModel *model1 = [[TJNotificationModel alloc] init];
        model1.title = @"iOS10推送：下班打卡";
        model1.body = @"下班打卡";
        model1.userInfo = @{@"push":@"下班打卡"};
        
        model1.hour = 18;
        model1.minute = 59;
        model1.second = 0;
        model.categoryIdentifier = @"xiabandaka";
        
        if (@available(iOS 10.0, *)) {
            [TJLocalPush addLocalPushWithModel:model PushModel:^(TJNotificationModel * _Nonnull pushModel) {
                NSLog(@"添加成功");
            } withCompletionHandler:^(NSError * _Nonnull error) {
                NSLog(@"iOS10Push:error = %@",error);
            }];
            
            [TJLocalPush addLocalPushWithModel:model1 PushModel:^(TJNotificationModel * _Nonnull pushModel) {
                NSLog(@"添加成功");
            } withCompletionHandler:^(NSError * _Nonnull error) {
                NSLog(@"iOS10Push:error = %@",error);
            }];
        }
    }
    if (indexPath.row == 6) {
        [TJToolTip showActivity];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [TJToolTip hideActivity];
        });
    }
    if (indexPath.row == 7) {
        OrderInfo *orderInfo = [[OrderInfo alloc] init];
        orderInfo.productIDs = @[@"recharge_6"];
        //    orderInfo.productIDs = @[@"recharge_6", @"recharge_12", @"recharge_30", @"recharge_68", @"recharge_128", @"recharge_328", @"recharge_648", @"shop1_14"];
        orderInfo.orderID = @"54618913546876168";
        orderInfo.shareSecret = @"f450802e3bf040ada450e42a7cf3916c";
        [[TJAppleZF shareInstance] appleZFWithProductID:orderInfo completionHandler:^(NSDictionary * _Nonnull resultDic) {
            NSLog(@"%@",resultDic);
        }];
    }
    if (indexPath.row == 8) {
        [TJKeychain setValue:@"save_value" forKey:@"save_key"];
        
        NSLog(@"%@", [TJKeychain valueForKey:@"save_key"]);
        
        [TJKeychain deleteValueForKey:@"save_key"];
        
        NSLog(@"%@", [TJKeychain valueForKey:@"save_key"]);
    }
    if (indexPath.row == 9) {
        [[TJDeviceInfo shareInstance] getDeviceInfoDic:^(NSDictionary * _Nonnull resultDic) {
            NSLog(@"%@", resultDic);
        }];
    }
    if (indexPath.row == 10) {
//        [[TJLocation shareInstance] startUpdatingLocation:^(NSDictionary * _Nonnull locationInfo) {
//            [[TJLocation shareInstance] stopUpdatingLocation];
//            NSLog(@"%@", locationInfo);
//        }];
        [[TJLocation shareInstance] requestLocation:^(NSDictionary * _Nonnull resultDic) {
            NSLog(@"%@", resultDic);
        }];
    }
    if (indexPath.row == 11) {
        [[TJAlert sharedAlert] showActionSheetViewWithTitle:@"TJAppleCode" message:@"选择使用功能" actionText:@[@"下载页", @"评价页", @"分享", @"粘贴板"] resultAction:^(NSString *actionTitle) {
            if ([actionTitle isEqualToString:@"下载页"]) {
                [[TJAppleCode shareInstance] openInStoreProductViewControllerForAppId:@"454638411"];
            }else if ([actionTitle isEqualToString:@"评价页"]) {
                ReviewModel *model = [[ReviewModel alloc] init];
                model.type = FiveStar;
                [TJAppleCode openReview:model completionHandler:^(NSDictionary * _Nonnull resultDic) {
                    NSLog(@"%@", resultDic);
                }];
            }else if ([actionTitle isEqualToString:@"分享"]) {
                ShareModel *model = [[ShareModel alloc] init];
                model.shareType = ShareLink;
                model.URL = @"https://www.baidu.com";
                [TJAppleCode systemShareWithModel:model withViewController:self completionHandler:^(NSDictionary * _Nonnull resultDic) {
                    NSLog(@"%@", resultDic);
                }];
            }else if ([actionTitle isEqualToString:@"粘贴板"]) {
                [TJAppleCode CopyStrToPasteboard:@"粘贴板测试内容"];
            }
        }];
    }
    
}

#pragma mark CrashDelegate
- (void)monitorCrashLogs:(NSArray *)crashLogs
{
    // 崩溃日志处理逻辑
    for (NSDictionary *dic in crashLogs) {
        NSLog(@"=======崩溃日志=======:%@", dic);
        // 上传日志
        // 删除日志缓存
        [[TJCrash sharedInstance] cleanCrashLog:dic];
    }
}

@end
