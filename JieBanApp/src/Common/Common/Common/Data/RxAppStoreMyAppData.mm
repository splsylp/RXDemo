//
//  RxAppStoreMyAppData.mm
//  Common
//
//  Created by lxj on 2018/8/6.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "RxAppStoreMyAppData+WCTTableCoding.h"
#import "RxAppStoreMyAppData.h"
#import <WCDB/WCDB.h>

#import "KitMyAppStoreOperate+WCTTableCoding.h"

@implementation RxAppStoreMyAppData

WCDB_IMPLEMENTATION(RxAppStoreMyAppData)
WCDB_SYNTHESIZE(RxAppStoreMyAppData, appId)
WCDB_SYNTHESIZE(RxAppStoreMyAppData, appName)
WCDB_SYNTHESIZE(RxAppStoreMyAppData, appType)
WCDB_SYNTHESIZE(RxAppStoreMyAppData, appLogo)
WCDB_SYNTHESIZE(RxAppStoreMyAppData, appUrl)
WCDB_SYNTHESIZE(RxAppStoreMyAppData, appDes)
WCDB_SYNTHESIZE(RxAppStoreMyAppData, groupId)
WCDB_SYNTHESIZE(RxAppStoreMyAppData, publicStatus)
WCDB_SYNTHESIZE(RxAppStoreMyAppData, installStatus)
WCDB_SYNTHESIZE(RxAppStoreMyAppData, account)
WCDB_SYNTHESIZE(RxAppStoreMyAppData, groupName)
WCDB_SYNTHESIZE(RxAppStoreMyAppData, groupCode)
WCDB_SYNTHESIZE(RxAppStoreMyAppData, appCode)
WCDB_SYNTHESIZE(RxAppStoreMyAppData, appVersion)
WCDB_SYNTHESIZE(RxAppStoreMyAppData, appPackageUrl)
WCDB_SYNTHESIZE_DEFAULT(RxAppStoreMyAppData, isNaviBar, 1)
WCDB_SYNTHESIZE_DEFAULT(RxAppStoreMyAppData, isForcedInstall, 1)
WCDB_SYNTHESIZE_DEFAULT(RxAppStoreMyAppData, appOrder, 0)
WCDB_SYNTHESIZE_COLUMN_DEFAULT(RxAppStoreMyAppData, isAppHidden, "isHidden",1)
WCDB_PRIMARY(RxAppStoreMyAppData, appId)

#pragma mark - 增
//插入单条应用商店数据
+ (BOOL)insertMyAppData:(RxAppStoreMyAppData *)infoData{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase insertOrReplaceObject:infoData into:DATA_APPSTORE_MyApps_DBTABLE];
}
//批量插入数据
+ (void)insertMyAppsInfo:(NSArray<RxAppStoreMyAppData *> *)resourse{
    [self insertData:resourse useTransaction:YES];
}

//使用事务来入库
+ (void)insertData:(NSArray<RxAppStoreMyAppData *> *)resourse useTransaction:(BOOL)useTransaction{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    if (useTransaction) {///事务插入
        BOOL result = [dataBase beginTransaction];
        if (!result) {
            NSLog(@"事务开启失败");
        }

        [dataBase insertOrReplaceObjects:resourse into:DATA_APPSTORE_MyApps_DBTABLE];

        if (![dataBase commitTransaction]) {///事务失败 回滚
            [dataBase rollbackTransaction];
        }
    }else{//普通插入
        [dataBase insertOrReplaceObjects:resourse into:DATA_APPSTORE_MyApps_DBTABLE];
    }
}
#pragma mark - 删
///删除方法
+ (BOOL)deleteMyAppDataByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteObjectsFromTable:DATA_APPSTORE_MyApps_DBTABLE where:condition];
}
//根据appId删除 installStatus = 1
+ (BOOL)deleteMyAppData:(NSString *)appId{
    return [self deleteMyAppDataByCondition:RxAppStoreMyAppData.appId == appId && RxAppStoreMyAppData.installStatus == 1];
}
///删除所有
+ (BOOL)deleteMyAllAppData{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteAllObjectsFromTable:DATA_APPSTORE_MyApps_DBTABLE];
}
#pragma mark - 改
//根据appId更新标记installStatus
+ (BOOL)updateMyAppDataInstallFlag:(NSString *)appId flag:(int)flag{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;

    RxAppStoreMyAppData *appData = [[RxAppStoreMyAppData alloc] init];
    appData.installStatus = flag;

    return [dataBase updateRowsInTable:DATA_APPSTORE_MyApps_DBTABLE onProperties:RxAppStoreMyAppData.installStatus withObject:appData where:RxAppStoreMyAppData.appId == appId];
}


//根据appcode获取对应的应用数据
+ (NSDictionary *)getOneMyAppStoreDataWithAppCode:(NSString *)appcode{
    RxAppStoreMyAppData *appData = [self getMyAppByCondition:RxAppStoreMyAppData.appCode == appcode];
    //需要什么参数自己加
    NSDictionary *oneDic = @{
                           @"appName":appData.appName,
                           @"appCode":appData.appCode,
                           @"appLogo":appData.appLogo,
                           @"appDes":appData.appDes,
                           @"isNaviBar":@(appData.isNaviBar),
                           };
    return oneDic;
}

#pragma mark - 查
///单条查询
+ (RxAppStoreMyAppData *)getMyAppByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getOneObjectOfClass:self fromTable:DATA_APPSTORE_MyApps_DBTABLE where:condition];
}
///changeby李晓杰
//需要做处理 跨表查询
+ (NSArray<RxAppStoreMyAppData *> *)getMyAppWithGroupId:(int)groupId{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    NSMutableArray<RxAppStoreMyAppData *> *appDataArray = [NSMutableArray array];

   NSArray<RxAppStoreMyAppData *> *appArray = [dataBase getObjectsOfClass:self fromTable:DATA_APPSTORE_MyApps_DBTABLE where:RxAppStoreMyAppData.groupId == groupId && RxAppStoreMyAppData.isAppHidden == 0 && RxAppStoreMyAppData.installStatus == 1];
    NSArray<KitMyAppStoreOperate *> *operateArray = [KitMyAppStoreOperate getAllAppStoreOperate];
    for (RxAppStoreMyAppData *appData in appArray) {
        if (appData.isForcedInstall == 3) {//强制安装不可卸载
            [appDataArray addObject:appData];
        }else if (appData.isForcedInstall == 2) {//强制安装可卸载
            BOOL need = YES;
            for (KitMyAppStoreOperate *operateData in operateArray) {
                if (appData.appId == operateData.appId && operateData.curStatus == 2) {
                    need = NO;
                }
            }
            if (need) {
                [appDataArray addObject:appData];
            }
        }else{//普通
            BOOL need = NO;
            for (KitMyAppStoreOperate *operateData in operateArray) {
                if (appData.appId == operateData.appId && operateData.curStatus
                    == 1) {
                    need = YES;
                }
            }
            if (need) {
                [appDataArray addObject:appData];
            }
        }
    }
    return appDataArray;

//    WCTMultiSelect *multiSelect = [[[dataBase prepareSelectMultiObjectsOnResults:{
//        RxAppStoreMyAppData.AllProperties.inTable(DATA_APPSTORE_MyApps_DBTABLE),
//        KitMyAppStoreOperate.curStatus.inTable(DATA_MYAPPOPEARTE_DBTABLE),
//    } fromTables:@[DATA_APPSTORE_MyApps_DBTABLE,DATA_MYAPPOPEARTE_DBTABLE]] where: (RxAppStoreMyAppData.appId.inTable(DATA_APPSTORE_MyApps_DBTABLE) == KitMyAppStoreOperate.appId.inTable(DATA_MYAPPOPEARTE_DBTABLE) && RxAppStoreMyAppData.groupId.inTable(DATA_APPSTORE_MyApps_DBTABLE) == groupId) &&  RxAppStoreMyAppData.isAppHidden.inTable(DATA_APPSTORE_MyApps_DBTABLE) == 0 && RxAppStoreMyAppData.installStatus.inTable(DATA_APPSTORE_MyApps_DBTABLE) == 1] orderBy:RxAppStoreMyAppData.appOrder.order(WCTOrderedAscending)] ;
//
//
//    NSMutableArray<RxAppStoreMyAppData *> *appDataArray = [NSMutableArray array];
//    while (WCTMultiObject *multiObject = [multiSelect nextMultiObject]) {
//        RxAppStoreMyAppData *appData = (RxAppStoreMyAppData *) [multiObject objectForKey:DATA_APPSTORE_MyApps_DBTABLE];
//        KitMyAppStoreOperate *operate = (KitMyAppStoreOperate *) [multiObject objectForKey:DATA_MYAPPOPEARTE_DBTABLE];
////        installStatus curStatus本地存在安装卸载字段 isForcedInstall 安装状态 publicStatus :是否是公用应用 isForcedInstall等于0的时候 兼容老版本
//
//        int isForcedInstall = appData.isForcedInstall;
//        int publicStatus = appData.publicStatus;
//        NSInteger curStatus = operate.curStatus;
//        if ((isForcedInstall == 1 && curStatus == 1) ||
//            (isForcedInstall == 2 && curStatus !=2) ||
//            isForcedInstall == 3 ||
//            isForcedInstall == 0 ||
//            publicStatus != 1) {
//            [appDataArray addObject:appData];
//        }
//    }
//    return appDataArray;
}
///判断是否有已安装的app 即installStatus为1
+ (BOOL)getHasMyAppWithAppId:(int)appId{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    NSNumber *count = [dataBase getOneValueOnResult:RxAppStoreMyAppData.appId.count() fromTable:DATA_APPSTORE_MyApps_DBTABLE where:RxAppStoreMyAppData.appId == appId && RxAppStoreMyAppData.installStatus == 1];
    return count.intValue > 0 ? YES:NO;
}
///根据appId 查询 installStatus为1 isHidden为0的数据
+ (RxAppStoreMyAppData *)getMyAppWithAppId:(int)appId{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getOneObjectOfClass:self fromTable:DATA_APPSTORE_MyApps_DBTABLE where:RxAppStoreMyAppData.appId == appId && RxAppStoreMyAppData.installStatus == 1 && RxAppStoreMyAppData.isAppHidden == 0];
}

///查最新的n条数据 installStatus = 1  isHidden = 0
+ (NSArray<RxAppStoreMyAppData *> *)getMyAppWithCount:(int)count{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getObjectsOfClass:self fromTable:DATA_APPSTORE_MyApps_DBTABLE where:RxAppStoreMyAppData.installStatus == 1 && RxAppStoreMyAppData.isAppHidden == 0 limit:count];
}
///所有数据 installStatus = 1  isHidden = 0
+ (NSArray<RxAppStoreMyAppData *> *)getAllMyApp{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getObjectsOfClass:self fromTable:DATA_APPSTORE_MyApps_DBTABLE where:RxAppStoreMyAppData.installStatus == 1 && RxAppStoreMyAppData.isAppHidden == 0];
}


//根据appId获取对应的应用数据
+ (NSDictionary *)getAppStoreParamsWithAppId:(NSString *)appId appType:(NSInteger)appType{
    RxAppStoreMyAppData *appData = [self getMyAppByCondition:RxAppStoreMyAppData.appType == appType && RxAppStoreMyAppData.appId == appId];
    //需要什么参数自己加
    NSDictionary *oneDic = @{
                             @"appName":appData.appName,
                             @"appCode":appData.appCode,
                             @"appLogo":appData.appLogo,
                             @"appDes":appData.appDes,
                             @"isNaviBar":@(appData.isNaviBar),
                             @"appType":@(appData.appType),
                             };
    return oneDic;
}
@end
