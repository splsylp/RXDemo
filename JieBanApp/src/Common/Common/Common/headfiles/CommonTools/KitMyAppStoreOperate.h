//
//  KitMyAppStoreOperate.h
//  Common
//
//  Created by yuxuanpeng on 2017/8/17.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "BaseModel.h"

@interface KitMyAppStoreOperate : BaseModel

@property(nonatomic,assign)NSInteger appId;
@property(nonatomic,assign)NSInteger appType;
@property(nonatomic,assign)NSInteger curStatus;//状态 1/2 存在/不存在

#pragma mark - 增
//使用事务来入库
+ (void)insertData:(KitMyAppStoreOperate *)resourse useTransaction:(BOOL)useTransaction;
#pragma mark - 删
+ (BOOL)deleteAppStroeWithAppId:(NSString *)appId appType:(NSInteger)appType;
#pragma mark - 查
+ (NSArray *)getAllAppStoreOperate;
+ (NSInteger)getAppStoreCurStatusWithAppId:(NSString *)appId appType:(NSInteger)appType;
@end
