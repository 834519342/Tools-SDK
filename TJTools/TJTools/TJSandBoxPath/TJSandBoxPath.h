//
//  TJFileManager.h
//  TJTools
//
//  Created by admin on 2020/2/27.
//  Copyright © 2020 TJ. All rights reserved.
//
//  文件路径管理
//  资料一：https://www.jianshu.com/p/133de925fdb4

#import <Foundation/Foundation.h>

typedef enum{
    HomePath = 0,   // ./
    
    DocumentPath,   // ./Documents
    
    CachesPath,  // ./Library/Caches
    PreferencePanesPath,  // ./Library/PreferencePanes
    Application_SupportPath, // ./Library/Application Support
    
    tmpPath,    // ./tmp/
}DocPath;

NS_ASSUME_NONNULL_BEGIN

@interface TJSandBoxPath : NSObject

+ (instancetype)sharedInstance;

- (NSString *)getFilePathWithType:(DocPath)type;



@end

NS_ASSUME_NONNULL_END
