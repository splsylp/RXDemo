//
//  RxAppStoreData.mm
//  Common
//
//  Created by lxj on 2018/8/6.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "RxAppStoreData+WCTTableCoding.h"
#import "RxAppStoreData.h"
#import <WCDB/WCDB.h>

@implementation RxAppStoreData

WCDB_IMPLEMENTATION(RxAppStoreData)
WCDB_SYNTHESIZE(RxAppStoreData, appId)
WCDB_SYNTHESIZE(RxAppStoreData, appName)
WCDB_SYNTHESIZE(RxAppStoreData, appType)
WCDB_SYNTHESIZE(RxAppStoreData, appLogo)
WCDB_SYNTHESIZE(RxAppStoreData, appUrl)
WCDB_SYNTHESIZE(RxAppStoreData, appDes)
WCDB_SYNTHESIZE(RxAppStoreData, groupId)
WCDB_SYNTHESIZE(RxAppStoreData, publicStatus)
WCDB_SYNTHESIZE(RxAppStoreData, installStatus)
WCDB_SYNTHESIZE(RxAppStoreData, account)
WCDB_SYNTHESIZE(RxAppStoreData, appCode)
WCDB_SYNTHESIZE_DEFAULT(RxAppStoreData, isForcedInstall, 1)
WCDB_SYNTHESIZE_DEFAULT(RxAppStoreData, isHidden, 1)
WCDB_SYNTHESIZE_DEFAULT(RxAppStoreData, isNaviBar, 1)

WCDB_PRIMARY(RxAppStoreData, groupId)


#pragma mark - 增
//插入单条应用商店数据
+ (BOOL)insertAppInfoData:(RxAppStoreData*)infoData{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase insertOrReplaceObject:infoData into:DATA_APPSTORE_AppInfo_DBTABLE];
}
//批量插入数据
+ (void)insertAppsInfo:(NSArray<RxAppStoreData *> *)resourse{
    [self insertData:resourse useTransaction:YES];
}

//使用事务来入库
+ (void)insertData:(NSArray<RxAppStoreData *> *)resourse useTransaction:(BOOL)useTransaction{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    if (useTransaction) {///事务插入
        BOOL result = [dataBase beginTransaction];
        if (!result) {
            NSLog(@"事务开启失败");
        }

        [dataBase insertOrReplaceObjects:resourse into:DATA_APPSTORE_AppInfo_DBTABLE];

        if (![dataBase commitTransaction]) {///事务失败 回滚
            [dataBase rollbackTransaction];
        }
    }else{//普通插入
        [dataBase insertOrReplaceObjects:resourse into:DATA_APPSTORE_AppInfo_DBTABLE];
    }
}


#pragma mark - 删
///删除方法
+ (BOOL)deleteAppInfoDataByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteObjectsFromTable:DATA_APPSTORE_AppInfo_DBTABLE where:condition];
}
//删除
+ (BOOL)deleteAppInfoData:(NSString *)appId{
    return [self deleteAppInfoDataByCondition:RxAppStoreData.appId == appId];
}
#pragma mark - 查
///单条查询
+ (RxAppStoreData *)getAppInfoByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getOneObjectOfClass:self fromTable:DATA_APPSTORE_AppInfo_DBTABLE where:condition];
}
///根据appid查询
+ (RxAppStoreData *)getAppInfoWithAppId:(int)appId{
    return [self getAppInfoByCondition:RxAppStoreData.appId == appId];
}
///根据appId查appUrl
+ (NSString *)getAppUrl:(int)appId{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    NSString *appUrl = [dataBase getOneValueOnResult:RxAppStoreData.appId fromTable:DATA_APPSTORE_AppInfo_DBTABLE where:RxAppStoreData.appId == appId];
    return appUrl;
}
///查最新的n条数据
+ (NSArray<RxAppStoreData *> *)getAPPInfoWithCount:(int)count{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getObjectsOfClass:self fromTable:DATA_APPSTORE_AppInfo_DBTABLE limit:count];
}
///查询所有数据
+ (NSArray<RxAppStoreData *> *)getAllAppInfo{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getAllObjectsOfClass:self fromTable:DATA_APPSTORE_AppInfo_DBTABLE];
}
@end
