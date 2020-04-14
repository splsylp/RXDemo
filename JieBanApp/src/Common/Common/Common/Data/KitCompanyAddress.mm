//
//  KitCompanyAddress.mm
//  AddressBook
//
//  Created by lxj on 2018/7/27.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "KitCompanyAddress+WCTTableCoding.h"
#import "KitCompanyAddress.h"
#import <WCDB/WCDB.h>


static NSString *myAccount;
static NSMutableArray *allCompanyAddress;
static NSMutableArray *allThreeLevelAddress;
static NSMutableArray *allTenLevelAddress;//十级目录 zmf add

@implementation KitCompanyAddress

WCDB_IMPLEMENTATION(KitCompanyAddress)
WCDB_SYNTHESIZE(KitCompanyAddress, name)
WCDB_SYNTHESIZE(KitCompanyAddress, nameId)
WCDB_SYNTHESIZE(KitCompanyAddress, pyname)
WCDB_SYNTHESIZE(KitCompanyAddress, fnmname)
WCDB_SYNTHESIZE(KitCompanyAddress, mobilenum)
WCDB_SYNTHESIZE(KitCompanyAddress, voipaccount)
WCDB_SYNTHESIZE(KitCompanyAddress, photourl)
WCDB_SYNTHESIZE(KitCompanyAddress, signature)
WCDB_SYNTHESIZE(KitCompanyAddress, place)
WCDB_SYNTHESIZE(KitCompanyAddress, qq)
WCDB_SYNTHESIZE(KitCompanyAddress, urlmd5)
WCDB_SYNTHESIZE(KitCompanyAddress, department_id)
WCDB_SYNTHESIZE(KitCompanyAddress, mail)
WCDB_SYNTHESIZE(KitCompanyAddress, isLeader)
WCDB_SYNTHESIZE(KitCompanyAddress, sex)
WCDB_SYNTHESIZE(KitCompanyAddress, account)
WCDB_SYNTHESIZE(KitCompanyAddress, state)
WCDB_SYNTHESIZE(KitCompanyAddress, userStatus)
WCDB_SYNTHESIZE(KitCompanyAddress, personLevel)
WCDB_SYNTHESIZE(KitCompanyAddress, depart_name)
WCDB_SYNTHESIZE(KitCompanyAddress, online)

WCDB_SYNTHESIZE_COLUMN(KitCompanyAddress, level, "calevel")
WCDB_SYNTHESIZE_COLUMN_DEFAULT(KitCompanyAddress, order, "orderrank", 0)
WCDB_NOT_NULL(KitCompanyAddress, account)
WCDB_UNIQUE(KitCompanyAddress, account)

WCDB_PRIMARY(KitCompanyAddress, nameId)

WCDB_INDEX(KitCompanyAddress, "idx1", nameId)
WCDB_INDEX(KitCompanyAddress, "idx2", voipaccount)
WCDB_INDEX(KitCompanyAddress, "idx3", nameId)
WCDB_INDEX(KitCompanyAddress, "idx3", department_id)
WCDB_INDEX(KitCompanyAddress, "idx4", mobilenum)
WCDB_INDEX(KitCompanyAddress, "idx5", isLeader)
WCDB_INDEX(KitCompanyAddress, "idx6", account)
WCDB_INDEX(KitCompanyAddress, "idx7", account)
WCDB_INDEX(KitCompanyAddress, "idx7", userStatus)

///FTS
WCDB_VIRTUAL_TABLE_MODULE(KitCompanyAddress, @"fts3")
WCDB_VIRTUAL_TABLE_TOKENIZE(KitCompanyAddress, @"WCDB")



+ (NSDictionary *)modelCustomPropertyMapper{
    return @{@"voipaccount":@[@"voipaccount",@"voip"],
             @"pyname":@[@"user_pinyin",@"py"],
             @"fnmname":@[@"user_initial",@"fnm"],
             @"order":@[@"order",@"orderField"],
             @"place":@[@"duty",@"up"],
             @"mail":@[@"mail",@"email"],
             @"name":@[@"username",@"unm"],
             @"urlmd5":@[@"urlmd5",@"md5"],
             @"photourl":@[@"photourl",@"url"],
             @"isLeader":@[@"isLeader",@"isl"],
             @"signature":@[@"signature",@"sign"],
             @"mobilenum":@[@"mobilenum",@"mtel"],
             @"department_id":@"udid",
             @"level":@"userLevel",
             @"nameId":@"uid",
             @"depart_name":@[@"depart_name",@"dnm"],
             @"online":@"online",
             };
}


+ (KitCompanyAddress *)sharedInstance{
    static KitCompanyAddress *address = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        address = [[KitCompanyAddress alloc] init];
    });
    return address;
}
#pragma mark - 增
///批量插入数据
+ (void)insertCompanyAddressInfo:(NSArray *)resourse{
    [self insertData:resourse useTransaction:YES];
}

//使用事务来入库
+ (void)insertData:(NSArray *)resourse useTransaction:(BOOL)useTransaction{
    if (allCompanyAddress) {
        [allCompanyAddress removeAllObjects];
    }
    ///整理数据
    NSMutableArray<KitCompanyAddress *> *array = [NSMutableArray new];
    for (NSDictionary *person in resourse) {
        KitCompanyAddress *address = [KitCompanyAddress yy_modelWithDictionary:person];
        [array addObject:address];
        ///如果有自己的数据 通知更新
        if ([address.account isEqualToString:[Common  sharedInstance].getAccount]) {
            [[AppModel sharedInstance] runModuleFunc:@"UserCenter" :@"updateMyInformation:" :@[person]];
        }
    }

    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    if (useTransaction) {///事务插入
        BOOL result = [dataBase beginTransaction];
        if (!result) {
            NSLog(@"事务开启失败");
        }
        for (KitCompanyAddress *address in array) {
            if (address.account) {
                [[KitCompanyAddress sharedInstance] updateCompanyAddressInfoDataDB:address];
            }
        }
        if (![dataBase commitTransaction]) {///事务失败 回滚
            [dataBase rollbackTransaction];
        }
    }else{//普通插入
        for (KitCompanyAddress *address in array) {
            if (address.mobilenum) {
                [[KitCompanyAddress sharedInstance] updateCompanyAddressInfoDataDB:address];
            }
        }
    }
}

///插入一条数据
+ (void)insertCompanyAddressDic:(NSDictionary *)personDic{
    if (allCompanyAddress) {
        [allCompanyAddress removeAllObjects];
    }
    if (personDic == nil) {
        return;
    }
    //组装对象
    KitCompanyAddress *address = [KitCompanyAddress yy_modelWithDictionary:personDic];
    //去掉脏数据
    if ([address.account isEqualToString:@""]) {
        return;
    }
    if ([address.account isEqualToString:[Common sharedInstance].getAccount]) {//如果插入的是自己的信息 通知更新数据
        [[AppModel  sharedInstance] runModuleFunc:@"UserCenter" :@"updateMyInformation:" :personDic?@[personDic]:@[]];
    }
    //插入数据
    [[KitCompanyAddress sharedInstance] updateCompanyAddressInfoDataDB:address];
}

///大通讯录使用 只有4个参数 name account departmentid photourl
- (void)insertDataWhenBigAddress:(NSDictionary *)dic{
    NSString *account = dic[Table_User_account];
    NSString *member_name = dic[Table_User_member_name];
    NSString *headImageUrl = dic[Table_User_avatar];
    NSString *md5 = dic[Table_User_urlmd5];
    KitCompanyAddress *address = [[KitCompanyAddress alloc] init];
    address.nameId = account;
    address.account = account;
    address.name = member_name;
    address.photourl = headImageUrl;
    address.urlmd5 = md5;

    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    KitCompanyAddress *companyInfoExit = [KitCompanyAddress getCompanyAddressInfoDataWithAccount:address.account];
    if (companyInfoExit) {//修改
        [dataBase updateRowsInTable:DATA_COMPANYADDRESS_DBTABLE onProperties:{KitCompanyAddress.nameId,KitCompanyAddress.account,KitCompanyAddress.name,KitCompanyAddress.photourl,KitCompanyAddress.urlmd5} withObject:address where:KitCompanyAddress.nameId == address.nameId];
    }else{
         [dataBase insertOrReplaceObject:address into:DATA_COMPANYADDRESS_DBTABLE];
    }
}
#pragma mark - 删
///删除方法
+ (BOOL)deleteCompanyAddressByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    BOOL result = [dataBase deleteObjectsFromTable:DATA_COMPANYADDRESS_DBTABLE where:condition];
    [self deleteCompanyAddressFTSByCondition:condition];
    if (result && allCompanyAddress) {
        [allCompanyAddress removeAllObjects];
    }
    return result;
}
///根据voipaccount删除
+ (BOOL)deleteCompanyAddressVoip:(NSString *)voipaccount{
    BOOL result = [KitCompanyAddress deleteCompanyAddressByCondition:KitCompanyAddress.voipaccount == voipaccount];
    return result;
}
///根据nameid删除
+ (BOOL)deleteCompanyAddressInfoDataDB:(KitCompanyAddress *)companyAddressInfoData{
    BOOL result = [KitCompanyAddress deleteCompanyAddressByCondition:KitCompanyAddress.nameId == companyAddressInfoData.nameId];
    return result;
}
///根据nameId 部门departmentId 删除数据
+ (BOOL)deleteCompanyAddressUid:(NSString *)nameId withDepartmentId:(NSString *)departmentId{
    BOOL result;
    KitCompanyAddress *address = [KitCompanyAddress getCompanyAddressInfoDataWithNameId:nameId];
    if (address) {
        if ([address.department_id containsString:@","]) {
            //包含就有多个部门
            NSString *departId = nil;
            NSArray *array = [address.department_id componentsSeparatedByString:@","];
            for(int i = 0; i < array.count;i++) {
                if([array[i] isEqualToString:departmentId]){
                    //不拼接
                    departId = [NSString stringWithFormat:@"%@",departmentId];
                }
            }
            address.department_id = departId;
            ///更新部门信息
            result = [self updateCompanyDepartment:address];
        } else {
            ///根据nameId删除
            result = [KitCompanyAddress deleteCompanyAddressByCondition:KitCompanyAddress.nameId == nameId];
        }
    } else{
        result = NO;
    }

    if (result && allCompanyAddress) {
        [allCompanyAddress removeAllObjects];
    }
    return result;
}
#pragma mark - 改
///更新企业通讯录
- (BOOL)updateCompanyAddressInfoDataDB:(KitCompanyAddress *)address{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    BOOL result;
    KitCompanyAddress *companyInfoExit = [KitCompanyAddress getCompanyAddressInfoDataWithAccount:address.account];
    if(address.department_id && companyInfoExit &&
       ![companyInfoExit.department_id containsString:address.department_id]){//一个人存在多个部门的问题
        address.department_id = [NSString stringWithFormat:@"%@,%@",companyInfoExit.department_id,address.department_id];
    }
    result = [dataBase insertOrReplaceObject:address into:DATA_COMPANYADDRESS_DBTABLE];
    if (ISFTSMODE) {
        [self updateCompanyAddressFTSInfoData:address];
    }
    if (result && allCompanyAddress) {
        [allCompanyAddress removeAllObjects];
    }
    return YES;
}
///更新个人信息 头像 签名
- (id)updateCompanyAddressInfo:(NSDictionary *)dict{
    KitCompanyAddress *address = [KitCompanyAddress getCompanyAddressInfoDataWithAccount:[Common sharedInstance].getAccount];
    if (!address) {
        return nil;
    }
    if ([dict hasValueForKey:@"headUrl"]) {//修改头像
        NSString *headUrl = dict[@"headUrl"];
        address.photourl = headUrl;
    }
    if ([dict hasValueForKey:@"signature"]) {
        NSString *signautre = dict[@"signature"];
        address.signature= signautre;
    }
    if ([dict hasValueForKey:@"headMd5"]) {
        NSString *headMd5 = dict[@"headMd5"];
        address.urlmd5 = headMd5;
    }
    [[KitCompanyAddress sharedInstance] updateCompanyAddressInfoDataDB:address];
    if (ISFTSMODE) {
        [[KitCompanyAddress sharedInstance] updateCompanyAddressFTSInfoData:address];
    }
    return nil;
}
///根据account 修改userStatus
+ (BOOL)updateCompanyUserStatus:(NSString *)status withAccount:(NSString *)account{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    KitCompanyAddress *address = [[KitCompanyAddress alloc] init];
    address.userStatus = status;
    address.account = account;
    BOOL result = [dataBase updateRowsInTable:DATA_COMPANYADDRESS_DBTABLE onProperties:{KitCompanyAddress.userStatus} withObject:address where:KitCompanyAddress.account == address.account];
    if (ISFTSMODE) {
        [self updateCompanyFTS:address];
    }
    return result;
}
///更新部门
+ (BOOL)updateCompanyDepartment:(KitCompanyAddress *)address{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    BOOL result = [dataBase updateRowsInTable:DATA_COMPANYADDRESS_DBTABLE onProperties:KitCompanyAddress.department_id withObject:address where:KitCompanyAddress.nameId == address.nameId];
    if (ISFTSMODE) {
        [self updateCompanyFTSDepartment:address];
    }
    return result;
}
#pragma mark - 查
///获取数量
+ (NSInteger)getCompanyAddressCount{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    NSNumber *count = [dataBase getOneValueOnResult:KitCompanyAddress.AnyProperty.count() fromTable:DATA_COMPANYADDRESS_DBTABLE where:KitCompanyAddress.userStatus.isNot(3).isNot(4)];
    return count.integerValue;
}
///根据部门id获取数量
+ (NSInteger)getCompanyAddressCountByDepartment_id:(NSString *)department_id{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    NSNumber *count = [dataBase getOneValueOnResult:KitCompanyAddress.AnyProperty.count() fromTable:DATA_COMPANYADDRESS_DBTABLE where:KitCompanyAddress.userStatus.isNot(3).isNot(4) && KitCompanyAddress.department_id == department_id];
    return count.integerValue;
}
///单条查询
+ (KitCompanyAddress *)getCompanyAddressInfoDataByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getOneObjectOfClass:self fromTable:DATA_COMPANYADDRESS_DBTABLE where:condition];
}
///批量查询
+ (NSArray<KitCompanyAddress *> *)getObjectsOfClassByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getObjectsOfClass:self fromTable:DATA_COMPANYADDRESS_DBTABLE where:condition orderBy:KitCompanyAddress.order.order(WCTOrderedAscending)];
}
///根据nameId查询用户信息
+ (KitCompanyAddress *)getCompanyAddressInfoDataWithNameId:(NSString *)nameId{
    return [KitCompanyAddress getCompanyAddressInfoDataByCondition:KitCompanyAddress.nameId == nameId];
}
///根据mobilenum查询
+ (KitCompanyAddress *)getCompanyAddressInfoDataWithMobilenum:(NSString*)mobilenum{
    return [KitCompanyAddress getCompanyAddressInfoDataByCondition:KitCompanyAddress.mobilenum == mobilenum];
}

+ (KitCompanyAddress *)getMyFrindInfoDataWithAccount:(NSString *)account {
    return [KitCompanyAddress getCompanyAddressInfoDataByCondition:KitCompanyAddress.account == account && KitCompanyAddress.userStatus!=@"3"];
}

///根据account查询
+ (KitCompanyAddress *)getCompanyAddressInfoDataWithAccount:(NSString *)account{ 
    return [KitCompanyAddress getCompanyAddressInfoDataByCondition:KitCompanyAddress.account == account];
}
///根据departmentid,userId查询
+ (KitCompanyAddress *)getCompanyAddressInfoDataWithDepartmentid:(NSString *)departmentid withUserId:(NSString *)userId{
    return [KitCompanyAddress getCompanyAddressInfoDataByCondition:KitCompanyAddress.department_id == departmentid && KitCompanyAddress.nameId = userId];
}

//获取全部通讯录
+ (NSArray<KitCompanyAddress *> *)getCompanyAddressArray {
    NSArray<KitCompanyAddress *> *array = [KitCompanyAddress getObjectsOfClassByCondition:KitCompanyAddress.userStatus.isNot(3).isNot(4)];
    return array;
}
//获取全部通讯录
+ (NSArray<KitCompanyAddress *> *)getCompanyAddressArrayByDepartment_id:(NSString *)department_id{
    NSArray<KitCompanyAddress *> *array = [KitCompanyAddress getObjectsOfClassByCondition:KitCompanyAddress.userStatus.isNot(3).isNot(4) && KitCompanyAddress.department_id == department_id];
    return array;
}
///add by 李晓杰 通讯录sql筛选
//获取全部通讯录(除比自己高两个级别以及两个级别以上的用户)  根据输入筛选
+ (NSArray<KitCompanyAddress *> *)getCompanyAddressArrayBySearchText:(NSString *)searchText page:(NSInteger)page pageSize:(NSInteger)pageSize{
    TICK;
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    NSString *text = [NSString stringWithFormat:@"%%%@%%",searchText];
    NSArray *array;
    if (ISLEVELMODE) {
        array = [dataBase getObjectsOfClass:self fromTable:DATA_COMPANYADDRESS_DBTABLE where:(KitCompanyAddress.userStatus.isNot(3).isNot(4) && (KitCompanyAddress.pyname.like(text) || KitCompanyAddress.fnmname.like(text) || (KitCompanyAddress.mobilenum.like(text) && KitCompanyAddress.level > ([[Common sharedInstance] getUserLevel].intValue - 2)) || KitCompanyAddress.name.like(text))) orderBy:KitCompanyAddress.order.order(WCTOrderedAscending)];
    } else{
        array = [dataBase getObjectsOfClass:self fromTable:DATA_COMPANYADDRESS_DBTABLE where:(KitCompanyAddress.userStatus.isNot(3).isNot(4) && (KitCompanyAddress.pyname.like(text) || KitCompanyAddress.fnmname.like(text) || KitCompanyAddress.mobilenum.like(text) || KitCompanyAddress.name.like(text))) orderBy:KitCompanyAddress.order.order(WCTOrderedAscending)];
    }
    TOCK;
    return array;
}

#pragma mark - 清空表
+ (BOOL)deleteAllCompanyAddressInfoDataDB{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    BOOL result = [dataBase deleteAllObjectsFromTable:DATA_COMPANYADDRESS_DBTABLE];
    if (ISFTSMODE) {
        [self deleteAllCompanyAddressFTS];
    }

    if (result && allCompanyAddress) {
        [allCompanyAddress removeAllObjects];
    }
    return result;
}

///FTS新增
///添加或修改FTS数据
- (BOOL)updateCompanyAddressFTSInfoData:(KitCompanyAddress *)address{
    BOOL result = NO;

    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    ///先查看是否存在
//    KitCompanyAddress *temp = [dataBase getOneObjectOfClass:self fromTable:DATA_COMPANYADDRESS_DBTABLE_FTS where:KitCompanyAddress.nameId == address.nameId];

    NSNumber *count = [dataBase getOneValueOnResult:KitCompanyAddress.AnyProperty.count() fromTable:DATA_COMPANYADDRESS_DBTABLE_FTS where:KitCompanyAddress.nameId == address.nameId];
    if (count.integerValue > 0) {//存在更新
        [dataBase updateRowsInTable:DATA_COMPANYADDRESS_DBTABLE_FTS onProperties:
        {
            KitCompanyAddress.name,
            KitCompanyAddress.pyname,
            KitCompanyAddress.fnmname,
            KitCompanyAddress.mobilenum,
            KitCompanyAddress.voipaccount,
            KitCompanyAddress.photourl,
            KitCompanyAddress.signature,
            KitCompanyAddress.place,
            KitCompanyAddress.qq,
            KitCompanyAddress.urlmd5,
            KitCompanyAddress.department_id,
            KitCompanyAddress.mail,
            KitCompanyAddress.isLeader,
            KitCompanyAddress.sex,
            KitCompanyAddress.account,
            KitCompanyAddress.state,
            KitCompanyAddress.userStatus,
            KitCompanyAddress.level,
            KitCompanyAddress.order,
            KitCompanyAddress.personLevel,
    } withObject:address where:KitCompanyAddress.nameId == address.nameId];
    }else{//不存在插入
        result = [dataBase insertObject:address into:DATA_COMPANYADDRESS_DBTABLE_FTS];
    }
    return result;
}
///根据account 修改userStatus
+ (BOOL)updateCompanyFTS:(KitCompanyAddress *)address{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase updateRowsInTable:DATA_COMPANYADDRESS_DBTABLE_FTS onProperties:{KitCompanyAddress.userStatus} withObject:address where:KitCompanyAddress.account == address.account];
}
+ (BOOL)updateCompanyFTSDepartment:(KitCompanyAddress *)address{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    BOOL result = [dataBase updateRowsInTable:DATA_COMPANYADDRESS_DBTABLE_FTS onProperties:KitCompanyAddress.department_id withObject:address where:KitCompanyAddress.nameId == address.nameId];
    return result;
}
///删除方法
+ (BOOL)deleteCompanyAddressFTSByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    BOOL result = [dataBase deleteObjectsFromTable:DATA_COMPANYADDRESS_DBTABLE_FTS where:condition];
    return result;
}
+ (BOOL)deleteAllCompanyAddressFTS{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    BOOL result = [dataBase deleteAllObjectsFromTable:DATA_COMPANYADDRESS_DBTABLE_FTS];
    return result;
}
///FTS查询
+ (NSArray<KitCompanyAddress *> *)getCompanyAddressFTSArrayBySearchText:(NSString *)searchText page:(NSInteger)page pageSize:(NSInteger)pageSize{
    TICK;
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    NSString *text = [NSString stringWithFormat:@"%@*",searchText];

    NSArray *array;
    if (ISLEVELMODE) {
        array = [dataBase getObjectsOfClass:self fromTable:DATA_COMPANYADDRESS_DBTABLE_FTS where:KitCompanyAddress.pyname.match(text) || KitCompanyAddress.fnmname.match(text) || (KitCompanyAddress.mobilenum.match(text) &&  KitCompanyAddress.level > ([[Common sharedInstance] getUserLevel].intValue - 2))|| KitCompanyAddress.name.match(text)];
    }else{
        array = [dataBase getObjectsOfClass:self fromTable:DATA_COMPANYADDRESS_DBTABLE_FTS where:KitCompanyAddress.pyname.match(text) || KitCompanyAddress.fnmname.match(text) || KitCompanyAddress.mobilenum.match(text) || KitCompanyAddress.name.match(text)];
    }
    TOCK;
    return array;
}
@end
