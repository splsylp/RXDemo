//
//  CoreModel+VoIP.m
//  CoreModel
//
//  Created by wangming on 16/8/24.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "CoreModel.h"
#import "CoreModel+VoIP.h"
#import "CocoaLumberjack.h"
@implementation CoreModel(VoIP)

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
-(NSString*)makeCall:(KitDialingInfoData*)callInfo completion:(void(^)(ECError *error, ECCallBackEntity* callBackEntity))completion{
    if (callInfo.callDirect != 0) {
        return nil;
    }
    if (callInfo.callType == 3) {
        ECCallBackEntity* callBack = [[ECCallBackEntity alloc] init];
        callBack.src = [NSString stringWithFormat:@"0086%@", self.userPhoneNum];;//主叫
        callBack.dest = callInfo.dialMobile;//被叫
        callBack.srcSerNum = callInfo.callerDisplay;
        callBack.destSerNum = callInfo.calledDisplay;
        [[ECDevice sharedInstance].VoIPManager makeCallback:callBack  completion:completion];
        return @"callback";
    }
    else
    {
        if (callInfo.callType == 0 || callInfo.callType == 1) {
            return [[ECDevice sharedInstance].VoIPManager makeCallWithType:callInfo.callType andCalled:callInfo.dialAccount];
        }else{
//            return [[ECDevice sharedInstance].VoIPManager makeCallWithType:callInfo.callType andCalled:callInfo.dialMobile];
          return   [[ECDevice sharedInstance].VoIPManager makeCallWithType:callInfo.callType andCalled:callInfo.dialMobile andToThird:@"000"];
        }
    }
}

/**
 @brief 挂断电话
 @param callid 电话id
 @return 0:成功  非0:失败
 */
- (NSInteger)releaseCall:(NSString *)callid{
    return [[ECDevice sharedInstance].VoIPManager releaseCall:callid];
}

/**
 @brief 挂断电话
 @param callid 电话id
 @param reason 预留参数,挂断原因值，可以传入大于1000的值，通话对方会在onMakeCallFailed收到该值
 @return 0:成功  非0:失败
 */
- (NSInteger)releaseCall:(NSString *)callid andReason:(NSInteger) reason{
    return [[ECDevice sharedInstance].VoIPManager releaseCall:callid andReason:reason];
}

/**
 @brief 接听电话
 @param callid 电话id
 @param callType 电话类型
 V2.1
 @return 0:成功  非0:失败
 */
- (NSInteger)acceptCall:(NSString*)callid withType:(CallType)callType{
    return [[ECDevice sharedInstance].VoIPManager acceptCall:callid withType:callType];
}

/**
 @brief 拒绝呼叫(挂断一样,当被呼叫的时候被呼叫方的挂断状态)
 @param callid 电话id
 @param reason 拒绝呼叫的原因, 可以传入ReasonDeclined:用户拒绝 ReasonBusy:用户忙
 @return 0:成功  非0:失败
 */
- (NSInteger)rejectCall:(NSString *)callid andReason:(NSInteger) reason{
    return [[ECDevice sharedInstance].VoIPManager rejectCall:callid andReason:reason];
}

/**
 @brief 获取当前通话的callid
 @return 电话id
 */
-(NSString*)getCurrentCall{
    return [[ECDevice sharedInstance].VoIPManager getCurrentCall];
}

/**
 @brief 请求切换音视频
 @param callType 请求的音视频类型
 @return 是否成功 0:成功；非0失败
 */
- (NSInteger)requestSwitchCallMediaType:(NSString*)callid toMediaType:(CallType)callType{
    return [[ECDevice sharedInstance].VoIPManager requestSwitchCallMediaType:callid toMediaType:callType];
}

/**
 @brief 回复对方的切换音视频请求
 @param callType 回复的音视频类型
 @return 是否成功 0:成功；非0失败
 */
- (NSInteger)responseSwitchCallMediaType:(NSString*)callid withMediaType:(CallType)callType{
    return [[ECDevice sharedInstance].VoIPManager responseSwitchCallMediaType:callid withMediaType:callType];
}

/**
 @brief 发送DTMF
 @param callid 电话id
 @param dtmf 键值
 @return 0:成功  非0:失败
 */
- (NSInteger)sendDTMF:(NSString *)callid dtmf:(NSString *)dtmf{
    return [[ECDevice sharedInstance].VoIPManager sendDTMF:callid dtmf:dtmf];
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
    DDLogInfo(@"callid=%@,fileName=%@,filePath=%@,resolution=%@,source=%d,isMix=%d,url=%@",callid,fileName,filePath,resolution,(int)source,isMix,url);
    [[ECDevice sharedInstance].VoIPManager startServerRecord:callid fileName:fileName filePath:filePath resolution:resolution source:source isMixScreen:isMix callBackUrl:url completion:^(ECError *error) {
        if (error.errorCode != ECErrorType_NoError) {
            DDLogError(@"errorCode = %d.des = %@",(int)error.errorCode,error.errorDescription);
        }
        if (completion) {
            completion(error);
        }
    }];
}

/**
 @brief 关闭启服务器录像
 @param callid 会话ID
 @param completion 执行结果回调block
 */
- (void)stopServerRecord:(NSString*)callid completion:(void(^)(ECError *error))completion {
    [[ECDevice sharedInstance].VoIPManager stopServerRecord:callid completion:^(ECError *error) {
        if (error.errorCode != ECErrorType_NoError) {
            DDLogError(@"errorCode = %d.des = %@",(int)error.errorCode,error.errorDescription);
        }
        if (completion) {
            completion(error);
        }
    }];
}

#pragma mark - 基本设置函数

/**
 @brief 静音设置
 @param on NO:正常 YES:静音
 */
- (NSInteger)setMute:(BOOL)on{
    return [[ECDevice sharedInstance].VoIPManager setMute:on];
}

/**
 @brief 获取当前静音状态
 @return NO:正常 YES:静音
 */
- (BOOL)getMuteStatus{
    return [[ECDevice sharedInstance].VoIPManager getMuteStatus];
}
/**
 @brief 获取当前免提状态
 @return NO:关闭 YES:打开
 */
- (BOOL)getLoudsSpeakerStatus{
    return [[ECDevice sharedInstance].VoIPManager getLoudsSpeakerStatus];
}

/**
 @brief 免提设置
 @param enable NO:关闭 YES:打开
 */
- (NSInteger)enableLoudsSpeaker:(BOOL)enable{
    return [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:enable];
}

/**
 @brief 设置电话
 @param phoneNumber 电话号
 */
- (void)setSelfPhoneNumber:(NSString *)phoneNumber{
    [[ECDevice sharedInstance].VoIPManager setSelfPhoneNumber:phoneNumber];
}
/**
 @brief 设置voip通话个人信息
 @param voipCallUserInfo VoipCallUserInfo对象
 */
- (void)setVoipCallUserInfo:(VoIPCallUserInfo *)voipCallUserInfo{
    [[ECDevice sharedInstance].VoIPManager setVoipCallUserInfo:voipCallUserInfo];
}

/**
 @brief 设置视频通话显示的view
 @param view 对方显示视图
 @param localView 本地显示视图
 */
- (NSInteger)setVideoView:(UIView*)view andLocalView:(UIView*)localView{
    return [[ECDevice sharedInstance].VoIPManager setVideoView:view andLocalView:localView];
}
/**
 @brief 获取摄像设备信息
 @return 摄像设备信息数组
 */
- (NSArray*)getCameraInfo{
    return [[ECDevice sharedInstance].VoIPManager getCameraInfo];
}
/**
 @brief 选择使用的摄像设备
 @param cameraIndex 设备index
 @param capabilityIndex 能力index
 @param fps 帧率
 @param rotate 旋转的角度
 */
- (NSInteger)selectCamera:(NSInteger)cameraIndex capability:(NSInteger)capabilityIndex fps:(NSInteger)fps rotate:(ECRotate)rotate{
    return [[ECDevice sharedInstance].VoIPManager selectCamera:cameraIndex capability:capabilityIndex fps:fps rotate:rotate];
}
/**
 @brief 设置支持的编解码方式，默认全部都支持
 @param codec 编解码类型
 @param enabled NO:不支持 YES:支持
 */
-(void)setCodecEnabledWithCodec:(ECCodec)codec andEnabled:(BOOL)enabled{
    [[ECDevice sharedInstance].VoIPManager setCodecEnabledWithCodec:codec andEnabled:enabled];
}
/**
 @brief 设置媒体流冗余。打开后通话减少丢包率，但是会增加流量
 @param bAudioRed:音频开关,底层默认2。0关闭，1协商打开,2只有会议才协商
 */
-(void)setAudioCodecRed:(NSInteger)bAudioRed{
    [[ECDevice sharedInstance].VoIPManager setAudioCodecRed:bAudioRed];
}

/**
 @brief 获得媒体流冗余当前设置值。
 */
-(NSInteger)getAudioCodecRed{
    return [[ECDevice sharedInstance].VoIPManager getAudioCodecRed];
}

/**
 @brief 获取编解码方式是否支持
 @param codec 编解码类型
 @return NO:不支持 YES:支持
 */
-(BOOL)getCondecEnabelWithCodec:(ECCodec)codec{
    return [[ECDevice sharedInstance].VoIPManager getCondecEnabelWithCodec:codec];
}

/**
 @brief  设置客户端标示
 @param agent 客服账号
 */
- (void)setUserAgent:(NSString *)agent{
    [[ECDevice sharedInstance].VoIPManager setUserAgent:agent];
}

/**
 @brief 设置音频处理的开关,在呼叫前调用
 @param type  音频处理类型. enum AUDIO_TYPE { AUDIO_AGC, AUDIO_EC, AUDIO_NS };
 @param enabled YES：开启，NO：关闭；AGC默认关闭; EC和NS默认开启.
 @param mode: 各自对应的模式: AUDIO_AgcMode、AUDIO_EcMode、AUDIO_NsMode.
 @return  成功 0 失败 -1
 */
-(NSInteger)setAudioConfigEnabledWithType:(ECAudioType) type andEnabled:(BOOL) enabled andMode:(NSInteger) mode{
    return [[ECDevice sharedInstance].VoIPManager setAudioConfigEnabledWithType:type andEnabled:enabled andMode:mode];
}

/**
 @brief 获取音频处理的开关
 @param type  音频处理类型. enum AUDIO_TYPE { AUDIO_AGC, AUDIO_EC, AUDIO_NS };
 @return  成功：音频属性结构 失败：nil
 */
-(ECAudioConfig*)getAudioConfigEnabelWithType:(ECAudioType)type{
    return [[ECDevice sharedInstance].VoIPManager getAudioConfigEnabelWithType:type];
}

/**
 @brief 设置视频通话码率
 @param bitrates  视频码流，kb/s，范围30-300
 */
-(void)setVideoBitRates:(NSInteger)bitrates{
    [[ECDevice sharedInstance].VoIPManager setVideoBitRates:bitrates];
}

/**
 @brief 统计通话质量
 @return  返回丢包率等通话质量信息对象
 */
-(CallStatisticsInfo*)getCallStatisticsWithCallid:(NSString*)callid andType:(CallType)type{
    return [[ECDevice sharedInstance].VoIPManager getCallStatisticsWithCallid:callid andType:type];
}

/**
 @brief 获取通话的网络流量信息
 @param   callid :  会话ID,会议类传入房间号
 @return  返回网络流量信息对象
 */
- (NetworkStatistic*)getNetworkStatisticWithCallId:(NSString*)callid{
    return [[ECDevice sharedInstance].VoIPManager getNetworkStatisticWithCallId:callid];
}

/**
 @brief 通话过程中设置本端摄像头开启关闭，自己能看到对方，通话对方看不到自己。
 @param callid:会话ID
 @param on:是否开启
 @return 是否成功 0：成功； 非0失败
 */
- (NSInteger)setLocalCameraOfCallId:(NSString*)callid andEnable:(BOOL)enable{
    return [[ECDevice sharedInstance].VoIPManager setLocalCameraOfCallId:callid andEnable:enable];
}

@end
