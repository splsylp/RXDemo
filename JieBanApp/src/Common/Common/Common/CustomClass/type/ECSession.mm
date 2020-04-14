//
//  ECSession.mm
//  Common
//
//  Created by lxj on 2018/8/21.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "ECSession+WCTTableCoding.h"
#import "ECSession.h"
#import <WCDB/WCDB.h>

#import "DataBaseManager.h"
@implementation ECSession

WCDB_IMPLEMENTATION(ECSession)
WCDB_SYNTHESIZE(ECSession, sessionId)
WCDB_SYNTHESIZE(ECSession, dateTime)
WCDB_SYNTHESIZE(ECSession, type)
WCDB_SYNTHESIZE(ECSession, text)
WCDB_SYNTHESIZE(ECSession, unreadCount)
WCDB_SYNTHESIZE(ECSession, sumCount)
WCDB_SYNTHESIZE_DEFAULT(ECSession, isAt, 0)
WCDB_SYNTHESIZE(ECSession, draft)
WCDB_SYNTHESIZE(ECSession, fromId)
WCDB_SYNTHESIZE_DEFAULT(ECSession, isNotice,0)

WCDB_PRIMARY(ECSession, sessionId)
WCDB_UNIQUE(ECSession, sessionId)
WCDB_NOT_NULL(ECSession, sessionId)


#pragma mark - 增
///使用事务来入库
+ (BOOL)insertSessionArr:(NSArray<ECSession *> *)resourse useTransaction:(BOOL)useTransaction{
    NSLog(@"消息批量入库 resourse.count = %lu",(unsigned long)resourse.count);
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    if (useTransaction) {///事务插入
        BOOL result = [dataBase beginTransaction];
        if (!result) {
            NSLog(@"事务开启失败");
        }

        BOOL res =  [dataBase insertOrReplaceObjects:resourse into:DATA_SESSION_DBTABLE];
        NSLog(@"insertSessionArr消息批量入库res = %d",res);
        if (![dataBase commitTransaction]) {///事务失败 回滚
            [dataBase rollbackTransaction];
        }
        return res;
    }else{//普通插入
       
        return [dataBase insertOrReplaceObjects:resourse into:DATA_SESSION_DBTABLE];
    }
}



+ (BOOL)addNewSession:(ECSession *)session{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase insertOrReplaceObject:session into:DATA_SESSION_DBTABLE];
}
#pragma mark - 删
///删除方法
+ (BOOL)deleteSessionByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteObjectsFromTable:DATA_SESSION_DBTABLE where:condition];
}
///根据sessionId删除
+ (BOOL)deleteSessionBySessionId:(NSString *)sessionId{
    return [self deleteSessionByCondition:ECSession.sessionId == sessionId];
}
///根据type删除
+ (BOOL)deleteSessionType:(NSString *)type{
    return [self deleteSessionByCondition:ECSession.type == type];
}
///删除所有会话
+ (BOOL)deleteAllSession{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteAllObjectsFromTable:DATA_SESSION_DBTABLE];
}
#pragma mark - 改
///更新是否消息提醒
+ (BOOL)updateSessionNoticeBySessionId:(NSString *)sessionId isNotice:(BOOL)isNotice{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;

    ECSession *session = [[ECSession alloc] init];
    session.isNotice = isNotice;
    return [dataBase updateRowsInTable:DATA_SESSION_DBTABLE onProperties:ECSession.isNotice withObject:session where:ECSession.sessionId == sessionId];
}

#pragma mark - 查
///单条查询
+ (ECSession *)getSessionByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getOneObjectOfClass:self fromTable:DATA_SESSION_DBTABLE where:condition];
}
///根据sessionId查询
+ (ECSession *)getSessionBySessionId:(NSString *)sessionId{
    return [self getSessionByCondition:ECSession.sessionId == sessionId];
}
///按时间倒序查所有session
+ (NSArray<ECSession *> *)getAllSession{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getObjectsOfClass:self fromTable:DATA_SESSION_DBTABLE orderBy:ECSession.dateTime.order(WCTOrderedDescending)];
}

///未读消息数量
+ (NSInteger)getUnreadSessionCount{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    NSNumber *number = [dataBase getOneValueOnResult:ECSession.unreadCount.sum() fromTable:DATA_SESSION_DBTABLE where:ECSession.isNotice == 0];
    return number.integerValue;
}
@end
