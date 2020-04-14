//
//  KitGroupInfoData.h
//  ECSDKDemo_OC
//
//  Created by ronglianmac1 on 15/8/22.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "BaseModel.h"

@interface KitGroupInfoData : BaseModel
@property(retain,nonatomic)NSString *groupId;//群组ID
@property(retain,nonatomic)NSString *groupName;//群组名字
@property(retain,nonatomic)NSString *declared;//公告
@property(retain,nonatomic)NSString *createTime;//创建时间
@property(retain,nonatomic)NSString *owner;//创建者
@property(assign,nonatomic)NSInteger memberCount;//成员数量
@property(assign,nonatomic)NSInteger type;//暂定
@property (nonatomic,assign) BOOL isAnonymity;//匿名
@property (assign,nonatomic) BOOL isDiscuss;//是否是讨论组
@property (assign,nonatomic) BOOL isNotice;//是否新消息提醒
@property (assign,nonatomic) BOOL isGroupMember;//是否是群内成员
@property (nonatomic ,assign) NSInteger scope;//群组类型

#pragma mark - 增
+ (BOOL)insertGroupInfoData:(KitGroupInfoData*)infoData;
#pragma mark - 改
//更新groupName declared owner
+ (BOOL)upDateGroupInfo:(KitGroupInfoData *)groupInfo;
///更新isNotice
+ (BOOL)updateGroupMessageOption:(NSString *)groupId withstatus:(BOOL)status;
#pragma mark - 删
///删除所有
+ (BOOL)deleteAlldeleteGroupInfoDataDB;
///根据groupId删除
+ (BOOL)deleteGroupInfoDataDB:(NSString *)groupId;
#pragma mark - 查
///根据groupId查询
+ (KitGroupInfoData *)getGroupInfoWithGroupId:(NSString*)groupId;
///查询所有
+ (NSArray<KitGroupInfoData *> *)getGroupInfoDataArray;

#pragma mark - ECGroup_son迁移过来的
#pragma mark - 增
///新增或修改group
+ (BOOL)addGroup:(ECGroup *)group;
#pragma mark - 删
///根据groupId删除
+ (BOOL)deleteGroupByGroupId:(NSString *)groupId;
///删除所有群组
+ (BOOL)deleteAllGroup;
#pragma mark - 改
///修改成员在群中的状态
+ (BOOL)updateMemberStateByGroupId:(NSString *)groupId isGroupMember:(BOOL)isGroupMember;
#pragma mark - 查
///根据groupId查ECGroup对象
+ (ECGroup *)getGroupByGroupId:(NSString *)groupId;
///所有的群组
+ (NSArray<ECGroup *> *)getAllGroup;
///所有群组数量
+ (NSInteger)getGroupAllCount;
///根据groupId查name
+ (NSString *)getGroupNameByGroupId:(NSString *)groupId;
///返回字典
+ (NSArray *)getGroupInformationByGroupId:(NSString *)groupId;
///根据输入name 倒序查询符合的群组
+ (NSArray<ECGroup *> *)getGroupWithSearchText:(NSString *)searchText;
@end
