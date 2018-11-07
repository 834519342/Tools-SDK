//
//  TJAppleZF.m
//  TJTools
//
//  Created by xt on 2018/11/6.
//  Copyright © 2018年 TJ. All rights reserved.
//

#import "TJAppleZF.h"
#import <StoreKit/StoreKit.h>
#import "TJToolTip.h"
#import "TJAlert.h"

@interface TJAppleZF ()<SKPaymentTransactionObserver,SKProductsRequestDelegate>

@property (nonatomic, copy) AppleZFBlock appleBlock;

@property (nonatomic, strong) NSString *productIdentifier;

@end

@implementation TJAppleZF

+ (instancetype)shareIPA
{
    static TJAppleZF *appleZF = nil;
    if (appleZF == nil) {
        appleZF = [[TJAppleZF alloc] init];
        //购买监听写在程序入口,程序挂起时移除监听,这样如果有未完成的订单将会自动执行并回调 paymentQueue:updatedTransactions:方法
        [[SKPaymentQueue defaultQueue] addTransactionObserver:appleZF];
    }
    return appleZF;
}

- (void)appleZFWithProductID:(NSString *)productID resultBlock:(AppleZFBlock)appleZFBlock
{
    if (appleZFBlock) {
        self.appleBlock = appleZFBlock;
        self.productIdentifier = productID;
        
        //开始支付操作
        if ([SKPaymentQueue canMakePayments]) {
            NSSet *set = [NSSet setWithArray:@[productID]];
            SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
            request.delegate = self;
            [request start];
            //显示加载器
            [TJToolTip showActivity];
        }else {
            //不允许内购
            [self handleActionWithType:SIAPPurchNotArrow data:nil];
        }
        
    }
}

#pragma mark - SKProductsRequestDelegate
//查询结果
- (void)productsRequest:(nonnull SKProductsRequest *)request didReceiveResponse:(nonnull SKProductsResponse *)response
{
    NSArray *product = response.products;
    if ([product count] <= 0) {
        [TJToolTip hideActivity];
        [self handleActionWithType:SIAPPurchNoProduct data:nil];
        return;
    }
    
    SKProduct *p = nil;
    for (SKProduct *pro in product) {
        if ([pro.productIdentifier isEqualToString:self.productIdentifier]) {
            //商品信息
            p = pro;
            break;
        }
    }
    if (p) {
        //购买请求
        SKPayment *zfMent = [SKPayment paymentWithProduct:p];
        [[SKPaymentQueue defaultQueue] addPayment:zfMent];
    }else {
        [TJToolTip hideActivity];
        [self handleActionWithType:SIAPPurchProductIdError data:nil];
    }
    
    //商品信息
    NSLog(@"************商品信息**************");
    NSLog(@"productID:%@", response.invalidProductIdentifiers);
    NSLog(@"产品付费数量:%lu",(unsigned long)[product count]);
    NSLog(@"%@",[p description]);
    NSLog(@"%@",[p localizedTitle]);
    NSLog(@"%@",[p localizedDescription]);
    NSLog(@"%@",[p price]);
    NSLog(@"%@",[p productIdentifier]);
    NSLog(@"发送购买请求");
    NSLog(@"*********************************");
}

//请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"%s",__func__);
}

//请求成功
- (void)requestDidFinish:(SKRequest *)request
{
    NSLog(@"%s",__func__);
}

#pragma mark - SKPaymentTransactionObserver
//购买完成结果
- (void)paymentQueue:(nonnull SKPaymentQueue *)queue updatedTransactions:(nonnull NSArray<SKPaymentTransaction *> *)transactions
{
    for (SKPaymentTransaction *tran in transactions) {
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品添加进列表");
                break;
            case SKPaymentTransactionStatePurchased:
                NSLog(@"交易完成");
                [TJToolTip hideActivity];
                [self completedTransactionsFinished:tran];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"交易失败");
                [TJToolTip hideActivity];
                [self failedTransaction:tran];
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"已经购买过商品");
                [TJToolTip hideActivity];
                //移除支付队列
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                break;
            case SKPaymentTransactionStateDeferred:
                NSLog(@"最终状态未确认");
                [TJToolTip hideActivity];
                break;
            default:
                break;
        }
    }
}

#pragma mark - 交易完成
- (void)completedTransactionsFinished:(SKPaymentTransaction *)transaction
{
    //判断沙箱支付
    NSString * str = [[NSString alloc]initWithData:transaction.transactionReceipt encoding:NSUTF8StringEncoding];
    NSString *environment=[self environmentForReceipt:str];
    
    if ([environment isEqualToString:@"environment=Sandbox"])
    {
        NSLog(@"environment = %@",environment);
    }
    
    NSString *productIdentifier = transaction.payment.productIdentifier;
    if ([productIdentifier length] > 0) {
        //购买凭证
        NSString *receipt = [transaction.transactionReceipt base64Encoding];
        [self handleActionWithType:SIAPPurchSuccess data:receipt];
    }
    
    //移除支付队列
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

//收据判断沙箱环境
-(NSString * )environmentForReceipt:(NSString * )str
{
    str= [str stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    str = [str stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    
    str=[str stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    str=[str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    NSArray * arr=[str componentsSeparatedByString:@";"];
    
    //存储收据环境的变量
    NSString * environment=arr[2];
    return environment;
}

#pragma mark - 交易失败
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        [self handleActionWithType:SIAPPurchFailed data:nil];
    }else{
        [self handleActionWithType:SIAPPurchCancle data:nil];
    }
    //移除支付队列
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)handleActionWithType:(SIAPPurchType)type data:(NSString *)data{
    NSString *resultStr;
    switch (type) {
        case SIAPPurchSuccess:
            resultStr = @"购买成功";
            break;
        case SIAPPurchFailed:
            resultStr = @"购买失败";
            break;
        case SIAPPurchCancle:
            resultStr = @"用户取消购买";
            break;
        case SIAPPurchNoProduct:
            resultStr = @"获取商品信息失败";
            break;
        case SIAPPurchProductIdError:
            resultStr = @"商品ID错误";
            break;
        case SIAPPurchNotArrow:
            resultStr = @"不允许程序内付费";
            break;
        case SIAPPurchVerFailed:
            resultStr = @"订单校验失败";
            break;
        case SIAPPurchVerSuccess:
            resultStr = @"订单校验成功";
            break;
        default:
            break;
    }
    
    [[TJAlert sharedAlert] showAlertViewWithTitle:@"支付提示" message:resultStr actionText:@[@"确定"] resultAction:^(NSString *actionTitle) {
    }];
    
    if(self.appleBlock){
        if (data == nil) {
            data = [[NSString alloc] init];
        }
        self.appleBlock(@{@"code":[NSString stringWithFormat:@"%d",type],@"message":resultStr,@"data":data});
    }
}

- (void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [TJToolTip hideActivity];
}

@end
