//
//  TJVersionRequest.h
//  TJVersion
//
//  Created by TJ on 2016/12/14.
//  Copyright © 2016年 TJ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RequestSucess) (NSDictionary *responseDict);

typedef void(^RequestFailure)(NSError *error);

@interface TJVersionRequest : NSObject

/**
 *  从AppStore中获取App信息
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 */

+ (void)requestVersionInfoSuccess:(RequestSucess)success failure:(RequestFailure)failure;

@end    
