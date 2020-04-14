//
//  KitDialingData.h
//  guodiantong
//
//  Created by yuxuanpeng on 14-10-27.
//  Copyright (c) 2014年 guodiantong. All rights reserved.
//

#import "BaseModel.h"

//拨号数据库的操作

@interface KitDialingData : BaseModel

///自增id
@property(nonatomic ,assign) int tid;

@property (copy,nonatomic) NSString *mobile;
@property (copy,nonatomic) NSString *account;
@property (copy,nonatomic) NSString *call_status;//0  呼出电话 1 呼出未接听 2 呼入电话接听 3 呼入拒接
@property (copy,nonatomic) NSString *nickname;
@property (assign,nonatomic) NSInteger call_number;   //电话个数
@property (assign,nonatomic) NSTimeInterval call_date;
@property (assign,nonatomic) NSInteger call_type;//呼叫类型 0 voip 1 视频 2直拨落地 3回拨   20语音会议 21视频会议 22 线下会议室


#pragma mark - 删
///根据mobile删除
+ (BOOL)deleteDialingPhoneDataDB:(NSString *)mobile;
///根据mobile和call_status删除数据
+ (BOOL)deleteDialingDataDB:(KitDialingData *)dialingData;
///删除所有
+ (BOOL)deleteAllDialingDataDB;
#pragma mark - 改
+ (BOOL)updateDialingDataDB:(KitDialingData *)dialingData;
#pragma mark - 查
+ (NSArray<KitDialingData *> *)getDialingArray;
//通过手机号码去获取数据
+ (KitDialingData *)getDialingWithMobile:(NSString *)mobile;
//通过手机号码和call_status判断
+ (KitDialingData *)getDialingDataWithMobile:(NSString*)mobile call_status:(NSString*)call_status;
//检查某一指定mobile的记录是否已经存在
+ (BOOL)checkRecordExistInDb:(NSString*)mobile;
@end
