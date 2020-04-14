//
//  YHCConference.h
//  YouHui
//
//  Created by 王文龙 on 2017/8/19.
//  Copyright © 2017年 wwl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHCConferenceSetting.h"
#import "ECConferenceInfo.h"
#import "ECError.h"
#import "YHCConfInfo.h"

#define kNOTIFICATION_ReloadConfCurrentList       @"NOTIFICATION_ReloadConfCurrentList"
#define kNOTIFICATION_ReloadConfHistoryList       @"NOTIFICATION_ReloadConfHistoryList"

@interface YHCConference : NSObject
@property(nonatomic,strong) UIViewController* meettingVC;
@property(nonatomic,strong) UIViewController* answerVC;
@property(nonatomic,copy) NSString* appKey;
//单例
+ (instancetype)sharedInstance;

- (id)getRealDelegateCanRespondsToSelector:(SEL)aSelector;

/**
 @brief 最大成员数
 */
@property (nonatomic, assign) NSUInteger maxMember;

/**
 @brief 加入会议
 @discussion 根据传入的参数加入会议
 @param     confId 会议id
 @param     nickname 自己的名字
 @param     mute 静音加入
 @param     closeVideo 关闭摄像头加入
 @success completion 错误码和成功后的会议信息
 */
- (void)joinConferenceWithConfId:(NSString *)confId
                        nickName:(NSString *)nickname
                            mute:(BOOL)mute
                      closeVideo:(BOOL)closeVideo;

/**
 @brief 创建预约会议
 @discussion 根据传入的参数创建预约会议
 @param     confInfo 会议信息
 @success completion 错误码和成功后的会议信息
 */
- (void)reserverConference:(YHCConfInfo *)confInfo
                completion:(void(^)(ECError* error, ECConferenceInfo*conferenceInfo))completion ;
/**
 @brief 更新预约会议
 @discussion 根据传入的参数创建预约会议
 @param     conferenceId 会议号
 @param     confInfo 会议信息
 @success completion 错误码和成功后的会议信息
 */
- (void)updateReserverConferenceId:(NSString *)conferenceId
                        conference:(YHCConfInfo *)confInfo
                        completion:(void(^)(ECError* error, ECConferenceInfo*conferenceInfo))completion;

/**
 @brief 锁定会议
 @param confId 会议ID
 @param lockType 0 锁定，1 解锁，2 锁定白板发起，3 解锁，4 锁定白板标注，5 解锁
 @param completion 执行结果回调block
 */
- (void)lockConference:(NSString*)confId lockType:(int)lockType completion:(void(^)(ECError* error))completion;

/**
 @brief 立即会议
 @discussion 根据传入的参数创建立即会议
 @param     confInfo 会议信息
 @success completion 错误码和成功后的会议信息
 */
- (void)startConference:(YHCConfInfo *)confInfo
             completion:(void(^)(ECError* error, ECConferenceInfo*conferenceInfo))completion ;

/**
 @brief 获取会议相关设置 会议呼入号码，会议最大参会人数，会议最小参会人数
 @discussion 获取会议相关设置
 */
- (void)getConfSettingCompletion:(void(^)(ECError* error, YHCConferenceSetting *appSettingfo))completion;

/**
 @brief 获取会议列表页面
 */
-(UIViewController*)getConflistVC;
/**
 @brief 获取立即开始会议页面
 */
-(UIViewController*)getConfStartVC;
/**
 @brief 获取创建预约会议页面，conferenceInfo不为空时为更新预约会议
 */
-(UIViewController*)getConfReserverVCWithInfo:(ECConferenceInfo *)conferenceInfo;
/**
 @brief 获取加入会议页面
 */
-(UIViewController*)getConfJoinVC;
/**
 @brief 获取会议详情页面
 */
-(UIViewController*)getConfInfoVCWithConfId:(NSString *)confId haveEnd:(BOOL)haveEnd;
@end
