//
//  TJLocation.m
//  TJTools
//
//  Created by LM on 2019/8/13.
//  Copyright © 2019 TJ. All rights reserved.
//

#import "TJLocation.h"
#import <CoreLocation/CoreLocation.h>

typedef void(^Callback)(NSDictionary * _Nonnull);

@interface TJLocation ()<CLLocationManagerDelegate, NSCopying>

@property (nonatomic, strong) CLLocationManager *locationManager;  //定位服务

@property (nonatomic, strong) Callback callback;

@end

@implementation TJLocation

+ (instancetype)sharedInstance
{
    static TJLocation *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[super allocWithZone:NULL] init];
            [instance initLocationManager];
        }
    });
    return instance;
}
// 规避创建新的单例
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedInstance];
}
// 规避创建新的单例
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (void)initLocationManager
{
    //判断定位功能是否打开
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager requestAlwaysAuthorization];  //请求在应用程序运行时使用位置服务的权限
        [self.locationManager requestWhenInUseAuthorization];   //请求在应用程序位于前台时使用位置服务的权限
        
        //设置定位精确度
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest; //可用的最佳准确度
        self.locationManager.distanceFilter = 5.0; //在生成更新事件之前，设备必须水平移动的最小距离（以米为单位）
    }
}

- (void)startUpdatingLocation:(void (^)(NSDictionary * _Nonnull))callback
{
    self.callback = callback;
    
    //判断应用程序是否获得授权
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation]; //开始生成当前位置更新
    }else {
        NSLog(@"没有授权应用使用定位功能");
        if (self.callback) {
            self.callback(@{@"ret": @0, @"message": @"unauthorized"});
        }
    }
}

- (void)stopUpdatingLocation
{
    //停止生成位置更新
    [self.locationManager stopUpdatingLocation];
}

- (void)requestLocation:(void (^)(NSDictionary * _Nonnull))callback
{
    self.callback = callback;
    
    //获取一次当前定位信息
    [self.locationManager requestLocation];
}

- (NSDictionary *)getLocationInfo:(CLPlacemark *)placemark
{
    NSDictionary *info = @{
                           @"ret": @1,
                           @"location": [NSString stringWithFormat:@"%f,%f", placemark.location.coordinate.latitude, placemark.location.coordinate.longitude],
                           @"ISOcountryCode": placemark.ISOcountryCode,
                           @"country": placemark.country,
                           @"administrativeArea": placemark.administrativeArea,
                           @"locality": placemark.locality
                           };
    return info;
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *currentLocation = [locations lastObject];
    //反地理编码
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
       
        if (placemarks.count > 0) {
            CLPlacemark *placemark = placemarks[0];
            if (self.callback) {
                self.callback([self getLocationInfo:placemark]);
            }
        }else {
            NSLog(@"经纬度编码失败:%@", error);
            if (self.callback) {
                self.callback(@{@"ret": @-1, @"message": error});
            }
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"获取定位失败:%@", error);
    if (self.callback) {
        self.callback(@{@"ret": @-1, @"message": error});
    }
}

@end
