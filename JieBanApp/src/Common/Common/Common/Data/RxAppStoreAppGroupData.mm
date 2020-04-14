//
//  RxAppStoreAppGroupData.mm
//  Common
//
//  Created by lxj on 2018/8/6.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "RxAppStoreAppGroupData+WCTTableCoding.h"
#import "RxAppStoreAppGroupData.h"
#import <WCDB/WCDB.h>

@implementation RxAppStoreAppGroupData

WCDB_IMPLEMENTATION(RxAppStoreAppGroupData)
WCDB_SYNTHESIZE(RxAppStoreAppGroupData, groupId)
WCDB_SYNTHESIZE(RxAppStoreAppGroupData, groupName)
WCDB_SYNTHESIZE(RxAppStoreAppGroupData, groupCode)
WCDB_SYNTHESIZE(RxAppStoreAppGroupData, account)
WCDB_SYNTHESIZE_DEFAULT(RxAppStoreAppGroupData, groupOrder, 0)
WCDB_PRIMARY(RxAppStoreAppGroupData, groupId)

#pragma mark - 增
///单个插入或更新 应用商店数据
+ (BOOL)insertGroupData:(RxAppStoreAppGroupData *)infoData{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase insertOrReplaceObject:infoData into:DATA_APPSTORE_Group_DBTABLE];
}

//批量插入数据
+ (void)insertGroups:(NSArray<RxAppStoreAppGroupData *> *)resourse{
    [self insertData:resourse useTransaction:YES];
}

//使用事务来入库
+ (void)insertData:(NSArray<RxAppStoreAppGroupData *> *)resourse useTransaction:(BOOL)useTransaction{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    if (useTransaction) {///事务插入
        BOOL result = [dataBase beginTransaction];
        if (!result) {
            NSLog(@"事务开启失败");
        }

        [dataBase insertOrReplaceObjects:resourse into:DATA_APPSTORE_Group_DBTABLE];

        if (![dataBase commitTransaction]) {///事务失败 回滚
            [dataBase rollbackTransaction];
        }
    }else{//普通插入
        [dataBase insertOrReplaceObjects:resourse into:DATA_APPSTORE_Group_DBTABLE];
    }
}

#pragma mark - 删
///删除方法
+ (BOOL)deleteGroupDataByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteObjectsFromTable:DATA_APPSTORE_Group_DBTABLE where:condition];
}
//根据groupId删除
+ (BOOL)deleteGroupData:(NSString *)groupId{
    return [self deleteGroupDataByCondition:RxAppStoreAppGroupData.groupId == groupId];
}
///删除所有
+ (BOOL)deleteAllGroupData{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteAllObjectsFromTable:DATA_APPSTORE_Group_DBTABLE];
}
#pragma mark - 查
///查数量
+ (int)getGroupCount{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    NSNumber *count = [dataBase getOneValueOnResult:RxAppStoreAppGroupData.groupId.count() fromTable:DATA_APPSTORE_Group_DBTABLE];
    return count.intValue;
}
///单条查询
+ (RxAppStoreAppGroupData *)getGroupByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getOneObjectOfClass:self fromTable:DATA_APPSTORE_Group_DBTABLE where:condition];
}
///根据groupId查询
+ (RxAppStoreAppGroupData *)getGroupWithGroupId:(int)groupId{
    return [self getGroupByCondition:RxAppStoreAppGroupData.groupId == groupId];
}
///查最新的n条数据
+ (NSArray<RxAppStoreAppGroupData *> *)getAPPInfoWithCount:(int)count{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getObjectsOfClass:self fromTable:DATA_APPSTORE_Group_DBTABLE limit:count];
}
///查所有数据
+ (NSArray<RxAppStoreAppGroupData *> *)getAllGroup{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getObjectsOfClass:self fromTable:DATA_APPSTORE_Group_DBTABLE orderBy:RxAppStoreAppGroupData.groupOrder.order(WCTOrderedAscending)];
}
@end
