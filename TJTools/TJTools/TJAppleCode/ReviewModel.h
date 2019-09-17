//
//  ReViewModel.h
//  LMGame
//
//  Created by LM on 2019/9/10.
//  Copyright © 2019 tj. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    FiveStar = 0,   //五星好评提示框
    StoreReview = 1, //商城评论页面
}ReviewType;

@interface ReviewModel : NSObject

@property (nonatomic, strong) NSString *AppID;  // 苹果应用ID

@property (nonatomic, strong) NSString *title; // 提示框标题

@property (nonatomic, assign) ReviewType type;  // 评论类型

@end

NS_ASSUME_NONNULL_END
