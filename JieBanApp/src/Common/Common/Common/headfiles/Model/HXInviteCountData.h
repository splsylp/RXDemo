//
//  HXInviteCountData.h
//  ECSDKDemo_OC
//
//  Created by ywj on 16/7/24.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "BaseModel.h"

@interface HXInviteCountData : BaseModel
@property(nonatomic,strong) NSString *userAccount;
@property(nonatomic,assign) NSInteger inviteCount;

#pragma mark - 增
+ (BOOL)insertInviteCount:(NSInteger)inviteCount withAccount:(NSString *)account;
#pragma mark - 改
+ (BOOL)updateInviteCount:(NSInteger)inviteCount withAccount:(NSString *)account;
+ (BOOL)updateAllInviteCount:(NSInteger)inviteCount;
#pragma mark - 查
//获取单个的邀请数量
+ (NSInteger)getAppointInviteCount:(NSString *)account;
//获取当前邀请数量
+ (NSInteger)getCurrentInviteCount;

@end
