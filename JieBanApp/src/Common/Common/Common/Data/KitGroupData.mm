//
//  KitGroupData.mm
//  Common
//
//  Created by lxj on 2018/8/2.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "KitGroupData+WCTTableCoding.h"
#import "KitGroupData.h"
#import <WCDB/WCDB.h>

@implementation KitGroupData

WCDB_IMPLEMENTATION(KitGroupData)
WCDB_SYNTHESIZE(KitGroupData, groupId)
WCDB_SYNTHESIZE(KitGroupData, groupName)
WCDB_SYNTHESIZE(KitGroupData, groupAD)
WCDB_SYNTHESIZE_DEFAULT(KitGroupData, isOpenIMMsg, 1)
WCDB_SYNTHESIZE_DEFAULT(KitGroupData, isMsgTopDisplay, 1)
WCDB_SYNTHESIZE_DEFAULT(KitGroupData, isGroupNickname, 1)

WCDB_PRIMARY(KitGroupData, groupId)

/// IMGroupInfo 转 KitGroupData
+ (KitGroupData *)convertFromData:(IMGroupInfo *)groupInfo{
    KitGroupData* data  = [[KitGroupData alloc] init];
    data.groupId = groupInfo.groupId;
    data.groupName = groupInfo.name;
    data.groupAD = groupInfo.declared;
    data.groupInfo = groupInfo;
    return data;
}

@end

@implementation KitGroupData (Ext)

//从本地或网络中请求群组信息
+ (KitGroupData *)getGroupData:(NSString *)groupId{
    KitGroupData * groupData = [KitGroupData queryForGroupId:groupId];
    if (!groupData) {//不存在则初始化
        groupData = [[KitGroupData alloc] init];
        groupData.groupId = groupId;
    }
    return groupData;
}
#pragma mark - 增
+ (BOOL)insertOrReplaceGroupData:(KitGroupData *)groupData{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase insertOrReplaceObject:groupData into:DATA_GROUP_DBTABLE];
}
#pragma mark - 删
///删除方法
+ (BOOL)deleteGroupDataByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteObjectsFromTable:DATA_GROUP_DBTABLE where:condition];
}
///根据groupId删除
+ (BOOL)deleteGroupData:(NSString *)groupId{
    return [self deleteGroupDataByCondition:KitGroupData.groupId == groupId];
}
#pragma mark - 查
///单条查询
+ (KitGroupData *)getGroupDataByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getOneObjectOfClass:self fromTable:DATA_GROUP_DBTABLE where:condition];
}
///根据groupId查询
+ (KitGroupData *)queryForGroupId:(NSString *)groupId{
    return [self getGroupDataByCondition:KitGroupData.groupId == groupId];
}

@end
