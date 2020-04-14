//
//  KitGroupMemberInfoData.mm
//  Common
//
//  Created by lxj on 2018/8/3.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "KitGroupMemberInfoData+WCTTableCoding.h"
#import "KitGroupMemberInfoData.h"
#import <WCDB/WCDB.h>

#import "KitCompanyAddress+WCTTableCoding.h"
@implementation KitGroupMemberInfoData

WCDB_IMPLEMENTATION(KitGroupMemberInfoData)
WCDB_SYNTHESIZE(KitGroupMemberInfoData, memberId)
WCDB_SYNTHESIZE(KitGroupMemberInfoData, groupId)
WCDB_SYNTHESIZE(KitGroupMemberInfoData, memberName)
WCDB_SYNTHESIZE(KitGroupMemberInfoData, headUrl)
WCDB_SYNTHESIZE(KitGroupMemberInfoData, headMd5)
WCDB_SYNTHESIZE(KitGroupMemberInfoData, role)
WCDB_SYNTHESIZE(KitGroupMemberInfoData, sex)

WCDB_SYNTHESIZE_COLUMN(KitGroupMemberInfoData, tid, "id")
WCDB_PRIMARY_ASC_AUTO_INCREMENT(KitGroupMemberInfoData, tid)

WCDB_INDEX(KitGroupMemberInfoData, "idx1", memberId)
WCDB_INDEX(KitGroupMemberInfoData, "idx2", groupId)
WCDB_INDEX(KitGroupMemberInfoData, "idx3", memberId)
WCDB_INDEX(KitGroupMemberInfoData, "idx3", groupId)
WCDB_INDEX(KitGroupMemberInfoData, "idx4", groupId)
WCDB_INDEX(KitGroupMemberInfoData, "idx4", role)



#pragma mark - 增
//批量导入 使用事务
+ (void)insertGroupMemberArray:(NSArray *)memberArray withGroupId:(NSString *)groupId{
    [self insertData:memberArray useTransaction:YES withGroupId:groupId];
}

+ (void)insertData:(NSArray*)resourse useTransaction:(BOOL)useTransaction withGroupId:(NSString *)groupId{
    ///先组装数据
    NSMutableArray<KitGroupMemberInfoData *> *array = [[NSMutableArray alloc] init];
    for (ECGroupMember *member in resourse) {
        KitGroupMemberInfoData *infodata = [[KitGroupMemberInfoData alloc] init];
        infodata.groupId = groupId;

        infodata.memberId = member.memberId;
        infodata.memberName = member.display;
        infodata.role = [NSString stringWithFormat:@"%d",(int)member.role];
        infodata.sex = [NSString stringWithFormat:@"%d",(int)member.sex];
        if(infodata.groupId){
            [array addObject:infodata];
        }
    }

    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    if (useTransaction) {///事务插入
        BOOL result = [dataBase beginTransaction];
        if (!result) {
            NSLog(@"事务开启失败");
        }

        for (KitGroupMemberInfoData *infoData in array) {
            [self insertGroupMemberInfoData:infoData];
        }

        if (![dataBase commitTransaction]) {///事务失败 回滚
            [dataBase rollbackTransaction];
        }
    }else{//普通插入
        for (KitGroupMemberInfoData *infoData in array) {
            [self insertGroupMemberInfoData:infoData];
        }
    }
}
+ (BOOL)insertGroupMemberInfoData:(KitGroupMemberInfoData *)infoData{
    KitGroupMemberInfoData *memberInfoExit = [KitGroupMemberInfoData getGroupMemberInfoWithMemberId:infoData.memberId withGroupId:infoData.groupId];

    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    //满足这二种条件就更新 否则存入
    if (memberInfoExit) {
        return [dataBase updateRowsInTable:DATA_GROUPMEMBERINFO_DBTABLE onProperties:{KitGroupMemberInfoData.memberName,
            KitGroupMemberInfoData.headUrl,
            KitGroupMemberInfoData.headMd5,
            KitGroupMemberInfoData.role,
            KitGroupMemberInfoData.sex,
        } withObject:infoData where:KitGroupMemberInfoData.memberId == infoData.memberId && KitGroupMemberInfoData.groupId == infoData.groupId];
    } else {
        infoData.isAutoIncrement = YES;
        return [dataBase insertObject:infoData into:DATA_GROUPMEMBERINFO_DBTABLE];
    }
}
#pragma mark - 删
///删除方法
+ (BOOL)deleteGroupMemberInfoByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteObjectsFromTable:DATA_GROUPMEMBERINFO_DBTABLE where:condition];
}
///根据groupId删除
+ (BOOL)deleteGroupAllMemberInfoDataDB:(NSString*)groupId{
    return [self deleteGroupMemberInfoByCondition:KitGroupMemberInfoData.groupId == groupId];
}
///根据memberId和groupId删除
+ (BOOL)deleteGroupMemberPhoneInfoDataDB:(NSString*)memberId withGroupId:(NSString *)groupId{
      return [self deleteGroupMemberInfoByCondition:KitGroupMemberInfoData.memberId == memberId && KitGroupMemberInfoData.groupId == groupId];
}
///删除所有
+ (BOOL)deleteAlldeleteGroupMemberInfoDataDB{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteAllObjectsFromTable:DATA_GROUPMEMBERINFO_DBTABLE];
}
#pragma makr - 改
//更新角色等级
+ (BOOL)updateRoleStateaMemberId:(NSString *)memberId andRole:(NSString *)role{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return  [dataBase updateRowsInTable:DATA_GROUPMEMBERINFO_DBTABLE onProperty:KitGroupMemberInfoData.role withValue:role where:KitGroupMemberInfoData.memberId == memberId];
}

+ (BOOL)updateRoleStateWithMemberIds:(NSArray *)memberIds andRole:(NSString *)role {
    BOOL result;
    for (NSString *memberId in memberIds) {
        result = [self updateRoleStateaMemberId:memberId andRole:role];
    }
    return result;
}
#pragma mark - 查
///单条查询
+ (KitGroupMemberInfoData *)getGroupMemberInfoByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getOneObjectOfClass:self fromTable:DATA_GROUPMEMBERINFO_DBTABLE where:condition];
}
///根据groupId memberId查询
+ (KitGroupMemberInfoData *)getGroupMemberInfoWithMemberId:(NSString*)memberId withGroupId:(NSString *)groupId{
    return [self getGroupMemberInfoByCondition:KitGroupMemberInfoData.memberId == memberId && KitGroupMemberInfoData.groupId == groupId];
}

///批量查询
+ (NSArray<KitGroupMemberInfoData *> *)getAllGroupMemberInfoByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getObjectsOfClass:self fromTable:DATA_GROUPMEMBERINFO_DBTABLE where:condition];
}
///查询所有
+ (NSArray<KitGroupMemberInfoData *> *)getGroupMemberInfoDataArray{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getAllObjectsOfClass:self fromTable:DATA_GROUPMEMBERINFO_DBTABLE];
}

//新增选择成员查询 返回通讯录数据
+ (NSMutableArray *)getSelectCompanyDataWithGroupId:(NSString *)groupId{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    WCTMultiSelect *multiSelect = [[dataBase prepareSelectMultiObjectsOnResults:{
        KitGroupMemberInfoData.memberId.inTable(DATA_GROUPMEMBERINFO_DBTABLE),
        KitGroupMemberInfoData.memberName.inTable(DATA_GROUPMEMBERINFO_DBTABLE),

        KitCompanyAddress.name.inTable(DATA_COMPANYADDRESS_DBTABLE),
        KitCompanyAddress.photourl.inTable(DATA_COMPANYADDRESS_DBTABLE),
        KitCompanyAddress.urlmd5.inTable(DATA_COMPANYADDRESS_DBTABLE),
        KitCompanyAddress.level.inTable(DATA_COMPANYADDRESS_DBTABLE),
        KitCompanyAddress.userStatus.inTable(DATA_COMPANYADDRESS_DBTABLE),
        KitCompanyAddress.department_id.inTable(DATA_COMPANYADDRESS_DBTABLE),
        KitCompanyAddress.mobilenum.inTable(DATA_COMPANYADDRESS_DBTABLE),
    } fromTables:@[DATA_GROUPMEMBERINFO_DBTABLE,DATA_COMPANYADDRESS_DBTABLE]] where: (KitGroupMemberInfoData.memberId.inTable(DATA_GROUPMEMBERINFO_DBTABLE) == KitCompanyAddress.account.inTable(DATA_COMPANYADDRESS_DBTABLE) && KitGroupMemberInfoData.groupId.inTable(DATA_GROUPMEMBERINFO_DBTABLE) == groupId)];

    NSMutableArray *groupDataArray = [NSMutableArray array];
    while (WCTMultiObject *multiObject = [multiSelect nextMultiObject]) {
        KitGroupMemberInfoData *memberInfo = (KitGroupMemberInfoData *) [multiObject objectForKey:DATA_GROUPMEMBERINFO_DBTABLE];
        KitCompanyAddress *address = (KitCompanyAddress *) [multiObject objectForKey:DATA_COMPANYADDRESS_DBTABLE];

        NSString *account =  memberInfo.memberId;
        NSString *name = address.name != nil ? address.name : memberInfo.memberName;
        NSString *headUrl = address.photourl;
        NSString *md5 = address.urlmd5;
        NSInteger level = address.level;
        NSString *userStatus = address.userStatus;
        NSString *department_id = address.department_id;
        NSString *mobile = address.mobilenum;
        //不用对象 字典传出 垃圾代码 看懂了在优化
        NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
        mDic[Table_User_member_name] = KSCNSTRING_ISNIL(name);
        mDic[Table_User_account] = KSCNSTRING_ISNIL(account);
        mDic[Table_User_avatar] = KSCNSTRING_ISNIL(headUrl);
        mDic[Table_User_urlmd5] = KSCNSTRING_ISNIL(md5);
        mDic[Table_User_Level] = [NSNumber numberWithInteger:level];
        mDic[Table_User_status] = KSCNSTRING_ISNIL(userStatus);
        mDic[Table_User_department_id] = KSCNSTRING_ISNIL(department_id);
        mDic[Table_User_mobile] = KSCNSTRING_ISNIL(mobile);
        [groupDataArray addObject:mDic];
    }
    return groupDataArray;
}

//新增查询聊天界面成员2017yxp8.10
+ (NSMutableArray *)getChatGroupAllMemberInfoWithGroupId:(NSString *)groupId{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    WCTMultiSelect *multiSelect = [[dataBase prepareSelectMultiObjectsOnResults:{
        KitGroupMemberInfoData.memberId.inTable(DATA_GROUPMEMBERINFO_DBTABLE),
        KitCompanyAddress.name.inTable(DATA_COMPANYADDRESS_DBTABLE),
    } fromTables:@[DATA_GROUPMEMBERINFO_DBTABLE,DATA_COMPANYADDRESS_DBTABLE]] where: (KitGroupMemberInfoData.memberId.inTable(DATA_GROUPMEMBERINFO_DBTABLE) == KitCompanyAddress.account.inTable(DATA_COMPANYADDRESS_DBTABLE) && KitGroupMemberInfoData.groupId.inTable(DATA_GROUPMEMBERINFO_DBTABLE) == groupId)];


    NSMutableArray *groupDataArray = [NSMutableArray array];
    while (WCTMultiObject *multiObject = [multiSelect nextMultiObject]) {
        KitGroupMemberInfoData *memberInfo = (KitGroupMemberInfoData *) [multiObject objectForKey:DATA_GROUPMEMBERINFO_DBTABLE];
        KitCompanyAddress *address = (KitCompanyAddress *) [multiObject objectForKey:DATA_COMPANYADDRESS_DBTABLE];

        NSString *memberId = memberInfo.memberId;
        NSString *memberName = address.name != nil ? address.name:@"无名称";
        NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
        mDic[Table_User_member_name] = memberName;
        mDic[Table_User_account] = memberId;
        mDic[@"isVoip"] = @"1";
        [groupDataArray addObject:mDic];
    }
    return groupDataArray;
}
///根据groupId批量查询
+ (NSArray<KitGroupMemberInfoData *> *)getAllmemberInfoWithGroupId:(NSString *)groupId{
    return [self getAllGroupMemberInfoByCondition:KitGroupMemberInfoData.groupId == groupId];
}

//优化查询群组成员信息 2017yxp8.3
+ (NSMutableArray<KitGroupMemberInfoData *> *)getGroupMembers:(NSString *)groupId{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    
    NSNumber *comCount = [[AppModel sharedInstance] runModuleFunc:@"RXAddressBook" :@"getCompanyAddressBookCount" :nil];
    
    if ([comCount integerValue] > 0) {//存在的话 联
        
        WCTMultiSelect *multiSelect = [[dataBase prepareSelectMultiObjectsOnResults:{
            KitGroupMemberInfoData.memberId.inTable(DATA_GROUPMEMBERINFO_DBTABLE),
            KitGroupMemberInfoData.groupId.inTable(DATA_GROUPMEMBERINFO_DBTABLE),
            KitGroupMemberInfoData.memberName.inTable(DATA_GROUPMEMBERINFO_DBTABLE),
            KitGroupMemberInfoData.role.inTable(DATA_GROUPMEMBERINFO_DBTABLE),
            
            KitCompanyAddress.name.inTable(DATA_COMPANYADDRESS_DBTABLE),
            KitCompanyAddress.pyname.inTable(DATA_COMPANYADDRESS_DBTABLE),
            KitCompanyAddress.mobilenum.inTable(DATA_COMPANYADDRESS_DBTABLE),
            KitCompanyAddress.fnmname.inTable(DATA_COMPANYADDRESS_DBTABLE),
            KitCompanyAddress.photourl.inTable(DATA_COMPANYADDRESS_DBTABLE),
            KitCompanyAddress.urlmd5.inTable(DATA_COMPANYADDRESS_DBTABLE),
            KitCompanyAddress.sex.inTable(DATA_COMPANYADDRESS_DBTABLE),
            KitCompanyAddress.level.inTable(DATA_COMPANYADDRESS_DBTABLE),
            KitCompanyAddress.place.inTable(DATA_COMPANYADDRESS_DBTABLE),
        } fromTables:@[DATA_GROUPMEMBERINFO_DBTABLE,DATA_COMPANYADDRESS_DBTABLE]] where: (KitGroupMemberInfoData.memberId.inTable(DATA_GROUPMEMBERINFO_DBTABLE) == KitCompanyAddress.account.inTable(DATA_COMPANYADDRESS_DBTABLE) && KitGroupMemberInfoData.groupId.inTable(DATA_GROUPMEMBERINFO_DBTABLE) == groupId)];
        
        NSMutableArray *groupDataArray = [NSMutableArray array];
        while (WCTMultiObject *multiObject = [multiSelect nextMultiObject]) {
            KitGroupMemberInfoData *memberInfo = (KitGroupMemberInfoData *) [multiObject objectForKey:DATA_GROUPMEMBERINFO_DBTABLE];
            KitCompanyAddress *address = (KitCompanyAddress *) [multiObject objectForKey:DATA_COMPANYADDRESS_DBTABLE];
            
            memberInfo.headUrl = address.photourl;
            memberInfo.headMd5 = address.urlmd5;
            memberInfo.userName = address.name;
            memberInfo.place = address.place;
            memberInfo.pyname = address.pyname;
            memberInfo.fnm = address.fnmname;
            memberInfo.mobile = address.mobilenum;
            memberInfo.level = address.level;
            [groupDataArray addObject:memberInfo];
        }
        return groupDataArray;
    } else {
        return [NSMutableArray arrayWithArray:[dataBase getObjectsOfClass:self fromTable:DATA_GROUPMEMBERINFO_DBTABLE where:KitGroupMemberInfoData.groupId == groupId orderBy:KitGroupMemberInfoData.role.order(WCTOrderedAscending)]];
    }
}
//获取对应组的所有成员的数量
+ (NSInteger)getAllMemberCountGroupId:(NSString *)groupId{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    NSNumber *count = [dataBase getOneValueOnResult:KitGroupMemberInfoData.AnyProperty.count() fromTable:DATA_GROUPMEMBERINFO_DBTABLE where:KitGroupMemberInfoData.groupId == groupId];
    return count.integerValue;
}
//获取指定数量的数据
+ (NSArray<KitGroupMemberInfoData *> *)getMemberInfoWithGroupId:(NSString *)groupId withCount:(int)count{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getObjectsOfClass:self fromTable:DATA_GROUPMEMBERINFO_DBTABLE where:KitGroupMemberInfoData.groupId == groupId orderBy:KitGroupMemberInfoData.role.order(WCTOrderedAscending)  limit:count];
}

//获取多个成员数据 排序好的 从创建者开始
+ (NSArray<KitGroupMemberInfoData *> *)getSequenceMembersforGroupId:(NSString *)groupId memberCount:(int)count{
    NSNumber *comCount = [[AppModel sharedInstance] runModuleFunc:@"RXAddressBook" :@"getCompanyAddressBookCount" :nil];

    if ([comCount integerValue] > 0) {//存在的话 联查
        WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
        WCTMultiSelect *multiSelect = [[[[dataBase prepareSelectMultiObjectsOnResults:{
            KitGroupMemberInfoData.memberId.inTable(DATA_GROUPMEMBERINFO_DBTABLE),
            KitGroupMemberInfoData.groupId.inTable(DATA_GROUPMEMBERINFO_DBTABLE),
            KitGroupMemberInfoData.memberName.inTable(DATA_GROUPMEMBERINFO_DBTABLE),

            KitCompanyAddress.name.inTable(DATA_COMPANYADDRESS_DBTABLE),
            KitCompanyAddress.photourl.inTable(DATA_COMPANYADDRESS_DBTABLE),
            KitCompanyAddress.urlmd5.inTable(DATA_COMPANYADDRESS_DBTABLE),
        } fromTables:@[DATA_GROUPMEMBERINFO_DBTABLE,DATA_COMPANYADDRESS_DBTABLE]] where: (KitGroupMemberInfoData.memberId.inTable(DATA_GROUPMEMBERINFO_DBTABLE) == KitCompanyAddress.account.inTable(DATA_COMPANYADDRESS_DBTABLE) && KitGroupMemberInfoData.groupId.inTable(DATA_GROUPMEMBERINFO_DBTABLE) == groupId)] orderBy:KitGroupMemberInfoData.role.order(WCTOrderedAscending)] limit:count];

        NSMutableArray<KitGroupMemberInfoData *> *sequenceArray = [[NSMutableArray alloc] init];
        while (WCTMultiObject *multiObject = [multiSelect nextMultiObject]) {
            KitGroupMemberInfoData *memberInfo = (KitGroupMemberInfoData *) [multiObject objectForKey:DATA_GROUPMEMBERINFO_DBTABLE];
            KitCompanyAddress *address = (KitCompanyAddress *) [multiObject objectForKey:DATA_COMPANYADDRESS_DBTABLE];

            memberInfo.headUrl = address.photourl;
            memberInfo.headMd5 = address.urlmd5;
            memberInfo.userName = address.name;
            [sequenceArray addObject:memberInfo];
        }
        return sequenceArray;
    } else {
        return [self getMemberInfoWithGroupId:groupId withCount:count];
    }
}
//获取 role 为1的数据 创建者
+ (KitGroupMemberInfoData *)getAuthorWithGroupId:(NSString *)groupId withRole:(NSString *)role{
    return [self getGroupMemberInfoByCondition:KitGroupMemberInfoData.groupId == groupId && KitGroupMemberInfoData.role == role];
}
//获取 role 为2的数据 管理员
+ (NSArray<KitGroupMemberInfoData *> *)getManagersWithGroupId:(NSString *)groupId withRole:(NSString *)role{
    return [self getAllGroupMemberInfoByCondition:KitGroupMemberInfoData.groupId == groupId && KitGroupMemberInfoData.role == role];
}
///根据name 查询满足的群组
+ (NSArray<ECGroup *> *)getGroupInfoWithName:(NSString *)name{
    //先查出包含的群组id
    NSString *text = [NSString stringWithFormat:@"%%%@%%",name];
    NSArray<KitGroupMemberInfoData *> *array = [self getAllGroupMemberInfoByCondition:KitGroupMemberInfoData.memberName.like(text)];
    //去重
    NSMutableDictionary *mDic = [[NSMutableDictionary alloc] init];
    for (KitGroupMemberInfoData *info in array) {
        [mDic setValue:info forKey:info.groupId];
    }
    ///找出groupid 和 匹配上的名称
    NSMutableArray<ECGroup *> *dataArr = [[NSMutableArray alloc] init];
    for (KitGroupMemberInfoData *info in mDic.allValues) {
        ECGroup *group = [[ECGroup alloc] init];
        group.groupId = info.groupId;
        ///根据groupId查name
        group.name = [[KitMsgData sharedInstance] getGroupNameOfId: info.groupId];
        group.remark = info.memberName;
        [dataArr addObject:group];
    }
    return dataArr;
}
@end
