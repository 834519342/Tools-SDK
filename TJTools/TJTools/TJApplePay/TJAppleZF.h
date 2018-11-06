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
    SIAPPurchSuccess = 0,       // 购买成功
    SIAPPurchFailed = 1,        // 购买失败
    SIAPPurchCancle = 2,        // 取消购买
    SIAPPurchNoProduct = 3,     // 没有商品信息
    SIAPPurchProductIdError = 4, // 商品ID错误
    SIAPPurchNotArrow = 5,      // 不允许内购
    SIAPPurchVerFailed = 6,     // 订单校验失败
    SIAPPurchVerSuccess = 7,    // 订单校验成功
}SIAPPurchType;

typedef void(^AppleZFBlock)(NSDictionary *resultDic);

@interface TJAppleZF : NSObject

+ (instancetype)shareIPA;

- (void)appleZFWithProductID:(NSString *)productID resultBlock:(AppleZFBlock)appleZFBlock;

@end

NS_ASSUME_NONNULL_END
