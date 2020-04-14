//
//  RxAppStoreAppGroupData.h
//  Common
//
//  Created by wangming on 2017/5/25.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "BaseModel.h"
@class RxAppStoreMyAppData;

@interface RxAppStoreAppGroupData : BaseModel

@property(nonatomic,strong)NSString *account;//用户账号
@property(nonatomic,assign)int groupId;//应用分组id
@property(nonatomic,strong)NSString *groupCode;//分组编号
@property(nonatomic,strong)NSString *groupName;//分组名
@property(nonatomic,strong)NSMutableArray<RxAppStoreMyAppData *> *apps;//应用信息
@property(nonatomic,assign)int groupOrder;//排序

#pragma mark - 增
///单个插入或更新 应用商店数据
+ (BOOL)insertGroupData:(RxAppStoreAppGroupData *)infoData;
//批量插入数据
+ (void)insertGroups:(NSArray<RxAppStoreAppGroupData *> *)resourse;
//使用事务来入库
+ (void)insertData:(NSArray<RxAppStoreAppGroupData *> *)resourse useTransaction:(BOOL)useTransaction;
#pragma mark - 删
//根据groupId删除
+ (BOOL)deleteGroupData:(NSString *)groupId;
///删除所有
+ (BOOL)deleteAllGroupData;
#pragma mark - 查
///查数量
+ (int)getGroupCount;
///根据groupId查询
+ (RxAppStoreAppGroupData *)getGroupWithGroupId:(int)groupId;
///查最新的n条数据
+ (NSArray<RxAppStoreAppGroupData *> *)getAPPInfoWithCount:(int)count;
///查所有数据
+ (NSArray<RxAppStoreAppGroupData *> *)getAllGroup;


+ (RxAppStoreAppGroupData *)getAppInfoWith:(int)groupId;

@end
