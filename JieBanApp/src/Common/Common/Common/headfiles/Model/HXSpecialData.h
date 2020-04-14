//
//  HXSpecialData.h
//  ECSDKDemo_OC
//
//  Created by ywj on 16/6/13.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "BaseModel.h"

@interface HXSpecialData : BaseModel

@property(nonatomic, copy) NSString *account;//账号 唯一主键

#pragma mark - 增
//批量插入数据
+ (void)insertSpecialAttentsInfo:(NSArray<NSString *> *)resourse;
#pragma mark - 删
///根据account删除
+ (BOOL)deleteSpecialAccount:(NSString *)account;
//删除全部
+ (BOOL)deleteAllSpecialData;
//批量删除
+ (void)deleteSpecialAttentsInfo:(NSArray<NSString *> *)resourse;
#pragma mark - 查
///是否是特别关注
+ (BOOL)haveSpecialWithAccount:(NSString *)account;
///数量
+ (NSInteger)getSpecialCount;
///所有
+ (NSArray<HXSpecialData *> *)getAllSpecialData;

@end
