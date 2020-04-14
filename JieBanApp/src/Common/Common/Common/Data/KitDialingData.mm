//
//  KitDialingData.mm
//  Common
//
//  Created by lxj on 2018/8/2.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "KitDialingData+WCTTableCoding.h"
#import "KitDialingData.h"
#import <WCDB/WCDB.h>


@implementation KitDialingData

WCDB_IMPLEMENTATION(KitDialingData)
WCDB_SYNTHESIZE(KitDialingData, mobile)
WCDB_SYNTHESIZE(KitDialingData, account)
WCDB_SYNTHESIZE(KitDialingData, nickname)
WCDB_SYNTHESIZE(KitDialingData, call_status)
WCDB_SYNTHESIZE(KitDialingData, call_type)
WCDB_SYNTHESIZE_COLUMN(KitDialingData, call_date, "create_date")
WCDB_SYNTHESIZE_DEFAULT(KitDialingData, call_number, 0)

///自增id
WCDB_SYNTHESIZE_COLUMN(KitDialingData, tid, "id")
WCDB_PRIMARY_ASC_AUTO_INCREMENT(KitDialingData, tid)

#pragma mark - 删
///删除方法
+ (BOOL)deleteDialingByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteObjectsFromTable:DATA_DIALING_DBTABLE_NAME where:condition];
}
///根据mobile删除
+ (BOOL)deleteDialingPhoneDataDB:(NSString *)mobile{
    return [self deleteDialingByCondition:KitDialingData.mobile == mobile];
}
///根据mobile和call_status删除数据
+ (BOOL)deleteDialingDataDB:(KitDialingData *)dialingData{
    return [self deleteDialingByCondition:KitDialingData.mobile == dialingData.mobile && KitDialingData.call_status == dialingData.call_status];
}
///删除所有
+ (BOOL)deleteAllDialingDataDB{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteAllObjectsFromTable:DATA_DIALING_DBTABLE_NAME];
}
#pragma mark - 改
+ (BOOL)updateDialingDataDB:(KitDialingData *)dialingData{
    BOOL result; //UPDATE

    if (KCNSSTRING_ISEMPTY(dialingData.mobile)) {
        return NO;
    }

    KitDialingData *dialingExit = [KitDialingData getDialingDataWithMobile:dialingData.mobile call_status:dialingData.call_status];

    if (dialingExit) {//存在呼叫次数+1
        dialingData.call_number = dialingExit.call_number + 1;
        WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
        result = [dataBase updateRowsInTable:DATA_DIALING_DBTABLE_NAME onProperties:KitDialingData.AllProperties withObject:dialingData where:KitDialingData.mobile == dialingData.mobile && KitDialingData.call_status == dialingData.call_status];
    } else {
        WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
        dialingData.isAutoIncrement = YES;
        result = [dataBase insertObject:dialingData into:DATA_DIALING_DBTABLE_NAME];
    }
    return result;
}

#pragma mark - 查
+ (NSArray<KitDialingData *> *)getDialingArray{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getObjectsOfClass:self fromTable:DATA_DIALING_DBTABLE_NAME orderBy:KitDialingData.call_date.order(WCTOrderedAscending)];
}
///单条查询
+ (KitDialingData *)getDialingByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getOneObjectOfClass:self fromTable:DATA_DIALING_DBTABLE_NAME where:condition];
}
//通过手机号码去获取数据
+ (KitDialingData *)getDialingWithMobile:(NSString *)mobile{
    return [self getDialingByCondition:KitDialingData.mobile == mobile];
}
//通过手机号码和call_status判断
+ (KitDialingData *)getDialingDataWithMobile:(NSString*)mobile call_status:(NSString*)call_status{
    return [self getDialingByCondition:KitDialingData.mobile == mobile && KitDialingData.call_status == call_status];
}
//检查某一指定mobile的记录是否已经存在
+ (BOOL)checkRecordExistInDb:(NSString*)mobile{
    BOOL result;
    KitDialingData *dialing = [self getDialingWithMobile:mobile];
    result = (dialing == nil) ? NO:YES;
    return result;
}
@end
