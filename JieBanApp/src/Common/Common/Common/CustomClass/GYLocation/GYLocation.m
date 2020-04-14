//
//  GYLocation.m
//  Common
//
//  Created by 高源 on 2018/11/19.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "GYLocation.h"
#import  "AMapUtility.h"
//#import "AMapSearchKit.h"

@implementation GYLocationModel

@end


@interface GYLocation()

/** model */
@property (nonatomic,strong) GYLocationModel *model;

/** manager */
@property (nonatomic,strong) CLLocationManager *manager;

/** block */
@property (nonatomic,copy) void (^locationBlock)(GYLocationModel *model);

/** block */
@property (nonatomic,copy) void (^errorBlock)(NSError *error);

/** type 坐标系 */
@property(nonatomic,assign)GYLocationType type;
@end

@implementation GYLocation

SYNTHESIZE_SINGLETON_FOR_CLASS(GYLocation);

- (void)startLocationWithType:(GYLocationType)type location:(void (^)(GYLocationModel *model))locationBlock errorBlock:(void (^)(NSError *error))errorBlock {
    self.locationBlock = locationBlock;
    self.errorBlock = errorBlock;
    self.type = type;
    if (!_manager) {
        _manager = [[CLLocationManager alloc] init];
        _manager.delegate = self;
    }
    
    //iOS8.0之后
    if ([_manager respondsToSelector:@selector(requestWhenInUseAuthorization)]&&[_manager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [_manager requestWhenInUseAuthorization];
        //        [_manager requestAlwaysAuthorization];
    }
    
    //判断用户定位服务是否开启
    if ([CLLocationManager locationServicesEnabled]) {
        
        //开始定位用户的位置
        [_manager startUpdatingLocation];
        
        //每隔多少米定位一次（这里的设置为任何的移动）
        _manager.distanceFilter=kCLDistanceFilterNone;
        
        //设置定位的精准度，一般精准度越高，越耗电（这里设置为精准度最高的，适用于导航应用）
        _manager.desiredAccuracy=kCLLocationAccuracyBestForNavigation;
    }else{//不能定位用户的位置
        [self locationError:nil];
        //1.提醒用户检查当前的网络状况
        [SVProgressHUD showInfoWithStatus:languageStringWithKey(@"请检查当前网络状态或者是否已开启获取定位权限")];
        //2.提醒用户打开定位开关
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    for (CLLocation *location in locations) {
        if (self.type == GYLocationTypeWGS84) {
            self.model.longitude = location.coordinate.longitude;
            self.model.latitude = location.coordinate.latitude;
            [self geoAddress:location];
        }else {
            CLLocationCoordinate2D amapcoord = AMapCoordinateConvert(CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude), 6);
            self.model.longitude = amapcoord.longitude;
            self.model.latitude = amapcoord.latitude;
            CLLocation *_location = [[CLLocation alloc]initWithLatitude:amapcoord.latitude longitude:amapcoord.longitude];
            [self geoAddress:_location];
        }
    }
    [manager stopUpdatingLocation];
}

- (void)geoAddress:(CLLocation*)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemark, NSError *error) {
        if (error){
            [self locationError:error];
            return;
        }
        
        if(placemark.count > 0) {
            CLPlacemark *pl = placemark.lastObject;
            __block NSString *cityName = pl.locality;//市
            NSString *subLocality = pl.subLocality; //区
            NSString *name = pl.name; //关南西区22栋
            NSString *administrativeArea = pl.administrativeArea; //省
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *geoAddress  = [NSString stringWithFormat:@"%@%@%@%@",administrativeArea,cityName,subLocality,name];
                self.model.detailAddress = geoAddress;
                self.model.province = administrativeArea;
                self.model.city = cityName;
                //                self.model.city = [cityName stringByReplacingOccurrencesOfString:@"市" withString:@""];
                self.model.district = subLocality;
                self.model.street = name;
                self.model.speed = _manager.desiredAccuracy;
                self.model.accuracy = _manager.distanceFilter;
                !self.locationBlock?:self.locationBlock(self.model);
            });
        }
    }];
}

//定位失败调用
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    [SVProgressHUD showInfoWithStatus:languageStringWithKey(@"请检查当前网络状态或者是否已开启获取定位权限")];
    [self locationError:error];
}

- (void)locationError:(NSError *)error {
    !self.errorBlock?:self.errorBlock(error);
    [_manager stopUpdatingLocation];
}

#pragma mark  - getter
- (GYLocationModel *)model {
    if (!_model) {
        _model = [GYLocationModel new];
    }
    return _model;
}

@end

