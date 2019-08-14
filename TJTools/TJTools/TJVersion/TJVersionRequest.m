//
//  TJVersionRequest.m
//  TJVersion
//
//  Created by 谭杰 on 2016/12/14.
//  Copyright © 2016年 谭杰. All rights reserved.
//

#import "TJVersionRequest.h"

@implementation TJVersionRequest

+ (void)requestVersionInfoSuccess:(RequestSucess)success failure:(RequestFailure)failure {
    
    NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString *)kCFBundleIdentifierKey];
//    bundleId = @"com.linkedtech.joyRunner";       //测试bundleID
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@",bundleId]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//            NSLog(@"response = %@",response);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                    if (success) {
//                        NSLog(@"responseDict = %@",responseDict);
                        success(responseDict);
                    }
                }else {
                    if (failure) {
                        failure(error);
                        NSLog(@"%@",error);
                    }
                }
            });
        }];
        //开始任务
        [dataTask resume];
    });
}

@end
