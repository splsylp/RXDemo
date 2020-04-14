//
//  KitGroupMemberInfoData.h
//  ECSDKDemo_OC
//
//  Created by ronglianmac1 on 15/8/22.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "BaseModel.h"
@class ECGroup;
@interface KitGroupMemberInfoData : BaseModel
///表里字段
///自增id
@property(nonatomic ,assign) int tid;
@property(retain,nonatomic)NSString *memberId;//成员账号
@property(retain,nonatomic)NSString *groupId;//群组ID
@property(retain,nonatomic)NSString *memberName;//成员名字
@property(retain,nonatomic)NSString *headUrl;//成员头像url
@property(retain,nonatomic)NSString *headMd5;//成员md5
@property(retain,nonatomic)NSString *role;//角色 1群主 2管理员 3普通人
@property(retain,nonatomic)NSString *sex;//性别
///非表内字段
@property(retain,nonatomic)NSString *userName;//用户名称
@property(retain,nonatomic)NSString *place;//职位
@property(retain,nonatomic)NSString *mobile;//手机号
@property(nonatomic,assign)NSInteger level;//用户级别
@property(retain,nonatomic)NSString *pyname;//全拼
@property(retain,nonatomic)NSString *fnm;//拼音首字母

#pragma mark - 增
//批量导入 使用事务
+ (void)insertGroupMemberArray:(NSArray *)memberArray withGroupId:(NSString *)groupId;
+ (void)insertData:(NSArray*)resourse useTransaction:(BOOL)useTransaction withGroupId:(NSString *)groupId;
+ (BOOL)insertGroupMemberInfoData:(KitGroupMemberInfoData *)infoData;
#pragma mark - 删
///根据groupId删除
+ (BOOL)deleteGroupAllMemberInfoDataDB:(NSString*)groupId;
///根据memberId和groupId删除
+ (BOOL)deleteGroupMemberPhoneInfoDataDB:(NSString*)memberId withGroupId:(NSString *)groupId;
///删除所有
+ (BOOL)deleteAlldeleteGroupMemberInfoDataDB;
#pragma makr - 改
//更新角色等级
+ (BOOL)updateRoleStateaMemberId:(NSString *)memberId andRole:(NSString *)role;

+ (BOOL)updateRoleStateWithMemberIds:(NSArray <NSString *>*)memberIds andRole:(NSString *)role;
#pragma mark - 查
///根据groupId memberId查询
+ (KitGroupMemberInfoData *)getGroupMemberInfoWithMemberId:(NSString*)memberId withGroupId:(NSString *)groupId;
///查询所有
+ (NSArray<KitGroupMemberInfoData *> *)getGroupMemberInfoDataArray;
//新增选择成员查询 返回通讯录数据
+ (NSMutableArray *)getSelectCompanyDataWithGroupId:(NSString *)groupId;
//新增查询聊天界面成员2017yxp8.10
+ (NSMutableArray *)getChatGroupAllMemberInfoWithGroupId:(NSString *)groupId;
///根据groupId批量查询
+ (NSArray<KitGroupMemberInfoData *> *)getAllmemberInfoWithGroupId:(NSString*)groupId;
//优化查询群组成员信息 2017yxp8.3
+ (NSMutableArray<KitGroupMemberInfoData *> *)getGroupMembers:(NSString *)groupId;
//获取对应组的所有成员的数量
+ (NSInteger)getAllMemberCountGroupId:(NSString *)groupId;
//获取指定数量的数据
+ (NSArray<KitGroupMemberInfoData *> *)getMemberInfoWithGroupId:(NSString *)groupId withCount:(int)count;
//获取多个成员数据 排序好的 从创建者开始
+ (NSArray<KitGroupMemberInfoData *> *)getSequenceMembersforGroupId:(NSString *)groupId memberCount:(int)count;
//获取 role 为1的数据 创建者
+ (KitGroupMemberInfoData *)getAuthorWithGroupId:(NSString *)groupId withRole:(NSString *)role;
/// 获取 role 为2的数据 管理员
+ (NSArray<KitGroupMemberInfoData *> *)getManagersWithGroupId:(NSString *)groupId withRole:(NSString *)role;
///根据name 查询满足的群组
+ (NSArray<ECGroup *> *)getGroupInfoWithName:(NSString *)name;
@end
