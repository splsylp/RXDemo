//
//  AppMode+SDK.h
//  AppModel
//
//  Created by wangming on 2016/12/26.
//  Copyright © 2016年 ronglian. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "AppModel.h"

@interface AppModel(SDK)


/**
 @brief  拨打电话
 @param callInfo 拨号信息 Dict中key分别是
 callType，呼叫类型，0音频，1视频，2网络直拨落地，3回拨；
 caller 主叫；
 called被叫；
 主叫显号callerDisplay；
 被叫显号calledDisplay；
 @return callid
 */
-(NSString*)makeCall:(KitDialingInfoData*)callInfo completion:(void(^)(ECError *error, ECCallBackEntity* callBackEntity))completion;


/**
 @brief 挂断电话
 @param callid 电话id
 @return 0:成功  非0:失败
 */
- (NSInteger)releaseCall:(NSString *)callid;

/**
 @brief 挂断电话
 @param callid 电话id
 @param reason 预留参数,挂断原因值，可以传入大于1000的值，通话对方会在onMakeCallFailed收到该值
 @return 0:成功  非0:失败
 */
- (NSInteger)releaseCall:(NSString *)callid andReason:(NSInteger) reason;

/**
 @brief 接听电话
 @param callid 电话id
 @param callType 电话类型
 V2.1
 @return 0:成功  非0:失败
 */
- (NSInteger)acceptCall:(NSString*)callid withType:(CallType)callType;

/**
 @brief 拒绝呼叫(挂断一样,当被呼叫的时候被呼叫方的挂断状态)
 @param callid 电话id
 @param reason 拒绝呼叫的原因, 可以传入ReasonDeclined:用户拒绝 ReasonBusy:用户忙
 @return 0:成功  非0:失败
 */
- (NSInteger)rejectCall:(NSString *)callid andReason:(NSInteger) reason;

/**
 @brief 获取当前通话的callid
 @return 电话id
 */
-(NSString*)getCurrentCall;

/**
 @brief 请求切换音视频
 @param callType 请求的音视频类型
 @return 是否成功 0:成功；非0失败
 */
- (NSInteger)requestSwitchCallMediaType:(NSString*)callid toMediaType:(CallType)callType;

/**
 @brief 回复对方的切换音视频请求
 @param callType 回复的音视频类型
 @return 是否成功 0:成功；非0失败
 */
- (NSInteger)responseSwitchCallMediaType:(NSString*)callid withMediaType:(CallType)callType;

/**
 @brief 发送DTMF
 @param callid 电话id
 @param dtmf 键值
 @return 0:成功  非0:失败
 */
- (NSInteger)sendDTMF:(NSString *)callid dtmf:(NSString *)dtmf;


#pragma mark - 基本设置函数

/**
 @brief 静音设置
 @param on NO:正常 YES:静音
 */
- (NSInteger)setMute:(BOOL)on;

/**
 @brief 获取当前静音状态
 @return NO:正常 YES:静音
 */
- (BOOL)getMuteStatus;

/**
 @brief 获取当前免提状态
 @return NO:关闭 YES:打开
 */
- (BOOL)getLoudsSpeakerStatus;

/**
 @brief 免提设置
 @param enable NO:关闭 YES:打开
 */
- (NSInteger)enableLoudsSpeaker:(BOOL)enable;

/**
 @brief 设置电话
 @param phoneNumber 电话号
 */
- (void)setSelfPhoneNumber:(NSString *)phoneNumber;

/**
 @brief 设置voip通话个人信息
 @param voipCallUserInfo VoipCallUserInfo对象
 */
- (void)setVoipCallUserInfo:(VoIPCallUserInfo *)voipCallUserInfo;

/**
 @brief 设置视频通话显示的view
 @param view 对方显示视图
 @param localView 本地显示视图
 */
- (NSInteger)setVideoView:(UIView*)view andLocalView:(UIView*)localView;

/**
 @brief 获取摄像设备信息
 @return 摄像设备信息数组
 */
- (NSArray*)getCameraInfo;

/**
 @brief 选择使用的摄像设备
 @param cameraIndex 设备index
 @param capabilityIndex 能力index
 @param fps 帧率
 @param rotate 旋转的角度
 */
- (NSInteger)selectCamera:(NSInteger)cameraIndex capability:(NSInteger)capabilityIndex fps:(NSInteger)fps rotate:(ECRotate)rotate;

/**
 @brief 设置支持的编解码方式，默认全部都支持
 @param codec 编解码类型
 @param enabled NO:不支持 YES:支持
 */
-(void)setCodecEnabledWithCodec:(ECCodec)codec andEnabled:(BOOL)enabled;

/**
 @brief 获取编解码方式是否支持
 @param codec 编解码类型
 @return NO:不支持 YES:支持
 */
-(BOOL)getCondecEnabelWithCodec:(ECCodec)codec;
/**
 @brief 设置媒体流冗余。打开后通话减少丢包率，但是会增加流量
 @param bAudioRed:音频开关,底层默认2。0关闭，1协商打开,2只有会议才协商
 */
-(void)setAudioCodecRed:(NSInteger)bAudioRed;

/**
 @brief 获得媒体流冗余当前设置值。
 */
-(NSInteger)getAudioCodecRed;
/**
 @brief 设置是否获取全部离线消息
 @param enable 是否全部
 */
- (void)setReceiveAllOfflineMsgEnabled:(BOOL)enable;
/**
 @brief  设置客户端标示
 @param agent 客服账号
 */
- (void)setUserAgent:(NSString *)agent;

/**
 @brief 设置音频处理的开关,在呼叫前调用
 @param type  音频处理类型. enum AUDIO_TYPE { AUDIO_AGC, AUDIO_EC, AUDIO_NS };
 @param enabled YES：开启，NO：关闭；AGC默认关闭; EC和NS默认开启.
 @param mode: 各自对应的模式: AUDIO_AgcMode、AUDIO_EcMode、AUDIO_NsMode.
 @return  成功 0 失败 -1
 */
-(NSInteger)setAudioConfigEnabledWithType:(ECAudioType) type andEnabled:(BOOL) enabled andMode:(NSInteger) mode;

/**
 @brief 获取音频处理的开关
 @param type  音频处理类型. enum AUDIO_TYPE { AUDIO_AGC, AUDIO_EC, AUDIO_NS };
 @return  成功：音频属性结构 失败：nil
 */
-(ECAudioConfig*)getAudioConfigEnabelWithType:(ECAudioType)type;

/**
 @brief 设置视频通话码率
 @param bitrates  视频码流，kb/s，范围30-300
 */
-(void)setVideoBitRates:(NSInteger)bitrates;

/**
 @brief 统计通话质量
 @return  返回丢包率等通话质量信息对象
 */
-(CallStatisticsInfo*)getCallStatisticsWithCallid:(NSString*)callid andType:(CallType)type;

/**
 @brief 获取通话的网络流量信息
 @param   callid :  会话ID,会议类传入房间号
 @return  返回网络流量信息对象
 */
- (NetworkStatistic*)getNetworkStatisticWithCallId:(NSString*)callid;

/**
 @brief 通话过程中设置本端摄像头开启关闭，自己能看到对方，通话对方看不到自己。
 @param callid:会话ID
 @param on:是否开启
 @return 是否成功 0：成功； 非0失败
 */
- (NSInteger)setLocalCameraOfCallId:(NSString*)callid andEnable:(BOOL)enable;


/**
 @brief 获取群组属性
 @param groupId 获取信息的群组id
 @param completion 执行结果回调block
 */
-(void)getGroupDetail:(NSString *)groupId completion:(void(^)(ECError *error ,ECGroup *group))completion;



/**
 @brief 发送消息
 @discussion 发送文本消息时，进度不生效；发送附件消息时，进度代理生效
 @param message 发送的消息
 @param progress 发送进度代理
 @param completion 执行结果回调block
 @return 函数调用成功返回消息id，失败返回nil
 */
-(NSString*)sendMessage:(ECMessage*)message progress:(id<ECProgressDelegate>)progress completion:(void(^)(ECError *error, ECMessage* message))completion;

/**
 @brief 取消发送消息，取消结果在发送消息completion返回错误171259；暂时只支持以下类型：
 MessageBodyType_Voice
 MessageBodyType_Video
 MessageBodyType_Image
 MessageBodyType_File
 MessageBodyType_Preview
 
 @param message 取消发送的消息
 */
-(ECError*)cancelSendMessage:(ECMessage*)message;

/**
 @brief 录制arm音频
 @param msg 音频的消息体
 @param completion 执行结果回调block
 */
-(void)startVoiceRecording:(ECVoiceMessageBody*)msg error:(void(^)(ECError* error, ECVoiceMessageBody *messageBody))error;

/**
 @brief 停止录制arm音频
 @param completion 执行结果回调block
 */
-(void)stopVoiceRecording:(void(^)(ECError *error, ECVoiceMessageBody *messageBody))completion;

/**
 @brief 播放arm音频消息
 @param completion 执行结果回调block
 */
-(void)playVoiceMessage:(ECVoiceMessageBody*)msg completion:(void(^)(ECError *error))completion;

/**
 @brief 停止播放音频
 */
-(BOOL)stopPlayingVoiceMessage;

/**
 @brief 下载附件消息
 @param message 多媒体类型消息
 @param progress 下载进度
 @param completion 执行结果回调block
 */
-(void)downloadMediaMessage:(ECMessage*)message progress:(id<ECProgressDelegate>)progress completion:(void(^)(ECError *error, ECMessage* message))completion;

/**
 @brief 下载图片文件缩略图
 @param message 多媒体类型消息
 @param progress 下载进度
 @param completion 执行结果回调block
 */
-(void)downloadThumbnailMessage:(ECMessage*)message progress:(id<ECProgressDelegate>)progress completion:(void(^)(ECError *error, ECMessage* message))completion;

/**
 @brief 删除点对点消息(目前只支持删除接收到的消息)
 @param message 需要删除的消息
 @param completion 执行结果回调block
 */
-(void)deleteMessage:(ECMessage*)message completion:(void(^)(ECError *error, ECMessage* message)) completion;

/**
 @brief 撤回消息
 @param message 需要撤回的消息
 @param completion 执行结果回调block
 */
-(void)revokeMessage:(ECMessage*)message completion:(void(^)(ECError *error, ECMessage* message)) completion;

/**
 @brief 消息已读（接收到的消息）
 @param message 设置已读的消息
 @param completion 执行结果回调block
 */
-(void)readedMessage:(ECMessage*)message completion:(void(^)(ECError *error, ECMessage* message)) completion;

/**
 @brief 获取消息状态（只支持群组，且发送的消息）
 @param message 设置已读的消息
 @param completion 执行结果回调block
 */
-(void)queryMessageReadStatus:(ECMessage*)message completion:(void(^)(ECError *error, NSArray* readArray, NSArray* unreadArray)) completion;

/**
 @brief 变声操作
 @param dstSoundConfig 目标文件的变化配置
 @param completion 执行结果回调block
 */
-(void)changeVoiceWithSoundConfig:(ECSountTouchConfig*)dstSoundConfig completion:(void(^)(ECError *error, ECSountTouchConfig* dstSoundConfig)) completion;

/**
 @brief 是否置顶会话
 @param sesionId 会话id
 @param isTop 0 取消置顶 1 置顶
 */
-(void)setSession:(NSString*)sesionId IsTop:(BOOL)isTop completion:(void(^)(ECError *error, NSString *seesionId))completion;

/**
 @brief 获取置顶会话列表
 @param completion 执行结果回调block（注：topContactLists为会话seesionId）
 */
- (void)getTopSessionLists:(void(^)(ECError *error, NSArray *topContactLists))completion;


#pragma mark -群组相关
/**
 @brief 创建群组
 @param group 创建的群组信息 只需关注group中name、declared、type、mode
 @param completion 执行结果回调block
 */
-(void)createGroup:(ECGroup *)group completion:(void(^)(ECError *error ,ECGroup *group))completion;


/**
 @brief 修改群组
 @param group 修改的群组信息
 @param completion 执行结果回调block
 */
-(void)modifyGroup:(ECGroup *)group completion:(void(^)(ECError *error ,ECGroup *group))completion;


/**
 @brief 删除群组
 @param groupId 删除的群组id
 @param completion 执行结果回调block
 */
-(void)deleteGroup:(NSString*)groupId completion:(void(^)(ECError *error, NSString* groupId))completion;


/**
 @brief 按条件搜索公共群组
 @param match 需要匹配的条件
 @param completion 执行结果回调block
 */
-(void)searchPublicGroups:(ECGroupMatch *)match completion:(void(^)(ECError *error, NSArray* groups))completion;


/**
 @brief 获取群组属性
 @param groupId 获取信息的群组id
 @param completion 执行结果回调block
 */
-(void)getGroupDetail:(NSString *)groupId completion:(void(^)(ECError *error ,ECGroup *group))completion;


/**
 @brief 用户申请加入群组
 @param groupId 申请加入的群组Id
 @param reason 申请加入的理由
 @param completion 执行结果回调block
 */
-(void)joinGroup:(NSString*)groupId reason:(NSString*)reason completion:(void(^)(ECError *error, NSString* groupId))completion;


/**
 @brief 管理员邀请加入群组
 @param groupId 邀请加入的群组id
 @param reason 邀请理由
 @param members 邀请加入的人
 @param confirm 是否需要对方验证 1:直接加入(不需要验证) 2:需要对方验证
 @param completion 执行结果回调block
 */
-(void)inviteJoinGroup:(NSString *)groupId reason:(NSString*)reason members:(NSArray*)members confirm:(NSInteger)confirm completion:(void(^)(ECError *error, NSString* groupId, NSArray* members))completion;


/**
 @brief 删除成员
 @param groupId 删除成员的群组id
 @param member 删除的成员
 @param completion 执行结果回调block
 */
-(void)deleteGroupMember:(NSString*)groupId member:(NSString*)member completion:(void(^)(ECError* error, NSString* groupId, NSString* member))completion;


/**
 @brief 退出群聊
 @param groupId 退出的群组id
 @param completion 执行结果回调block
 */
-(void)quitGroup:(NSString*)groupId completion:(void(^)(ECError* error, NSString* groupId))completion;


/**
 @brief 修改群组成员名片
 @param member 修改的成员名片
 @param completion 执行结果回调block
 */
-(void)modifyMemberCard:(ECGroupMember *)member completion:(void(^)(ECError *error, ECGroupMember* member))completion;


/**
 @brief 查询群组成员名片
 @param memberId 查询的成员id
 @param groupId 成员所属群组id
 @param completion 执行结果回调block
 */
-(void)queryMemberCard:(NSString *)memberId belong:(NSString*)groupId completion:(void(^)(ECError *error, ECGroupMember *member))completion;


/**
 @brief 查询群组成员
 @param groupId 查询的群组id
 @param completion 执行结果回调block
 */
-(void)queryGroupMembers:(NSString*)groupId completion:(void(^)(ECError *error, NSString* groupId, NSArray* members))completion;


/**
 @brief 分页查询群组成员
 @param groupId 查询的群组id
 @param borderMemberId 为nil时，从头查询
 @param pageSize 每页数量
 @param completion 执行结果回调block
 */
-(void)queryGroupMembers:(NSString*)groupId border:(NSString*)borderMemberId pageSize:(NSInteger)pageSize completion:(void(^)(ECError *error, NSString* groupId, NSArray* members))completion;


/**
 @brief 查询加入的群组
 @param groupType 需要查询的群组类型
 @param completion 执行结果回调block
 */
-(void)queryOwnGroupsWith:(ECGroupType)groupType completion:(void(^)(ECError *error, NSArray *groups))completion;


/**
 @brief 分页查询加入的群组
 @param boarderGroupId 为nil时，从头查询
 @param pageSize 每页数量
 @param groupType 需要查询的群组类型
 @param completion 执行结果回调block
 */
-(void)queryOwnGroupsWithBoarder:(NSString*)boarderGroupId pageSize:(NSInteger)pageSize groupType:(ECGroupType)groupType completion:(void (^)(ECError *error, NSArray *groups))completion;

/**
 @brief 管理员对成员禁言
 @param groupId 成员所属群组id
 @param memberId 成员id
 @param status 禁言状态
 @param completion 执行结果回调block
 */
-(void)forbidMemberSpeakStatus:(NSString*)groupId member:(NSString*)memberId speakStatus:(ECSpeakStatus)status completion:(void(^)(ECError *error, NSString* groupId, NSString* memberId))completion;


/**
 @brief 管理员验证用户申请加入群组
 @param groupId 申请加入的群组id
 @param memberId 申请加入的成员id
 @param type 是否同意
 @param completion 执行结果回调block
 */
-(void)ackJoinGroupRequest:(NSString *)groupId member:(NSString*)memberId ackType:(ECAckType)type completion:(void(^)(ECError *error, NSString* gorupId, NSString* memberId))completion;


/**
 @brief 用户验证管理员邀请加入群组
 @param groupId 邀请加入的群组id
 @param invitor 邀请者id
 @param type 是否同意
 @param completion 执行结果回调block
 */
-(void)ackInviteJoinGroupRequest:(NSString*)groupId invitor:(NSString*)invitor ackType:(ECAckType)type completion:(void(^)(ECError *error, NSString* gorupId))completion;


/**
 @brief 成员设置群组消息规则
 @param option 群组消息规则
 @param completion 执行结果回调block
 */
-(void)setGroupMessageOption:(ECGroupOption*)option completion:(void(^)(ECError* error, NSString* groupId))completion;

/**
 @brief 管理员修改用户角色权限
 @param groupId 群组id
 @param memberId 成员id
 @param role 2管理员 3普通成员
 @param completion 执行结果回调block
 */
- (void)setGroupMemberRole:(NSString*)groupId member:(NSString*)memberId role:(ECMemberRole)role completion:(void(^)(ECError *error,NSString *groupId,NSString *memberId))completion;

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
-(void)controlMicInInterphoneMeeting:(NSString*)meetingNumber completion:(void(^)(ECError *error))completion;

/**
 @brief 实时对讲放麦
 @param meetingNumber 房间号
 @param completion    执行结果回调block
 */
-(void)releaseMicInInterphoneMeeting:(NSString*)meetingNumber completion:(void(^)(ECError *error))completion;

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
- (void)cancelMemberVideoWithAccount:(NSString*)username andVideoMeeting:(NSString*)meetingNumber andPwd:(NSString*)meetingPwd completion:(void(^)(ECError *error, NSString *meetingNumber, NSString *member))complewangtion;

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
