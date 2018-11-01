//
//  TJAppInfo.m
//  TJVersion
//
//  Created by 谭杰 on 2016/12/14.
//  Copyright © 2016年 谭杰. All rights reserved.
//

#import "TJAppInfo.h"

@implementation TJAppInfo

- (instancetype)initWithResult:(NSDictionary *)result {
    
    self = [super init];
    if (self) {
        self.version = result[@"version"];
        self.releaseNotes = result[@"releaseNotes"];
        self.currentVersionReleaseDate = result[@"currentVersionReleaseDate"];
        self.trackId = result[@"trackId"];
        self.bundleId = result[@"bundleId"];
        self.trackViewUrl = result[@"trackViewUrl"];
        self.appDescription = result[@"appDescription"];
        self.sellerName = result[@"sellerName"];
        self.fileSizeBytes = result[@"fileSizeBytes"];
        self.screenshotUrls = result[@"screenshotUrls"];
    }
    return self;
}

@end
