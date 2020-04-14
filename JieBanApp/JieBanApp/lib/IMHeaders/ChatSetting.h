//
//  ChatSetting.h
//  Chat
//
//  Created by zhangmingfei on 2017/3/13.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatSetting : NSObject

/*
 @brief 设置新消息提示开关
 @param status YES:开启新消息提示，NO:关闭新消息提示
 */
+(void)setNewMsgNotiVailableStatus:(BOOL)status;

/*
 @brief 获取新消息提示开关状态
 @return YES:开启新消息提示，NO:关闭新消息提示
 */
+(BOOL)newMsgNotiVailableStatus;

/*
 @brief 设置声音提示新消息开关
 @param status YES:开启声音提示，NO:关闭声音提示
 */
+(void)setMsgSoundVailableStatus:(BOOL)status;

/*
 @brief 获取声音提示新消息开关状态
 @return YES:开启声音提示，NO:关闭声音提示
 */
+(BOOL)msgSoundVailableStatus;

/*
 @brief 设置震动提示新消息开关
 @param status YES:开启震动提示，NO:关闭震动提示
 */
+(void)setMsgVibrateVailableStatus:(BOOL)status;

/*
 @brief 获取震动提示新消息开关状态
 @return YES:开启震动提示，NO:关闭震动提示
 */
+(BOOL)msgVibrateVailableStatus;

/*
 @brief 设置听筒/扬声器接听语音消息
 @param status YES:听筒，NO:开启扬声器
 */
+(void)setPlayEarStatus:(BOOL)status;

/*
 @brief 获取听筒/扬声器接听语音消息状态
 @return YES:听筒，NO:开启扬声器
 */
+(BOOL)playEarStatus;

/*
 @brief	清除所有聊天记录
 */
+(void)deleteAllSessionAndGroupnoticeData;

@end
