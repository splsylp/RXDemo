//
//  KitDialingInfoData.mm
//  Common
//
//  Created by lxj on 2018/8/2.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "KitDialingInfoData+WCTTableCoding.h"
#import "KitDialingInfoData.h"
#import <WCDB/WCDB.h>

@implementation KitDialingInfoData

WCDB_IMPLEMENTATION(KitDialingInfoData)
WCDB_SYNTHESIZE(KitDialingInfoData, dialMobile)
WCDB_SYNTHESIZE(KitDialingInfoData, dialNickName)
WCDB_SYNTHESIZE(KitDialingInfoData, dialType)
WCDB_SYNTHESIZE(KitDialingInfoData, dialState)
WCDB_SYNTHESIZE(KitDialingInfoData, dialTime)
WCDB_SYNTHESIZE(KitDialingInfoData, dialBeginTime)
WCDB_SYNTHESIZE_COLUMN(KitDialingInfoData, dialAccount, "account")

WCDB_SYNTHESIZE_COLUMN(KitDialingInfoData, tid, "id")
WCDB_PRIMARY_ASC_AUTO_INCREMENT(KitDialingInfoData, tid)


#pragma mark - 增
+ (BOOL)insertdialData:(KitDialingInfoData *)dialingInfoData{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    dialingInfoData.isAutoIncrement = YES;
    return [dataBase insertObject:dialingInfoData into:DATA_INFODIALING_DATABLE_NAME];
}
#pragma mark - 删
///删除所有
+ (BOOL)deleteAllInfoDialingDataDB{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteAllObjectsFromTable:DATA_INFODIALING_DATABLE_NAME];
}
///删除方法
+ (BOOL)deleteDialingDataByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteObjectsFromTable:DATA_INFODIALING_DATABLE_NAME where:condition];
}
///根据dialMobile和dialState删除
+ (BOOL)deleteDialingInfoDataDB:(KitDialingInfoData *)infoDialingData{
    return [self deleteDialingDataByCondition:KitDialingInfoData.dialMobile == infoDialingData.dialMobile && KitDialingInfoData.dialState == infoDialingData.dialState];
}
///根据dialMobile删除
+ (BOOL)deleteDialingInfoPhoneDataDB:(NSString *)dialMobile{
    return [self deleteDialingDataByCondition:KitDialingInfoData.dialMobile == dialMobile];
}
#pragma mark - 查
///单条查询
+ (KitDialingInfoData *)getDialingInfoByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getOneObjectOfClass:self fromTable:DATA_INFODIALING_DATABLE_NAME where:condition];
}
///根据dialMobile查询
+ (KitDialingInfoData *)getInfoDialingWithMobile:(NSString*)dialMobile{
    return [self getDialingInfoByCondition:KitDialingInfoData.dialMobile == dialMobile];
}
///根据dialaccount查询
+ (KitDialingInfoData *)getInfoDialingWithAccount:(NSString*)dialaccount{
    return [self getDialingInfoByCondition:KitDialingInfoData.dialAccount == dialaccount];
}
///查询所有
+ (NSArray<KitDialingInfoData *> *)dialInfoAllArray{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getAllObjectsOfClass:self fromTable:DATA_INFODIALING_DATABLE_NAME];
}
///批量查询
+ (NSArray<KitDialingInfoData *> *)getAllInfoDialingByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getObjectsOfClass:self fromTable:DATA_INFODIALING_DATABLE_NAME where:condition];
}
///根据手机号查询数组
+ (NSArray<KitDialingInfoData *> *)getAllInfoDialingWithMobile:(NSString *)dialmobile{
    return [self getAllInfoDialingByCondition:KitDialingInfoData.dialMobile == dialmobile];
}
///根据dialaccount查询数组
+ (NSArray<KitDialingInfoData *> *)getAllInfoDialingWithAccount:(NSString *)dialaccount{
    return [self getAllInfoDialingByCondition:KitDialingInfoData.dialAccount == dialaccount];
}

@end
