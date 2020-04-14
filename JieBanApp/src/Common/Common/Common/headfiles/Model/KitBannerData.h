//
//  KitBannerData.h
//  Common
//
//  Created by yuxuanpeng on 2017/7/27.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "BaseModel.h"

@interface KitBannerData : BaseModel

@property(nonatomic ,assign) NSInteger bannerId;
@property(nonatomic ,assign) NSInteger bannerStatus;
@property(nonatomic ,strong) NSString *bannerImageUrl;
@property(nonatomic ,strong) NSString *bannerTitle;
@property(nonatomic ,strong) NSString *bannerUrl;
@property(nonatomic ,strong) NSString *bannerUpdateTime;
///排序
@property(nonatomic ,assign) int orders;
//批量插入数据
+ (void)insertMyAppsInfo:(NSArray *)resourse;
#pragma mark - 查
+ (NSArray<KitBannerData *> *)getAllBannerData;
#pragma mark - 删
///根据bannerId删除
+ (BOOL)deleteBannerAppointId:(NSInteger)bannerId;
///删除全部
+ (BOOL)deleteAllBannerData;
@end
