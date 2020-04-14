//
//  KContinuityVibrationManager.h
//  zhendong
//
//  Created by 陈长军 on 2017/2/17.
//  Copyright © 2017年 陈长军. All rights reserved.
//


/**
//连续振动管理类,
 */


#import <Foundation/Foundation.h>

#define Max_VibrationErrorTime    30      //容错机制_连续振动超过最大时长 会停止振动（s）
#define Time_Interval_Vibration   0.5      //每次振动的时间间隔（s）


@interface KContinuityVibrationManager : NSObject

+(instancetype)shardDefaultManager;

/**
 @brief 开始振动（内部已经判断App设置振动开关）
 */
-(void)startVibration;

/**
 @brief 停止振动
 */
-(void)stopVibration;


/**
 @brief 静音模式不让播放音乐
 @discussion
 */
-(void)setSoundPayerMode;


/**
 @brief 是否静音模式
 @discussion
 */
-(BOOL)silenced;


/**
 @brief 是否有摄像头权限
 @discussion
 */
-(BOOL)isHaveCameraRights;



@end
