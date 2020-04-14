//
//  AppMode+SDK.m
//  AppModel
//
//  Created by wangming on 2016/12/26.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "AppMode+SDK.h"

@implementation AppModel(SDK)

#pragma mark - voip主调函数
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
-(NSString*)makeCall:(KitDialingInfoData*)callInfo completion:(void(^)(ECError *error, ECCallBackEntity* callBackEntity))completion;{
    
    KitDialingInfoData* call_Info = [[KitDialingInfoData alloc] init];
    call_Info.callid = callInfo.callid;
    call_Info.callType = callInfo.callType;
    call_Info.callDirect = callInfo.callDirect;
    call_Info.voipCallStatus = callInfo.voipCallStatus;
    self.appData.curVoipCall = call_Info;
    
    self.appData.curVoipCall.callid = [[CoreModel sharedInstance] makeCall:callInfo completion:completion];
    return self.appData.curVoipCall.callid;
}

/**
 @brief 挂断电话
 @param callid 电话id
 @return 0:成功  非0:失败
 */
- (NSInteger)releaseCall:(NSString *)callid{
    NSInteger ret = [[CoreModel sharedInstance]  releaseCall:callid];
    if (ret == 0)
    {
          [[NSNotificationCenter defaultCenter] postNotificationName:@"thechangeofcallrecords" object:nil];
    }
    return ret;
}

/**
 @brief 挂断电话
 @param callid 电话id
 @param reason 预留参数,挂断原因值，可以传入大于1000的值，通话对方会在onMakeCallFailed收到该值
 @return 0:成功  非0:失败
 */
- (NSInteger)releaseCall:(NSString *)callid andReason:(NSInteger) reason{
    NSInteger ret = [[CoreModel sharedInstance]  releaseCall:callid andReason:reason];
    if (ret == 0)
    {
        
    }
    return ret;
}

/**
 @brief 接听电话
 @param callid 电话id
 @param callType 电话类型
 V2.1
 @return 0:成功  非0:失败
 */
- (NSInteger)acceptCall:(NSString*)callid withType:(CallType)callType{
    NSInteger ret = [[CoreModel sharedInstance]  acceptCall:callid withType:callType];
    if (ret == 0)
    {
    }
    return ret;
}

/**
 @brief 拒绝呼叫(挂断一样,当被呼叫的时候被呼叫方的挂断状态)
 @param callid 电话id
 @param reason 拒绝呼叫的原因, 可以传入ReasonDeclined:用户拒绝 ReasonBusy:用户忙
 @return 0:成功  非0:失败
 */
- (NSInteger)rejectCall:(NSString *)callid andReason:(NSInteger) reason{
    NSInteger ret = [[CoreModel sharedInstance]  rejectCall:callid andReason:reason];
    if (ret == 0)
    {
        
    }
    return ret;
}

/**
 @brief 获取当前通话的callid
 @return 电话id
 */
-(NSString*)getCurrentCall{
    return [[CoreModel sharedInstance]  getCurrentCall];
}

/**
 @brief 请求切换音视频
 @param callType 请求的音视频类型
 @return 是否成功 0:成功；非0失败
 */
- (NSInteger)requestSwitchCallMediaType:(NSString*)callid toMediaType:(CallType)callType{
    return [[CoreModel sharedInstance]  requestSwitchCallMediaType:callid toMediaType:callType];
}

/**
 @brief 回复对方的切换音视频请求
 @param callType 回复的音视频类型
 @return 是否成功 0:成功；非0失败
 */
- (NSInteger)responseSwitchCallMediaType:(NSString*)callid withMediaType:(CallType)callType{
    return [[CoreModel sharedInstance]  responseSwitchCallMediaType:callid withMediaType:callType];
}

/**
 @brief 发送DTMF
 @param callid 电话id
 @param dtmf 键值
 @return 0:成功  非0:失败
 */
- (NSInteger)sendDTMF:(NSString *)callid dtmf:(NSString *)dtmf{
    return [[CoreModel sharedInstance]  sendDTMF:callid dtmf:dtmf];
}

#pragma mark - 基本设置函数

/**
 @brief 静音设置
 @param on NO:正常 YES:静音
 */
- (NSInteger)setMute:(BOOL)on{
    return [[CoreModel sharedInstance]  setMute:on];
}

/**
 @brief 获取当前静音状态
 @return NO:正常 YES:静音
 */
- (BOOL)getMuteStatus{
    return [[CoreModel sharedInstance]  getMuteStatus];
}
/**
 @brief 获取当前免提状态
 @return NO:关闭 YES:打开
 */
- (BOOL)getLoudsSpeakerStatus{
    return [[CoreModel sharedInstance]  getLoudsSpeakerStatus];
}

/**
 @brief 免提设置
 @param enable NO:关闭 YES:打开
 */
- (NSInteger)enableLoudsSpeaker:(BOOL)enable{
    return [[CoreModel sharedInstance]  enableLoudsSpeaker:enable];
}

/**
 @brief 设置电话
 @param phoneNumber 电话号
 */
- (void)setSelfPhoneNumber:(NSString *)phoneNumber{
    [[CoreModel sharedInstance]  setSelfPhoneNumber:phoneNumber];
}
/**
 @brief 设置voip通话个人信息
 @param voipCallUserInfo VoipCallUserInfo对象
 */
- (void)setVoipCallUserInfo:(VoIPCallUserInfo *)voipCallUserInfo{
    [[CoreModel sharedInstance]  setVoipCallUserInfo:voipCallUserInfo];
}

/**
 @brief 设置视频通话显示的view
 @param view 对方显示视图
 @param localView 本地显示视图
 */
- (NSInteger)setVideoView:(UIView*)view andLocalView:(UIView*)localView{
    return [[CoreModel sharedInstance]  setVideoView:view andLocalView:localView];
}
/**
 @brief 获取摄像设备信息
 @return 摄像设备信息数组
 */
- (NSArray*)getCameraInfo{
    return [[CoreModel sharedInstance] getCameraInfo];
}
/**
 @brief 选择使用的摄像设备
 @param cameraIndex 设备index
 @param capabilityIndex 能力index
 @param fps 帧率
 @param rotate 旋转的角度
 */
- (NSInteger)selectCamera:(NSInteger)cameraIndex capability:(NSInteger)capabilityIndex fps:(NSInteger)fps rotate:(ECRotate)rotate{
    return [[CoreModel sharedInstance]  selectCamera:cameraIndex capability:capabilityIndex fps:fps rotate:rotate];
}
/**
 @brief 设置支持的编解码方式，默认全部都支持
 @param codec 编解码类型
 @param enabled NO:不支持 YES:支持
 */
-(void)setCodecEnabledWithCodec:(ECCodec)codec andEnabled:(BOOL)enabled{
    [[CoreModel sharedInstance] setCodecEnabledWithCodec:codec andEnabled:enabled];
}

/**
 @brief 获取编解码方式是否支持
 @param codec 编解码类型
 @return NO:不支持 YES:支持
 */
-(BOOL)getCondecEnabelWithCodec:(ECCodec)codec{
    return [[CoreModel sharedInstance]  getCondecEnabelWithCodec:codec];
}
/**
 @brief 设置媒体流冗余。打开后通话减少丢包率，但是会增加流量
 @param bAudioRed:音频开关,底层默认2。0关闭，1协商打开,2只有会议才协商
 */
-(void)setAudioCodecRed:(NSInteger)bAudioRed{
     [[CoreModel sharedInstance] setAudioCodecRed:bAudioRed];
}

/**
 @brief 获得媒体流冗余当前设置值。
 */
-(NSInteger)getAudioCodecRed{
      return [[CoreModel sharedInstance]  getAudioCodecRed];
}
/**
 @brief 设置是否获取全部离线消息
 @param enable 是否全部
 */
- (void)setReceiveAllOfflineMsgEnabled:(BOOL)enable{
    [[ECDevice sharedInstance] setReceiveAllOfflineMsgEnabled:enable];
}
/**
 @brief  设置客户端标示
 @param agent 客服账号
 */
- (void)setUserAgent:(NSString *)agent{
    [[CoreModel sharedInstance]  setUserAgent:agent];
}

/**
 @brief 设置音频处理的开关,在呼叫前调用
 @param type  音频处理类型. enum AUDIO_TYPE { AUDIO_AGC, AUDIO_EC, AUDIO_NS };
 @param enabled YES：开启，NO：关闭；AGC默认关闭; EC和NS默认开启.
 @param mode: 各自对应的模式: AUDIO_AgcMode、AUDIO_EcMode、AUDIO_NsMode.
 @return  成功 0 失败 -1
 */
-(NSInteger)setAudioConfigEnabledWithType:(ECAudioType) type andEnabled:(BOOL) enabled andMode:(NSInteger) mode{
    return [[CoreModel sharedInstance]  setAudioConfigEnabledWithType:type andEnabled:enabled andMode:mode];
}

/**
 @brief 获取音频处理的开关
 @param type  音频处理类型. enum AUDIO_TYPE { AUDIO_AGC, AUDIO_EC, AUDIO_NS };
 @return  成功：音频属性结构 失败：nil
 */
-(ECAudioConfig*)getAudioConfigEnabelWithType:(ECAudioType)type{
    return [[CoreModel sharedInstance]  getAudioConfigEnabelWithType:type];
}

/**
 @brief 设置视频通话码率
 @param bitrates  视频码流，kb/s，范围30-300
 */
-(void)setVideoBitRates:(NSInteger)bitrates{
    [[CoreModel sharedInstance]  setVideoBitRates:bitrates];
}

/**
 @brief 统计通话质量
 @return  返回丢包率等通话质量信息对象
 */
-(CallStatisticsInfo*)getCallStatisticsWithCallid:(NSString*)callid andType:(CallType)type{
    return [[CoreModel sharedInstance]  getCallStatisticsWithCallid:callid andType:type];
}

/**
 @brief 获取通话的网络流量信息
 @param   callid :  会话ID,会议类传入房间号
 @return  返回网络流量信息对象
 */
- (NetworkStatistic*)getNetworkStatisticWithCallId:(NSString*)callid{
    return [[CoreModel sharedInstance]  getNetworkStatisticWithCallId:callid];
}

/**
 @brief 通话过程中设置本端摄像头开启关闭，自己能看到对方，通话对方看不到自己。
 @param callid:会话ID
 @param on:是否开启
 @return 是否成功 0：成功； 非0失败
 */
- (NSInteger)setLocalCameraOfCallId:(NSString*)callid andEnable:(BOOL)enable{
    return [[CoreModel sharedInstance]  setLocalCameraOfCallId:callid andEnable:enable];
}


/**
 @brief 发送消息
 @discussion 发送文本消息时，进度不生效；发送附件消息时，进度代理生效
 @param message 发送的消息
 @param progress 发送进度代理
 @param completion 执行结果回调block
 @return 函数调用成功返回消息id，失败返回nil
 */
-(NSString*)sendMessage:(ECMessage*)message progress:(id<ECProgressDelegate>)progress completion:(void(^)(ECError *error, ECMessage* message))completion{
    return [[CoreModel sharedInstance]  sendMessage:message progress:progress completion:completion];
}

/**
 @brief 取消发送消息，取消结果在发送消息completion返回错误171259；暂时只支持以下类型：
 MessageBodyType_Voice
 MessageBodyType_Video
 MessageBodyType_Image
 MessageBodyType_File
 MessageBodyType_Preview
 
 @param message 取消发送的消息
 */
-(ECError*)cancelSendMessage:(ECMessage*)message{
    return [[CoreModel sharedInstance]  cancelSendMessage:message];
}
/**
 @brief 录制arm音频
 @param msg 音频的消息体
 @param completion 执行结果回调block
 */
-(void)startVoiceRecording:(ECVoiceMessageBody*)msg error:(void(^)(ECError* error, ECVoiceMessageBody *messageBody))error{
    [[CoreModel sharedInstance]  startVoiceRecording:msg error:error];
}

/**
 @brief 停止录制arm音频
 @param completion 执行结果回调block
 */
-(void)stopVoiceRecording:(void(^)(ECError *error, ECVoiceMessageBody *messageBody))completion{
    [[CoreModel sharedInstance]  stopVoiceRecording:completion];
}

/**
 @brief 播放arm音频消息
 @param completion 执行结果回调block
 */
-(void)playVoiceMessage:(ECVoiceMessageBody*)msg completion:(void(^)(ECError *error))completion{
    [[CoreModel sharedInstance]  playVoiceMessage:msg completion:completion];
}

/**
 @brief 停止播放音频
 */
-(BOOL)stopPlayingVoiceMessage{
    return [[CoreModel sharedInstance]  stopPlayingVoiceMessage];
}
/**
 @brief 下载附件消息
 @param message 多媒体类型消息
 @param progress 下载进度
 @param completion 执行结果回调block
 */
-(void)downloadMediaMessage:(ECMessage*)message progress:(id<ECProgressDelegate>)progress completion:(void(^)(ECError *error, ECMessage* message))completion{
    [[CoreModel sharedInstance]  downloadMediaMessage:message progress:progress completion:completion];
}
/**
 @brief 下载图片文件缩略图
 @param message 多媒体类型消息
 @param progress 下载进度
 @param completion 执行结果回调block
 */
-(void)downloadThumbnailMessage:(ECMessage*)message progress:(id<ECProgressDelegate>)progress completion:(void(^)(ECError *error, ECMessage* message))completion{
    [[CoreModel sharedInstance]  downloadThumbnailMessage:message progress:progress completion:completion];
}

/**
 @brief 删除点对点消息(目前只支持删除接收到的消息)
 @param message 需要删除的消息
 @param completion 执行结果回调block
 */
-(void)deleteMessage:(ECMessage*)message completion:(void(^)(ECError *error, ECMessage* message)) completion{
    [[CoreModel sharedInstance]  deleteMessage:message completion:completion];
}

/**
 @brief 撤回消息
 @param message 需要撤回的消息
 @param completion 执行结果回调block
 */
-(void)revokeMessage:(ECMessage*)message completion:(void(^)(ECError *error, ECMessage* message)) completion{
    [[CoreModel sharedInstance]  revokeMessage:message completion:completion];
}

/**
 @brief 消息已读（接收到的消息）
 @param message 设置已读的消息
 @param completion 执行结果回调block
 */
-(void)readedMessage:(ECMessage*)message completion:(void(^)(ECError *error, ECMessage* message)) completion{
    [[CoreModel sharedInstance]  readedMessage:message completion:completion];
}

/**
 @brief 获取消息状态（只支持群组，且发送的消息）
 @param message 设置已读的消息
 @param completion 执行结果回调block
 */
-(void)queryMessageReadStatus:(ECMessage*)message completion:(void(^)(ECError *error, NSArray* readArray, NSArray* unreadArray)) completion{
    [[CoreModel sharedInstance]   queryMessageReadStatus:message completion:completion];
}

/**
 @brief 变声操作
 @param dstSoundConfig 目标文件的变化配置
 @param completion 执行结果回调block
 */
-(void)changeVoiceWithSoundConfig:(ECSountTouchConfig*)dstSoundConfig completion:(void(^)(ECError *error, ECSountTouchConfig* dstSoundConfig)) completion{
    [[CoreModel sharedInstance]   changeVoiceWithSoundConfig:dstSoundConfig completion:completion];
}

/**
 @brief 是否置顶会话
 @param seesionId 会话id
 @param isTop 0 取消置顶 1 置顶
 */
-(void)setSession:(NSString*)sesionId IsTop:(BOOL)isTop completion:(void(^)(ECError *error, NSString *seesionId))completion{
    [[CoreModel sharedInstance]  setSession:sesionId IsTop:isTop completion:completion];
}

/**
 @brief 获取置顶会话列表
 @param completion 执行结果回调block（注：topContactLists为会话seesionId）
 */
- (void)getTopSessionLists:(void(^)(ECError *error, NSArray *topContactLists))completion{
    [[CoreModel sharedInstance]  getTopSessionLists:completion];
}

#pragma mark -群组相关
/**
 @brief 创建群组
 @param group 创建的群组信息 只需关注group中name、declared、type、mode
 @param completion 执行结果回调block
 */
-(void)createGroup:(ECGroup *)group completion:(void(^)(ECError *error ,ECGroup *group))completion{
    [[CoreModel sharedInstance]  createGroup:group completion:completion];
}

/**
 @brief 修改群组
 @param group 修改的群组信息
 @param completion 执行结果回调block
 */
-(void)modifyGroup:(ECGroup *)group completion:(void(^)(ECError *error ,ECGroup *group))completion
{
    [[CoreModel sharedInstance]  modifyGroup:group completion:completion];
}

/**
 @brief 删除群组
 @param groupId 删除的群组id
 @param completion 执行结果回调block
 */
-(void)deleteGroup:(NSString*)groupId completion:(void(^)(ECError *error, NSString* groupId))completion{
    [[CoreModel sharedInstance]  deleteGroup:groupId completion:completion];
}


/**
 @brief 按条件搜索公共群组
 @param match 需要匹配的条件
 @param completion 执行结果回调block
 */
-(void)searchPublicGroups:(ECGroupMatch *)match completion:(void(^)(ECError *error, NSArray* groups))completion{
    [[CoreModel sharedInstance]  searchPublicGroups:match completion:completion];
}

/**
 @brief 获取群组属性
 @param groupId 获取信息的群组id
 @param completion 执行结果回调block
 */
-(void)getGroupDetail:(NSString *)groupId completion:(void(^)(ECError *error ,ECGroup *group))completion{
    [[CoreModel sharedInstance]  getGroupDetail:groupId completion:completion];
}


/**
 @brief 用户申请加入群组
 @param groupId 申请加入的群组Id
 @param reason 申请加入的理由
 @param completion 执行结果回调block
 */
-(void)joinGroup:(NSString*)groupId reason:(NSString*)reason completion:(void(^)(ECError *error, NSString* groupId))completion{
    [[CoreModel sharedInstance]  joinGroup:groupId reason:reason completion:completion];
}


/**
 @brief 管理员邀请加入群组
 @param groupId 邀请加入的群组id
 @param reason 邀请理由
 @param members 邀请加入的人
 @param confirm 是否需要对方验证 1:直接加入(不需要验证) 2:需要对方验证
 @param completion 执行结果回调block
 */
-(void)inviteJoinGroup:(NSString *)groupId reason:(NSString*)reason members:(NSArray*)members confirm:(NSInteger)confirm completion:(void(^)(ECError *error, NSString* groupId, NSArray* members))completion{
    [[CoreModel sharedInstance]  inviteJoinGroup:groupId reason:reason members:members confirm:confirm completion:completion];
}

/**
 @brief 删除成员
 @param groupId 删除成员的群组id
 @param member 删除的成员
 @param completion 执行结果回调block
 */
-(void)deleteGroupMember:(NSString*)groupId member:(NSString*)member completion:(void(^)(ECError* error, NSString* groupId, NSString* member))completion{
    [[CoreModel sharedInstance]  deleteGroupMember:groupId member:member completion:completion];
}

/**
 @brief 退出群聊
 @param groupId 退出的群组id
 @param completion 执行结果回调block
 */
-(void)quitGroup:(NSString*)groupId completion:(void(^)(ECError* error, NSString* groupId))completion{
    [[CoreModel sharedInstance]  quitGroup:groupId completion:completion];
}

/**
 @brief 修改群组成员名片
 @param member 修改的成员名片
 @param completion 执行结果回调block
 */
-(void)modifyMemberCard:(ECGroupMember *)member completion:(void(^)(ECError *error, ECGroupMember* member))completion{
    [[CoreModel sharedInstance]  modifyMemberCard:member completion:completion];
}

/**
 @brief 查询群组成员名片
 @param memberId 查询的成员id
 @param groupId 成员所属群组id
 @param completion 执行结果回调block
 */
-(void)queryMemberCard:(NSString *)memberId belong:(NSString*)groupId completion:(void(^)(ECError *error, ECGroupMember *member))completion{
    [[CoreModel sharedInstance]  queryMemberCard:memberId belong:groupId completion:completion];
}


/**
 @brief 查询群组成员
 @param groupId 查询的群组id
 @param completion 执行结果回调block
 */
-(void)queryGroupMembers:(NSString*)groupId completion:(void(^)(ECError *error, NSString* groupId, NSArray* members))completion{
    [[CoreModel sharedInstance]  queryGroupMembers:groupId completion:completion];
}


/**
 @brief 分页查询群组成员
 @param groupId 查询的群组id
 @param borderMemberId 为nil时，从头查询
 @param pageSize 每页数量
 @param completion 执行结果回调block
 */
-(void)queryGroupMembers:(NSString*)groupId border:(NSString*)borderMemberId pageSize:(NSInteger)pageSize completion:(void(^)(ECError *error, NSString* groupId, NSArray* members))completion{
    [[CoreModel sharedInstance]  queryGroupMembers:groupId border:borderMemberId pageSize:pageSize completion:completion];
}


/**
 @brief 查询加入的群组
 @param groupType 需要查询的群组类型
 @param completion 执行结果回调block
 */
-(void)queryOwnGroupsWith:(ECGroupType)groupType completion:(void(^)(ECError *error, NSArray *groups))completion{
    [[CoreModel sharedInstance]  queryOwnGroupsWith:groupType completion:completion];
}


/**
 @brief 分页查询加入的群组
 @param boarderGroupId 为nil时，从头查询
 @param pageSize 每页数量
 @param groupType 需要查询的群组类型
 @param completion 执行结果回调block
 */
-(void)queryOwnGroupsWithBoarder:(NSString*)boarderGroupId pageSize:(NSInteger)pageSize groupType:(ECGroupType)groupType completion:(void (^)(ECError *error, NSArray *groups))completion{
    [[CoreModel sharedInstance]  queryOwnGroupsWithBoarder:boarderGroupId pageSize:pageSize groupType:groupType completion:completion];
}

/**
 @brief 管理员对成员禁言
 @param groupId 成员所属群组id
 @param memberId 成员id
 @param status 禁言状态
 @param completion 执行结果回调block
 */
-(void)forbidMemberSpeakStatus:(NSString*)groupId member:(NSString*)memberId speakStatus:(ECSpeakStatus)status completion:(void(^)(ECError *error, NSString* groupId, NSString* memberId))completion{
    [[CoreModel sharedInstance]  forbidMemberSpeakStatus:groupId member:memberId speakStatus:status completion:completion];
}


/**
 @brief 管理员验证用户申请加入群组
 @param groupId 申请加入的群组id
 @param memberId 申请加入的成员id
 @param type 是否同意
 @param completion 执行结果回调block
 */
-(void)ackJoinGroupRequest:(NSString *)groupId member:(NSString*)memberId ackType:(ECAckType)type completion:(void(^)(ECError *error, NSString* gorupId, NSString* memberId))completion{
    [[CoreModel sharedInstance]  ackJoinGroupRequest:groupId member:memberId ackType:type completion:completion];
}


/**
 @brief 用户验证管理员邀请加入群组
 @param groupId 邀请加入的群组id
 @param invitor 邀请者id
 @param type 是否同意
 @param completion 执行结果回调block
 */
-(void)ackInviteJoinGroupRequest:(NSString*)groupId invitor:(NSString*)invitor ackType:(ECAckType)type completion:(void(^)(ECError *error, NSString* gorupId))completion{
    [[CoreModel sharedInstance]  ackInviteJoinGroupRequest:groupId invitor:invitor ackType:type completion:completion];
}


/**
 @brief 成员设置群组消息规则
 @param option 群组消息规则
 @param completion 执行结果回调block
 */
-(void)setGroupMessageOption:(ECGroupOption*)option completion:(void(^)(ECError* error, NSString* groupId))completion{
    [[CoreModel sharedInstance]  setGroupMessageOption:option completion:completion];
}

/**
 @brief 管理员修改用户角色权限
 @param groupId 群组id
 @param memberId 成员id
 @param role 2管理员 3普通成员
 @param completion 执行结果回调block
 */
- (void)setGroupMemberRole:(NSString*)groupId member:(NSString*)memberId role:(ECMemberRole)role completion:(void(^)(ECError *error,NSString *groupId,NSString *memberId))completion{
    [[CoreModel sharedInstance]  setGroupMemberRole:memberId member:memberId role:role completion:completion];
}


/**
 @brief 创建音频会议、视频会议回调
 @param params     会议类
 @param completion 执行结果回调block
 */
-(void)createMultMeetingByType:(ECCreateMeetingParams *)params completion:(void(^)(ECError* error, NSString *meetingNumber))completion{
    [[CoreModel sharedInstance] createMultMeetingByType:params completion:completion];
}

/**
 @brief 加入音频会议、视频会议、实时对讲
 @param meetingNumber 房间号
 @param meetingType   会议房间的类型
 @param meetingPwd    房间密码
 @param completion    执行结果回调block
 */
-(void)joinMeeting:(NSString*)meetingNumber ByMeetingType:(ECMeetingType )meetingType andMeetingPwd:(NSString *)meetingPwd completion:(void(^)(ECError* error, NSString *meetingNumber))completion{
    [[CoreModel sharedInstance] joinMeeting:meetingNumber ByMeetingType:meetingType andMeetingPwd:meetingPwd completion:completion];
}


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
- (void)inviteMembersJoinMultiMediaMeeting:(NSString *)meetingNumber andIsLoandingCall:(BOOL)isLoadingCall andMembers:(NSArray *)members andDisplayNumber:(NSString*)displaynumber andSDKUserData:(NSString*)sdkUserData andServiceUserData:(NSString*)serviceUserData completion:(void (^)(ECError *error ,NSString * meetingNumber))completion{
    [[CoreModel sharedInstance] inviteMembersJoinMultiMediaMeeting:meetingNumber andIsLoandingCall:isLoadingCall andMembers:members andDisplayNumber:displaynumber andSDKUserData:sdkUserData andServiceUserData:serviceUserData completion:completion];
}

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
- (void)inviteMembersJoinMultiMediaMeeting:(NSString *)meetingNumber andIsLoandingCall:(BOOL)isLoadingCall andMembers:(NSArray *)members andSpeak:(BOOL)isSpeak andListen:(BOOL)isListen andDisplayNumber:(NSString*)displaynumber andSDKUserData:(NSString*)sdkUserData andServiceUserData:(NSString*)serviceUserData completion:(void (^)(ECError *, NSString *))completion{
    [[CoreModel sharedInstance] inviteMembersJoinMultiMediaMeeting:meetingNumber andIsLoandingCall:isLoadingCall andMembers:members andSpeak:isSpeak andListen:isListen andDisplayNumber:displaynumber andSDKUserData:sdkUserData andServiceUserData:serviceUserData completion:completion];
}


/**
 @brief 退出音频会议、实时对讲、视频会议
 @return 1 成功 0 失败
 */
-(BOOL)exitMeeting{
    return [[CoreModel sharedInstance] exitMeeting];
}

/**
 @brief 解散音频会议、视频会议
 @param multMeetingType 会议房间的类型
 @param meetingNumber   房间号
 @param completion      执行结果回调block
 */
-(void)deleteMultMeetingByMeetingType:(ECMeetingType)multMeetingType andMeetingNumber:(NSString *)meetingNumber completion:(void(^)(ECError *error, NSString *meetingNumber))completion{
    [[CoreModel sharedInstance] deleteMultMeetingByMeetingType:multMeetingType andMeetingNumber:meetingNumber completion:completion];
}

/**
 @brief 获取实时对讲、音频会议、视频会议成员列表
 @param meetingtype   会议房间的类型
 @param meetingNumber 房间号
 @param completion    执行结果回调block
 */
-(void)queryMeetingMembersByMeetingType:(ECMeetingType)meetingtype andMeetingNumber:(NSString *)meetingNumber completion:(void(^)(ECError *error, NSArray* members))completion{
    [[CoreModel sharedInstance] queryMeetingMembersByMeetingType:meetingtype andMeetingNumber:meetingNumber completion:completion];
}

/**
 @brief 踢人音频会议、视频会议
 @param multMeetingType 会议房间的类型
 @param meetingNumber   房间号
 @param memberVoip     成员viop号
 @param completion      执行结果回调block
 */
-(void)removeMemberFromMultMeetingByMeetingType:(ECMeetingType)multMeetingType andMeetingNumber:(NSString *)meetingNumber andMember:(ECVoIPAccount *)memberVoip completion:(void(^)(ECError *error, ECVoIPAccount *memberVoip))completion{
    [[CoreModel sharedInstance] removeMemberFromMultMeetingByMeetingType:multMeetingType andMeetingNumber:meetingNumber andMember:memberVoip completion:completion];
}

/**
 @brief 获取音频会议、视频会议列表
 @param multMeetingType 会议房间的类型
 @param keywords        房间密码
 @param completion      执行结果回调block
 */
-(void)listAllMultMeetingsByMeetingType:(ECMeetingType)multMeetingType andKeywords:(NSString *)keywords completion:(void(^)(ECError *error, NSArray * meetingList))completion{
    [[CoreModel sharedInstance] listAllMultMeetingsByMeetingType:multMeetingType andKeywords:keywords completion:completion];
}

/**
 @brief 创建实时对讲
 @param members    成员
 @param completion 执行结果回调block
 */
-(void)createInterphoneMeetingWithMembers:(NSArray *)members completion:(void(^)(ECError* error, NSString* meetingNumber))completion{
    [[CoreModel sharedInstance] createInterphoneMeetingWithMembers:members completion:completion];
}

/**
 @brief 实时对讲进行控麦
 @param meetingNumber 房间号
 @param completion    执行结果回调block
 */
-(void)controlMicInInterphoneMeeting:(NSString*)meetingNumber completion:(void(^)(ECError *error))completion{
    [[CoreModel sharedInstance] publishVoiceInConference:meetingNumber exclusively:1 completion:completion];
}

/**
 @brief 实时对讲放麦
 @param meetingNumber 房间号
 @param completion    执行结果回调block
 */
-(void)releaseMicInInterphoneMeeting:(NSString*)meetingNumber completion:(void(^)(ECError *error))completion{
    [[CoreModel sharedInstance] stopVoiceInConference:meetingNumber exclusively:1 completion:completion];
}

/**
 @brief 视频会议发布自己的视频
 @param meetingNumber 房间号
 @param completion    执行结果回调block
 */
-(void)publishSelfVideoFrameInVideoMeeting:(NSString *)meetingNumber completion:(void(^)(ECError *error, NSString *meetingNumber))completion{
    [[CoreModel sharedInstance] publishSelfVideoFrameInVideoMeeting:meetingNumber completion:completion];
}

/**
 @brief 视频会议取消自己的视频
 @param meetingNumber 房间号
 @param completion    执行结果回调block
 */
-(void)cancelPublishSelfVideoFrameInVideoMeeting:(NSString *)meetingNumber completion:(void(^)(ECError *error, NSString *meetingNumber))completion{
    [[CoreModel sharedInstance] cancelPublishSelfVideoFrameInVideoMeeting:meetingNumber completion:completion];
}

/**
 @brief 视频会议请求某一远端视频
 @param username 用户账号
 @param displayView 显示的view
 @param meetingNumber 房间号
 @param meetingPwd 房间密码
 @param port 视频源端口
 @param completion    执行结果回调block
 */
- (void)requestMemberVideoWithAccount:(NSString*)username andDisplayView:(UIView*)displayView andVideoMeeting:(NSString*)meetingNumber andPwd:(NSString*)meetingPwd andPort:(NSInteger)port completion:(void(^)(ECError *error, NSString *meetingNumber,NSString *member))completion{
    [[CoreModel sharedInstance] requestMemberVideoWithAccount:username andDisplayView:displayView andVideoMeeting:meetingNumber andPwd:meetingPwd andPort:port completion:completion];
}

/**
 @brief 视频会议取消请求某一远端视频
 @param username 用户账号
 @param meetingNumber 房间号
 @param meetingPwd 房间密码
 @param completion    执行结果回调block
 */
- (void)cancelMemberVideoWithAccount:(NSString*)username andVideoMeeting:(NSString*)meetingNumber andPwd:(NSString*)meetingPwd completion:(void(^)(ECError *error, NSString *meetingNumber, NSString *member))completion{
    [[CoreModel sharedInstance] cancelMemberVideoWithAccount:username andVideoMeeting:meetingNumber andPwd:meetingPwd completion:completion];
}

/**
 @brief 设置会议地址
 @param addr 视频会议源地址
 @return 0:成功 非0失败
 */
- (NSInteger)setVideoConferenceAddr:(NSString*)addr{
    return [[CoreModel sharedInstance] setVideoConferenceAddr:addr];
}

/**
 @brief 设置会议某成员是否可听可讲（不支持实时对讲）
 @param memberVoip    成员viop号
 @param speakListen   是否可听可讲 1、禁言 2、可讲 3、禁听 4、可听
 @param meetingType   会议房间的类型
 @param meetingNumber 房间号
 @param completion    执行结果回调block
 */
- (void)setMember:(ECVoIPAccount *)memberVoip speakListen:(NSInteger)speakListen ofMeetingType:(ECMeetingType)meetingType andMeetingNumber:(NSString*)meetingNumber completion:(void(^)(ECError *error, NSString *meetingNumber))completion{
    [[CoreModel sharedInstance] setMember:memberVoip speakListen:speakListen ofMeetingType:meetingType andMeetingNumber:meetingNumber completion:completion];
}

/**
 @brief 获取应用下的总的会议设置信息
 @param completion 执行结果回调block
 */
- (void)getConferenceAppSetting:(void(^)(ECError* error, ECConferenceAppSettingInfo *appSettingfo))completion {
    [[CoreModel sharedInstance] getConferenceAppSetting:completion];
}

/**
 @brief 获取用户会议室ID
 @param completion 执行结果回调block
 */
- (void)getConfroomIdListWithAccount:(ECAccountInfo *)member confId:(NSString *)confId completion:(void(^)(ECError* error, NSArray *arr))completion {
    [[CoreModel sharedInstance] getConfroomIdListWithAccount:member confId:confId completion:completion];
}


/**
 @brief 创建会议
 @param conferenceInfo 会议类
 @param completion 执行结果回调block
 */
- (void)createConference:(ECConferenceInfo*)conferenceInfo completion:(void(^)(ECError* error, ECConferenceInfo*conferenceInfo))completion {
    [[CoreModel sharedInstance] createConference:conferenceInfo completion:completion];
}

/**
 @brief 删除会议
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)deleteConference:(NSString*)confId completion:(void(^)(ECError* error))completion {
    [[CoreModel sharedInstance] deleteConference:confId completion:completion];
}

/**
 @brief 更新会议信息
 @param conferenceInfo 会议类
 @param completion 执行结果回调block
 */
- (void)updateConference:(ECConferenceInfo*)conferenceInfo completion:(void(^)(ECError* error))completion {
    [[CoreModel sharedInstance] updateConference:conferenceInfo completion:completion];
}

/**
 @brief 获取会议信息
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)getConference:(NSString*)confId completion:(void(^)(ECError* error, ECConferenceInfo*conferenceInfo))completion {
    [[CoreModel sharedInstance] getConference:confId completion:completion];
}

/**
 @brief 获取会议列表
 @param condition 筛选条件
 @param page 分页信息
 @param completion 执行结果回调block
 */
- (void)getConferenceListWithCondition:(ECConferenceCondition*)condition page:(CGPage)page ofMember:(ECAccountInfo*)member completion:(void(^)(ECError* error, NSArray* conferenceList))completion {
    [[CoreModel sharedInstance] getConferenceListWithCondition:condition page:page ofMember:member completion:completion];
}

/**
 @brief 获取历史会议列表
 @param condition 筛选条件
 @param page 分页信息
 @param completion 执行结果回调block
 */
- (void)getHistoryConferenceListWithCondition:(ECConferenceCondition*)condition page:(CGPage)page completion:(void(^)(ECError* error, NSArray* conferenceList))completion {
    [[CoreModel sharedInstance] getHistoryConferenceListWithCondition:condition page:page completion:completion];
}

/**
 @brief 锁定会议
 @param confId 会议ID
 @param lockType 0 锁定，1 解锁，2 锁定白板发起，3 解锁，4 锁定白板标注，5 解锁
 @param completion 执行结果回调block
 */
- (void)lockConference:(NSString*)confId lockType:(int)lockType completion:(void(^)(ECError* error))completion {
    [[CoreModel sharedInstance] lockConference:confId lockType:lockType completion:completion];
}

/**
 @brief 加入会议
 @param joinInfo 加入条件
 @param completion 执行结果回调block
 */
- (void)joinConferenceWith:(ECConferenceJoinInfo*)joinInfo completion:(void(^)(ECError* error, ECConferenceInfo*conferenceInfo))completion {
    [[CoreModel sharedInstance] joinConferenceWith:joinInfo completion:completion];
}

/**
 @brief 退出会议
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)quitConference:(NSString*)confId completion:(void(^)(ECError* error))completion {
    [[CoreModel sharedInstance] quitConference:confId completion:completion];
}

/**
 @brief 更换成员信息
 @param memberInfo 成员信息
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)updateMember:(ECConferenceMemberInfo*)memberInfo ofConference:(NSString*)confId completion:(void(^)(ECError* error))completion {
    [[CoreModel sharedInstance] updateMember:memberInfo ofConference:confId completion:completion];
}

/**
 @brief 获取成员信息
 @param member 账号信息
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)getMember:(ECAccountInfo*)member ofConference:(NSString*)confId completion:(void(^)(ECError* error, ECConferenceMemberInfo* memberInfo))completion {
    [[CoreModel sharedInstance] getMember:member ofConference:confId completion:completion];
}

/**
 @brief 获取成员列表
 @param confId 会议ID
 @param page 分页信息
 @param completion 执行结果回调block
 */
- (void)getMemberListOfConference:(NSString*)confId page:(CGPage)page completion:(void(^)(ECError* error, NSArray* members))completion {
    [[CoreModel sharedInstance] getMemberListOfConference:confId page:page completion:completion];
}

/**
 @brief 获取会议中的成员与会记录
 @param accountInfo 相关成员记录 如果为nil，获取所有成员与会记录
 @param confId 会议ID
 @param page 分页信息
 @param completion 执行结果回调block
 */
- (void)getMemberRecord:(ECAccountInfo*)accountInfo ofConference:(NSString*)confId page:(CGPage)page completion:(void(^)(ECError* error, NSArray* membersRecord))completion {
    [[CoreModel sharedInstance] getMemberRecord:accountInfo ofConference:confId page:page completion:completion];
}

/**
 @brief 邀请加入会议
 @param inviteMembers ECAccountInfo数组 邀请的成员
 @param confId 会议ID
 @param callImmediately 是否立即发起呼叫 对于自定义账号，1表示给用户显示呼叫页面，并设置超时时间1分钟 对于电话号码（或关联电话）账号，1表示立即给cm发呼叫命令 0表示仅在会议中增加成员（一般用户预约会议开始前增加成员）
 @param appData 预留
 @param completion 执行结果回调block
 */
- (void)inviteMembers:(NSArray*)inviteMembers inConference:(NSString*)confId callImmediately:(int)callImmediately appData:(NSString*)appData completion:(void(^)(ECError* error))completion {
    [[CoreModel sharedInstance] inviteMembers:inviteMembers inConference:confId callImmediately:callImmediately appData:appData completion:completion];
}


/**
 @brief 拒绝会议邀请
 @param invitationId 邀请的id
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)rejectInvitation:(NSString*)invitationId cause:(NSString*)cause ofConference:(NSString*)confId completion:(void(^)(ECError* error))completion {
    [[CoreModel sharedInstance] rejectInvitation:invitationId cause:cause ofConference:confId completion:completion];
}
/**
 @brief 踢出成员
 @param kickMembers ECAccountInfo数组 踢出的成员
 @param confId 会议ID
 @param appData 预留
 @param completion 执行结果回调block
 */
- (void)kickMembers:(NSArray*)kickMembers outConference:(NSString*)confId appData:(NSString*)appData completion:(void(^)(ECError* error))completion {
    [[CoreModel sharedInstance] kickMembers:kickMembers outConference:confId appData:appData completion:completion];
}

/**
 @brief 设置成员角色
 @param member 相关设置信息
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)setMemberRole:(ECAccountInfo*)member ofConference:(NSString*)confId completion:(void(^)(ECError* error))completion {
    [[CoreModel sharedInstance] setMemberRole:member ofConference:confId completion:completion];
}

/**
 @brief 媒体控制
 @param action 控制动作
 @param members ECAccountInfo数组 控制成员列表
 @param isAllMember 是否全部成员
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)controlMedia:(ECControlMediaAction)action toMembers:(NSArray*)members isAll:(int)isAllMember ofConference:(NSString*)confId completion:(void(^)(ECError* error))completion {
    [[CoreModel sharedInstance] controlMedia:action toMembers:members isAll:isAllMember ofConference:confId completion:completion];
}

/**
 @brief 会议媒体是否sdk自动控制   1 sdk收到会控通知会自动控制媒体 0 sdk不会控制媒体相关
 
 @param isAuto 是否自动控制
 */
- (NSInteger)setConferenceAutoMediaControl:(BOOL)isAuto{
    return [[CoreModel sharedInstance] setConferenceAutoMediaControl:isAuto];
}

/**
 @brief 会议录制
 @param action 录制控制
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)record:(ECRecordAction)action conference:(NSString*)confId completion:(void(^)(ECError* error))completion {
    [[CoreModel sharedInstance] record:action conference:confId completion:completion];
}

/**
 @brief 发布音频
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)publishVoiceInConference:(NSString*)confId completion:(void(^)(ECError* error))completion {
    [[CoreModel sharedInstance] publishVoiceInConference:confId exclusively:0 completion:completion];
}

/**
 @brief 取消发布
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)stopVoiceInConference:(NSString*)confId completion:(void(^)(ECError* error))completion {
    [[CoreModel sharedInstance] stopVoiceInConference:confId exclusively:0 completion:completion];
}

/**
 @brief 发布视频
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)publishVideoInConference:(NSString*)confId completion:(void(^)(ECError* error))completion {
    [[CoreModel sharedInstance] publishVideoInConference:confId completion:completion];
}

/**
 @brief 取消发布
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)cancelVideoInConference:(NSString*)confId completion:(void(^)(ECError* error))completion {
    [[CoreModel sharedInstance] cancelVideoInConference:confId completion:completion];
}

/**
 @brief 共享屏幕
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)shareScreenInConference:(NSString*)confId completion:(void(^)(ECError* error))completion {
    [[CoreModel sharedInstance] shareScreenInConference:confId completion:completion];
}

/**
 @brief 停止共享屏幕
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)stopScreenInConference:(NSString*)confId completion:(void(^)(ECError* error))completion {
    [[CoreModel sharedInstance] stopScreenInConference:confId completion:completion];
}

/**
 @brief 请求成员视频
 @param videoInfo 视频信息
 @param completion 执行结果回调block
 */
- (void)requestMemberVideoWith:(ECConferenceVideoInfo*)videoInfo completion:(void(^)(ECError* error))completion {
    if (([AppModel sharedInstance].isInConf == NO) && (videoInfo.sourceType == ECConferenceSourceType_Video)) {
           NSLog(@"加入会议没有回调，不去请求视频requestMemberVideoWith videoInfo.member.accountId = %@,videoInfo.sourceType = %lu ",videoInfo.member.accountId,(unsigned long)videoInfo.sourceType);
    }else{
        NSLog(@"加入会议回调成功，去请求视频requestMemberVideoWith videoInfo.member.accountId = %@,videoInfo.sourceType = %lu ",videoInfo.member.accountId,(unsigned long)videoInfo.sourceType);
          [[CoreModel sharedInstance] requestMemberVideoWith:videoInfo completion:completion];
    }

}

/**
 @brief 停止成员视频
 @param videoInfo 视频信息
 @param completion 执行结果回调block
 */
- (void)stopMemberVideoWith:(ECConferenceVideoInfo*)videoInfo completion:(void(^)(ECError* error))completion {
    [[CoreModel sharedInstance] stopMemberVideoWith:videoInfo completion:completion];
}

/**
 @brief 重置显示View
 @param videoInfo 视频信息
 */
- (int)resetMemberVideoWith:(ECConferenceVideoInfo*)videoInfo {
    if (([AppModel sharedInstance].isInConf == NO) && (videoInfo.sourceType == ECConferenceSourceType_Video)) {
        NSLog(@"加入会议没有回调，不去resetMemberVideoWith");
        return 1;
    }else{
         NSLog(@"加入会议有回调，去resetMemberVideoWith");
         return [[CoreModel sharedInstance] resetMemberVideoWith:videoInfo];
    }
   
//    return 0;
}

/**
 @brief 重置本地预览显示View
 */
- (int)resetLocalVideoWithConfId:(NSString *)confId remoteView:(UIView *)remoteView localView:(UIView *)localView {
    return [[CoreModel sharedInstance] resetLocalVideoWithConfId:confId remoteView:remoteView localView:localView];
}

/**
 @brief 开启服务器录像
 @param callid 会话ID
 @param fileName 录像文件名称
 @param filePath 录像服务器地址
 @param resolution 录像分辨率 720p或1080p
 @param source 录制源，0录制双方、1主叫、2被叫
 @param isMix 是否混屏
 @param url 录制回调URL
 @param completion 执行结果回调block
 */
- (void)startServerRecord:(NSString*)callid fileName:(NSString*)fileName filePath:(NSString*)filePath resolution:(NSString*)resolution source:(NSInteger)source isMixScreen:(BOOL)isMix callBackUrl:(NSString*)url completion:(void(^)(ECError *error))completion {
    [[CoreModel sharedInstance] startServerRecord:callid fileName:fileName filePath:filePath resolution:resolution source:source isMixScreen:isMix callBackUrl:url completion:completion];
}

/**
 @brief 关闭启服务器录像
 @param callid 会话ID
 @param completion 执行结果回调block
 */
- (void)stopServerRecord:(NSString*)callid completion:(void(^)(ECError *error))completion {
    [[CoreModel sharedInstance] stopServerRecord:callid completion:completion];
}

@end
