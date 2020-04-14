//
//  RXCollectData.mm
//  Common
//
//  Created by lxj on 2018/8/6.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "RXCollectData+WCTTableCoding.h"
#import "RXCollectData.h"
#import <WCDB/WCDB.h>



@implementation RXCollectData

WCDB_IMPLEMENTATION(RXCollectData)
WCDB_SYNTHESIZE(RXCollectData, collectId)
WCDB_SYNTHESIZE(RXCollectData, type)
WCDB_SYNTHESIZE(RXCollectData, txtContent)
WCDB_SYNTHESIZE(RXCollectData, url)
WCDB_SYNTHESIZE(RXCollectData, time)
WCDB_SYNTHESIZE(RXCollectData, sessionId)
WCDB_SYNTHESIZE(RXCollectData, messageId)
WCDB_SYNTHESIZE(RXCollectData, fromId)

WCDB_PRIMARY(RXCollectData, collectId)

#pragma mark - 增
//插入单条或更新收藏数据
+ (BOOL)insertCollectionInfoData:(RXCollectData*)infoData{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase insertOrReplaceObject:infoData into:DATA_COLLECTION_DBTABLE];
}

//批量插入数据
+ (void)insertCollectionAttentsInfo:(NSArray *)resourse{
    [self insertData:resourse useTransaction:YES];
}
//使用事务来入库
+ (void)insertData:(NSArray<RXCollectData *> *)resourse useTransaction:(BOOL)useTransaction{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    if (useTransaction) {///事务插入
        BOOL result = [dataBase beginTransaction];
        if (!result) {
            NSLog(@"事务开启失败");
        }

        [dataBase insertOrReplaceObjects:resourse into:DATA_COLLECTION_DBTABLE];

        if (![dataBase commitTransaction]) {///事务失败 回滚
            [dataBase rollbackTransaction];
        }
    }else{//普通插入
        [dataBase insertOrReplaceObjects:resourse into:DATA_COLLECTION_DBTABLE];
    }
}

#pragma mark - 删
///删除方法
+ (BOOL)deleteCollectionDataByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteObjectsFromTable:DATA_COLLECTION_DBTABLE where:condition];
}
//根据collectId 删除
+ (BOOL)deleteCollectionData:(NSString *)collectId{
    return [self deleteCollectionDataByCondition:RXCollectData.collectId == collectId];
}
#pragma mark - 查
///单条查询
+ (RXCollectData *)getCollectDataByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getOneObjectOfClass:self fromTable:DATA_COLLECTION_DBTABLE where:condition];
}
///根据collectId查询
+ (RXCollectData *)getCollectDataWithCollectId:(NSString *)collectId{
    return [self getCollectDataByCondition:RXCollectData.collectId == collectId];
}
///查最近的n条数据
+ (NSArray<RXCollectData *> *)getRecentlyCollectionDataWithCount:(int)count{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getObjectsOfClass:self fromTable:DATA_COLLECTION_DBTABLE orderBy:RXCollectData.time.order(WCTOrderedDescending) limit:count];
}
///查询时间前的n条数据
+ (NSArray<RXCollectData *> *)getCollectionDataWithTime:(NSString *)time Count:(int)count{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getObjectsOfClass:self fromTable:DATA_COLLECTION_DBTABLE where:RXCollectData.time < [time longLongValue] orderBy:RXCollectData.time.order(WCTOrderedDescending) limit:count];
}
///查所有数据
+ (NSArray<RXCollectData *> *)getAllCollectionData{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getObjectsOfClass:self fromTable:DATA_COLLECTION_DBTABLE orderBy:RXCollectData.time.order(WCTOrderedDescending)];
}

///查所有文件类型数据
+ (NSArray<RXCollectData *> *)getAllFileCollectionData {
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getObjectsOfClass:self fromTable:DATA_COLLECTION_DBTABLE where:RXCollectData.type == 7];
}

///查所有图片视频类型数据
+ (NSArray<RXCollectData *> *)getAllMeidaCollectionData {
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getObjectsOfClass:self fromTable:DATA_COLLECTION_DBTABLE where:RXCollectData.type == 2 || RXCollectData.type == 5];
}

///查所有链接类型数据
+ (NSArray<RXCollectData *> *)getAllLinkCollectionData {
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getObjectsOfClass:self fromTable:DATA_COLLECTION_DBTABLE where:RXCollectData.type == 3];
}
@end


@implementation RXCollectModel

@end
