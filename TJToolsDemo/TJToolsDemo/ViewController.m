//
//  ViewController.m
//  TJToolsDemo
//
//  Created by xt on 2018/10/30.
//  Copyright © 2018年 TJ. All rights reserved.
//

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
    
    self.arr = @[@"TJVersion",@"TJCrash",@"TJAlert",@"TJNSString",@"TJToolTip",@"iOS9Push"];
    
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
        NSString *abc = @"wo shi yuan chuan";
        NSString *abc1 = [abc convertStringToHexStr];
        NSLog(@"%@,convertStringToHexStr:%@",abc,abc1);
        NSLog(@"%@,convertHexStrToString:%@",abc1,[abc1 convertHexStrToString]);
        NSLog(@"%@,MD5:%@",abc,[abc MD5]);
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
        model.title = @"iOS10Push_title";
        model.body = @"iOS10Push_body";
        model.userInfo = @{@"push":@"iOS10Push"};
        model.hour = 18;
        model.minute = 45;
        model.second = 10;
//        model.calendarUnit = NSCalendarUnitDay;
        
        if (@available(iOS 10.0, *)) {
            [TJLocalPush addLocalPushWithModel:model PushModel:^(TJNotificationModel * _Nonnull pushModel) {
                if (pushModel) {
                    [TJLocalPush removeLocalPushWithCategoryId:pushModel.categoryIdentifier withCompletionHandler:^(NSError * _Nonnull error) {
                        NSLog(@"%@",error);
                    }];
                }
            } withCompletionHandler:^(NSError * _Nonnull error) {
                NSLog(@"iOS10Push:error = %@",error);
            }];
        } else {
//        [TJLocalPush pushLocalNotificationWithModel:model ResultInfo:^(BOOL result, UILocalNotification * _Nonnull localNotification) {
//            NSLog(@"iOS9Push:%i",result);
//        }];
        }
    }
    
}


@end
