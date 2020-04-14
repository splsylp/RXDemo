//
//  KitGroupInfoData.mm
//  Common
//
//  Created by lxj on 2018/8/2.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "KitGroupInfoData+WCTTableCoding.h"
#import "KitGroupInfoData.h"
#import <WCDB/WCDB.h>

@implementation KitGroupInfoData

WCDB_IMPLEMENTATION(KitGroupInfoData)
WCDB_SYNTHESIZE(KitGroupInfoData, groupId)
WCDB_SYNTHESIZE(KitGroupInfoData, groupName)
WCDB_SYNTHESIZE(KitGroupInfoData, declared)
WCDB_SYNTHESIZE(KitGroupInfoData, createTime)
WCDB_SYNTHESIZE(KitGroupInfoData, owner)
WCDB_SYNTHESIZE(KitGroupInfoData, memberCount)
WCDB_SYNTHESIZE(KitGroupInfoData, type)
WCDB_SYNTHESIZE(KitGroupInfoData, isAnonymity)
WCDB_SYNTHESIZE(KitGroupInfoData, isDiscuss)
WCDB_SYNTHESIZE(KitGroupInfoData, isNotice)
WCDB_SYNTHESIZE(KitGroupInfoData, scope)
WCDB_SYNTHESIZE_DEFAULT(KitGroupInfoData, isGroupMember, 0)
WCDB_PRIMARY(KitGroupInfoData, groupId)

#pragma mark - 增
+ (BOOL)insertGroupInfoData:(KitGroupInfoData *)infoData{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase insertOrReplaceObject:infoData into:DATA_GROUPINFO_DBTABLE];
}
#pragma mark - 改
//更新groupName declared owner
+ (BOOL)upDateGroupInfo:(KitGroupInfoData *)groupInfo{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase updateRowsInTable:DATA_GROUPINFO_DBTABLE onProperties:{KitGroupInfoData.groupName,KitGroupInfoData.declared,KitGroupInfoData.owner} withObject:groupInfo where:KitGroupInfoData.groupId == groupInfo.groupId];
}
///更新isNotice
+ (BOOL)updateGroupMessageOption:(NSString *)groupId withstatus:(BOOL)status{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;

    KitGroupInfoData *data = [[KitGroupInfoData alloc] init];
    data.isNotice = status;
    data.groupId = groupId;

    return [dataBase updateRowsInTable:DATA_GROUPINFO_DBTABLE onProperties:KitGroupInfoData.isNotice withObject:data where:KitGroupInfoData.groupId == data.groupId];
}

#pragma mark - 删
///删除方法
+ (BOOL)deleteGroupInfoDataByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteObjectsFromTable:DATA_GROUPINFO_DBTABLE where:condition];
}
///删除所有
+ (BOOL)deleteAlldeleteGroupInfoDataDB{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteAllObjectsFromTable:DATA_GROUPINFO_DBTABLE];
}
///根据groupId删除
+ (BOOL)deleteGroupInfoDataDB:(NSString*)groupId{
    NSArray *groups = [[NSUserDefaults standardUserDefaults] objectForKey:@"NotRealGroups"];
    if (groups && [groups containsObject:groupId]) {
        NSMutableArray *mArr = groups.mutableCopy;
        [mArr removeObject:groupId];
        groups = mArr.copy;
        [[NSUserDefaults standardUserDefaults] setObject:groups forKey:@"NotRealGroups"];
    }
    return [self deleteGroupInfoDataByCondition:KitGroupInfoData.groupId == groupId];
}

#pragma mark - 查
///单条查询
+ (KitGroupInfoData *)getGroupDataByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getOneObjectOfClass:self fromTable:DATA_GROUPINFO_DBTABLE where:condition];
}
///根据groupId查询
+ (KitGroupInfoData *)getGroupInfoWithGroupId:(NSString*)groupId{
    return [self getGroupDataByCondition:KitGroupInfoData.groupId == groupId];
}

///查询所有
+ (NSArray<KitGroupInfoData *> *)getGroupInfoDataArray{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getAllObjectsOfClass:self fromTable:DATA_GROUPINFO_DBTABLE];
}
///批量查询
+ (NSArray<KitGroupInfoData *> *)getAllGroupInfoByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getObjectsOfClass:self fromTable:DATA_GROUPINFO_DBTABLE where:condition];
}

#pragma mark - ECGroup_son迁移过来的
#pragma mark - 增
///新增或修改group
+ (BOOL)addGroup:(ECGroup *)group{
    KitGroupInfoData *son = [KitGroupInfoData groupWithECGroup:group];

    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase insertOrReplaceObject:son into:DATA_GROUPINFO_DBTABLE];
//    return [dataBase insertOrReplaceObject:son onProperties:{
//        KitGroupInfoData.groupId,
//        KitGroupInfoData.groupName,
//        KitGroupInfoData.createTime,
//        KitGroupInfoData.memberCount
//    } into:DATA_GROUPINFO_DBTABLE];;
}
#pragma mark - 删
///删除方法
+ (BOOL)deleteGroupByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteObjectsFromTable:DATA_GROUPINFO_DBTABLE where:condition];
}
///根据groupId删除
+ (BOOL)deleteGroupByGroupId:(NSString *)groupId{
    return [self deleteGroupByCondition:KitGroupInfoData.groupId == groupId];
}
///删除所有群组
+ (BOOL)deleteAllGroup{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteAllObjectsFromTable:DATA_GROUPINFO_DBTABLE];
}
#pragma mark - 改
///修改成员在群中的状态
+ (BOOL)updateMemberStateByGroupId:(NSString *)groupId isGroupMember:(BOOL)isGroupMember{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;

    KitGroupInfoData *son = [[KitGroupInfoData alloc] init];
    son.isGroupMember = isGroupMember;
    return [dataBase updateRowsInTable:DATA_GROUPINFO_DBTABLE onProperties:KitGroupInfoData.isGroupMember withObject:son where:KitGroupInfoData.groupId == groupId];
}

#pragma mark - 查
///根据groupId查ECGroup对象
+ (ECGroup *)getGroupByGroupId:(NSString *)groupId{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    KitGroupInfoData *infoData = [dataBase getOneObjectOfClass:self fromTable:DATA_GROUPINFO_DBTABLE  where:KitGroupInfoData.groupId == groupId];
    ECGroup *group = [self ECGroupWithGroup:infoData];
    return group;
}
///所有的群组
+ (NSArray<ECGroup *> *)getAllGroup{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    NSArray<KitGroupInfoData *> *dataArr = [dataBase getObjectsOfClass:self fromTable:DATA_GROUPINFO_DBTABLE  where:KitGroupInfoData.isGroupMember == 0 orderBy:KitGroupInfoData.createTime.order(WCTOrderedAscending)];

    NSMutableArray<ECGroup *> *groupArr = [[NSMutableArray alloc] init];
    for (KitGroupInfoData *infoData in dataArr) {
        ECGroup *group = [self ECGroupWithGroup:infoData];
        if (group != nil) {
            [groupArr addObject:group];
        }
    }
    return groupArr;
}
///所有群组数量
+ (NSInteger)getGroupAllCount{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    NSNumber *number = [dataBase getOneValueOnResult:KitGroupInfoData.AnyProperty.count() fromTable:DATA_GROUPINFO_DBTABLE where:KitGroupInfoData.isGroupMember == 0];
    return number.integerValue;
}
///根据groupId查name
+ (NSString *)getGroupNameByGroupId:(NSString *)groupId{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getOneValueOnResult:KitGroupInfoData.groupName fromTable:DATA_GROUPINFO_DBTABLE where:KitGroupInfoData.groupId == groupId];
}
///返回字典
+ (NSArray *)getGroupInformationByGroupId:(NSString *)groupId{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    NSArray<KitGroupInfoData *> *dataArr = [dataBase getObjectsOfClass:self fromTable:DATA_GROUPINFO_DBTABLE where:KitGroupInfoData.groupId == groupId];

    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (KitGroupInfoData *infoData in dataArr) {
        NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
        mDic[@"groupId"] = infoData.groupId;
        mDic[@"groupname"] = infoData.groupName;
        mDic[@"isGroupMember"] = [NSString stringWithFormat:@"%d",infoData.isGroupMember];
        mDic[@"memberCount"] = [NSString stringWithFormat:@"%ld",(long)infoData.memberCount];
        mDic[@"dateCreated"] = infoData.createTime;
        [array addObject:mDic];
    }
    return array;
}
///根据输入name 倒序查询符合的群组
+ (NSArray<ECGroup *> *)getGroupWithSearchText:(NSString *)searchText{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    NSString *text = [NSString stringWithFormat:@"%%%@%%",searchText];
    NSArray<KitGroupInfoData *> *dataArr = [dataBase getObjectsOfClass:self fromTable:DATA_GROUPINFO_DBTABLE  where:KitGroupInfoData.isGroupMember == 0 && KitGroupInfoData.groupName.like(text) orderBy:KitGroupInfoData.createTime.order(WCTOrderedDescending)];

    NSMutableArray<ECGroup *> *groupArr = [[NSMutableArray alloc] init];
    for (KitGroupInfoData *infoData in dataArr) {
        ECGroup *group = [self ECGroupWithGroup:infoData];
        if (group != nil) {
            [groupArr addObject:group];
        }
    }
    return groupArr;
}
///ECGroup转KitGroupInfoData
+ (KitGroupInfoData *)groupWithECGroup:(ECGroup *)group{
    if (group == nil) {
        return nil;
    }
    KitGroupInfoData *infoData = [[KitGroupInfoData alloc] init];
    infoData.groupId = group.groupId;
    infoData.groupName = group.name;
    infoData.createTime = group.createdTime;
    infoData.memberCount = group.memberCount;
    return infoData;
}
///KitGroupInfoData转ECGroup
+ (ECGroup *)ECGroupWithGroup:(KitGroupInfoData *)infoData{
    if (infoData == nil) {
        return nil;
    }
    ECGroup *group = [[ECGroup alloc] init];
    group.groupId = infoData.groupId;
    group.name = infoData.groupName;
    group.createdTime = infoData.createTime;
    group.memberCount = infoData.memberCount;
    return group;
}
@end
