//
//  KitVoipInfoData.h
//  guodiantong
//
//  Created by zhaozhibo on 15/1/20.
//  Copyright (c) 2015年 guodiantong. All rights reserved.
//

#import "KitBaseData.h"
@interface KitVoipInfoData : KitBaseData
@property (nonatomic, copy) NSString *voipaccount;
@property (nonatomic, copy) NSString *nickname;//昵称
@property (nonatomic, copy) NSString *photo;//图片地址
@property (nonatomic, copy) NSString *urlmd5;//头像的MD5值
@property (nonatomic, copy) NSString *mobile;//手机号码
@property (nonatomic, copy) NSString *isLeader;//是否领导
@property (nonatomic, copy) NSString *department_name;//部门名字
@property (nonatomic, copy) NSString *username;//用户名称
@property (nonatomic, copy) NSString *email;//邮箱
@property (nonatomic, copy) NSString *signature;//签名
@property (nonatomic, copy) NSString *sex;//性别
@property (nonatomic, copy) NSString *duty;//用户职位

//voip保存信息的操作

+ (KitVoipInfoData*)getVoipInfoDataWithVoipaccount:(NSString*)voipaccount;
+ (KitVoipInfoData *)getVoipInfoDataWithMobile:(NSString *)mobile;

//批量插入数据
+ (void)insertVoipInfoData:(NSMutableArray*)resourse;
+ (void)insertVoipInfo:(NSMutableArray*)resourse;
+ (void)insertVoipInfoUser:(NSArray*)resourse;

+ (bool)updateVoipInfoDataDB:(KitVoipInfoData*)voipInfoData;

+ (BOOL)deleteVoipInfoDataDB:(KitVoipInfoData*)voipInfoData;

+ (BOOL)deleteAllVoipInfoDataDB;
@end
