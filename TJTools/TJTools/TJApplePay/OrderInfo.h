//
//  OrderInfo.h
//  LMGame
//
//  Created by LM on 2019/8/26.
//  Copyright © 2019 tj. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OrderInfo : NSObject

@property (nonatomic, strong) NSString *orderID;    // 服务器订单ID

@property (nonatomic, strong) NSArray *productIDs;  // 商品ID

@property (nonatomic, strong) NSString *shareSecret; // 共享密钥

@end

NS_ASSUME_NONNULL_END
