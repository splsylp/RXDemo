//
//  HXMyFriendList.mm
//  Common
//
//  Created by lxj on 2018/8/7.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "HXMyFriendList+WCTTableCoding.h"
#import "HXMyFriendList.h"
#import <WCDB/WCDB.h>

@implementation HXMyFriendList

WCDB_IMPLEMENTATION(HXMyFriendList)
WCDB_SYNTHESIZE(HXMyFriendList, account)
WCDB_PRIMARY(HXMyFriendList, account)

#pragma mark - 增
+ (void)insertMyFriendData:(NSArray *)friendJson{
    ///处理数据
    NSMutableArray<HXMyFriendList *> *friends = [[NSMutableArray alloc] init];
    for (NSDictionary * dataDic in friendJson){
        HXMyFriendList *friendList = [[HXMyFriendList alloc]init];
        friendList.account = [dataDic objectForKey:@"friendAccount"];

        [friends addObject:friendList];
    }

    [self insertmyFriendData:friends useTransaction:YES];
}

+ (void)insertmyFriendData:(NSArray<HXMyFriendList *> *)friendarray useTransaction:(BOOL)useTransaction{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    if (useTransaction) {///事务插入
        BOOL result = [dataBase beginTransaction];
        if (!result) {
            NSLog(@"事务开启失败");
        }

        [dataBase insertOrReplaceObjects:friendarray into:DATA_MYFRIEND_LIST];

        if (![dataBase commitTransaction]) {///事务失败 回滚
            [dataBase rollbackTransaction];
        }
    }else{//普通插入
        [dataBase insertOrReplaceObjects:friendarray into:DATA_MYFRIEND_LIST];
    }
}

+ (BOOL)insertOneFriend:(HXMyFriendList *)friendList{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase insertOrReplaceObject:friendList into:DATA_MYFRIEND_LIST];
}
#pragma mark - 删
///删除方法
+ (BOOL)deleteMyFriendDataByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteObjectsFromTable:DATA_MYFRIEND_LIST where:condition];
}
///根据account删除
+ (BOOL)deleteOneMyFriendData:(NSString *)userAccount{
    return [self deleteMyFriendDataByCondition:HXMyFriendList.account == userAccount];
}
///删除全部
+ (BOOL)deleteMyFriendAllData{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase deleteAllObjectsFromTable:DATA_MYFRIEND_LIST];
}
///根据数组删除数据
+ (void)deleteArrayFriend:(NSArray *)friendArray{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    BOOL result = [dataBase beginTransaction];
    if (!result) {
        NSLog(@"事务开启失败");
    }

    for (NSString *account in friendArray){
        if ([self isMyFriend:account]) {
            [self deleteOneMyFriendData:account];
        }
    }

    if (![dataBase commitTransaction]) {///事务失败 回滚
        [dataBase rollbackTransaction];
    }
}
#pragma mark - 查
///单条查询
+ (HXMyFriendList *)getFriendByCondition:(const WCTCondition &)condition{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase getOneObjectOfClass:self fromTable:DATA_MYFRIEND_LIST where:condition];
}
//是不是好友
+ (BOOL)isMyFriend:(NSString *)account{
    HXMyFriendList *friendList = [self getFriendByCondition:HXMyFriendList.account == account];
    return friendList != nil ? YES:NO;
}

+ (NSInteger)getMyFriendCount{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    NSNumber *count = [dataBase getOneValueOnResult:HXMyFriendList.AnyProperty.count() fromTable:DATA_MYFRIEND_LIST];
    return count.integerValue;
}

@end
