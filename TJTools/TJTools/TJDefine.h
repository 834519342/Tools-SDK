//
//  TJDefine.h
//  TJTools
//
//  Created by LM on 2019/8/19.
//  Copyright © 2019 TJ. All rights reserved.
//

/*
 自定义输出
 Xcode配置：Preprocessor Macros    DEBUG=1
 */
#ifdef DEBUG
# define TJLog(fmt, ...) NSLog((@"\n[文件：%s]\n" "[函数：%s]\n" "[行：%d]\n" "[日志：" fmt "]"),\
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],\
__FUNCTION__,\
__LINE__,\
##__VA_ARGS__);
#else
# define TJLog(fmt, ...) NSLog((fmt), ##__VA_ARGS__);
#endif
