//
//  CoreModel.m
//  CoreModel
//
//  Created by wangming on 16/7/12.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "CoreModel.h"
#import "CoreModel+VoIP.h"
#import "CoreModel+IM.h"
#import "CoreModel+Meeting.h"
#import "UIKitConfiManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import "KitGlobalClass.h"
#import "NSDictionary+Ext.h"
#import "CocoaLumberjack.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
/// eagle 有会
#if IsHaveYHCConference
#import "YHCUserInfo.h"
#import "YHCECSDKManager.h"
#endif
@interface CoreModel()<ECDeviceDelegate>
{
    SystemSoundID receiveSound;
}

@property (nonatomic, strong) ECLoginInfo * ecLoginInfo;

@property (nonatomic, copy) NSString *sessionId;
@property (nonatomic, strong) NSString *offlineCallid;
@property (nonatomic, strong) NSDate* preDate;
@property (nonatomic, assign) ECNetworkType netType;
@property (nonatomic, assign) NSInteger offlineCount;


@end


@implementation CoreModel

SYNTHESIZE_SINGLETON_FOR_CLASS(CoreModel);

-(id)init
{
    if (self = [super init]) {
        
        //wangming add  登录后重新初始化日志组件 这样可以保证使用当前登录账户作为目录保存日志
        [DDLog removeAllLoggers];
        //配置DDLog
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        // TTY = Xcode console
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        // ASL = Apple System Logs
        DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithPath:[self getLogPath:nil]];
        // File Logger
        fileLogger.rollingFrequency = 60 * 60 * 24;
        // 24 hour rolling
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
        [DDLog addLogger:fileLogger];
        //wangming  end
        
        self.device  = [ECDevice sharedInstance];
        [self.device setReceiveAllOfflineMsgEnabled:YES];
        [self.device setPrivateCloudCompanyId:@"yuntongxun" andCompanyPwd:@"ytx123"];
        ///收到新消息的音频设置
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"ECKitBundle.bundle/icon/receive_msg" ofType:@"caf"];
        if (soundPath.length > 0) {
            NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
            OSStatus err = AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL,&receiveSound);
            if (err != kAudioServicesNoError)
                DDLogError(@"Could not load %@, error code: %d", soundURL, (int)err);
        }
    }
    return self;
}

-(void)login:(NSDictionary*) loginInfo :(void(^)(NSError* error)) LoginCompletion{
    DDLogInfo(@"\n*****************************\n loginInfo=%@\n*****************************",loginInfo);
    self.ecLoginInfo = [[ECLoginInfo alloc] init];
    self.userName = [loginInfo objectForKey:Table_User_member_name];
    self.userPhoneNum = [loginInfo objectForKey:Table_User_mobile];
    self.ecLoginInfo.username = [loginInfo objectForKey:Table_User_account];
    self.ecLoginInfo.userPassword = [loginInfo objectForKey:Table_User_account];
    self.ecLoginInfo.appKey = [loginInfo objectForKey:App_AppKey];
    self.ecLoginInfo.appToken = [loginInfo objectForKey:App_Token];
    self.ecLoginInfo.authType = LoginAuthType_NormalAuth;
    self.ecLoginInfo.mode = (LoginMode)[[loginInfo objectForKey:@"mode"] intValue];
    /// eagle 有会
    #if IsHaveYHCConference
    [YHCECSDKManager sharedInstance].account = [loginInfo objectForKey:Table_User_account];
     [YHCECSDKManager sharedInstance].userName = [loginInfo objectForKey:Table_User_member_name];
     [YHCECSDKManager sharedInstance].userPhoneNum = [loginInfo objectForKey:Table_User_mobile];
    [YHCUserInfo sharedInstance].userName = [loginInfo objectForKey:Table_User_member_name];
    [YHCUserInfo sharedInstance].userId = [loginInfo objectForKey:Table_User_account];;
    [YHCUserInfo sharedInstance].mobile = [loginInfo objectForKey:Table_User_mobile];
#endif
    
    [ECDevice sharedInstance].delegate = self;
    [[ECDevice sharedInstance] login:self.ecLoginInfo completion:^(ECError *error){
        DDLogError(@"login error.errorCode....返回的状态.......%ld",(long)error.errorCode);
        if (error.errorCode == ECErrorType_NoError) {
           
            [self setPersonInfo];
            [self setVoIPUserInfo:YES];
        }
        if (!error.errorDescription) {
            error.errorDescription = @"";
        }
        NSError* err = [NSError errorWithDomain:error.errorDescription code:error.errorCode userInfo:nil];
        LoginCompletion(err);
    }];
    
}

-(NSString*) getLogPath:(NSString*)acd{
#if TARGET_OS_IPHONE
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *baseDir = paths.firstObject;
        NSString *logsDirectory = [baseDir stringByAppendingPathComponent:@"Logs"];
#else
        NSString *appName = [[NSProcessInfo processInfo] processName];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *basePath = ([paths count] > 0) ? paths[0] : NSTemporaryDirectory();
        NSString *logsDirectory = [[basePath stringByAppendingPathComponent:@"Logs"] stringByAppendingPathComponent:appName];        
#endif
        if ([acd length]>0) {
            logsDirectory =  [logsDirectory stringByAppendingPathComponent: acd];
        }
    return logsDirectory;
}

-(void)reLogin:(void(^)(NSError* error)) LoginCompletion {
    if (self.ecLoginInfo) {
        [[ECDevice sharedInstance] login:self.ecLoginInfo completion:^(ECError *error){
            DDLogError(@"reLogin error.errorCode....返回的状态.......%ld",(long)error.errorCode);
            if (error.errorCode == ECErrorType_NoError) {
                [self setPersonInfo];
                [self setVoIPUserInfo:YES];
            }
            else{
                if (error.errorCode == ECErrorType_KickedOff) {
                }
            }
            [ECDevice sharedInstance].delegate = self;
            if (!error.errorDescription) {
                error.errorDescription = @"";
            }
            NSError* err = [NSError errorWithDomain:error.errorDescription code:error.errorCode userInfo:nil];
            LoginCompletion(err);
        }];
    }
}


-(void)logout:(void(^)(NSError* error)) LogoutCompletion{
    [[ECDevice sharedInstance] logout:^(ECError *error)
     {
         DDLogError(@"logout 状态.......%d  信息    %@",(int)error.errorCode,error.errorDescription);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
         id dataBaseManager = [NSClassFromString(@"KitDataBaseManager") performSelector:NSSelectorFromString(@"sharedInstance")];
         if (dataBaseManager) {
             if([dataBaseManager respondsToSelector:NSSelectorFromString(@"setDataBaseToNil")])
                 [dataBaseManager performSelector:NSSelectorFromString(@"setDataBaseToNil")];
         }
#pragma clang diagnostic pop
         
         if (!error.errorDescription) {
             error.errorDescription = @"";
         }
         NSError* err = [NSError errorWithDomain:error.errorDescription code:error.errorCode userInfo:nil];
         LogoutCompletion(err);
     }];
}
#pragma mark - 有会

/**
 @brief 客户端录音振幅代理函数
 @param amplitude 录音振幅
 */
-(void)onRecordingAmplitude:(double) amplitude{
    //zmf add
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KNOTIFICATION_onRecordingAmplitude" object:@(amplitude)];
    //zmf end
}

/**
 @brief 网络改变后调用的代理方法
 @param status 网络状态值
 */
- (void)onReachbilityChanged:(ECNetworkType)status{
    self.netType = status;
    DDLogError(@"onReachbilityChanged 状态.......%d",(int)status);
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onNetworkChanged object:@(status)];
}


- (void)playRecMsgSound:(NSString *)sessionId isChat:(BOOL)isChat{
    //后台切前台接收消息判断
    if (self.preDate == nil) {
        self.preDate = [NSDate date];
    }
    if (self.preDate != nil && [self.preDate timeIntervalSinceNow] >- 1) {
        self.preDate = [NSDate date];
        return;
    }
    //查看设置
    if ([UIKitConfiManager newMsgNotiVailableStatus]) {    //有新消息需要提醒
        if([UIKitConfiManager msgSoundVailableStatus]){
            //播放声音
            if (isChat) {

            }else{
                AudioServicesPlaySystemSound(receiveSound);
            }
        }
        if([UIKitConfiManager msgVibrateVailableStatus]){//只振动
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    }
}


/**
 @brief 接收即时消息代理函数
 @param message 接收的消息
 */
-(void)onReceiveMessage:(ECMessage*)message{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onReceiveMessage:)]) {
        [self.delegate onReceiveMessage:message];
    }
}


-(void)setVoIPUserInfo:(BOOL) showPhoneNum
{
    VoIPCallUserInfo* VoIPInfo = [[VoIPCallUserInfo alloc] init];
    VoIPInfo.nickName = self.userName;
    if (showPhoneNum) {
        VoIPInfo.phoneNum = self.userPhoneNum;
    }
//    [[YHCUserInfo sharedInstance] setMobile:self.userPhoneNum];
    [[ECDevice sharedInstance].VoIPManager setVoipCallUserInfo:VoIPInfo];
}

-(void)setPersonInfo
{
    // 应该不管有木有都设置，否则出现，名称已经改了，不去设置的问题
//    BOOL isSetUserInfo =[[NSUserDefaults standardUserDefaults]boolForKey:[NSString stringWithFormat:@"%@%@",self.ecLoginInfo.username,@"isLoginSetPersonInfo",nil]];
//    if(isSetUserInfo)
//    {
//        return ;
//    }
    //设置个人信息
    ECPersonInfo *UserInfo =[[ECPersonInfo alloc]init];
    if(self.userName.length>0)
    {
        UserInfo.nickName = self.userName;
    }
    if (self.ecLoginInfo.username.length>0) {
        UserInfo.userAcc =self.ecLoginInfo.username;
    }
//    [[YHCUserInfo sharedInstance] setUserId:self.ecLoginInfo.username];
//    NSLog(@"setPersonInfo &&&& %@",[[YHCUserInfo sharedInstance] userId]);
//    [[YHCUserInfo sharedInstance] setUserName:self.userName];
    [[ECDevice sharedInstance]setPersonInfo:UserInfo completion:^(ECError *error, ECPersonInfo *person) {
        DDLogInfo(@"----setNickname:%@----%d %@",self.ecLoginInfo.username,(int)error.errorCode,error.errorDescription);
        if(error.errorCode==ECErrorType_NoError && !KCNSSTRING_ISEMPTY(person.nickName)) {
            //存入昵称成功
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:[NSString stringWithFormat:@"%@%@",self.ecLoginInfo.username,@"isLoginSetPersonInfo",nil]];
        }
    }];

}



#pragma mark 主调函数



#pragma mark 各种回调
/**
 @brief 有呼叫进入
 @param callid      会话id
 @param caller      主叫人账号
 @param callerphone 主叫人设置的手机号
 @param callername  主叫人设置的昵称
 @param calltype    呼叫类型
 */
- (NSString*)onIncomingCallReceived:(NSString*)callid withCallerAccount:(NSString *)caller withCallerPhone:(NSString *)callerphone withCallerName:(NSString *)callername withCallType:(CallType)calltype{
    DDLogInfo(@"\n*****************************\n callid=%@\n caller=%@\n callerphone=%@\n callername=%@\n calltype=%d\n*****************************",callid,caller,callerphone,callername,(int)calltype);
    //wangming add
    CTCallCenter* callCenter = [[CTCallCenter alloc] init];
    NSSet* calls =  callCenter.currentCalls;
    for (id call in calls) {
        if ([call isKindOfClass:[CTCall class]]) {
            [self.device.VoIPManager rejectCall:callid andReason:5];
            DDLogInfo(@"================= In system calls, refuse to call");
            return nil;
        }
    }
    //    //wangming end
    if (self.delegate && [self.delegate respondsToSelector:@selector(onIncomingCallReceived:withCallerAccount:withCallerPhone:withCallerName:withCallType:)]) {
        return [self.delegate onIncomingCallReceived:callid withCallerAccount:caller withCallerPhone:callerphone withCallerName:callername withCallType:calltype];
    }
    return nil;
}

/**
 @brief 收到dtmf
 @param callid 会话id
 @param dtmf   键值
 */
- (void)onReceiveFrom:(NSString*)callid DTMF:(NSString*)dtmf{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onReceiveFrom:DTMF:)]) {
        [self.delegate onReceiveFrom:callid DTMF:dtmf];
    }
}

/**
 @brief 视频分辨率发生改变
 @param callid       会话id
 @param voip         VoIP号
 @param isConference NO 不是, YES 是
 @param width        宽度
 @param height       高度
 */
- (void)onCallVideoRatioChanged:(NSString *)callid andVoIP:(NSString *)voip andIsConfrence:(BOOL)isConference andWidth:(NSInteger)width andHeight:(NSInteger)height{
    NSLog(@"onCallVideoRatioChanged 123");
    if (self.delegate && [self.delegate respondsToSelector:@selector(onCallVideoRatioChanged:andVoIP:andIsConfrence:andWidth:andHeight:)]) {
        [self.delegate onCallVideoRatioChanged:callid andVoIP:voip andIsConfrence:isConference andWidth:width andHeight:height];
    }
}
-(void)onCallVideoRatioChanged:(NSString *)callid andWidth:(NSInteger)width andHeight:(NSInteger)height{
    
    
    NSLog(@"onCallVideoRatioChanged callid = %@,width = %ld,height = %ld",callid,(long)width,(long)height);
}
/**
 @brief 收到对方切换音视频的请求
 @param callid  会话id
 @param requestType 请求音视频类型 视频:需要响应 音频:请求删除视频（不需要响应，双方自动去除视频）
 */
- (void)onSwitchCallMediaTypeRequest:(NSString *)callid withMediaType:(CallType)requestType{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSwitchCallMediaTypeRequest:withMediaType:)]) {
        [self.delegate onSwitchCallMediaTypeRequest:callid withMediaType:requestType];
    }
}

/**
 @brief 收到对方应答切换音视频请求
 @param callid   会话id
 @param responseType 回复音视频类型
 */
- (void)onSwitchCallMediaTypeResponse:(NSString *)callid withMediaType:(CallType)responseType{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSwitchCallMediaTypeResponse:withMediaType:)]) {
        [self.delegate onSwitchCallMediaTypeResponse:callid withMediaType:responseType];
    }
}


/**
 @brief 获取本地回铃音路径
 @param voipCall  呼叫相关信息
 */
- (NSString*)onGetRingBackWavPath:(VoIPCall*)voipCall{
    return nil;
}

/**
 @brief 获取本地忙音路径
 @param voipCall  呼叫相关信息
 */
- (NSString*)onGetBusyWavPath:(VoIPCall*)voipCall{
    return nil;
}


-(void)onLogInfo:(NSString*)log {
    //    DDLogInfo(@"ECDeviceSDK LOG:%@",log);
}

/**
 @brief 连接状态接口
 @discussion 监听与服务器的连接状态 V5.0版本接口
 @param state 连接的状态
 @param error 错误原因值
 */
-(void)onConnectState:(ECConnectState)state  failed:(ECError*)error{
    DDLogInfo(@"onConnectState error.errorCode....返回的状态.......%ld",(long)error.errorCode);
    if (self.delegate && [self.delegate respondsToSelector:@selector(onConnectState:failed:)]) {
        [self.delegate onConnectState:state failed:error];
    }
}


/**
 @brief 个人信息版本号
 @param version 服务器上的个人信息版本号
 */
-(void)onServicePersonVersion:(unsigned long long)version{
    if ([KitGlobalClass sharedInstance].dataVersion==0 && version==0) {
        [KitGlobalClass sharedInstance].isNeedSetData = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_needInputName object:nil];
    } else if (version>[KitGlobalClass sharedInstance].dataVersion) {
        [[ECDevice sharedInstance] getPersonInfo:^(ECError *error, ECPersonInfo *person) {
            if (error.errorCode == ECErrorType_NoError)
            {
                [KitGlobalClass sharedInstance].dataVersion = person.version;
                [KitGlobalClass sharedInstance].birth = person.birth;
                [KitGlobalClass sharedInstance].nickName = person.nickName;
                [KitGlobalClass sharedInstance].sex = person.sex;
            }
        }];
    }
}

/**
 @brief 最新软件版本号
 @param version 软件版本号
 @param mode 更新模式  1：手动更新 2：强制更新
 */
-(void)onSoftVersion:(NSString*)version andUpdateMode:(NSInteger)mode {
    DDLogError(@"SoftVersion=%@ mode=%d",version, (int)mode);
}

/**
 @brief 离线消息数
 @param count 消息数
 */
-(void)onOfflineMessageCount:(NSUInteger)count{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onOfflineMessageCount:)]) {
        [self.delegate onOfflineMessageCount:count];
    }
}
/**
 @brief 需要获取的消息数
 @return 消息数 -1:全部获取 0:不获取
 */
-(NSInteger)onGetOfflineMessage{
     DDLogInfo(@"eagle.获取离线消息");
    if (self.delegate && [self.delegate respondsToSelector:@selector(onGetOfflineMessage)]) {
        return [self.delegate onGetOfflineMessage];
    }
    return -1;
}

/**
 @brief 接收离线消息代理函数
 @param message 接收的消息
 */
-(void)onReceiveOfflineMessage:(ECMessage*)message{
    DDLogInfo(@"eagle.接收到离线消息");
    if (self.delegate && [self.delegate respondsToSelector:@selector(onReceiveOfflineMessage:)]) {
        [self.delegate onReceiveOfflineMessage:message];
    }
}

/**
 @brief 接收离线消息代理函数
 @param msgArray 消息数组
 */
//- (void)onReceiveOfflineMessageArray:(NSArray *)msgArray{
//    DDLogInfo(@"eagle.接收到离线消息 msgaArray.acount = %lu",(unsigned long)msgArray.count);
//    if (self.delegate && [self.delegate respondsToSelector:@selector(onReceiveOfflineMessage:)]) {
//        [self.delegate onReceiveOfflineMessageArray:msgArray];
//    }
//}
/**
 @brief 消息操作通知
 @param message 通知消息
 */
- (void)onReceiveMessageNotify:(ECMessageNotifyMsg *)message {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onReceiveMessageNotify:)]) {
        [self.delegate onReceiveMessageNotify:message];
    }
}

/**
 @brief 离线消息接收是否完成
 @param isCompletion YES:拉取完成 NO:拉取未完成(拉取消息失败)
 */
-(void)onReceiveOfflineCompletion:(BOOL)isCompletion {
    if (isCompletion) {
        DDLogInfo(@"eagle.接收离线消息完成");
        
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(onReceiveOfflineCompletion:)]) {
        [self.delegate onReceiveOfflineCompletion:isCompletion];
    }
}


/**
 @brief 接收群组相关消息
 @discussion 参数要根据消息的类型，转成相关的消息类；
 解散群组、收到邀请、申请加入、退出群聊、有人加入、移除成员等消息
 @param groupMsg 群组消息
 */
-(void)onReceiveGroupNoticeMessage:(ECGroupNoticeMessage *)groupMsg{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onReceiveGroupNoticeMessage:)]) {
        [self.delegate onReceiveGroupNoticeMessage:groupMsg];
    }
}


-(void)onCallEvents:(VoIPCall *)voipCall
{
    DDLogInfo(@"\n*****************************\n callID=%@\n caller=%@\n callee=%@\n callDirect=%lu\n callType=%ld\n callStatus = %lu\n reason = %ld\n*****************************",voipCall.callID,voipCall.caller,voipCall.callee,(unsigned long)voipCall.callDirect,(long)voipCall.callType,(unsigned long)voipCall.callStatus,(long)voipCall.reason);
    if (self.delegate && [self.delegate respondsToSelector:@selector(onCallEvents:)]) {
        [self.delegate onCallEvents:voipCall];
    }
}


#pragma mark 语音会议代理函数
-(void)onReceiveMultiVoiceMeetingMsg:(ECMultiVoiceMeetingMsg *)msg
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(onReceiveMultiVoiceMeetingMsg:)])
    {
        [self.delegate onReceiveMultiVoiceMeetingMsg:msg];
    }
}

#pragma mark 多路视频会议代理函数
-(void)onReceiveMultiVideoMeetingMsg:(ECMultiVideoMeetingMsg *)msg
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(onReceiveMultiVideoMeetingMsg:)])
    {
        [self.delegate onReceiveMultiVideoMeetingMsg:msg];
    }
}

- (void) onReceivedConferenceNotification:(ECConferenceNotification*)info {
    if(self.delegate && [self.delegate respondsToSelector:@selector(onReceivedConferenceNotification:)])
    {
        [self.delegate onReceivedConferenceNotification:info];
    }
}
#pragma mark - 废弃 用下面的
//- (void)onReceivedConferenceVoiceMemberNotification:(NSDictionary *)info{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(onReceivedConferenceVoiceMemberNotification:)]) {
//        [self.delegate onReceivedConferenceVoiceMemberNotification:info];
//    }
//}

- (void) onReceivedConferenceVoiceMemberWithID:(NSString *)confId members:(NSArray *)members{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onReceivedConferenceVoiceMemberWithID:members:)]) {
        [self.delegate onReceivedConferenceVoiceMemberWithID:confId members:members];
    }
}
/**
 @brief 有会议呼叫邀请
 @param callid      会话id
 @param calltype    呼叫类型
 @param meetingData 会议的数据
 */
-(NSString *)onMeetingCallReceived:(NSString *)callid withCallType:(CallType)calltype withMeetingData:(NSDictionary *)meetingData
{
    DDLogInfo(@"\n*****************************\n callid = %@\n meetingData = %@\n calltype = %ld\n*****************************",callid,meetingData,(long)calltype);
    //wangming add
    CTCallCenter* callCenter = [[CTCallCenter alloc] init];
    NSSet* calls =  callCenter.currentCalls;
    for (id call in calls) {
        if ([call isKindOfClass:[CTCall class]]) {
            [self.device.VoIPManager rejectCall:callid andReason:5];
            DDLogInfo(@"================= In system calls, refuse to call");
            return nil;
        }
    }
    //    //wangming end
    if(self.delegate && [self.delegate respondsToSelector:@selector(onMeetingCallReceived:withCallType:withMeetingData:)])
    {
        return [self.delegate onMeetingCallReceived:callid withCallType:calltype withMeetingData:meetingData];
    }
    return nil;
}

#pragma mark 朋友圈推送  公众号消息推送
/**
 @brief 消息操作通知  朋友圈通知
 @param message 通知消息
 */
-(void)onReceiveServerUndefineMessage:(NSString*)jsonString;
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(onReceiveServerUndefineMessage:)])
    {
        [self.delegate onReceiveServerUndefineMessage:jsonString];
    }
}

/**
 @brief 收到多设备的状态
 @param multiDevices ECMultiDeviceState数组 多设备状态
 */
-(void)onReceiveMultiDeviceState:(NSArray*)multiDevices{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onReceiveMultiDeviceState:)]) {
        [self.delegate onReceiveMultiDeviceState:multiDevices];
    }
}

- (void)onReceiveFriendsPublishPresence:(NSArray<ECUserState *> *)friends{
    if (self.delegate && [self.delegate respondsToSelector:@selector(onReceiveFriendsPublishPresence:)]) {
        [self.delegate onReceiveFriendsPublishPresence:friends];
    }
}

@end
