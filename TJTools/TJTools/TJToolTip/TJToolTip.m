//
//  TJToolTip.m
//  TJTools
//
//  Created by xt on 2018/11/1.
//  Copyright © 2018年 TJ. All rights reserved.
//

#import "TJToolTip.h"

//默认显示时间
#define DEFAULT_DISPLAY_DURATION 2.f
//获取屏幕宽度
#define ScreenWidth [UIScreen mainScreen].bounds.size.width

@interface TJToolTip ()

//提示内容
@property (nonatomic, copy) NSString *message;

//显示时间
@property (nonatomic, assign) CGFloat duration;

//显示容器
@property (nonatomic, strong) UIButton *contentView;

//保存回调地址
@property (nonatomic, copy) ClickToolTipBlock clickToolTipBlock;

@end

@implementation TJToolTip

//显示居中提示
+ (void)showToolTipOnCenterWithMessage:(NSString *)message duration:(CGFloat)duration clickToolTipBlock:(ClickToolTipBlock)block
{
    TJToolTip *toolTip = [[TJToolTip alloc] initShowCenterWithMessage:message duration:duration];
    if (block) {
        toolTip.clickToolTipBlock = block;
    }
    [toolTip showCenter];
}

//居中显示
- (instancetype)initShowCenterWithMessage:(NSString *)message duration:(CGFloat)duration {
    
    self = [super init];
    if (self) {
        self.message = message;
        if (duration) {
            self.duration = duration;
        }else {
            self.duration = DEFAULT_DISPLAY_DURATION;
        }
        
        UIFont *font = [UIFont boldSystemFontOfSize:16.f];
        CGSize textSize = [message boundingRectWithSize:CGSizeMake(280, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size;
        
        self.contentView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, textSize.width + 20, textSize.height + 20)];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.contentView.layer.shadowOffset = CGSizeMake(0, 0);
        self.contentView.layer.shadowRadius = 5.f;
        self.contentView.layer.shadowOpacity = 0.8;
        self.contentView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.8].CGColor;
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addTarget:self action:@selector(tapCenter:) forControlEvents:UIControlEventTouchDown];
        self.contentView.alpha = 0.f;
        
        UIView *yuanjiaoView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        yuanjiaoView.userInteractionEnabled = NO;
        yuanjiaoView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        yuanjiaoView.layer.cornerRadius = 8.f;
        yuanjiaoView.layer.masksToBounds = YES;
        [self.contentView addSubview:yuanjiaoView];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.font = font;
        textLabel.text = self.message;
        textLabel.numberOfLines = 0;
        [self.contentView addSubview:textLabel];
        
        //监听屏幕方向改变的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    }
    return self;
}

//点击手势
- (void)tapCenter:(UIGestureRecognizer *)tap
{
    if (tap) {
        [self hideAnimationSetAlpha];
        if (self.clickToolTipBlock) {
            self.clickToolTipBlock(self.message);
        }
    }
}

//显示提示框，带动画
- (void)showCenter
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.contentView.center = window.center;
    [window addSubview:self.contentView];
    [self showAnimationSetAlpha];
    [self performSelector:@selector(hideAnimationSetAlpha) withObject:nil afterDelay:self.duration];
}

//动画改变提示框透明度
- (void)showAnimationSetAlpha
{
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.alpha = 1.0;
    }];
}

//动画改变透明度，再移除对象
- (void)hideAnimationSetAlpha
{
    if (self.contentView) {
        [UIView animateWithDuration:0.3 animations:^{
            self.contentView.alpha = 0.f;
        } completion:^(BOOL finished) {
            [self dismissAlert];
        }];
    }
}

//监听屏幕转动
- (void)deviceOrientationDidChanged:(NSNotification *)aNotification
{
    [self hideAnimationSetAlpha];
}

//显示顶端提示
+ (void)showToolTipOnTopWithMessage:(NSString *)message duration:(CGFloat)duration clickToolTipBlock:(ClickToolTipBlock)block
{
    TJToolTip *toolTip = [[TJToolTip alloc] initShowTopWithMessage:message duration:duration];
    if (block) {
        toolTip.clickToolTipBlock = block;
    }
    [toolTip showTop];
}

//顶端显示
- (instancetype)initShowTopWithMessage:(NSString *)message duration:(CGFloat)duration
{
    self = [super init];
    if (self) {
        self.message = [message copy];
        if (duration) {
            self.duration = duration;
        }else {
            self.duration = DEFAULT_DISPLAY_DURATION;
        }
        
        self.contentView = [[UIButton alloc] initWithFrame:CGRectMake(10, -54, ScreenWidth - 20, 54)];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.contentView.layer.shadowOffset = CGSizeMake(0, 0); //阴影方向
        self.contentView.layer.shadowRadius = 5.f; //阴影宽度
        self.contentView.layer.shadowOpacity = 0.8; //阴影强度
        self.contentView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.8].CGColor; //阴影颜色
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self.contentView addTarget:self action:@selector(tapTop:) forControlEvents:UIControlEventTouchDown];
        
        UIView *yuanjiaoView = [UIView new];
        yuanjiaoView.frame = self.contentView.bounds;
        yuanjiaoView.userInteractionEnabled = NO;
        yuanjiaoView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
        yuanjiaoView.layer.cornerRadius = 8.f;
        yuanjiaoView.layer.masksToBounds = YES; //圆角切割
//        yuanjiaoView.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.5].CGColor;
//        yuanjiaoView.layer.borderWidth = 1.f;
        [self.contentView addSubview:yuanjiaoView];
        
        UILabel *textLabel = [UILabel new];
        CGRect frame = self.contentView.bounds;
        frame.origin.x = 5;
        frame.origin.y = 10;
        frame.size.width = frame.size.width - 10;
        frame.size.height = frame.size.height - 20;
        textLabel.frame = frame;
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = [UIColor blackColor];
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.font = [UIFont boldSystemFontOfSize:14.f];
        textLabel.text = self.message;
        textLabel.numberOfLines = 0;
        [self.contentView addSubview:textLabel];
        
    }
    return self;
}

//点击手势
- (void)tapTop:(UIGestureRecognizer *)tap
{
    if (tap != nil) {
        [self hideTopAnimation];
        if (self.clickToolTipBlock) {
            self.clickToolTipBlock(self.message);
        }
    }
}

//顶端显示，带动画
- (void)showTop
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.contentView.frame = CGRectMake(10, -54, ScreenWidth - 20, 54);
    [window addSubview:self.contentView];
    [self showTopAnimation];
    [self performSelector:@selector(hideTopAnimation) withObject:nil afterDelay:self.duration];
}

//显示动画
- (void)showTopAnimation
{
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.frame = CGRectMake(10, 20, ScreenWidth - 20, 54);
    }];
}

//隐藏动画
- (void)hideTopAnimation
{
    if (self.contentView) {
        [UIView animateWithDuration:0.3 animations:^{
            self.contentView.frame = CGRectMake(10, -54, ScreenWidth - 20, 54);
        } completion:^(BOOL finished) {
            [self dismissAlert];
        }];
    }
}

//移除对象
- (void)dismissAlert
{
    [self.contentView removeFromSuperview];
    self.contentView = nil;
}

- (void)dealloc
{
    //移除监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
}

@end

