//
//  KitCompanyAddress.h
//  Rongxin
//
//  Created by tonywang on 16/8/19.
//  Copyright (c) 2015年 Rongxin.com. All rights reserved.
//

typedef enum : NSUInteger {
    meet_other = 0,    //其他类型
    meet_calling ,     //接通中
} meetState;

#import "BaseModel.h"

@interface KitCompanyAddress : BaseModel
///成员名字
@property(nonatomic ,strong) NSString *name;
///成员ID
@property(nonatomic ,strong) NSString *nameId;
///成员名字的拼音
@property(nonatomic ,strong) NSString *pyname;
///成员名字的头文字的首字母
@property(nonatomic ,strong) NSString *fnmname;
///成员电话号码
@property(nonatomic ,strong) NSString *mobilenum;
///成员voip号
@property(nonatomic ,strong) NSString *voipaccount;
///成员头像
@property(nonatomic ,strong) NSString *photourl;
///个性签名
@property(nonatomic ,strong) NSString *signature;
///职位
@property(nonatomic ,strong) NSString *place;
///QQ
@property(nonatomic ,strong) NSString *qq;
///md5
@property(nonatomic ,strong) NSString *urlmd5;
///部门id
@property(nonatomic ,strong) NSString *department_id;
///Email
@property(nonatomic ,strong) NSString *mail;
///是否为领导 0:普通 1:领导
@property(nonatomic ,strong) NSString *isLeader;
///性别
@property(nonatomic ,strong) NSString *sex;
///成员account
@property(nonatomic ,assign) NSInteger order;
@property(nonatomic ,strong) NSString *account;
@property(nonatomic ,assign) meetState state;
///用户状态,0:重置密码，1:正常，2:账号锁定，3:离职（暂未使用），4:账号冻结
@property(nonatomic ,copy) NSString *userStatus;
//@property (nonatomic, assign) int isOne;//判断两个号码是否是同一个人
///用户级别
@property(nonatomic ,assign) NSInteger level;
///部门名称
@property(nonatomic ,copy) NSString *depart_name;
// 是否在线
@property (nonatomic ,assign) NSInteger online; //是否在线,1在线，0离线

/// 级别
@property(nonatomic ,strong) NSString *personLevel;


+ (KitCompanyAddress *)sharedInstance;

#pragma mark - 增
///批量插入数据
+ (void)insertCompanyAddressInfo:(NSArray *)resourse;
//使用事务来入库
+ (void)insertData:(NSMutableArray *)resourse useTransaction:(BOOL)useTransaction;
///插入一条数据
+ (void)insertCompanyAddressDic:(NSDictionary *)personDic;

///大通讯录使用 只有4个参数 name account departmentid photourl
- (void)insertDataWhenBigAddress:(NSDictionary *)dic;
#pragma mark - 删
///根据voipaccount删除
+ (BOOL)deleteCompanyAddressVoip:(NSString *)voipaccount;
///根据nameid删除
+ (BOOL)deleteCompanyAddressInfoDataDB:(KitCompanyAddress *)companyAddressInfoData;
///根据nameId 部门departmentId 删除数据
+ (BOOL)deleteCompanyAddressUid:(NSString *)nameId withDepartmentId:(NSString *)departmentId;
#pragma mark - 改
///更新企业通讯录
- (BOOL)updateCompanyAddressInfoDataDB:(KitCompanyAddress *)address;
///更新个人信息 头像 签名
- (id)updateCompanyAddressInfo:(NSDictionary *)dict;
///根据account 修改userStatus
+ (BOOL)updateCompanyUserStatus:(NSString *)status withAccount:(NSString *)account;

#pragma mark - 查
///获取数量
+ (NSInteger)getCompanyAddressCount;
///根据部门id获取数量
+ (NSInteger)getCompanyAddressCountByDepartment_id:(NSString *)department_id;
///根据nameId查询用户信息
+ (KitCompanyAddress *)getCompanyAddressInfoDataWithNameId:(NSString *)nameId;
///根据mobilenum查询
+ (KitCompanyAddress *)getCompanyAddressInfoDataWithMobilenum:(NSString *)mobilenum;
///根据account查询
+ (KitCompanyAddress *)getCompanyAddressInfoDataWithAccount:(NSString *)account;
// 好友信息是不显示离职的
+ (KitCompanyAddress *)getMyFrindInfoDataWithAccount:(NSString *)account;
///根据departmentid,userId查询
+ (KitCompanyAddress *)getCompanyAddressInfoDataWithDepartmentid:(NSString *)departmentid withUserId:(NSString *)userId;

//获取全部通讯录
+ (NSArray<KitCompanyAddress *> *)getCompanyAddressArray;
///根据部门id获取通讯录
+ (NSArray<KitCompanyAddress *> *)getCompanyAddressArrayByDepartment_id:(NSString *)department_id;
//获取全部通讯录 根据输入筛选
+ (NSArray<KitCompanyAddress *> *)getCompanyAddressArrayBySearchText:(NSString *)searchText page:(NSInteger)page pageSize:(NSInteger)pageSize;
#pragma mark - 清空表
+ (BOOL)deleteAllCompanyAddressInfoDataDB;

///FTS查询
+ (NSArray<KitCompanyAddress *> *)getCompanyAddressFTSArrayBySearchText:(NSString *)searchText page:(NSInteger)page pageSize:(NSInteger)pageSize;
@end
