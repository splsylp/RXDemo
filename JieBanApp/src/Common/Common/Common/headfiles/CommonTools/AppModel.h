//
//  AppModel.h
//  AppModel
//
//  Created by wangming on 16/7/25.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppData.h"
#import "RXThirdPart.h"
#import "SynthesizeSingleton.h"
#import "AppModelDelegate.h"
#import <PushKit/PushKit.h>
#import "LanguageTools.h"
//#import "../../../../../../rongxin4/pluginHeads/SVC/Delegate/YHCPlugDelegate.h"
//#import "../../../../../../rongxin4/pluginHeads/SVC/Delegate/YHCConnectDelegate.h"
//#import "../../../../../../rongxin4/pluginHeads/SVC/Delegate/YHCBoardDelegate.h"
//#import "../../../../../../rongxin4/pluginHeads/SVC/Delegate/YHCConferenceDelegate.h"

//换肤相关的宏
#define ThemeImage(name)        [[AppModel sharedInstance] imageWithName:name]  //换图片
#define ThemeColor              [[AppModel sharedInstance] themeColor]          //换颜色
#define ThemeColorImage(image,color) [[AppModel sharedInstance] getThemeColorImage:(UIImage *)image withColor:(UIColor *)color]

#define LineViewColor           [UIColor colorWithHexString:@"#e0e0e0"] // 下划线的颜色
//主题文字相关 (暂时用字号加减,考虑用比例)
//字体变化发送通知
#define THEMEFONTCHANGENOTIFICATION @"ThemeFontChangeNotification"
///字体变化比例
#define FitThemeFont (ThemeFontLarge).pointSize / [AppModel sharedInstance].themeFontSizeLarge
//标准大小
#define ThemeFontLarge [[AppModel sharedInstance] themeFontWithSize:0 isTheme:YES]
//比标准小两号
#define ThemeFontMiddle [[AppModel sharedInstance] themeFontWithSize:1 isTheme:YES]
//比标准小四号
#define ThemeFontSmall [[AppModel sharedInstance] themeFontWithSize:2 isTheme:YES]
//系统的文字大小 不受主题影响
//标准大小
#define SystemFontLarge [[AppModel sharedInstance] themeFontWithSize:0 isTheme:NO]
//比标准小两号
#define SystemFontMiddle [[AppModel sharedInstance] themeFontWithSize:1 isTheme:NO]
//比标准小四号
#define SystemFontSmall [[AppModel sharedInstance] themeFontWithSize:2 isTheme:NO]


#define FitThemeTabBarFont ((((ThemeFontLarge).pointSize / [AppModel sharedInstance].themeFontSizeLarge) - 1) * 0.7 + 1)
#define ThemeDefaultHead(size,name,account) [[AppModel sharedInstance] drawDefaultHeadImageWithHeadSize:size andNameString:name andAccount:account]
#define ThemeNavigation(str)     [[AppModel sharedInstance] themNavigationBarTitleColor:str]
#define languageStringWithKey(key) [[LanguageTools sharedInstance] getStringForKey:key] //切换语言
#define UserDefault_CurResolution   @"UserDefault_CurResolution"  // 分辨率
#define UserDefault_VideoViewContentMode     @"UserDefault_VideoviewContentMode" // 视频显示模式
#import "BaseComponent.h"
typedef void(^completion)(NSArray *obj);
@interface AppModel : NSObject<UIApplicationDelegate, PKPushRegistryDelegate,ComponentDelegate>//,YHCPlugDelegate,YHCConnectDelegate,YHCBoardDelegate,YHCConferenceDelegate

@property (nonatomic,weak) id<AppModelDelegate>appModelDelegate;
@property (nonatomic,strong) AppData* appData;
@property (nonatomic,strong) id owner;
@property (nonatomic,assign) BOOL loginstate;
@property (nonatomic, copy) NSString *sessionId; //用于更新会话列表
@property (nonatomic,assign) NSInteger invateConType;// 邀请加入会议的方式 0 为ECAccountType_AppNumber(应用账号) 1为落地电话ECAccountType_PhoneNumber  2为快速邀请(手动输入手机号)
@property (nonatomic ,assign) CGFloat theViewDown; //有电话等，屏幕下压20
@property (nonatomic ,assign) BOOL isInConf; //是否在会议中
@property (nonatomic, assign) BOOL isInVoip; // 是否在点对点通话中
@property (nonatomic, assign) BOOL isInIOSPlatform; //是否属于ios平台
@property (nonatomic ,assign) BOOL isHaveGetTopList; //是否获取了在置顶列表
@property (nonatomic, strong) NSMutableArray *interphoneArray; // 接收到的实时对讲消息集合

//记录用户选择的字体大小
@property (nonatomic, assign) CGFloat selectedThemeFontSize;
@property (nonatomic, assign) CGFloat themeFontSizeLarge;

@property (strong,nonatomic) completion YHCcompletion;// 有会回调
@property (nonatomic,strong) NSString *muteState;//静音状态，1 静音，2 没静音
@property (nonatomic ,assign) BOOL isPCLogin; //是否在pc或者MAC登陆
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(AppModel);

/**
 登录 SDK
 
 @param loginInfo 登录所需信息
 
 @{
 @"App_AppKey" : @"8a9aea976091926b0160925dced4xxxx",
 @"App_Token" : @"aafb5c1e3d1f40fd9c84fa655225xxxx",
 @"account" : @"rhtx80697",
 @"member_name" : @"XX",
 @"mobile" : @"130XXXX9358",
 @"mode" : @1
 }
 
 @param LoginCompletion 登录回调
 */
-(void)loginSDK:(NSDictionary*)loginInfo :(void(^)(NSError* error)) LoginCompletion;



/**
 登出 SDK 清楚缓存信息
 
 @param LogoutCompletion 登出后回调
 */
-(void)logout:(void(^)(NSError* error)) LogoutCompletion;


/**
 通过 runtime 形式调用方法
 
 @param moduleName 类名
 @param funcName 方法名
 @param parms 参数
 @return 返回值 默认有返回值
 */
-(id)runModuleFunc:(NSString*)moduleName :(NSString*)funcName :(NSArray*)parms;

/**
 通过 runtime 形式调用方法
 
 @param moduleName 类名
 @param funcName 方法名
 @param parms 参数
 @param hasReturn 是否有返回值
 @return 返回值
 */
-(id)runModuleFunc:(NSString*)moduleName :(NSString*)funcName :(NSArray*)parms hasReturn:(BOOL)hasReturn;

/**
 结束会议之后开始VOIP通话
 */
-(void)afterhasCloseConfAndAcceptVoipCall;

/**
 播放新消息提示音
 
 @param sessionId 会话ID
 */
-(void)playRecMsgSound:(NSString*)sessionId;


/** tian ao
 @brief 切换多语言
 @param type  语言类型 0 简体中文 1 英文  2 繁体中文
 */

- (void)switchOtherLangeuage:(NSInteger)type;

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
/**
 @brief 是否置顶会话
 @param seesionId 会话id
 @param isTop 0 取消置顶 1 置顶
 */
-(void)setSession:(NSString*)seesionId IsTop:(BOOL)isTop completion:(void(^)(ECError *error, NSString *seesionId))completion;

#pragma mark - 基本设置函数
/**
 @brief 保持客户端TCP后台连接3分钟
 @discussion VoIP呼叫开始时打开，呼叫结束时关闭，保证APP在后台3分钟内收到呼叫状态回调
 @param isOpen 是否打开
 */
- (void)setOpenBackgroudTask:(BOOL)isOpen;
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
- (void)setCodecEnabledWithCodec:(ECCodec)codec andEnabled:(BOOL)enabled;

/**
 @brief 获取编解码方式是否支持
 @param codec 编解码类型
 @return NO:不支持 YES:支持
 */
- (BOOL)getCondecEnabelWithCodec:(ECCodec)codec;
/**
 @brief 设置媒体流冗余。打开后通话减少丢包率，但是会增加流量
 @param bAudioRed :音频开关,底层默认2。0关闭，1协商打开,2只有会议才协商
 */
- (void)setCodecRed:(NSInteger)bAudioRed;

/**
 @brief 获得媒体流冗余当前设置值。
 */
- (NSInteger)getCodecRed;

/**
 @brief  设置客户端标示
 @param agent 客服账号
 */
- (void)setUserAgent:(NSString *)agent;

/**
 @brief 设置音频处理的开关,在呼叫前调用
 @param type  音频处理类型. enum AUDIO_TYPE { AUDIO_AGC, AUDIO_EC, AUDIO_NS };
 @param enabled YES：开启，NO：关闭；AGC默认关闭; EC和NS默认开启.
 @param mode : 各自对应的模式: AUDIO_AgcMode、AUDIO_EcMode、AUDIO_NsMode.
 @return  成功 0 失败 -1
 */
- (NSInteger)setAudioConfigEnabledWithType:(ECAudioType) type andEnabled:(BOOL) enabled andMode:(NSInteger) mode;

/**
 @brief 获取音频处理的开关
 @param type  音频处理类型. enum AUDIO_TYPE { AUDIO_AGC, AUDIO_EC, AUDIO_NS };
 @return  成功：音频属性结构 失败：nil
 */
- (ECAudioConfig*)getAudioConfigEnabelWithType:(ECAudioType)type;

/**
 @brief 设置视频通话码率
 @param bitrates  视频码流，kb/s，范围30-300
 */
- (void)setVideoBitRates:(NSInteger)bitrates;

/**
 @brief 统计通话质量
 @return  返回丢包率等通话质量信息对象
 */
- (CallStatisticsInfo*)getCallStatisticsWithCallid:(NSString*)callid andType:(CallType)type;

/**
 @brief 获取通话的网络流量信息
 @param   callid :  会话ID,会议类传入房间号
 @return  返回网络流量信息对象
 */
- (NetworkStatistic*)getNetworkStatisticWithCallId:(NSString*)callid;

/**
 @brief 通话过程中设置本端摄像头开启关闭，自己能看到对方，通话对方看不到自己。
 @param callid :会话ID
 @param enable :是否开启
 @return 是否成功 0：成功； 非0失败
 */
- (NSInteger)setLocalCameraOfCallId:(NSString*)callid andEnable:(BOOL)enable;

/**
 @brief 创建音频会议、视频会议回调
 @param params     会议类
 @param completion 执行结果回调block
 */
- (void)createMultMeetingByType:(ECCreateMeetingParams *)params completion:(void(^)(ECError* error, NSString *meetingNumber))completion;

/**
 @brief 加入音频会议、视频会议、实时对讲
 @param meetingNumber 房间号
 @param meetingType   会议房间的类型
 @param meetingPwd    房间密码
 @param completion    执行结果回调block
 */
- (void)joinMeeting:(NSString*)meetingNumber ByMeetingType:(ECMeetingType )meetingType andMeetingPwd:(NSString *)meetingPwd completion:(void(^)(ECError* error, NSString *meetingNumber))completion;


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
- (BOOL)exitMeeting;

/**
 @brief 解散音频会议、视频会议
 @param multMeetingType 会议房间的类型
 @param meetingNumber   房间号
 @param completion      执行结果回调block
 */
- (void)deleteMultMeetingByMeetingType:(ECMeetingType)multMeetingType andMeetingNumber:(NSString *)meetingNumber completion:(void(^)(ECError *error, NSString *meetingNumber))completion;

/**
 @brief 获取实时对讲、音频会议、视频会议成员列表
 @param meetingtype   会议房间的类型
 @param meetingNumber 房间号
 @param completion    执行结果回调block
 */
- (void)queryMeetingMembersByMeetingType:(ECMeetingType)meetingtype andMeetingNumber:(NSString *)meetingNumber completion:(void(^)(ECError *error, NSArray* members))completion;

/**
 @brief 踢人音频会议、视频会议
 @param multMeetingType 会议房间的类型
 @param meetingNumber   房间号
 @param memberVoip     成员viop号
 @param completion      执行结果回调block
 */
- (void)removeMemberFromMultMeetingByMeetingType:(ECMeetingType)multMeetingType andMeetingNumber:(NSString *)meetingNumber andMember:(ECVoIPAccount *)memberVoip completion:(void(^)(ECError *error, ECVoIPAccount *memberVoip))completion;

/**
 @brief 视频会议发布自己的视频
 @param meetingNumber 房间号
 @param completion    执行结果回调block
 */
- (void)publishSelfVideoFrameInVideoMeeting:(NSString *)meetingNumber completion:(void(^)(ECError *error, NSString *meetingNumber))completion;

/**
 @brief 视频会议取消自己的视频
 @param meetingNumber 房间号
 @param completion    执行结果回调block
 */
- (void)cancelPublishSelfVideoFrameInVideoMeeting:(NSString *)meetingNumber completion:(void(^)(ECError *error, NSString *meetingNumber))completion;

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
 @brief 移出成员
 @param kickMembers ECAccountInfo数组 移出的成员
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
 @param completion 执行结果回调block
 */
- (void)publishVoiceInConference:(NSString*)confId completion:(void(^)(ECError* error))completion;

/**
 @brief 取消发布
 @param confId 会议ID
 @param completion 执行结果回调block
 */
- (void)stopVoiceInConference:(NSString*)confId completion:(void(^)(ECError* error))completion;

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
/**
 @brief 根据用户的选择更换字体的大小
 @param size  大0 中1 小2
 @param isTheme  YES是主题文字 NO是系统文字
 */
- (UIFont *)themeFontWithSize:(NSInteger)size isTheme:(BOOL)isTheme;
//收到个人助手消息处理
-(void)getPersonalAssistant;
/**
 @brief 根据用户的选择更换图片资源
 @param name  图片名字
 */
- (UIImage *)imageWithName:(NSString *)name;

/**
 @brief 根据用户的选择更换主题颜色
 */
- (UIColor *)themeColor;

- (UIImage *)getThemeColorImage:(UIImage *)image withColor:(UIColor *)color;

/**
 @brief 用户默认头像
 */
- (UIImage *)drawDefaultHeadImageWithHeadSize:(CGSize)size andNameString:(NSString *)name andAccount:(NSString *)account;


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
- (void)startServerRecord:(NSString*)callid fileName:(NSString*)fileName filePath:(NSString*)filePath resolution:(NSString*)resolution source:(NSInteger)source isMixScreen:(BOOL)isMix callBackUrl:(NSString*)url completion:(void(^)(ECError *error))completion;

/**
 @brief 关闭启服务器录像
 @param callid 会话ID
 @param completion 执行结果回调block
 */
- (void)stopServerRecord:(NSString*)callid completion:(void(^)(ECError *error))completion;
/**
 @brief 获取置顶会话列表
 @param completion 执行结果回调block（注：topContactLists为会话seesionId）
 */
- (void)getTopSessionLists:(void(^)(ECError *error, NSArray *topContactLists))completion;

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
@end
