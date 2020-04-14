//
//  HXMyFriendList.h
//  ECSDKDemo_OC
//
//  Created by ywj on 16/7/14.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "BaseModel.h"

@interface HXMyFriendList : BaseModel

//只存一个account标识
@property(nonatomic, strong) NSString *account;//朋友的账号

#pragma mark - 增
+ (void)insertMyFriendData:(NSArray *)friendJson;
+ (void)insertmyFriendData:(NSArray<HXMyFriendList *> *)friendarray useTransaction:(BOOL)useTransaction;
+ (BOOL)insertOneFriend:(HXMyFriendList *)friendList;
#pragma mark - 删
///根据account删除
+ (BOOL)deleteOneMyFriendData:(NSString *)userAccount;
///删除全部
+ (BOOL)deleteMyFriendAllData;
///根据数组删除数据
+ (void)deleteArrayFriend:(NSArray *)friendArray;
#pragma mark - 查
//是不是好友
+ (BOOL)isMyFriend:(NSString *)account;
+ (NSInteger)getMyFriendCount;

@end
