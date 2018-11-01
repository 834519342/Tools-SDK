//
//  TJAppInfo.h
//  TJVersion
//
//  Created by 谭杰 on 2016/12/14.
//  Copyright © 2016年 谭杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TJAppInfo : NSObject

//是否发布
@property (nonatomic, strong) NSString *resultCount;

//版本号
@property (nonatomic, copy) NSString *version;

//更新日志
@property (nonatomic, copy) NSString *releaseNotes;

//更新时间
@property (nonatomic, copy) NSString *currentVersionReleaseDate;

//APPId
@property (nonatomic, copy) NSString *trackId;

//bundleId
@property (nonatomic, copy) NSString *bundleId;

//AppStore地址
@property (nonatomic, copy) NSString *trackViewUrl;

//APP简介
@property (nonatomic, copy) NSString *appDescription;

//开发商
@property (nonatomic, copy) NSString *sellerName;

//文件大小
@property (nonatomic, copy) NSString *fileSizeBytes;

//展示图
@property (nonatomic, strong) NSArray *screenshotUrls;


- (instancetype)initWithResult:(NSDictionary *)result;

@end
