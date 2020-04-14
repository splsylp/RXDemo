//
//  KitGroupData.h
//  Rongxin
//
//  Created by yuxuanpeng MINA on 14-11-1.
//  Copyright (c) 2014年 Rongxin.com. All rights reserved.
//

#import "BaseModel.h"

//群组的操作
@interface KitGroupData : BaseModel

@property (nonatomic, copy) NSString *groupId; // 群组ID
@property (nonatomic, copy) NSString *groupName; // 群组名称
@property (nonatomic, copy) NSString *groupAD; // 群组公告
@property (nonatomic, assign) BOOL isOpenIMMsg; //是否打开新消息通知
@property (nonatomic, assign) BOOL isMsgTopDisplay;
@property (nonatomic, assign) BOOL isGroupNickname;


@property(nonatomic,retain) IMGroupInfo *groupInfo;

+ (KitGroupData *)convertFromData:(IMGroupInfo *)groupInfo;

@end

@interface KitGroupData (Ext)

//从本地或网络中请求群组信息
+ (KitGroupData *)getGroupData:(NSString *)groupId;
#pragma mark - 增
+ (BOOL)insertOrReplaceGroupData:(KitGroupData *)groupData;
#pragma mark - 删
///根据groupId删除
+ (BOOL)deleteGroupData:(NSString *)groupId;
#pragma mark - 查
///根据groupId查询
+ (KitGroupData *)queryForGroupId:(NSString *)groupId;


@end
