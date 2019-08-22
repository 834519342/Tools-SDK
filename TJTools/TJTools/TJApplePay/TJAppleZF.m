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

- (void)appleZFWithProductID:(NSString *)productID completionHandler:(AppleZFBlock)appleZFBlock
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
            [self handleActionWithType:PaymentNotAllowed data:nil];
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
        [self handleActionWithType:PaymentNoProduct data:nil];
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
        [self handleActionWithType:PaymentProductIdError data:nil];
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
                NSLog(@"商品被添加进支付队列");
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

//收据判断沙箱环境
//-(NSString * )environmentForReceipt:(NSString * )str
//{
//    str= [str stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
//    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//    str = [str stringByReplacingOccurrencesOfString:@"\t" withString:@""];
//    str=[str stringByReplacingOccurrencesOfString:@" " withString:@""];
//    str=[str stringByReplacingOccurrencesOfString:@"\"" withString:@""];
//    NSArray * arr=[str componentsSeparatedByString:@";"];
//    //存储收据环境的变量
//    NSString * environment=arr[2];
//    return environment;
//}

#pragma mark - 交易完成
- (void)completedTransactionsFinished:(SKPaymentTransaction *)transaction
{
    // 判断沙箱支付，iOS7以下
//        NSString * str = [[NSString alloc] initWithData:transaction.transactionReceipt encoding:NSUTF8StringEncoding];
//        NSString *environment=[self environmentForReceipt:str];
//        if ([environment isEqualToString:@"environment=Sandbox"])
//            NSLog(@"environment = %@",environment);
    
    // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
    NSURL *receiptURL= [[NSBundle mainBundle] appStoreReceiptURL];
    // 获取到购买凭据
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    if ([transaction.payment.productIdentifier length] > 0) {
        // 购买凭证
//        NSString *receipt = [transaction.transactionReceipt base64Encoding];
        NSString *receipt = [receiptData base64EncodedStringWithOptions:0];
//        [self verifyReceipt:receipt];
        [self handleActionWithType:PaymentSuccess data:receipt];
    }
    //移除支付队列
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

// 苹果服务器验证支付凭证
- (void)verifyReceipt:(NSString *)receipt
{
    // 根据地址判断沙箱支付
    NSString *receiptURLStr = [[[NSBundle mainBundle] appStoreReceiptURL] absoluteString];
    NSRange rangeSandbox = [receiptURLStr rangeOfString:@"sandbox"];
    // 根据是否是沙盒支付验证获取正确的地址
    NSURL *storeURL;
    if (rangeSandbox.location != NSNotFound) {
        NSLog(@"Sandbox Pay");
        storeURL= [[NSURL alloc] initWithString: @"https://sandbox.itunes.apple.com/verifyReceipt"];
    }else {
        storeURL= [[NSURL alloc] initWithString: @"https://buy.itunes.apple.com/verifyReceipt"];
    }
    // 验证服务器需要的凭证数据
    NSDictionary *requestContents = @{@"receipt-data": receipt};
    NSError *error;
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents options:0 error:&error];
    if (!requestData) {
        NSLog(@"%@", error);
        return;
    }
    // 开启全局异步线程来请求
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
        [storeRequest setHTTPMethod:@"POST"];
        [storeRequest setHTTPBody:requestData];
        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:storeRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                }else {
                    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if (responseDic) {
                        NSLog(@"%@", responseDic);
                    }
                }
            });
        }];
        [dataTask resume];
    });
}

#pragma mark - 交易失败
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    switch (transaction.error.code) {
        case SKErrorPaymentCancelled:
            [self handleActionWithType:PaymentCancel data:nil];
            break;
        default:
            [self handleActionWithType:PaymentFailed data:nil];
            break;
    }
    //移除支付队列
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)handleActionWithType:(SIAPPurchType)type data:(NSString *)data{
    NSString *resultStr;
    switch (type) {
        case PaymentCancel:
            resultStr = @"Payment Cancel";
            break;
        case PaymentSuccess:
            resultStr = @"Payment Success";
            break;
        case PaymentFailed:
            resultStr = @"Payment Failed";
            break;
        case PaymentNoProduct:
            resultStr = @"Payment No Product";
            break;
        case PaymentProductIdError:
            resultStr = @"Payment Product Id Error";
            break;
        case PaymentNotAllowed:
            resultStr = @"Payment Not Allowed";
            break;
        default:
            break;
    }
    
    if(self.appleBlock){
        if (data == nil) {
            data = @"NULL";
        }
        self.appleBlock(@{@"code":[NSNumber numberWithInt:type],@"message":resultStr,@"data":data});
    }
}

- (void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [TJToolTip hideActivity];
}

@end
