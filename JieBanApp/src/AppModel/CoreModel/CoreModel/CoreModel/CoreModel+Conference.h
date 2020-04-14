//
//  CoreModel+Conference.h
//  CoreModel
//
//  Created by zhouwh on 2017/12/18.
//  Copyright © 2017年 ronglian. All rights reserved.
//

#import "CoreModel.h"

@interface CoreModel (Conference)
/**
 @brief 获取应用下的总的会议设置信息
 @param completion 执行结果回调block
 */
- (void)getConferenceAppSetting:(void(^)(ECError* error, ECConferenceAppSettingInfo *appSettingfo))completion;

/**
 @brief 获取用户会议室ID
 @param completion 执行结果回调block
 */
- (void)getConfroomIdListWithAccount:(ECAccountInfo *)member confId:(NSString *)confId completion:(void(^)(ECError* error, NSArray *arr))completion;


/**
 @brief 创建会议
 @param conferenceInfo 会议类
 @param completion 执行结果回调block
 */
- (void)createConference:(ECConferenceInfo*)conferenceInfo completion:(void(^)(ECError* error, ECConferenceInfo*conferenceInfo))completion;

/**
 @brief 删除会议
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)deleteConference:(NSString*)confId completion:(void(^)(ECError* error))completion;

/**
 @brief 更新会议信息
 @param conferenceInfo 会议类
 @param completion 执行结果回调block
 */
- (void)updateConference:(ECConferenceInfo*)conferenceInfo completion:(void(^)(ECError* error))completion;

/**
 @brief 获取会议信息
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)getConference:(NSString*)confId completion:(void(^)(ECError* error, ECConferenceInfo*conferenceInfo))completion;

/**
 @brief 获取会议列表
 @param condition 筛选条件
 @param page 分页信息
 @param completion 执行结果回调block
 */
- (void)getConferenceListWithCondition:(ECConferenceCondition*)condition page:(CGPage)page ofMember:(ECAccountInfo*)member completion:(void(^)(ECError* error, NSArray* conferenceList))completion;

/**
 @brief 获取历史会议列表
 @param condition 筛选条件
 @param page 分页信息
 @param completion 执行结果回调block
 */
- (void)getHistoryConferenceListWithCondition:(ECConferenceCondition*)condition page:(CGPage)page completion:(void(^)(ECError* error, NSArray* conferenceList))completion;

/**
 @brief 锁定会议
 @param confId 会议ID
 @param lockType 0 锁定，1 解锁，2 锁定白板发起，3 解锁，4 锁定白板标注，5 解锁
 @param completion 执行结果回调block
 */
- (void)lockConference:(NSString*)confId lockType:(int)lockType completion:(void(^)(ECError* error))completion;

/**
 @brief 加入会议
 @param joinInfo 加入条件
 @param completion 执行结果回调block
 */
- (void)joinConferenceWith:(ECConferenceJoinInfo*)joinInfo completion:(void(^)(ECError* error, ECConferenceInfo*conferenceInfo))completion;

/**
 @brief 退出会议
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)quitConference:(NSString*)confId completion:(void(^)(ECError* error))completion;

/**
 @brief 更换成员信息
 @param memberInfo 成员信息
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)updateMember:(ECConferenceMemberInfo*)memberInfo ofConference:(NSString*)confId completion:(void(^)(ECError* error))completion;

/**
 @brief 获取成员信息
 @param member 账号信息
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)getMember:(ECAccountInfo*)member ofConference:(NSString*)confId completion:(void(^)(ECError* error, ECConferenceMemberInfo* memberInfo))completion;

/**
 @brief 获取成员列表
 @param confId 会议ID
 @param page 分页信息
 @param completion 执行结果回调block
 */
- (void)getMemberListOfConference:(NSString*)confId page:(CGPage)page completion:(void(^)(ECError* error, NSArray* members))completion;

/**
 @brief 获取会议中的成员与会记录
 @param accountInfo 相关成员记录 如果为nil，获取所有成员与会记录
 @param confId 会议ID
 @param page 分页信息
 @param completion 执行结果回调block
 */
- (void)getMemberRecord:(ECAccountInfo*)accountInfo ofConference:(NSString*)confId page:(CGPage)page completion:(void(^)(ECError* error, NSArray* membersRecord))completion;


/**
 @brief 邀请加入会议
 @param inviteMembers ECAccountInfo数组 邀请的成员
 @param confId 会议ID
 @param callImmediately 是否立即发起呼叫 对于自定义账号，1表示给用户显示呼叫页面，并设置超时时间1分钟 对于电话号码（或关联电话）账号，1表示立即给cm发呼叫命令 0表示仅在会议中增加成员（一般用户预约会议开始前增加成员）
 @param appData 预留
 @param completion 执行结果回调block
 */
- (void)inviteMembers:(NSArray*)inviteMembers inConference:(NSString*)confId callImmediately:(int)callImmediately appData:(NSString*)appData completion:(void(^)(ECError* error))completion;


/**
 @brief 拒绝会议邀请
 @param invitationId 邀请的id
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)rejectInvitation:(NSString*)invitationId cause:(NSString*)cause ofConference:(NSString*)confId completion:(void(^)(ECError* error))completion;
/**
 @brief 踢出成员
 @param kickMembers ECAccountInfo数组 踢出的成员
 @param confId 会议ID
 @param appData 预留
 @param completion 执行结果回调block
 */
- (void)kickMembers:(NSArray*)kickMembers outConference:(NSString*)confId appData:(NSString*)appData completion:(void(^)(ECError* error))completion;

/**
 @brief 设置成员角色
 @param member 相关设置信息
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)setMemberRole:(ECAccountInfo*)member ofConference:(NSString*)confId completion:(void(^)(ECError* error))completion;

/**
 @brief 媒体控制
 @param action 控制动作
 @param members ECAccountInfo数组 控制成员列表
 @param isAllMember 是否全部成员
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)controlMedia:(ECControlMediaAction)action toMembers:(NSArray*)members isAll:(int)isAllMember ofConference:(NSString*)confId completion:(void(^)(ECError* error))completion;

/**
 @brief 会议媒体是否sdk自动控制   1 sdk收到会控通知会自动控制媒体 0 sdk不会控制媒体相关
 
 @param isAuto 是否自动控制
 */
- (NSInteger)setConferenceAutoMediaControl:(BOOL)isAuto;

/**
 @brief 会议录制
 @param action 录制控制
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)record:(ECRecordAction)action conference:(NSString*)confId completion:(void(^)(ECError* error))completion;

/**
 @brief 发布音频
 @param confId 会议ID
 @param exclusively 仅用于实时对讲功能。
 1 表示控麦，此时仅允许会中有一个人发布语音，如果已经有人发布语音，此接口调用会返回错误
 0 表示发布语音，不考虑其他人语音发布状态
 @param completion 执行结果回调block
 */
- (void)publishVoiceInConference:(NSString*)confId exclusively:(int)exclusively completion:(void(^)(ECError* error))completion;

/**
 @brief 取消发布
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)stopVoiceInConference:(NSString*)confId exclusively:(int)exclusively completion:(void(^)(ECError* error))completion;

/**
 @brief 发布视频
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)publishVideoInConference:(NSString*)confId completion:(void(^)(ECError* error))completion;

/**
 @brief 取消发布
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)cancelVideoInConference:(NSString*)confId completion:(void(^)(ECError* error))completion;

/**
 @brief 共享屏幕
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)shareScreenInConference:(NSString*)confId completion:(void(^)(ECError* error))completion;

/**
 @brief 停止共享屏幕
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)stopScreenInConference:(NSString*)confId completion:(void(^)(ECError* error))completion;

/**
 @brief 请求成员视频
 @param videoInfo 视频信息
 @param completion 执行结果回调block
 */
- (void)requestMemberVideoWith:(ECConferenceVideoInfo*)videoInfo completion:(void(^)(ECError* error))completion;

/**
 @brief 停止成员视频
 @param videoInfo 视频信息
 @param completion 执行结果回调block
 */
- (void)stopMemberVideoWith:(ECConferenceVideoInfo*)videoInfo completion:(void(^)(ECError* error))completion;

/**
 @brief 重置显示View
 @param videoInfo 视频信息
 */
- (int)resetMemberVideoWith:(ECConferenceVideoInfo*)videoInfo;

/**
 @brief 重置本地预览显示View
 */
- (int)resetLocalVideoWithConfId:(NSString *)confId remoteView:(UIView *)remoteView localView:(UIView *)localView;
@end
