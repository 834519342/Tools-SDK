//
//  ShareModel.h
//  LMGame
//
//  Created by LM on 2019/7/30.
//  Copyright © 2019 tj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ShareType) {
    SharePhoto = 0,         //分享图片到主页，使用参数：photoImages 或 photoDatas
    ShareLink = 1,          //分享链接到主页，使用参数：URL
    ShareMessenger = 2,     //分享内容到messenger端，使用参数：URL、title、desc、imageURL
    ShareMessengerLink = 3, //分享链接到messenger端，使用参数：URL
    GameRequest = 4,        //游戏请求，发送通知消息，使用参数：title、desc、userIDs
};

@interface ShareModel : NSObject

@property (nonatomic, assign) ShareType shareType;  //分享类别

@property (nonatomic, strong) NSString *title;      //标题
@property (nonatomic, strong) NSString *desc;       //内容
@property (nonatomic, strong) NSString *URL;        //分享的链接
@property (nonatomic, strong) NSString *imageURL;   //分享内容中缩略图网址

@property (nonatomic, strong) NSArray<UIImage*> *photoImages;  //分享的图片
@property (nonatomic, strong) NSArray<NSData*> *photoDatas;    //分享的图片数据

@property (nonatomic, strong) NSArray<NSString*> *userIDs;  //指定好友ID

@end

NS_ASSUME_NONNULL_END
