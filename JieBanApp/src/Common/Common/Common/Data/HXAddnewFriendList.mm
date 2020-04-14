//
//  HXAddnewFriendList.mm
//  Common
//
//  Created by lxj on 2018/8/7.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "HXAddnewFriendList+WCTTableCoding.h"
#import "HXAddnewFriendList.h"
#import <WCDB/WCDB.h>

@implementation HXAddnewFriendList

WCDB_IMPLEMENTATION(HXAddnewFriendList)
WCDB_SYNTHESIZE(HXAddnewFriendList, userAccount)
WCDB_SYNTHESIZE(HXAddnewFriendList, userId)
WCDB_SYNTHESIZE(HXAddnewFriendList, describeMessage)
WCDB_SYNTHESIZE(HXAddnewFriendList, inviteStatus)
WCDB_SYNTHESIZE(HXAddnewFriendList, friendType)
WCDB_PRIMARY(HXAddnewFriendList, userAccount)


#pragma mark - 增
+ (BOOL)insertImMessage:(HXAddnewFriendList *)friendList{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase insertOrReplaceObject:friendList into:DATA_NEWFRIEND_LIST];
}

+ (void)insertFriendData:(NSArray *)friendJson{
    //处理数据
    NSMutableArray<HXAddnewFriendList *> *friends = [[NSMutableArray alloc] init];
    for (NSDictionary *dataDic in friendJson) {
        HXAddnewFriendList *friendList =[[HXAddnewFriendList alloc]init];
        friendList.userAccount = dataDic[@"account"];
        friendList.describeMessage = dataDic[@"describeMessage"];
        friendList.inviteStatus = (InviteFriendStatus) [dataDic[@"addFriendStatus"] intValue];
        friendList.friendType = (NewFriendType)1;
        friendList.userId = @"";

        [friends addObject:friendList];
    }
    [self insertFriendData:friends useTransaction:YES];
}
+ (void)insertFriendData:(NSArray<HXAddnewFriendList *> *)friendarray useTransaction:(BOOL)useTransaction{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    if (useTransaction) {///事务插入
        BOOL result = [dataBase beginTransaction];
        if (!result) {
            NSLog(@"事务开启失败");
        }

        [dataBase insertOrReplaceObjects:friendarray into:DATA_NEWFRIEND_LIST];

        if (![dataBase commitTransaction]) {///事务失败 回滚
            [dataBase rollbackTransaction];
        }
    }else{//普通插入
        [dataBase insertOrReplaceObjects:friendarray into:DATA_NEWFRIEND_LIST];
    }
}

#pragma mark - 删
///删除方法
+ (BOOL)deleteFriendDataByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteObjectsFromTable:DATA_NEWFRIEND_LIST where:condition];
}
///根据userAccount删除
+(BOOL)deleteOneFriendData:(NSString *)userAccount{
    return [self deleteFriendDataByCondition:HXAddnewFriendList.userAccount == userAccount];
}
///删除全部
+ (BOOL)deleteFriendAllData{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteAllObjectsFromTable:DATA_NEWFRIEND_LIST];
}

+ (void)deleteArrayFriendMessage:(NSArray *)friendArray{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    BOOL result = [dataBase beginTransaction];
    if (!result) {
        NSLog(@"事务开启失败");
    }

    for (NSString *account in friendArray){
        if ([self getNewFriendDataByCondition:HXAddnewFriendList.userAccount ==  account]) {
            [self deleteOneFriendData:account];
        }
    }
    if (![dataBase commitTransaction]) {///事务失败 回滚
        [dataBase rollbackTransaction];
    }
}
#pragma mark - 改
///修改状态
+ (BOOL)updateFrienInviteStatus:(NSString *)userAccount inviteFriendType:(InviteFriendStatus)inviteType{
    HXAddnewFriendList *friendList = [[HXAddnewFriendList alloc] init];
    friendList.inviteStatus = inviteType;

    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase updateRowsInTable:DATA_NEWFRIEND_LIST onProperties:HXAddnewFriendList.inviteStatus withObject:friendList where:HXAddnewFriendList.userAccount == userAccount];
}

#pragma mark - 查
///单条查询
+ (HXAddnewFriendList *)getNewFriendDataByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getOneObjectOfClass:self fromTable:DATA_NEWFRIEND_LIST where:condition];
}
///根据userAccount和inviteStaus查询
+ (BOOL)isExistLocationNewInvite:(NSString *)userAccount InviteFriendStatus:(InviteFriendStatus)inviteStaus{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    HXAddnewFriendList *newFriend = [dataBase getOneObjectOfClass:self fromTable:DATA_NEWFRIEND_LIST where:HXAddnewFriendList.userAccount == userAccount && HXAddnewFriendList.inviteStatus == inviteStaus];
    return newFriend != nil ? YES:NO;
}

+ (NSArray<HXAddnewFriendList *> *)getAllInviteFriendListWithout:(NSString *)account {
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getObjectsOfClass:self fromTable:DATA_NEWFRIEND_LIST where:HXAddnewFriendList.userAccount != account];
}
@end
