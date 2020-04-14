//
//  GYLocation.h
//  Common
//
//  Created by 高源 on 2018/11/19.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, GYLocationType) {
    GYLocationTypeWGS84,
    GYLocationTypeGCJ02
};

NS_ASSUME_NONNULL_BEGIN


@interface GYLocationModel : NSObject

/** 省 */
@property (nonatomic,strong) NSString *province;

/** 市*/
@property (nonatomic,copy) NSString *city;

/** 区 */
@property (nonatomic,copy) NSString *district;

/** 街道 */
@property (nonatomic,copy) NSString *street;

/** 当前详细地址*/
@property (nonatomic,copy) NSString *detailAddress;

/** 当前经度*/
@property (nonatomic,assign) double longitude;

/** 当前经度*/
@property (nonatomic,assign) double latitude;

/** 速度 */
@property (nonatomic,assign) double speed;

/** 位置精度 */
@property (nonatomic,assign) double accuracy;

@end


@interface GYLocation : NSObject<CLLocationManagerDelegate>

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(GYLocation);

//- (void)startLocation:(void (^)(GYLocationModel *model))locationBlock;

- (void)startLocationWithType:(GYLocationType)type location:(void (^)(GYLocationModel *model))locationBlock errorBlock:(void (^)(NSError *error))errorBlock;

@end

NS_ASSUME_NONNULL_END
