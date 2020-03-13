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

@interface TJAppleZF ()<SKPaymentTransactionObserver, SKProductsRequestDelegate, NSCopying>

@property (nonatomic, copy) AppleZFBlock appleBlock;    //支付回调
@property (nonatomic, strong) NSMutableDictionary *ZFInfo;  //支付信息
@property (nonatomic, strong) NSString *shareSecret;    // 苹果后台共享密钥

@end

@implementation TJAppleZF

+ (instancetype)sharedInstance
{
    static TJAppleZF *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[super allocWithZone:NULL] init];
            //购买监听写在程序入口,程序挂起时移除监听,这样如果有未完成的订单将会自动执行并回调 paymentQueue:updatedTransactions:方法
            [[SKPaymentQueue defaultQueue] addTransactionObserver:instance];
        }
    });
    return instance;
}
//
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}
//
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (NSMutableDictionary *)ZFInfo
{
    if (_ZFInfo == nil) {
        _ZFInfo = [NSMutableDictionary dictionary];
    }
    return _ZFInfo;
}

- (void)appleZFWithProductID:(OrderInfo *)orderInfo completionHandler:(AppleZFBlock)appleZFBlock
{
    if (appleZFBlock) {
        self.appleBlock = appleZFBlock;
        self.shareSecret = orderInfo.shareSecret;
        // 清除缓存
        [self.ZFInfo removeAllObjects];
        //开始支付操作
        if ([SKPaymentQueue canMakePayments]) {
            [self.ZFInfo setValue:[orderInfo.productIDs firstObject] forKey:@"productID"];  // 回传 商品ID
            [self.ZFInfo setValue:orderInfo.orderID forKey:@"orderId"];    // 回传 服务器订单ID
            NSSet *set = [NSSet setWithArray:orderInfo.productIDs];
            SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
            request.delegate = self;
            [request start];
            //显示加载器
            if (orderInfo.productIDs.count == 1) {
                [TJToolTip showActivity];
            }
        }else {
            //不允许内购
            [self handleActionWithType:PaymentNotAllowed data:nil];
        }
    }
}

//// 获取当前账号区域价格：￥6.00
//- (NSString *)getCurrencyStyle:(SKProduct *)product
//{
//    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
//    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
//    [numberFormatter setLocale:product.priceLocale];
//    NSString *formattedString = [numberFormatter stringFromNumber:product.price];
//    return formattedString;
//}
//
//// 获取当前账号区域价格: CNY6.00
//- (NSString *)getCurrencyISOCodeStyle:(SKProduct *)product
//{
//    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
//    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyISOCodeStyle];
//    [numberFormatter setLocale:product.priceLocale];
//    NSString *formattedString = [numberFormatter stringFromNumber:product.price];
//    return formattedString;
//}

// 获取货币格式信息
- (NSNumberFormatter *)getNumberFormatter:(SKProduct *)product
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    return numberFormatter;
}

#pragma mark - SKProductsRequestDelegate
//查询结果
- (void)productsRequest:(nonnull SKProductsRequest *)request didReceiveResponse:(nonnull SKProductsResponse *)response
{
    NSArray *products = response.products;
    NSLog(@"请求产品数量:%lu",(unsigned long)[products count]);
    if (products.count <= 0) {
        [TJToolTip hideActivity];
        [self handleActionWithType:PaymentNoProduct data:nil];
        return;
    }else if (products.count == 1) {
        // 支付操作
        SKProduct *p = nil;
        for (SKProduct *product in products) {
            if ([product.productIdentifier isEqualToString:[self.ZFInfo valueForKey:@"productID"]]) {
                //商品信息
                p = product;
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
        NSLog(@"************商品信息**************");
        NSLog(@"%@",p.productIdentifier);
        NSLog(@"%@",p.localizedTitle);
        NSLog(@"%@",p.localizedDescription);
        NSLog(@"%@%@", [self getNumberFormatter:p].currencySymbol, p.price);
        NSLog(@"发送购买请求");
        NSLog(@"*********************************");
        [self.ZFInfo setValue:p.localizedTitle forKey:@"productName"];    //回传 商品名字
        [self.ZFInfo setValue:p.price forKey:@"price"];   //回传 价格数字
    }else if (products.count > 1) {
        // 获取商品价格表
        NSMutableDictionary *productInfoDic = [NSMutableDictionary dictionary];
        for (SKProduct *product in products) {
            NSDictionary *dic = @{@"currency": [NSString stringWithFormat:@"%@%@", [self getNumberFormatter:product].currencySymbol, product.price],
                                  @"ISOCode": [self getNumberFormatter:product].internationalCurrencySymbol,
                                  @"priceNum": product.price,
                                  };
            [productInfoDic setValue:dic forKey:product.productIdentifier];
        }
        [productInfoDic setValue:@"price list" forKey:@"message"];
        if (self.appleBlock) {
            self.appleBlock(productInfoDic);
        }
    }
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

#pragma mark - 交易完成
- (void)completedTransactionsFinished:(SKPaymentTransaction *)transaction
{
    // 普通支付和首次自动订阅，不会有值
    if (transaction.originalTransaction) {
        NSLog(@"自动订阅..................");
    }
    if ([transaction.payment.productIdentifier length] > 0) {
        // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
        NSURL *receiptURL= [[NSBundle mainBundle] appStoreReceiptURL];
        // 获取到购买凭据
        NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
        // 购买凭据
        NSString *receipt = [receiptData base64EncodedStringWithOptions:0];
        [self.ZFInfo setValue:transaction.transactionIdentifier forKey:@"TransactionID"];
//        [self verifyReceipt:receipt]; // 凭据验证
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

- (void)handleActionWithType:(SIAPPurchType)type data:(NSString *)receipt{
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
    [self.ZFInfo setValue:[NSNumber numberWithInt:type] forKey:@"code"];    // 回传 支付状态
    [self.ZFInfo setValue:resultStr forKey:@"message"];     // 回传 支付消息说明
    if (receipt) {
        [self.ZFInfo setValue:receipt forKey:@"receipt"];   // 回传 支付收据信息
    }
    if(self.appleBlock){
        self.appleBlock(self.ZFInfo);
    }
}

- (void)dealloc
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [TJToolTip hideActivity];
}

@end
