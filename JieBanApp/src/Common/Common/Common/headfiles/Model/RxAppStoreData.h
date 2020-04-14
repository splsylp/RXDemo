//
//  RxAppStoreData.h
//  Common
//
//  Created by wangming on 2017/5/25.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "BaseModel.h"

@interface RxAppStoreData : BaseModel

@property(nonatomic,strong)NSString *account;//用户账号
@property(nonatomic,assign)int appId;//应用Id
@property(nonatomic,strong)NSString *appName;//应用名称
@property(nonatomic,strong)NSString *appCode;//应用编码
@property(nonatomic,assign)int appType;//应用类型
@property(nonatomic,strong)NSString *appLogo;//应用图片url
@property(nonatomic,strong)NSString *appUrl;//应用url
@property(nonatomic,strong)NSString *appDes;//应用描述
@property(nonatomic,assign)int groupId;//应用分组id
@property(nonatomic,assign)int publicStatus;//是否共有应用
@property(nonatomic,assign)int installStatus;//是否已安装
@property(nonatomic,assign)int isForcedInstall;//安装状态 1：不强制安装；2：强制安装可卸载；3：强制安装不可卸载';
@property(nonatomic,assign)int isHidden;//是否隐藏
@property(nonatomic,assign)int isNaviBar;//是否隐藏导航栏

#pragma mark - 增
//插入单条应用商店数据
+ (BOOL)insertAppInfoData:(RxAppStoreData*)infoData;
//批量插入数据
+ (void)insertAppsInfo:(NSArray<RxAppStoreData *> *)resourse;
//使用事务来入库
+ (void)insertData:(NSArray<RxAppStoreData *> *)resourse useTransaction:(BOOL)useTransaction;
#pragma mark - 删
//删除
+ (BOOL)deleteAppInfoData:(NSString *)appId;
#pragma mark - 查
///根据appid查询
+ (RxAppStoreData *)getAppInfoWithAppId:(int)appId;
///根据appId查appUrl
+ (NSString *)getAppUrl:(int)appId;
///查最新的n条数据
+ (NSArray<RxAppStoreData *> *)getAPPInfoWithCount:(int)count;
///查询所有数据
+ (NSArray<RxAppStoreData *> *)getAllAppInfo;
@end
