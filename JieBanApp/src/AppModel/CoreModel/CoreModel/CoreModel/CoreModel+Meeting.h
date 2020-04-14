//
//  CoreModel+Meeting.h
//  CoreModel
//
//  Created by wangming on 16/8/25.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreModel.h"

@interface CoreModel(Meeting)

/**
 @brief 创建音频会议、视频会议回调
 @param params     会议类
 @param completion 执行结果回调block
 */
-(void)createMultMeetingByType:(ECCreateMeetingParams *)params completion:(void(^)(ECError* error, NSString *meetingNumber))completion;

/**
 @brief 加入音频会议、视频会议、实时对讲
 @param meetingNumber 房间号
 @param meetingType   会议房间的类型
 @param meetingPwd    房间密码
 @param completion    执行结果回调block
 */
-(void)joinMeeting:(NSString*)meetingNumber ByMeetingType:(ECMeetingType )meetingType andMeetingPwd:(NSString *)meetingPwd completion:(void(^)(ECError* error, NSString *meetingNumber))completion;


/**
 @brief 邀请成员加入音频会议、视频会议
 @param meetingNumber 房间号
 @param isLoadingCall 用户登录的是手机号或者VoIP号，YES是VoIP号，NO是手机号
 @param members       加入房间的成员
 @param displaynumber 邀请非VoIP成员显示的号码
 @param sdkUserData   邀请VoIP成员，透传自定义数据
 @param serviceUserData 预留字段
 @param completion    执行结果回调block
 */
- (void)inviteMembersJoinMultiMediaMeeting:(NSString *)meetingNumber andIsLoandingCall:(BOOL)isLoadingCall andMembers:(NSArray *)members andDisplayNumber:(NSString*)displaynumber andSDKUserData:(NSString*)sdkUserData andServiceUserData:(NSString*)serviceUserData completion:(void (^)(ECError *error ,NSString * meetingNumber))completion;

/**
 @brief 邀请成员加入音频会议、视频会议
 @param meetingNumber 房间号
 @param isLoadingCall 用户登录的是手机号或者VoIP号，YES是手机号，NO是VoIP号
 @param members       加入房间的成员
 @param isSpeak       邀请加入的成员是否可讲
 @param isListen      邀请加入的成员是否可听
 @param displaynumber 邀请非VoIP成员显示的号码
 @param sdkUserData   邀请VoIP成员，透传自定义数据
 @param serviceUserData 预留字段
 @param completion    执行结果回调block
 */
- (void)inviteMembersJoinMultiMediaMeeting:(NSString *)meetingNumber andIsLoandingCall:(BOOL)isLoadingCall andMembers:(NSArray *)members andSpeak:(BOOL)isSpeak andListen:(BOOL)isListen andDisplayNumber:(NSString*)displaynumber andSDKUserData:(NSString*)sdkUserData andServiceUserData:(NSString*)serviceUserData completion:(void (^)(ECError *, NSString *))completion;

/**
 @brief 退出音频会议、实时对讲、视频会议
 @return 1 成功 0 失败
 */
-(BOOL)exitMeeting;

/**
 @brief 解散音频会议、视频会议
 @param multMeetingType 会议房间的类型
 @param meetingNumber   房间号
 @param completion      执行结果回调block
 */
-(void)deleteMultMeetingByMeetingType:(ECMeetingType)multMeetingType andMeetingNumber:(NSString *)meetingNumber completion:(void(^)(ECError *error, NSString *meetingNumber))completion;

/**
 @brief 获取实时对讲、音频会议、视频会议成员列表
 @param meetingtype   会议房间的类型
 @param meetingNumber 房间号
 @param completion    执行结果回调block
 */
-(void)queryMeetingMembersByMeetingType:(ECMeetingType)meetingtype andMeetingNumber:(NSString *)meetingNumber completion:(void(^)(ECError *error, NSArray* members))completion;

/**
 @brief 踢人音频会议、视频会议
 @param multMeetingType 会议房间的类型
 @param meetingNumber   房间号
 @param memberVoip     成员viop号
 @param completion      执行结果回调block
 */
-(void)removeMemberFromMultMeetingByMeetingType:(ECMeetingType)multMeetingType andMeetingNumber:(NSString *)meetingNumber andMember:(ECVoIPAccount *)memberVoip completion:(void(^)(ECError *error, ECVoIPAccount *memberVoip))completion;

/**
 @brief 获取音频会议、视频会议列表
 @param multMeetingType 会议房间的类型
 @param keywords        房间密码
 @param completion      执行结果回调block
 */
-(void)listAllMultMeetingsByMeetingType:(ECMeetingType)multMeetingType andKeywords:(NSString *)keywords completion:(void(^)(ECError *error, NSArray * meetingList))completion;

/**
 @brief 创建实时对讲
 @param members    成员
 @param completion 执行结果回调block
 */
-(void)createInterphoneMeetingWithMembers:(NSArray *)members completion:(void(^)(ECError* error, NSString* meetingNumber))completion;

/**
 @brief 实时对讲进行控麦
 @param meetingNumber 房间号
 @param completion    执行结果回调block
 */
-(void)controlMicInInterphoneMeeting:(NSString*)meetingNumber completion:(void(^)(ECError *error,NSString* memberVoip))completion;

/**
 @brief 实时对讲放麦
 @param meetingNumber 房间号
 @param completion    执行结果回调block
 */
-(void)releaseMicInInterphoneMeeting:(NSString*)meetingNumber completion:(void(^)(ECError *error,NSString *memberVoip))completion;

/**
 @brief 视频会议发布自己的视频
 @param meetingNumber 房间号
 @param completion    执行结果回调block
 */
-(void)publishSelfVideoFrameInVideoMeeting:(NSString *)meetingNumber completion:(void(^)(ECError *error, NSString *meetingNumber))completion;

/**
 @brief 视频会议取消自己的视频
 @param meetingNumber 房间号
 @param completion    执行结果回调block
 */
-(void)cancelPublishSelfVideoFrameInVideoMeeting:(NSString *)meetingNumber completion:(void(^)(ECError *error, NSString *meetingNumber))completion;

/**
 @brief 视频会议请求某一远端视频
 @param username 用户账号
 @param displayView 显示的view
 @param meetingNumber 房间号
 @param meetingPwd 房间密码
 @param port 视频源端口
 @param completion    执行结果回调block
 */
- (void)requestMemberVideoWithAccount:(NSString*)username andDisplayView:(UIView*)displayView andVideoMeeting:(NSString*)meetingNumber andPwd:(NSString*)meetingPwd andPort:(NSInteger)port completion:(void(^)(ECError *error, NSString *meetingNumber,NSString *member))completion;

/**
 @brief 视频会议取消请求某一远端视频
 @param username 用户账号
 @param meetingNumber 房间号
 @param meetingPwd 房间密码
 @param completion    执行结果回调block
 */
- (void)cancelMemberVideoWithAccount:(NSString*)username andVideoMeeting:(NSString*)meetingNumber andPwd:(NSString*)meetingPwd completion:(void(^)(ECError *error, NSString *meetingNumber, NSString *member))completion;

/**
 @brief 设置会议地址
 @param addr 视频会议源地址
 @return 0:成功 非0失败
 */
- (NSInteger)setVideoConferenceAddr:(NSString*)addr;

/**
 @brief 设置会议某成员是否可听可讲（不支持实时对讲）
 @param memberVoip    成员viop号
 @param speakListen   是否可听可讲 1、禁言 2、可讲 3、禁听 4、可听
 @param meetingType   会议房间的类型
 @param meetingNumber 房间号
 @param completion    执行结果回调block
 */
- (void)setMember:(ECVoIPAccount *)memberVoip speakListen:(NSInteger)speakListen ofMeetingType:(ECMeetingType)meetingType andMeetingNumber:(NSString*)meetingNumber completion:(void(^)(ECError *error, NSString *meetingNumber))completion;
@end
