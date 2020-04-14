//
//  KitMyAppStoreOperate.mm
//  Common
//
//  Created by lxj on 2018/8/6.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "KitMyAppStoreOperate+WCTTableCoding.h"
#import "KitMyAppStoreOperate.h"
#import <WCDB/WCDB.h>

@implementation KitMyAppStoreOperate

WCDB_IMPLEMENTATION(KitMyAppStoreOperate)
WCDB_SYNTHESIZE(KitMyAppStoreOperate, appId)
WCDB_SYNTHESIZE(KitMyAppStoreOperate, appType)
WCDB_SYNTHESIZE_DEFAULT(KitMyAppStoreOperate, curStatus, 0)
WCDB_PRIMARY(KitMyAppStoreOperate, appId)


#pragma mark - 增
//使用事务来入库
+ (void)insertData:(KitMyAppStoreOperate *)resourse useTransaction:(BOOL)useTransaction{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    if (useTransaction) {///事务插入
        BOOL result = [dataBase beginTransaction];
        if (!result) {
            NSLog(@"事务开启失败");
        }

        [dataBase insertOrReplaceObject:resourse into:DATA_MYAPPOPEARTE_DBTABLE];

        if (![dataBase commitTransaction]) {///事务失败 回滚
            [dataBase rollbackTransaction];
        }
    }else{//普通插入
        [dataBase insertOrReplaceObject:resourse into:DATA_APPSTORE_MyApps_DBTABLE];
    }
}
#pragma mark - 删
+ (BOOL)deleteAppStroeWithAppId:(NSString *)appId appType:(NSInteger)appType {
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteObjectsFromTable:DATA_MYAPPOPEARTE_DBTABLE where:KitMyAppStoreOperate.appId == appId && KitMyAppStoreOperate.appType == appType];
}

#pragma mark - 查
+ (NSArray *)getAllAppStoreOperate{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getAllObjectsOfClass:self fromTable:DATA_MYAPPOPEARTE_DBTABLE];
}
+ (NSInteger)getAppStoreCurStatusWithAppId:(NSString *)appId appType:(NSInteger)appType{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    NSNumber *curStatus = [dataBase getOneValueOnResult:KitMyAppStoreOperate.curStatus fromTable:DATA_MYAPPOPEARTE_DBTABLE where:KitMyAppStoreOperate.appId == appId && KitMyAppStoreOperate.appType == appType];
    return curStatus.integerValue;
}
@end
