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

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *arr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.arr = @[@"TJVersion",@"TJCrash",@"TJAlert",@"TJNSString",@"TJToolTip",@"iOS10Push",@"showActivity",@"TJAppleZF",@"TJKeychain",@"TJDeviceInfo",@"TJLocation"];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    //崩溃信息
//    [[TJCrash sharedCrash] sendCrashInfoToEMail];
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
        [[TJAppleZF shareIPA] appleZFWithProductID:@"10001" resultBlock:^(NSDictionary * _Nonnull resultDic) {
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
        [[TJDeviceInfo shareInstance] getDeviceInfoDic:^(NSDictionary * _Nonnull deviceInfo) {
            NSLog(@"%@", deviceInfo);
        }];
    }
    if (indexPath.row == 10) {
        [[TJLocation shareInstance] startUpdatingLocation:^(NSDictionary * _Nonnull locationInfo) {
            [[TJLocation shareInstance] stopUpdatingLocation];
            NSLog(@"%@", locationInfo);
        }];
    }
    
}

@end
