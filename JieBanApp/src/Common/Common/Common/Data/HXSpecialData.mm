//
//  HXSpecialData.mm
//  Common
//
//  Created by lxj on 2018/8/8.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "HXSpecialData+WCTTableCoding.h"
#import "HXSpecialData.h"
#import <WCDB/WCDB.h>

@implementation HXSpecialData

WCDB_IMPLEMENTATION(HXSpecialData)
WCDB_SYNTHESIZE(HXSpecialData, account)
WCDB_PRIMARY(HXSpecialData, account)

#pragma mark - 增
//批量插入数据
+ (void)insertSpecialAttentsInfo:(NSArray<NSString *> *)resourse{
    //处理数据
    NSMutableArray<HXSpecialData *> *specials = [[NSMutableArray alloc] init];
    for (NSString *account in resourse) {
        HXSpecialData *data = [[HXSpecialData alloc] init];
        data.account = account;
        [specials addObject:data];
    }
    [self insertData:specials useTransaction:YES];
}

//使用事务来入库
+ (void)insertData:(NSArray<HXSpecialData *> *)resourse useTransaction:(BOOL)useTransaction{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    if (useTransaction) {///事务插入
        BOOL result = [dataBase beginTransaction];
        if (!result) {
            NSLog(@"事务开启失败");
        }
        [dataBase insertOrReplaceObjects:resourse into:DATA_SPECIAL_DBTABLE];

        if (![dataBase commitTransaction]) {///事务失败 回滚
            [dataBase rollbackTransaction];
        }
    }else{//普通插入
        [dataBase insertOrReplaceObjects:resourse into:DATA_SPECIAL_DBTABLE];
    }
}
#pragma mark - 删
///删除方法
+ (BOOL)deleteSpecialDataByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteObjectsFromTable:DATA_SPECIAL_DBTABLE where:condition];
}
///根据account删除
+ (BOOL)deleteSpecialAccount:(NSString *)account{
    return [self deleteSpecialDataByCondition:HXSpecialData.account == account];
}

//删除全部
+ (BOOL)deleteAllSpecialData{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteAllObjectsFromTable:DATA_SPECIAL_DBTABLE];
}
//批量删除数据
+ (void)deleteSpecialAttentsInfo:(NSArray<NSString *> *)resourse{
    [self deleteData:resourse useTransaction:YES];
}
+ (void)deleteData:(NSArray<NSString *> *)deleteArray useTransaction:(BOOL)useTransaction{

    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    if (useTransaction) {///事务删除
        BOOL result = [dataBase beginTransaction];
        if (!result) {
            NSLog(@"事务开启失败");
        }

        for (NSString *account in deleteArray) {
            [dataBase deleteObjectsFromTable:DATA_SPECIAL_DBTABLE where:HXSpecialData.account == account];
        }

        if (![dataBase commitTransaction]) {///事务失败 回滚
            [dataBase rollbackTransaction];
        }
    }else{//普通删除
        for (NSString *account in deleteArray) {
            [dataBase deleteObjectsFromTable:DATA_SPECIAL_DBTABLE where:HXSpecialData.account == account];
        }
    }
}
#pragma mark - 查
///单条查询
+ (HXSpecialData *)getSpecialByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getOneObjectOfClass:self fromTable:DATA_SPECIAL_DBTABLE where:condition];
}
///是否是特别关注
+ (BOOL)haveSpecialWithAccount:(NSString *)account{
    HXSpecialData *special = [self getSpecialByCondition:HXSpecialData.account == account];
    return special != nil ? YES:NO;
}
///数量
+ (NSInteger)getSpecialCount{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    NSNumber *count = [dataBase getOneValueOnResult:HXSpecialData.AnyProperty.count() fromTable:DATA_SPECIAL_DBTABLE];
    return count.integerValue;
}

///所有
+ (NSArray<HXSpecialData *> *)getAllSpecialData{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getAllObjectsOfClass:self fromTable:DATA_SPECIAL_DBTABLE];
}
@end
