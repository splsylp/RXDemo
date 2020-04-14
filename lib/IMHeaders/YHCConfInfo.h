//
//  YHCConfInfo.h
//  YHCConference
//
//  Created by 王文龙 on 2018/5/3.
//  Copyright © 2018年 wwl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHCConfInfo : NSObject
/**
 @brief conferencename 会议id
 */
@property (nonatomic, copy) NSString *conferenceId;
/**
 @brief conferencename 会议主题
 */
@property (nonatomic, copy) NSString *conferencename;
/**
 @brief startTime 会议开始时间
 格式:yyyy-MM-dd HH:mm:ss
 */
@property (nonatomic, copy) NSString *startTime;
/**
 @brief duration 会议持续时间（15分钟的多少倍）
 */
@property (nonatomic, assign) NSInteger *duration;
/**
 @brief meetingMember  会议成员(ECConferenceMemberInfo或者ECAccountInfo对象)
 */
@property (nonatomic, copy) NSArray *meetingMember;
/**
 @brief 是否静音加入。
 */
@property (nonatomic, assign) BOOL mute;
/**
 @brief 是否关闭摄像头加入。
 */
@property (nonatomic, assign) BOOL closeVideo;
/**
 @brief 议题
 */
@property (nonatomic, copy) NSString *topicStr;
/**
 @brief 透传信息
 */
@property (nonatomic, copy) NSString *appData;
/**
 @brief 最大成员数
 */
@property (nonatomic, assign) NSUInteger maxMember;

@end
