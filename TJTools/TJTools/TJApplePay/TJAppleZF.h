//
//  TJAppleZF.h
//  TJTools
//
//  Created by xt on 2018/11/6.
//  Copyright © 2018年 TJ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    PaymentCancel = 0,          // 取消购买
    PaymentSuccess = 1,         // 购买成功
    PaymentFailed = 2,          // 购买失败
    PaymentNoProduct = 3,       // 没有商品信息
    PaymentProductIdError = 4,  // 商品ID错误
    PaymentNotAllowed = 5,      // 不允许内购
}SIAPPurchType;

typedef void(^AppleZFBlock)(NSDictionary *resultDic);

@interface TJAppleZF : NSObject

+ (instancetype)shareIPA;

- (void)appleZFWithProductID:(NSString *)productID completionHandler:(AppleZFBlock)appleZFBlock;

@end

NS_ASSUME_NONNULL_END
