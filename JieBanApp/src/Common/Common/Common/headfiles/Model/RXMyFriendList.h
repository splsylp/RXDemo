//
//  RXMyFriendList.h
//  Common
//
//  Created by mac on 2017/2/17.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "BaseModel.h"

@interface RXMyFriendList : BaseModel

@property (nonatomic, strong) NSString *account;//成员account

#pragma mark - 增
+ (void)insertMyFriendData:(NSArray *)friendJson;
+ (void)insertmyFriendData:(NSArray *)friendarray useTransaction:(BOOL)useTransaction;
+ (BOOL)insertOneFriend:(RXMyFriendList *)friendList;
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
+ (NSArray<RXMyFriendList *> *)getMyFriendAllData;
@end
