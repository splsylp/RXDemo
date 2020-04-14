//
//  UIKitConfiManager.h
//  guodiantong
//
//  Created by chaizhiyong on 14-12-8.
//  Copyright (c) 2014年 guodiantong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIKitConfiManager : NSObject

+(BOOL)newMsgNotiVailableStatus;
+(void)setNewMsgNotiVailableStatus:(BOOL)status;
//新消息振动提示
+(BOOL)msgVibrateVailableStatus;
//设置新消息振动状态
+(void)setMsgVibrateVailableStatus:(BOOL)status;
//新消息是否提示
+(BOOL)msgSoundVailableStatus;
//设置新消息提示状态
+(void)setMsgSoundVailableStatus:(BOOL)status;
//获取当前新消息的提示音
+ (NSString*)msgNotifSoundId;
//设置新消息的提示音
+ (void)setNewMsgNotifSoundId:(NSString*)sid;
//振动
+ (void)playSystemSound:(NSString*)systemSoundId;

+ (void)playSystemVibrate;
//后台消息提醒时段是否是整天
+ (BOOL)backgroundNotifiVailableAllday;

+(void)setBackgroundNotifiVailableAllday:(BOOL)status;

+(NSString*)backgroundNotifiSatrtTime;

+ (void)setBackgroundNotifiStartTime:(NSString*)time;

+(NSString*)backgroundNotifiEndTime;

+ (void)setBackgroundNotifiEndTime:(NSString*)time;

+(BOOL)companyNotifiNoDisturbingVailable;

+ (void)setCompanyNotifiNoDisturbingVailable:(BOOL)status;
//企业提醒是否全天开启
+ (BOOL)isBetweenCompanyNotifiTimes;
@end
