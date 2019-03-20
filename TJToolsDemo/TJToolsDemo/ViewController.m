//
//  ViewController.m
//  TJToolsDemo
//
//  Created by xt on 2018/10/30.
//  Copyright © 2018年 TJ. All rights reserved.
//

#define public_Key @"-----BEGIN PUBLIC KEY-----MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDL0YM5bgvHTu/pJkFuV2AWjzGMQnBDs/TRcJEvgvBswNZFt7X2h56aD1tIDW8wS0z95NK5MZJ5hAN/m8K+75KY7gqoPZdFbWDcgq3fJYcJytIykW2CMwyE0a4qR3t5lDPRbUEbai9kQsikaeyi/xjlGB2p+uDO52o70T+bqYf1fwIDAQAB-----END PUBLIC KEY-----"
#define private_Key @"-----BEGIN PRIVATE KEY-----MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAMvRgzluC8dO7+kmQW5XYBaPMYxCcEOz9NFwkS+C8GzA1kW3tfaHnpoPW0gNbzBLTP3k0rkxknmEA3+bwr7vkpjuCqg9l0VtYNyCrd8lhwnK0jKRbYIzDITRripHe3mUM9FtQRtqL2RCyKRp7KL/GOUYHan64M7najvRP5uph/V/AgMBAAECgYBllY7p2MdWFynL8p05+aKSm9v+JD7//3lNyeUS4RgjnBkvtlii/wU1k+HTD58TWvSMtrewRdzTY9C6kU+HCrDtVCLm5zdzDQplriX6/2V65IwzKE1Mm9QRy0uchjXFx3zaYC5xauH1p7xfmAKVqX8poZnXV1jFBXQ5ghxbQS91AQJBAOxLbpZYBDABlAZ+bXgDnP70LvmePJ8vQBbkTOjcnn4Maz8yVQlEmvVkuyJ9ureFujP0PBSwC1UmWGNm9HHzdRECQQDc0MHRpP9e35tOYukz36Mj92jRDN3NSpJLFEozZyXYX/BkSTKmPFp/+PO3JVEknRy3HeKiqa0Tim7SbqZbzIGPAkEAxfFarm8E8wIfcmEuar78IUeEom6/8cmvMn4FP3yw+H6GyOXs/lqORMshSH9yjpJjrWoHen0OwUHiAUMZuutrQQJAI0e7X+qT3q2tW7XT+rTFlQ6HkbcTjSRYAWTpghL96fdSKkPDsum7r+yvy9hLgaUUnHFK76Bahd+9WyPQsqQXIwJBAN1KPQhuvboAamMXuQcQwP7+lwVyUEqy/uzSgW+aYC6kFaCUaiz6H1R5Ybe7/Lk3Vr2Q1Rf7PjKbFUSCrEutXQg=-----END PRIVATE KEY-----"

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
    
    self.arr = @[@"TJVersion",@"TJCrash",@"TJAlert",@"TJNSString",@"TJToolTip",@"iOS10Push",@"showActivity",@"TJAppleZF"];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    //崩溃信息
    [[TJCrash sharedCrash] sendCrashInfoToEMail];
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
        NSLog(@"RSA:str = %@\nstr1 = %@", [str1 TJ_RSADecryptWithPrivateKey:private_Key], str1);
        
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
    
}

@end
