//
//  HXInviteCountData.mm
//  Common
//
//  Created by lxj on 2018/8/8.
//  Copyright © 2018年 ronglian. All rights reserved.
//

#import "HXInviteCountData+WCTTableCoding.h"
#import "HXInviteCountData.h"
#import <WCDB/WCDB.h>

@implementation HXInviteCountData

WCDB_IMPLEMENTATION(HXInviteCountData)
WCDB_SYNTHESIZE(HXInviteCountData, userAccount)
WCDB_SYNTHESIZE(HXInviteCountData, inviteCount)
WCDB_PRIMARY(HXInviteCountData, userAccount)

#pragma mark - 增
+ (BOOL)insertInviteCount:(NSInteger)inviteCount withAccount:(NSString *)account{
    HXInviteCountData *countData = [[HXInviteCountData alloc] init];
    countData.inviteCount = inviteCount;
    countData.userAccount = account;

    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase insertOrReplaceObject:countData into:DATA_NEWFRIENDINVITE_COUNT];
}
#pragma mark - 改
+ (BOOL)updateInviteCount:(NSInteger)inviteCount withAccount:(NSString *)account{
    HXInviteCountData *countData = [[HXInviteCountData alloc] init];
    countData.inviteCount = inviteCount;

    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase updateRowsInTable:DATA_NEWFRIENDINVITE_COUNT onProperties:HXInviteCountData.inviteCount withObject:countData where:HXInviteCountData.userAccount == account];
}

+ (BOOL)updateAllInviteCount:(NSInteger)inviteCount{
    HXInviteCountData *countData = [[HXInviteCountData alloc] init];
    countData.inviteCount = inviteCount;

    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    return [dataBase updateAllRowsInTable:DATA_NEWFRIENDINVITE_COUNT onProperties:HXInviteCountData.inviteCount withObject:countData];
}

#pragma mark - 查
//获取单个的邀请数量
+ (NSInteger)getAppointInviteCount:(NSString *)account{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    NSNumber *count = [dataBase getOneValueOnResult:HXInviteCountData.inviteCount fromTable:DATA_NEWFRIENDINVITE_COUNT where:HXInviteCountData.userAccount == account];
    return count.integerValue;
}
//获取当前邀请数量
+ (NSInteger)getCurrentInviteCount{
    WCTDatabase *dataBase = [DataBaseManager sharedInstance].dataBase;
    NSNumber *count = [dataBase getOneValueOnResult:HXInviteCountData.inviteCount.sum() fromTable:DATA_NEWFRIENDINVITE_COUNT];
    return count.integerValue;
}
@end
