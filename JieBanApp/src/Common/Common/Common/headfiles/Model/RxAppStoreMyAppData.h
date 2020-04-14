//
//  RxAppStoreMyAppData.h
//  Common
//
//  Created by wangming on 2017/5/25.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "BaseModel.h"

@interface RxAppStoreMyAppData : BaseModel
@property(nonatomic,strong)NSString *account;//用户账号
@property(nonatomic,assign)int appId;//应用Id
@property(nonatomic,strong)NSString *appName;//应用名称
@property(nonatomic,strong)NSString *appCode;//应用编码
@property(nonatomic,assign)int appType;//应用类型
@property(nonatomic,strong)NSString *appLogo;//应用图片url
@property(nonatomic,strong)NSString *appUrl;//应用url
@property(nonatomic,strong)NSString *appDes;//应用描述
@property(nonatomic,assign)int groupId;//应用分组id
@property(nonatomic,strong)NSString *groupName;//应用分组名称
@property(nonatomic,strong)NSString *groupCode;//应用分组编号
@property(nonatomic,assign)int publicStatus;//是否共有应用
@property(nonatomic,assign)int installStatus;//安装的状态
@property(nonatomic,assign)BOOL isNaviBar;//有没有导航栏
@property(nonatomic,assign)BOOL isAppHidden;//是否隐藏此应用
@property(nonatomic,assign)int isForcedInstall;//安装状态 1：不强制安装；2：强制安装可卸载；3：强制安装不可卸载';
@property(nonatomic,assign)int appOrder;//排序字段
@property(nonatomic,copy)NSString *appVersion;//app版本 新增
@property(nonatomic,copy)NSString *appPackageUrl;//app离线包安装

#pragma mark - 增
//插入单条应用商店数据
+ (BOOL)insertMyAppData:(RxAppStoreMyAppData *)infoData;
//批量插入数据
+ (void)insertMyAppsInfo:(NSArray<RxAppStoreMyAppData *> *)resourse;
//使用事务来入库
+ (void)insertData:(NSArray<RxAppStoreMyAppData *> *)resourse useTransaction:(BOOL)useTransaction;

#pragma mark - 删
//根据appId删除 installStatus = 1
+ (BOOL)deleteMyAppData:(NSString *)appId;
///删除所有
+ (BOOL)deleteMyAllAppData;
#pragma mark - 改
//根据appId更新标记installStatus
+ (BOOL)updateMyAppDataInstallFlag:(NSString *)appId flag:(int)flag;
//根据appcode获取对应的应用数据
+ (NSDictionary *)getOneMyAppStoreDataWithAppCode:(NSString *)appcode;
//根据appId和apptype获取对应的数据
+ (NSDictionary *)getAppStoreParamsWithAppId:(NSString *)appId appType:(NSInteger)appType;
#pragma mark - 查
//需要做处理 跨表查询
+ (NSMutableArray *)getMyAppWithGroupId:(int)groupId;
///判断是否有已安装的app 即installStatus为1
+ (BOOL)getHasMyAppWithAppId:(int)appId;
///根据appId 查询 installStatus为1 isHidden为0的数据
+ (RxAppStoreMyAppData *)getMyAppWithAppId:(int)appId;
///查最新的n条数据 installStatus = 1  isHidden = 0
+ (NSArray<RxAppStoreMyAppData *> *)getMyAppWithCount:(int)count;
///所有数据 installStatus = 1  isHidden = 0
+ (NSArray<RxAppStoreMyAppData *> *)getAllMyApp;

@end
