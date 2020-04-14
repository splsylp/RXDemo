//
//  KitBannerData.mm
//  Common
//
//  Created by lxj on 2018/8/6.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "KitBannerData+WCTTableCoding.h"
#import "KitBannerData.h"
#import <WCDB/WCDB.h>

@implementation KitBannerData

WCDB_IMPLEMENTATION(KitBannerData)

WCDB_SYNTHESIZE(KitBannerData, bannerImageUrl)
WCDB_SYNTHESIZE(KitBannerData, bannerTitle)
WCDB_SYNTHESIZE(KitBannerData, bannerUrl)
WCDB_SYNTHESIZE(KitBannerData, bannerUpdateTime)
WCDB_SYNTHESIZE(KitBannerData, orders)
WCDB_SYNTHESIZE_DEFAULT(KitBannerData, bannerStatus, 0)
WCDB_SYNTHESIZE_DEFAULT(KitBannerData, bannerId, 1)
WCDB_PRIMARY(KitBannerData, bannerId)

//批量插入数据
+ (void)insertMyAppsInfo:(NSArray *)resourse{
    //处理数据
    NSMutableArray<KitBannerData *> *bannerArray = [NSMutableArray new];
    for (NSDictionary *infoDic in resourse) {
        KitBannerData *banner = [[KitBannerData alloc] init];
        banner.bannerId = [infoDic[@"id"] integerValue];
        banner.bannerImageUrl = infoDic[@"image"];
        banner.bannerTitle = infoDic[@"title"];
        banner.bannerUrl = infoDic[@"url"];
        banner.bannerUpdateTime = [NSString stringWithFormat:@"%@",infoDic[@"update_time"]];
        banner.bannerStatus = [infoDic[@"status"] integerValue];
        banner.orders = [infoDic[@"orders"] intValue];
        [bannerArray addObject:banner];
    }

    [self insertData:bannerArray useTransaction:YES];
}

//使用事务来入库
+ (void)insertData:(NSArray<KitBannerData *> *)resourse useTransaction:(BOOL)useTransaction{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    if (useTransaction) {///事务插入
        BOOL result = [dataBase beginTransaction];
        if (!result) {
            NSLog(@"事务开启失败");
        }

        [dataBase insertOrReplaceObjects:resourse into:DATA_BANNER_DBTABLE];

        if (![dataBase commitTransaction]) {///事务失败 回滚
            [dataBase rollbackTransaction];
        }
    }else{//普通插入
        [dataBase insertOrReplaceObjects:resourse into:DATA_BANNER_DBTABLE];
    }
}


#pragma mark - 查
+ (NSArray<KitBannerData *> *)getAllBannerData{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getObjectsOfClass:self fromTable:DATA_BANNER_DBTABLE orderBy:KitBannerData.orders.order(WCTOrderedAscending)];
//    return [dataBase getAllObjectsOfClass:self fromTable:DATA_BANNER_DBTABLE];
}
#pragma mark - 删
///删除方法
+ (BOOL)deleteBannerDataByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteObjectsFromTable:DATA_BANNER_DBTABLE where:condition];
}
///根据bannerId删除
+ (BOOL)deleteBannerAppointId:(NSInteger)bannerId{
    return [self deleteBannerDataByCondition:KitBannerData.bannerId == bannerId];
}
///删除全部
+ (BOOL)deleteAllBannerData{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteAllObjectsFromTable:DATA_BANNER_DBTABLE];
}



@end
