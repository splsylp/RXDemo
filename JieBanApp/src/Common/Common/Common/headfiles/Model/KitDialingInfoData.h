//
//  KitDialingInfoData.h
//  ECSDKDemo_OC
//
//  Created by ronglianmac1 on 15/7/28.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "BaseModel.h"
#import "RXThirdPart.h"

//数据库拨号的详情记录

@interface KitDialingInfoData : BaseModel

///表里数据
@property(nonatomic ,assign) int tid;
@property(nonatomic,retain)NSString *dialMobile;//通话人的号码,对方的号码
@property(nonatomic,retain)NSString *dialNickName;//通话人名字
@property(nonatomic,retain)NSString *dialType;//通话类型
@property(nonatomic,retain)NSString *dialState; //来电状态
@property(nonatomic,assign)NSInteger dialBeginTime;//通话开始时间
@property(nonatomic,retain)NSString *dialTime; //通话时间
@property(nonatomic,retain)NSString *dialAccount; //通话人账号

///不存数据库的数据
@property(nonatomic,assign)int callType; //通话类型
@property (nonatomic, assign) ECallDirect  callDirect;//呼叫方向
@property (nonatomic, assign) ECallStatus voipCallStatus;//呼叫状态
@property(nonatomic,retain)NSString *callid; //通话id
@property(nonatomic,assign)int reason; //呼叫错误码
@property(nonatomic,retain)NSString *callerDisplay; //主叫显号；
@property(nonatomic,retain)NSString *calledDisplay; //被叫显号；

@property(nonatomic,retain)id callViewController;

#pragma mark - 增
+ (BOOL)insertdialData:(KitDialingInfoData *)dialingInfoData;
#pragma mark - 删
///删除所有
+ (BOOL)deleteAllInfoDialingDataDB;
///根据dialMobile和dialState删除
+ (BOOL)deleteDialingInfoDataDB:(KitDialingInfoData *)infoDialingData;
///根据dialMobile删除
+ (BOOL)deleteDialingInfoPhoneDataDB:(NSString *)dialMobile;
#pragma mark - 查
///根据dialMobile查询
+ (KitDialingInfoData *)getInfoDialingWithMobile:(NSString*)dialMobile;
///根据dialaccount查询
+ (KitDialingInfoData *)getInfoDialingWithAccount:(NSString*)dialaccount;
///查询所有
+ (NSArray<KitDialingInfoData *> *)dialInfoAllArray;
///根据手机号查询数组
+ (NSArray<KitDialingInfoData *> *)getAllInfoDialingWithMobile:(NSString *)dialmobile;
///根据dialaccount查询数组
+ (NSArray<KitDialingInfoData *> *)getAllInfoDialingWithAccount:(NSString *)dialaccount;

@end
