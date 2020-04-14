
//
//  AppModel.m
//  AppModel
//
//  Created by wangming on 16/7/25.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "CoreModel.h"
#import "NSDictionary+Ext.h"
#import "UIKitConfiManager.h"
#import "EmojiConvertor.h"

#import "IMCommon.h"

#import "Common.h"
#import "RXRevokeMessageBody.h"
#import "KitGroupInfoData.h"
#import "KitGroupMemberInfoData.h"
#import "KitDialingData.h"

#import <zlib.h>
#import "KCAPPAuth_string.h"
#import "KCConstants_API.h"

#import <PushKit/PushKit.h>
#import <PushKit/PKPushRegistry.h>
// hanwei start
#import "AlertSheet.h"
// hanwei end


#import "KitGlobalClass.h"
#import "UIAlertView+Ext.h"
#import "NSString+Ext.h"
#import "HXSpecialData.h"
#import "RXMyFriendList.h"
#import "HXAddnewFriendList.h"
#import "HXInviteCountData.h"
#import <AudioToolbox/AudioServices.h>
#import <AudioToolbox/AudioToolbox.h>

//wangming add
#import "HYTApiClient.h"
#import "HYTApiClient+Ext.h"
//wangming end

//add yuxp
#import "HXMyFriendList.h"
#import "HXInviteCountData.h"
//end yuxp

#import "RXCommonDialog.h"

#import "ECMessage+Ext.h"
#import "NSDate+Ext.h"
#import "KitCompanyAddress.h"

/// eagle
#if IsHaveYHCConference
#import "YHCConference.h"
#import "YHCOnConferenceViewController.h"
#import "YHCConferenceAnswerViewController.h"
#import "YHCECSDKManager.h"
#endif

#define KNOTIFICATION_DownloadMessageCompletion   @"KNOTIFICATION_DownloadMessageCompletion"
#define KNOTIFICATION_ReceiveMessageDelete   @"KNOTIFICATION_ReceiveMessageDelete"
#define KNOTIFICATION_IsReadMessage    @"KNOTIFICATION_IsReadMessage"

//恒信另一端修改密码通知消息 userData内参数字段名称

#define UpdatePwdPBSIM @"updatePwdPBSIM"
//恒信特别关注多端同步 userData内参数字段名称
#define kSpecialSynNotice_CustomType @"customtype=250" //标识

#import "DataBaseManager.h"

#import "YZMonitorRunloop.h"

#if IsHaveYHCConference
@interface AppModel()<CoreModelDelegate,ECDeviceDelegate,ComponentDelegate,YHCPlugDelegate,YHCConferenceDelegate>
#else

@interface AppModel()<CoreModelDelegate,ECDeviceDelegate,ComponentDelegate>
#endif
@property (nonatomic, strong) CoreModel* coreModel;

@property (nonatomic, assign) NSInteger offlineCount;
@property (nonatomic, assign) NSInteger revOfflineCount;

@property (nonatomic, assign) BOOL appIsActive; //是否在前台
@property (nonatomic, assign) BOOL isB2F;
@property (nonatomic,assign)BOOL isGroupNotice;

@property (nonatomic, strong) NSDate* preDate;

@property(nonatomic,assign)BOOL isRequestVersionSucceed;//是否检测版本成功
@property(nonatomic,assign)BOOL isLoading;//是否正在请求
@property(nonatomic,strong)NSTimer *vibrationTimer;

@property (nonatomic, strong) UILocalNotification * localNoti;//本地推送通知（用于pushkit）
@property (nonatomic, copy) NSDictionary * loginInfo;
@property (nonatomic, assign) BOOL terminate;//判断应用是否杀进程
// 点对点通话的数据
@property (nonatomic, strong) NSString *callid;
@property (nonatomic, strong) NSString *caller;
@property (nonatomic, strong) NSString *callerphone;
@property (nonatomic, strong) NSString *callername;
@property (nonatomic ,assign) CallType calltype;
@property (nonatomic, strong) UIAlertView *closeConfFirst;

/// eagle 有会
@property (nonatomic, strong) NSMutableDictionary* confStateDic;
@property (nonatomic, strong) NSString* account;

//第一次从plist读取 之后都从内存里读
@property (nonatomic, assign) CGFloat themeFontSizeMiddle;
@property (nonatomic, assign) CGFloat themeFontSizeSmall;


@property (nonatomic,strong) NSMutableArray *offLineMsgArray;//离线消息数组
@property (nonatomic,strong) NSMutableSet *offSessionArray;//离线消息数组
@property (nonatomic,strong) NSMutableArray *offLineMessageNotifyArray;//离线消息处理（撤回、已读未读）数组

@end

@implementation AppModel
bool globalisVoipView = NO;     //电话界面是否存在

SYNTHESIZE_SINGLETON_FOR_CLASS(AppModel);
- (id)init {

    if (self = [super init]) {
        self.coreModel = [CoreModel sharedInstance];
        self.coreModel.delegate = self;
        self.appData = [[AppData alloc] init];
        self.interphoneArray = [NSMutableArray array];

        NSString *themePath = [[NSBundle mainBundle] pathForResource:@"themeFont.plist" ofType:nil];
        NSDictionary *themeDict = [NSDictionary dictionaryWithContentsOfFile:themePath];
        self.themeFontSizeLarge = [themeDict[@"large"] floatValue];
        self.themeFontSizeMiddle = [themeDict[@"middle"] floatValue];
        self.themeFontSizeSmall = [themeDict[@"small"] floatValue];
        self.selectedThemeFontSize = 0;
//        [self getMsgMute];
        /// eagle 有会
#if IsHaveYHCConference
        [YHCConference sharedInstance].delegate = self;
#endif
        [SVProgressHUD setMinimumDismissTimeInterval:2.0];//提示框显示时间
        [DDDynamicLogLevel ddSetLogLevel:4];//日志级别
        
        self.offLineMsgArray = [NSMutableArray new];
        self.offSessionArray = [NSMutableSet new];
        self.offLineMessageNotifyArray = [NSMutableArray new];
#ifdef DEBUG
        // 卡顿检测
        [[YZMonitorRunloop sharedInstance] startMonitor];
#endif
       
    }
    return self;
}

- (void)initServerAddr {
    NSString *xmlBundle = [[NSBundle mainBundle] pathForResource:@"RXCCPSDKBundle" ofType:@"bundle"];
    NSString *xmlPath = [xmlBundle stringByAppendingPathComponent:kAPI_APPXMLPATH_XML];
    NSData *xmlData = [NSData dataWithContentsOfFile:xmlPath];

    NSMutableString *document = [[NSMutableString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    
    NSString *result = [[NSString alloc] initWithFormat:@"%@",document];
    NSError *error = nil;
    
    NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",kAPI_APPXMLPATH_CCPSDKBundle,kAPI_APPXMLPATH_XML]];
    [result writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    //服务器配置文件夹
    NSString * config = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"config.data"];
    bool flag = [result writeToFile:config atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if(flag){
        [[ECDevice sharedInstance] SwitchServerEvn:NO];
    }
}

- (void)setLoginInfo:(NSDictionary *)loginInfo {
    
    [[NSUserDefaults standardUserDefaults] setObject:loginInfo forKey:@"RL_loginInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDictionary *)loginInfo {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"RL_loginInfo"];
}

- (void)setTerminate:(BOOL)terminate {
    [[NSUserDefaults standardUserDefaults] setBool:terminate forKey:@"RL_Terminate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)terminate {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"RL_Terminate"];
}


-(NSString*)getMyAccount{
    return [self.appData.userInfo objectForKey:Table_User_account];
}

-(id)runModuleFunc:(NSString*)moduleName :(NSString*)funcName :(NSArray*)parms{
    return [self runModuleFunc:moduleName :funcName :parms hasReturn:YES];
}

-(id)runModuleFunc:(NSString *)moduleName :(NSString *)funcName :(NSArray *)parms hasReturn:(BOOL)hasReturn{
    id ret = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id rxModule = [self getModule:moduleName];
    if (rxModule) {
        if ([self moduleIsHaveFunc:rxModule FuncName:funcName]) {
            if (hasReturn) {
                if (parms == nil || parms.count ==0) {
                    ret = [rxModule performSelector:NSSelectorFromString(funcName)];
                }else if (parms.count == 1){
                    ret = [rxModule performSelector:NSSelectorFromString(funcName) withObject:parms[0]];
                }else if ([parms count] == 2){
                    ret = [rxModule performSelector:NSSelectorFromString(funcName) withObject:parms[0] withObject:parms[1]];
                }
            }else{
                if (parms == nil || [parms count] == 0) {
                    [rxModule performSelector:NSSelectorFromString(funcName)];
                }else if ([parms count] == 1){
                    [rxModule performSelector:NSSelectorFromString(funcName) withObject:parms[0]];
                }else if ([parms count] == 2){
                    [rxModule performSelector:NSSelectorFromString(funcName) withObject:parms[0] withObject:parms[1]];
                }
            }
        }
    }
#pragma clang diagnostic pop
    return ret;
}


#pragma mark PushKit
//c、Registering for VoIP push notifications
- (void) PushKitRegistry {
    //pushKit注册
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    // Create a push registry object
    PKPushRegistry * voipRegistry = [[PKPushRegistry alloc] initWithQueue: mainQueue];
    // Set the registry's delegate to self
    voipRegistry.delegate = self;
    // Set the push type to VoIP
    voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP];
    
    DDLogInfo(@"======================== Regist VoIP push ");
}


//d、Handling updated push notification credentials
- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials:(PKPushCredentials *)credentials forType:(PKPushType)type {
    NSString *pushToken = [[[[credentials.token description]
                             stringByReplacingOccurrencesOfString:@"<" withString:@""]
                            stringByReplacingOccurrencesOfString:@">" withString:@""]
                           stringByReplacingOccurrencesOfString:@" " withString:@""] ;
    DDLogInfo(@"pushKitToken = %@", pushToken);

    [[ECDevice sharedInstance] pushRegistry:registry didUpdatePushCredentials:credentials forType:type];
}

//e、Handling incoming push notifications
- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(PKPushType)type {
    
    if (!self.terminate) {
        [self loginSDK:self.loginInfo :^(NSError *error) {
            DDLogInfo(@"pushKit登录状态 %d",(int)error.code);
        }];
        DDLogInfo(@"============== app在后台收到pushkit推送，自动登录");
    } else {
        [self setTerminate:NO];
        DDLogInfo(@"============== app杀掉进程收到pushkit推送");
    }
    DDLogInfo(@"VoipPush content %@,%@", payload.dictionaryPayload,type);
    [[ECDevice sharedInstance] applicationBeginBackgroundTask:^{
        DDLogInfo(@"==================== voip推送后台启动应用，3分钟后挂起，底层做3分钟检测强制断开TCP");
        [[Common sharedInstance] stopShakeSoundVibrate];
    }];
}

- (void)pushRegistry:(PKPushRegistry *)registry didInvalidatePushTokenForType:(PKPushType)type {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self setTerminate:YES];
    DDLogInfo(@"========================== app杀掉进程");
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self setTerminate:NO];
    DDLogInfo(@"========================== app退回桌面");
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    DDLogInfo(@"===================== 进入应用，就关闭所有本地推送和持续震动");
    [[Common sharedInstance] stopShakeSoundVibrate];
    [self cancleVoipPush:YES];
}


- (void)presentLocalNoti:(NSDictionary *)dict {
    if (iOS10 && CallKitAuth) {
        return;
    }
    //收到苹果呼叫推送时，只创建本地推送对象，等收到呼叫请求再弹出本地呼叫推送、以及持续震动
    DDLogInfo(@"本地推送内容 %@",dict);
    
    NSString * pushPromptStr = ([dict[@"callType"] integerValue] == 1)?languageStringWithKey(@"发来一个视频呼叫"):languageStringWithKey(@"发来一个语音呼叫");
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        //创建一个本地推送
        _localNoti = [[UILocalNotification alloc] init];
        //推送声音
        _localNoti.soundName = @"CCPSDKBundle.bundle/call.caf";
        //内容
        _localNoti.alertBody = [NSString stringWithFormat:@"%@:%@",dict[@"nickname"],pushPromptStr];
        //显示在icon上的红色圈中的数子
        _localNoti.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
        //设置userinfo方便在之后需要撤销的时候使用
        NSDictionary *infoDic = [NSDictionary dictionaryWithObjectsAndKeys:dict[@"caller"],@"caller",dict[@"callid"],@"callid",nil];
        _localNoti.userInfo = infoDic;
        //添加推送到uiapplication
        [[UIApplication sharedApplication] presentLocalNotificationNow:_localNoti];
        
        DDLogInfo(@"====================== 添加本地推送 %@",_localNoti);
    });
}

- (void)cancleVoipPush:(BOOL)isEnterApp {
    DDLogInfo(@"====================== 关闭本地推送 isEnterApp = %d %@",isEnterApp,_localNoti);
    if (_localNoti) {
        [[UIApplication sharedApplication] cancelLocalNotification:_localNoti];
        _localNoti = nil;
        //收到呼叫推送时，点击进入APP关闭推送后，播放呼叫铃声
        if (isEnterApp) {
            [[Common sharedInstance] playAVAudioIncomingCall];
        }
    }
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

//#if CallKitAuth
//- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray * __nullable restorableObjects))restorationHandler NS_AVAILABLE_IOS(8_0){
//
//    INInteraction *interaction = userActivity.interaction;
//    INIntent *intent = interaction.intent;
//
//    if ([userActivity.activityType isEqualToString:@"INStartAudioCallIntent"])
//    {
//        INPerson *person = [(INStartAudioCallIntent *)intent contacts][0];
//        CXHandle *handle = [[CXHandle alloc] initWithType:(CXHandleType)person.personHandle.type value:person.personHandle.value];
//
////        [[CallKitManager sharedInstance] startCallAction:handle isVideo:NO];
//        return YES;
//    } else if([userActivity.activityType isEqualToString:@"INStartVideoCallIntent"]) {
//        INPerson *person = [(INStartVideoCallIntent *)intent contacts][0];
//        CXHandle *handle = [[CXHandle alloc] initWithType:(CXHandleType)person.personHandle.type value:person.personHandle.value];
//
////        [[CallKitManager sharedInstance] startCallAction:handle isVideo:YES];
//        return YES;
//    }
//
//    if (![AppModel sharedInstance].loginstate) {
//        return YES;
//    }else{
//        return NO;
//    }
//}
//#endif


#pragma 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // 将获取到的token传送消给SDK，用于苹果推息使用
    const unsigned *tokenBytes = (const unsigned *)[deviceToken bytes];
    NSString *token = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                       ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                       ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                       ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    DDLogInfo(@"IMToken = %@",token);
    [[ECDevice sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}


-(BOOL)moduleIsHaveFunc:(id)module FuncName:(NSString*)funcName
{
    return [module respondsToSelector:NSSelectorFromString(funcName)];
}

- (id)getModule:(NSString *)moduleName{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [NSClassFromString(moduleName) performSelector:NSSelectorFromString(@"sharedInstance")];
#pragma clang diagnostic pop
}

-(void)start{
    
}

-(void)showErrorWithStatus:(NSString *)str{
    
}

- (void)setDataWithType:(NSString *)type withData:(id)data withCover:(BOOL)isCover {
    
}

-(void)reLogin:(void(^)(NSError* error)) LoginCompletion{
    
    [self.coreModel reLogin:^(NSError *error) {
        if (error.code == 200) {
            self.loginstate = YES;
              [[NSNotificationCenter defaultCenter] postNotificationName:@"KNOTIFICATION_onSDKConnected" object:[ECError errorWithCode:ECErrorType_NoError]];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onConnected object:[ECError errorWithCode:ECErrorType_NoError]];
            
              [self getConferenceAppSetting];
        }
        else{
            self.loginstate = NO;
        }
        LoginCompletion(error);
    }];
}

-(void)loginSDK:(NSDictionary*)loginInfo :(void(^)(NSError* error)) LoginCompletion{
    
    //切换帐号清理数据库路径
    if (![loginInfo[@"account"] isEqualToString:self.loginInfo[@"account"]]) {
        [[DataBaseManager sharedInstance] clearAllSqliteData];
    }
    [AppModel sharedInstance].isHaveGetTopList = NO;
    NSMutableDictionary * loginDic = [NSMutableDictionary dictionaryWithCapacity:0];
    [loginDic setDictionary:loginInfo];
    [loginDic setObject:[NSNumber numberWithInt:2] forKey:@"mode"];
    [self setLoginInfo:loginDic];
    self.account = [loginInfo objectForKey:Table_User_account];
    
    
    
    [self.coreModel login:loginInfo :^(NSError *error) {
        self.appData.userInfo = loginInfo;
        if (error.code == 200) {
            //            if ([[AppModel sharedInstance] getCondecEnabelWithCodec:Codec_OPUS16]) {
            [[AppModel sharedInstance] setCodecEnabledWithCodec:Codec_OPUS16 andEnabled:NO];
            ////            }
            [[AppModel sharedInstance] setAudioCodecRed:1];
            
            NSArray *arr = [[NSUserDefaults standardUserDefaults]objectForKey:CodecSetArr];
            for (int i=0; i<arr.count; i++) {
                NSDictionary *dic = arr[i];
                if ([dic hasValueForKey:@"res"]) {
                    BOOL res = [dic[@"res"] boolValue];
                    [self setCodecEnabledWithCodec:i andEnabled:res];
                }
            }
            /// eagle maybe 有会
            [[NSNotificationCenter defaultCenter] postNotificationName:@"KNOTIFICATION_onSDKConnected" object:[ECError errorWithCode:ECErrorType_NoError]];
             [self getConferenceAppSetting];
            self.loginstate = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onConnected object:[ECError errorWithCode:ECErrorType_NoError]];
            [[AppModel sharedInstance] runModuleFunc:@"FusionMeeting" :@"getConferenceAppSetting" :nil];
        } else {
            self.loginstate = NO;
        }
        if (LoginCompletion) {
            LoginCompletion(error);
        }
    }];
}

- (void)logout:(void(^)(NSError *error))LogoutCompletion{
    [self.coreModel logout:^(NSError *error) {
        if (error.code == 200) {
            self.loginstate = NO;
        }
        [self runModuleFunc:@"YHCDataBaseManager" :@"setDataBaseToNil" :nil hasReturn:NO];
        [self runModuleFunc:@"YHCChat" :@"setDataBaseToNil" :nil hasReturn:NO];

        if (LogoutCompletion) {
            LogoutCompletion(error);
        }
    }];
}
#pragma mark - 有会
-(void)getConferenceAppSetting{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id YHCConference = [NSClassFromString(@"YHCConference") performSelector:NSSelectorFromString(@"sharedInstance")];
    if (YHCConference) {
        if([YHCConference respondsToSelector:NSSelectorFromString(@"getConferenceAppSetting:")])
            [YHCConference performSelector:NSSelectorFromString(@"getConferenceAppSetting:")withObject:nil];
    }
#pragma clang diagnostic pop
}
- (UIViewController *)activityViewController
{
    UIViewController* activityViewController = nil;
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if(window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow *tmpWin in windows)
        {
            if(tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    NSArray *viewsArray = [window subviews];
    if([viewsArray count] > 0)
    {
        UIView *frontView = [viewsArray objectAtIndex:0];
        
        id nextResponder = [frontView nextResponder];
        
        if([nextResponder isKindOfClass:[UIViewController class]])
        {
            activityViewController = nextResponder;
        }
        else
        {
            activityViewController = window.rootViewController;
        }
    }
    
    return activityViewController;
}
// 会议中来了VOIP通话，还没接听VOIP，对方就挂断了
-(void)voipEnd{
    [self.closeConfFirst dismissWithClickedButtonIndex:[self.closeConfFirst cancelButtonIndex] animated:YES];
}
// 结束会议之后开始VOIP通话
-(void)afterhasCloseConfAndAcceptVoipCall{
    if (self.callid) {
        [self onIncomingCallReceived:self.callid withCallerAccount:self.caller withCallerPhone:self.callerphone withCallerName:self.callername withCallType:self.calltype];
    }
}
- (NSString*)onIncomingCallReceived:(NSString*)callid withCallerAccount:(NSString *)caller withCallerPhone:(NSString *)callerphone withCallerName:(NSString *)callername withCallType:(CallType)calltype{
    if ([AppModel sharedInstance].isInConf) {
        // 判断是否在会议中，退出会议
        __block typeof(self) weakSelf = self;
        NSString *title = languageStringWithKey(@"通话通知");
        NSString *contentStr = languageStringWithKey(@"是否先结束会议，再接听通话");
        
        self.callid = callid;
        self.callerphone = callerphone;
        self.caller = caller;
        self.callername =callername;
        self.calltype = calltype;
        
        if (self.closeConfFirst) {
            return @"";
        }
        
        UIAlertView *alertView = [UIAlertView showAlertView:title message:contentStr click:^{
            weakSelf.closeConfFirst = nil;
            [[NSNotificationCenter defaultCenter]postNotificationName:kNotification_CloseConf object:nil];//hasCloseConf
            return;
            
            UIViewController* view = [self activityViewController];
            if ([[view class] isKindOfClass:[UINavigationController class] ]&& !globalisVoipView) {
                UIViewController *vc = (RXBaseNavgationController *)view;
                [vc dismissViewControllerAnimated:NO completion:nil];
            }
            
            if(globalisVoipView) {
                //通话过程中直接挂断
                [[CoreModel sharedInstance] releaseCall:callid andReason:ECErrorType_CallBusy];
                // 通话中 需要给自己发送通话记录的消息
                return ;
            }
            
            KitDialingInfoData* callInfo = [[KitDialingInfoData alloc] init];
            callInfo.callid = callid;
            callInfo.callType = calltype;
            callInfo.callDirect = EIncoming;//呼叫方向
            callInfo.voipCallStatus = 0;//呼叫状态
            self.appData.curVoipCall = callInfo;
            
            //没有名字的问题
            NSString *callerName = callername;
            if (callerName.length==0 && caller.length > 0) {
                callerName = [[[AppModel sharedInstance] getDicWithId:caller withType:0] objectForKey:Table_User_member_name];
            }
            
            id ret;
            NSDictionary* dict;
            //视频通话
            if(calltype==VIDEO) {
                dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"callType",caller,@"caller",callerName,@"nickname",callid,@"callid",[NSNumber numberWithInt:EIncoming],@"callDirect",nil];
                ret = [weakSelf runModuleFunc:@"Dialing" :@"startCallViewWithDict:" :[NSArray arrayWithObject:dict]];
            } else {
                //语音电话
                dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"0",@"callType",caller,@"caller",callerName,@"nickname",callid,@"callid",[NSNumber numberWithInt:EIncoming],@"callDirect",nil];
                ret = [weakSelf runModuleFunc:@"Dialing" :@"startCallViewWithDict:" :[NSArray arrayWithObject:dict]];
            }
            
            if (isOpenPushKit && [UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
                [weakSelf presentLocalNoti:dict];
                [[Common sharedInstance] startVibrate:YES];
                
            } else {
                [[Common sharedInstance] playAVAudioIncomingCall];
                [[Common sharedInstance] startVibrate:NO];
            }
            
            //            return ret?@"";//:nil;
        } cancel:^{
            weakSelf.closeConfFirst = nil;
            [[CoreModel sharedInstance] releaseCall:callid andReason:ECErrorType_CallBusy];
        }];
        [alertView show];
        self.closeConfFirst = alertView;
        return nil;
    }
    
    UIViewController* view = [self activityViewController];
    if ([[view class] isKindOfClass:[UINavigationController class]] && !globalisVoipView) {
        UIViewController *vc = (RXBaseNavgationController *)view;
        [vc dismissViewControllerAnimated:NO completion:nil];
    }
    
    if(globalisVoipView) {
        //通话过程中直接挂断
        [[CoreModel sharedInstance] releaseCall:callid andReason:ECErrorType_CallBusy];
        return @"";
    }
    
    KitDialingInfoData* callInfo = [[KitDialingInfoData alloc] init];
    callInfo.callid = callid;
    callInfo.callType = calltype;
    callInfo.callDirect = EIncoming;//呼叫方向
    callInfo.voipCallStatus = 0;//呼叫状态
    self.appData.curVoipCall = callInfo;
    
    //没有名字的问题
    if (callername.length==0 && caller.length > 0) {
        callername = [[[AppModel sharedInstance] getDicWithId:caller withType:0] objectForKey:Table_User_member_name];
    }
    
    id ret;
    NSDictionary* dict;
    //视频通话
    if(calltype==VIDEO) {
        dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"1",@"callType",caller,@"caller",callername,@"nickname",callid,@"callid",[NSNumber numberWithInt:EIncoming],@"callDirect",nil];
        ret = [self runModuleFunc:@"Dialing" :@"startCallViewWithDict:" :[NSArray arrayWithObject:dict]];
    } else {
        //语音电话
        dict = [[NSDictionary alloc] initWithObjectsAndKeys:@"0",@"callType",caller,@"caller",callername,@"nickname",callid,@"callid",[NSNumber numberWithInt:EIncoming],@"callDirect",nil];
        ret = [self runModuleFunc:@"Dialing" :@"startCallViewWithDict:" :[NSArray arrayWithObject:dict]];
    }
    
    if (isOpenPushKit && [UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        [self presentLocalNoti:dict];
        [[Common sharedInstance] startVibrate:YES];
        
    } else {
        [[Common sharedInstance] playAVAudioIncomingCall];
        [[Common sharedInstance] startVibrate:NO];
    }
    
    return ret?@"":nil;
}


/**
 @brief 有会议呼叫邀请
 @param callid      会话id
 @param calltype    呼叫类型
 @param meetingData 会议的数据
 */
-(NSString *)onMeetingCallReceived:(NSString *)callid withCallType:(CallType)calltype withMeetingData:(NSDictionary *)meetingData
{
    
    if ([AppModel sharedInstance].isInVoip) {
        if (self.closeConfFirst) {
            return @"";
        }
        // 判断是否在会议中，退出会议
        __block typeof(self) weakSelf = self;
        NSString *title = languageStringWithKey(@"有新消息过来");
        NSString *contentStr = languageStringWithKey(@"是否先结束会议，再接听通话");
        UIAlertView *alertView = [UIAlertView showAlertView:title message:contentStr click:^{
            weakSelf.closeConfFirst = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_CloseVoip object:nil];
            
            UIViewController* view = [weakSelf activityViewController];
            if ([[view class]isKindOfClass:[UINavigationController class]] && !globalisVoipView)
            {
                UIViewController *vc = (RXBaseNavgationController *)view;
                [vc dismissViewControllerAnimated:NO completion:nil];
            }
            if(globalisVoipView)
            {
                //通话过程中直接挂断
                [[CoreModel sharedInstance] releaseCall:callid andReason:ECErrorType_CallBusy];
                return ;
            }
            
            if ((!callid)||(!meetingData)) {
                return ;
            }
            
            KitDialingInfoData* callInfo = [[KitDialingInfoData alloc] init];
            callInfo.callid = callid;
            callInfo.callType = calltype;
            callInfo.callDirect = EIncoming;//呼叫方向
            callInfo.voipCallStatus = 0;//呼叫状态
            self.appData.curVoipCall = callInfo;
            
            id ret ;
            if(calltype==VIDEO){
                ret = [[AppModel sharedInstance] runModuleFunc:@"VideoMeeting" :@"getVideoMeetingAnswerViewWithCallId:withMeetingData:" :@[callid,meetingData]];
                
            }else{
                ret = [[AppModel sharedInstance] runModuleFunc:@"VoiceMeeting" :@"getVoiceMeetingAnswerViewWithCallId:withMeetingData:" :@[callid,meetingData]];
                
            }
            return ;
            //            return ret?@"":nil;
        } cancel:^{
            weakSelf.closeConfFirst = nil;
            [[CoreModel sharedInstance] releaseCall:callid andReason:ECErrorType_CallBusy];
        }];
        [alertView show];
        self.closeConfFirst = alertView;
        return @"";
    }
    
    UIViewController* view = [self activityViewController];
    if ([NSStringFromClass([view class]) isEqualToString:@"UINavigationController"] && !globalisVoipView)
    {
        UIViewController *vc = (RXBaseNavgationController *)view;
        [vc dismissViewControllerAnimated:NO completion:nil];
    }
    if(globalisVoipView)
    {
        //通话过程中直接挂断
        [[CoreModel sharedInstance] releaseCall:callid andReason:ECErrorType_CallBusy];
        return @"";
    }
    
    if ((!callid)||(!meetingData)) {
        return nil;
    }
    
    KitDialingInfoData* callInfo = [[KitDialingInfoData alloc] init];
    callInfo.callid = callid;
    callInfo.callType = calltype;
    callInfo.callDirect = EIncoming;//呼叫方向
    callInfo.voipCallStatus = 0;//呼叫状态
    self.appData.curVoipCall = callInfo;
    
    id ret ;
    if(calltype==VIDEO){
        ret = [[AppModel sharedInstance] runModuleFunc:@"VideoMeeting" :@"getVideoMeetingAnswerViewWithCallId:withMeetingData:" :@[callid,meetingData]];
        
    }else{
        ret = [[AppModel sharedInstance] runModuleFunc:@"VoiceMeeting" :@"getVoiceMeetingAnswerViewWithCallId:withMeetingData:" :@[callid,meetingData]];
        
    }
    return ret?@"":nil;
}

- (void)onReceiveInterphoneMeetingMsg:(ECInterphoneMeetingMsg *)message {
//    EC_SDKCONFIG_AppLog(@"onReceiveInterphoneMeetingMsg: type=%d", (int)message.type);
    
    if (message.type == Interphone_INVITE) {
        if (message.interphoneId.length > 0) {
            BOOL isExist = NO;
            for (ECInterphoneMeetingMsg *interphone in self.interphoneArray) {
                if ([interphone.interphoneId isEqualToString:message.interphoneId]) {
                    isExist = YES;
                    break;
                }
            }
            if (!isExist) {
                [self.interphoneArray addObject:message];
            }
        }
    } else if (message.type == Interphone_OVER) {
        if (message.interphoneId.length > 0) {
            for (ECInterphoneMeetingMsg *interphone in self.interphoneArray) {
                if ([interphone.interphoneId isEqualToString:message.interphoneId]) {
                    [self.interphoneArray removeObject:interphone];
                    break;
                }
            }
        }
    }else if (message.type == Interphone_JOIN) {
        if (message.interphoneId.length > 0) {
            BOOL isExist = NO;
            for (ECInterphoneMeetingMsg *interphone in self.interphoneArray) {
                if ([interphone.interphoneId isEqualToString:message.interphoneId]) {
                    isExist = YES;
                    break;
                }
            }
            if (!isExist) {
                [self.interphoneArray addObject:message];
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_ReceiveInterphoneMeetingMsg object:message];
}

#pragma mark 语音会议代理函数
-(void)onReceiveMultiVoiceMeetingMsg:(ECMultiVoiceMeetingMsg *)msg
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"onReceiveMultiVoiceMeetingMsg" object:msg];
}

#pragma mark 多路视频会议代理函数
-(void)onReceiveMultiVideoMeetingMsg:(ECMultiVideoMeetingMsg *)msg
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"onReceiveMultiVideoMeetingMsg" object:msg];
}
#pragma mark 接收客服消息代理函数
-(void)onReceiveDeskMessage:(ECMessage*)message {
    
}

/**
 @brief 收到dtmf
 @param callid 会话id
 @param dtmf   键值
 */
- (void)onReceiveFrom:(NSString*)callid DTMF:(NSString*)dtmf{
    
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
    NSDictionary *dic = @{@"callid":callid,@"voip":voip,@"isConference":[NSNumber numberWithBool:isConference],@"width":[NSNumber numberWithInteger:width],@"height":[NSNumber numberWithInteger:height]};
    DDLogInfo(@"视频分辨率发生变化 dic = %@",dic);
    if (([voip hasSuffix:@"@20"] || [voip hasSuffix:@"@22"])  && width<height) {
        NSLog(@"onCallVideoRatioChanged voip = %@ width = %ld,height = %ld",voip,(long)width, (long)height);
        return;
        
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:kNOTIFICATION_onCallVideoRatioChanged object:dic];
}

/**
 @brief 收到对方切换音视频的请求
 @param callid  会话id
 @param requestType 请求音视频类型 视频:需要响应 音频:请求删除视频（不需要响应，双方自动去除视频）
 */
- (void)onSwitchCallMediaTypeRequest:(NSString *)callid withMediaType:(CallType)requestType{
    
}

/**
 @brief 收到对方应答切换音视频请求
 @param callid   会话id
 @param responseType 回复音视频类型
 */
- (void)onSwitchCallMediaTypeResponse:(NSString *)callid withMediaType:(CallType)responseType{
    
}

/**
 @brief 需要获取的离线呼叫CallId (用于苹果推送下来的离线呼叫callid)
 @return apns推送的过来的callid
 */
- (NSString*)onGetOfflineCallId{
    return nil;
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


#pragma mark 各种回调


-(void)onLogInfo:(NSString*)log {
    DDLogDebug(@"AppModel LOG:%@",log);
}

/**
 @brief 连接状态接口
 @discussion 监听与服务器的连接状态 V5.0版本接口
 @param state 连接的状态
 @param error 错误原因值
 */
-(void)onConnectState:(ECConnectState)state  failed:(ECError*)error{
    
    if (state == State_ConnectSuccess) {
        self.loginstate = YES;
    }
    else{
        self.loginstate = NO;
    }
    
    if ([UIApplication sharedApplication].statusBarFrame.size.height == 40) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"KNOTIFICATION_statusBarChanged" object:nil];
    }
    //被踢下线
    if([error errorCode]==ECErrorType_KickedOff)
    {
        // 设置退出会议和通话
        self.isInConf = NO;
        self.isInVoip = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationKickedOff object:error.errorDescription];
        
        /// eagle 有会
#if IsHaveYHCConference
        if ([YHCConference sharedInstance].meettingVC) {
            YHCOnConferenceViewController *meetingVC = (YHCOnConferenceViewController *)[YHCConference sharedInstance].meettingVC;
            [meetingVC removeSelfFromWidow];
            
        }else if ([YHCConference sharedInstance].answerVC){
            [(YHCConferenceAnswerViewController *)[YHCConference sharedInstance].answerVC removeSelfFromWidow];
        }
#endif
    }
    
    [NSError errorWithDomain:error.description?error.description:@"" code:error.errorCode userInfo:nil];
    
    //    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(onConnectState:failed:)]) {
    //        return [self.appModelDelegate onConnectState:state failed:error];
    //    }
    
    switch (state) {
        case State_ConnectSuccess:
        {
            NSDate *dateTime =[NSDate date];
            NSUserDefaults *timeUser =  [NSUserDefaults standardUserDefaults];
            [timeUser removeObjectForKey:connetServerTime];
            [timeUser setObject:dateTime forKey:connetServerTime];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onConnected object:[ECError errorWithCode:ECErrorType_NoError]];
            
            DDLogInfo(@"连接sdk成功----------");
        }
            break;
        case State_Connecting:
        {
            //zmf 暂时屏蔽连接中的问题
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onConnected object:[ECError errorWithCode:ECErrorType_Connecting]];
            DDLogInfo(@"连接sdk中----------");
            
        }
            break;
        case State_ConnectFailed:
        {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onConnected object:error];
            DDLogInfo(@"连接sdk失败----------");
            
        }
            break;
        default:
            break;
    }
    
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(onConnectState:failed:)]) {
        [self.appModelDelegate onConnectState:state failed:error];
    }
}

#pragma mark -  群组相关
/**
 @brief 接收群组相关消息
 @discussion 参数要根据消息的类型，转成相关的消息类；
 解散群组、收到邀请、申请加入、退出群聊、有人加入、移除成员等消息
 @param groupMsg 群组消息
 */
-(void)onReceiveGroupNoticeMessage:(ECGroupNoticeMessage *)groupMsg {
    //keven ADD
    // 时间全部转换成本地时间
    if(!groupMsg.dateCreated){
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval tmp = [date timeIntervalSince1970] * 1000;
        groupMsg.dateCreated = [NSString stringWithFormat:@"%lld", (long long)tmp];
    }
    //keven END

    //keven ADD
    //    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    //    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    //    groupMsg.dateCreated = [NSString stringWithFormat:@"%lld", (long long)tmp];
    //keven END
    
    if (groupMsg.messageType == ECGroupMessageType_Dissmiss) {//群组解散
       // 不需要删除本地消息
        //[[Common sharedInstance] deleteAllMessageOfSession:groupMsg.groupId];
        
        //按需求  解散群组的时候 还要保留群组信息 手动删除的时候 删除群组信息
//        //群组解散  删除缓存
//        [KitGroupInfoData deleteGroupInfoDataDB:groupMsg.groupId];
        NSArray *groups = [[NSUserDefaults standardUserDefaults] objectForKey:@"NotRealGroups"];
        if (!groups) {
            groups = @[];
        }
        NSMutableArray *mArr = groups.mutableCopy;
        [mArr addObject:groupMsg.groupId];
        groups = mArr.copy;
        [[NSUserDefaults standardUserDefaults] setObject:groups forKey:@"NotRealGroups"];
        
        //删除成员缓存
        //[KitGroupMemberInfoData deleteGroupAllMemberInfoDataDB:groupMsg.groupId];
        //发送一个通知 群组被解散
        [[NSNotificationCenter defaultCenter] postNotificationName:@"groupIsDisbanded" object:groupMsg.groupId];
        //刷新一下通讯录中群列表数据
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Join_Group object:nil];
        return;
    } else if (groupMsg.messageType == ECGroupMessageType_RemoveMember) {//踢出成员
        
        ECRemoveMemberMsg *message = (ECRemoveMemberMsg *)groupMsg;
        
        if ([message.member isEqualToString:[[Common sharedInstance] getAccount]]) {//自己被踢
            [[KitMsgData sharedInstance] updateMemberStateInGroupId:groupMsg.groupId memberState:1];
            [KitGroupMemberInfoData updateRoleStateaMemberId:message.member andRole:@"3"];
            /// eagle 自己被踢出群组，不删除聊天记录
            [[Common sharedInstance] hideChatVCRightItemBarWithsessionId:groupMsg.groupId];
            [self someMemberRemoved:message withMemberName:languageStringWithKey(@"你")];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"IGetKickedOutOfGroup" object:groupMsg.groupId];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Join_Group object:nil];
        } else {
            NSString *whoName = [[[Common sharedInstance].componentDelegate getDicWithId:message.member withType:0] objectForKey:Table_User_member_name];
            if (!whoName) {
                [[ECDevice sharedInstance] getOtherPersonInfoWith:message.member completion:^(ECError *error, ECPersonInfo *person) {
                    NSString *memberName = person.nickName;
                    [self someMemberRemoved:message withMemberName:memberName];
                }];
                return;
            }
            [self someMemberRemoved:message withMemberName:whoName];
            //  [KitGroupMemberInfoData deleteGroupMemberPhoneInfoDataDB:message.member withGroupId:groupMsg.groupId];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotification_removeMember_group" object:groupMsg.groupId];
    }else if(groupMsg.messageType == ECGroupMessageType_ModifyGroup){
        //群组信息修改
        //入库
        KitGroupInfoData *groupData = [[KitGroupInfoData alloc] init];
        //对比的群组消息
        KitGroupInfoData *groupinfo =[KitGroupInfoData getGroupInfoWithGroupId:groupMsg.groupId];
        ECModifyGroupMsg *groupM =(ECModifyGroupMsg *)groupMsg;//群组公告
        NSDictionary *declaredDic = groupM.modifyDic;
        BOOL b = NO;
        if([declaredDic hasValueForKey:@"groupDeclared"]){
            groupData.declared =[declaredDic objectForKey:@"groupDeclared"];
            b = YES;
        }
        groupData.groupId = groupMsg.groupId;
        groupData.groupName = groupMsg.groupName;
        groupData.createTime = groupMsg.dateCreated;
        if(groupinfo){
            groupData.type = groupinfo.type;
            groupData.memberCount = groupinfo.memberCount;
            groupData.owner = groupinfo.owner;
            groupData.isAnonymity = groupinfo.isAnonymity;
            [KitGroupInfoData upDateGroupInfo:groupinfo];
        }
        //0 群名称  1 群公告
        [self groupInfoChangeWith:groupData sender:groupM.member type:(b?1:0)];
        
        ECGroup *group = [[ECGroup alloc] init];
        group.groupId = groupMsg.groupId;
        group.name = groupMsg.groupName;
        group.createdTime = groupMsg.dateCreated;
        [[KitMsgData sharedInstance] addGroupID:group];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"KNOTIFICATION_onReceivedGroupNoticeChageGroupInfo" object:groupMsg.groupId];
        return;
    }else if (groupMsg.messageType == ECGroupMessageType_Quit){//退出群聊
        ECQuitGroupMsg *quitMsg = (ECQuitGroupMsg *)groupMsg;
        // 2017.8.11
        NSString *whoName= quitMsg.member;
        if(!KCNSSTRING_ISEMPTY(quitMsg.nickName)){
            whoName = quitMsg.nickName;
        }else{
            //            whoName = [[Common sharedInstance] getOtherNameWithPhone:quitMsg.member];
            whoName = KCNSSTRING_ISEMPTY([[Common sharedInstance] getOtherNameWithPhone:quitMsg.member])?quitMsg.member:[[Common sharedInstance] getOtherNameWithPhone:quitMsg.member];
        }
        
        if([quitMsg.member isEqualToString:[[Common sharedInstance] getAccount]]){
            //            [[KitMsgData sharedInstance]updateMemberStateInGroupId:quitMsg.groupId memberState:1];
            //            [KitGroupMemberInfoData updateRoleStateaMemberId:quitMsg.member andRole:@"3"];
            //
            //            // [self haveMemberExit:quitMsg withMemberName:[RXUser sharedInstance].username];
            //            [self haveMemberExit:quitMsg withMemberName:whoName];
            [[KitMsgData sharedInstance] updateMemberStateInGroupId:groupMsg.groupId memberState:1];
            [[Common sharedInstance] deleteAllMessageOfSession:quitMsg.groupId];
            //解散成功 删除缓存
            [KitGroupInfoData deleteGroupInfoDataDB:quitMsg.groupId];
            //删除成员缓存
            [KitGroupMemberInfoData deleteGroupAllMemberInfoDataDB:quitMsg.groupId];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"KNOTIFICATION_onReceivedGroupNotice" object:nil];
            return;
        }else if([whoName isEqualToString:quitMsg.member]){
            //证明名字本地没有缓存
            //NSString* name = [[Common sharedInstance] getOtherNameWithPhone:quitMsg.member];
            if (whoName) {
                [self haveMemberExit:quitMsg withMemberName:whoName];
            }else{
                [self haveMemberExit:quitMsg withMemberName:quitMsg.member];
            }
        }else{
            [self haveMemberExit:quitMsg withMemberName:whoName];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotification_removeMember_group" object:quitMsg.groupId];
    }else if (groupMsg.messageType == ECGroupMessageType_Invite){//邀请加入
        ECInviterMsg *message = (ECInviterMsg *)groupMsg;
        if (message.confirm == 0) {//不需要确认，直接加入
            ///更新群组成员信息
            [self queryGroupMembers:groupMsg.groupId];

            //把群消息入库 因为现在本地没有这个群的数据了
            ECGroup *group = [[ECGroup alloc] init];
            group.groupId = groupMsg.groupId;
            group.name = groupMsg.groupName;
            group.createdTime = groupMsg.dateCreated;
            [[KitMsgData sharedInstance] addGroupIDs:@[group]];
            
            [[KitMsgData sharedInstance] updateMemberStateInGroupId:groupMsg.groupId memberState:0];
            [self addInviteMsgWithGroupMsg:message name:message.nickName];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Join_Group object:nil];
        }
    }else if (groupMsg.messageType == ECGroupMessageType_ChangeAdmin){
        //群组权限更改
        ECChangeAdminMsg *groupM = (ECChangeAdminMsg *)groupMsg;
        KitGroupInfoData *groupData =[KitGroupInfoData getGroupInfoWithGroupId:groupM.groupId];
        if (groupData) {
            groupData.owner = @"";
            [KitGroupInfoData upDateGroupInfo:groupData];
        }
        KitGroupMemberInfoData *newAdmin = [[KitGroupMemberInfoData alloc] init];
        newAdmin.memberId = groupM.member;
        newAdmin.memberName = groupM.nickName;
        newAdmin.groupId = groupM.groupId;
        newAdmin.role = [NSString stringWithFormat:@"%d",(int)ECMemberRole_Admin];
        [KitGroupMemberInfoData insertGroupMemberInfoData:newAdmin];
    }else if (groupMsg.messageType == ECGroupMessageType_ReplyInvite){
        //验证邀请
        ECReplyInviteGroupMsg *message = (ECReplyInviteGroupMsg *)groupMsg;
        if(message.hasVersion > 0){
            //说明是8的消息 直接屏蔽
            return;
        }
        ECGroup *group = [[ECGroup alloc] init];
        group.groupId = message.groupId;
        group.name = message.groupName;
        group.createdTime = message.dateCreated;
        //刷新群组信息
        [[KitMsgData sharedInstance] addGroupIDs:@[group]];
        ///更新群组成员信息
        [self queryGroupMembers:groupMsg.groupId];
        [self addInviteMsgWithGroupMsg:message name:message.nickName];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_Join_Group object:nil];
        return;
    }else if (groupMsg.messageType == ECGroupMessageType_ModifyGroupMember) {//群组成员信息修改
        ECModifyGroupMemberMsg *memberMsg = (ECModifyGroupMemberMsg *)groupMsg;
        if (![memberMsg.member isEqualToString:[[Common sharedInstance] getAccount]] &&
            !KCNSSTRING_ISEMPTY(memberMsg.nickName)) {
            KitGroupMemberInfoData *data = [KitGroupMemberInfoData getGroupMemberInfoWithMemberId:memberMsg.member withGroupId:memberMsg.groupId];
            data.memberName = memberMsg.nickName;
            if ([KitGroupMemberInfoData insertGroupMemberInfoData:data]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"KNOTIFICATION_onReceivedGroupNickNameModifyNotice" object:memberMsg userInfo:nil];
            }
        }
        return;
    }else if(groupMsg.messageType == ECGroupMessageType_InviteJoin) {
        ///更新群组成员信息
        [self queryGroupMembers:groupMsg.groupId];
        //消息14
        [self addInviteMsgWithGroupMsg:groupMsg name:nil];
    }else if(groupMsg.messageType == ECGroupMessageType_ChangeMemberRole)
    {
        // 待处理
        ECChangeMemberRoleMsg *changeM = (ECChangeMemberRoleMsg *)groupMsg;
        NSString *showText = [NSString stringWithFormat:@"\"%@\"%@",changeM.nickName,languageStringWithKey(@"已成为")];
        int role = [changeM.roleDic[@"role"] intValue];
        switch (role) {
            case 1:
                showText = [showText stringByAppendingString:languageStringWithKey(@"群主")];
                break;
            case 2:
                showText = [showText stringByAppendingString:languageStringWithKey(@"管理员")];
                break;
            case 3:
                showText = [showText stringByAppendingString:languageStringWithKey(@"普通成员")];
                break;
            default:
                break;
        }
        NSMutableDictionary *userParas = [NSDictionary dictionaryWithObjectsAndKeys:@"GROUP_NOTICE",kRonxinMessageType,nil].mutableCopy;
        NSMutableArray *arr = [NSMutableArray array];
        if (!KCNSSTRING_ISEMPTY(changeM.nickName) && !KCNSSTRING_ISEMPTY(changeM.member)) {
            [arr addObject:@{changeM.nickName:changeM.member}];
        }
        [userParas setObject:[arr.yy_modelToJSONString base64EncodingString] forKey:@"groupNotice_rich_text"];
        
        NSString *userdataStr=[NSString stringWithFormat:@"UserData={%@}",[userParas coverString]];
        ECTextMessageBody *messageBody = [[ECTextMessageBody alloc] initWithText:showText];
        ECMessage *msg = [[ECMessage alloc] initWithReceiver:changeM.groupId body:messageBody];
        msg.sessionId = changeM.groupId;
        msg.from = changeM.member;
        msg.to= changeM.groupId;
        msg.isRead = YES;
        msg.userData = userdataStr;
        msg.messageState = ECMessageState_SendSuccess;
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
        msg.timestamp=[NSString stringWithFormat:@"%lld", (long long)tmp];
        messageBody.text = [[EmojiConvertor sharedInstance] convertEmojiSoftbankToUnicode:messageBody.text];
        [[KitMsgData sharedInstance] addNewMessage:msg andSessionId:self.sessionId];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ECGroupMessageChangeMemberRoleNotif" object:changeM];
    }
    [self playRecMsgSound:nil];
    self.isGroupNotice = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_update_session_im_message_num object:nil userInfo:nil];
}

//(发送消息)邀请其他人加入群组
- (void)addInviteMsgWithGroupMsg:(ECGroupNoticeMessage *)groupMsg name:(NSString *)memberName{
    NSString *memberID;//管理员
    NSString *nickname;
    
    NSMutableArray *users = [NSMutableArray array];
    if (groupMsg.messageType == ECGroupMessageType_Invite){//邀请加入
        ECInviterMsg *message = (ECInviterMsg *)groupMsg;
        memberID = message.admin;
        if (message.confirm == 0) {
            nickname = languageStringWithKey(@"你");
        } else {
            return;
        }
    }else if (groupMsg.messageType == ECGroupMessageType_ReplyInvite){
        //验证邀请
        ECReplyJoinGroupMsg *message = (ECReplyJoinGroupMsg *)groupMsg;
        memberID = message.admin;
        if (message.member && ([message.member isEqualToString:[[Common sharedInstance] getAccount]])) {
            nickname = languageStringWithKey(@"你");
        }else if(message.member){
            nickname = [[[Common sharedInstance].componentDelegate getDicWithId:message.member withType:0] objectForKey:Table_User_member_name]?:message.member;
        }
    }else if (groupMsg.messageType == ECGroupMessageType_InviteJoin){
        ECInviteJoinGroupMsg *inviteMsg = (ECInviteJoinGroupMsg *)groupMsg;
        memberID = inviteMsg.admin;

        NSMutableArray *array = [NSMutableArray new];
//        for (NSDictionary *dic in inviteMsg.members) {
////            if ([dic hasValueForKey:@"nickName"]) {
////                [array addObject:dic[@"nickName"]];
////                continue;
////            }
//            NSString *tempID = dic[@"member"];
//            if ([tempID containsString:@"#"]) {
//                NSRange range = [tempID rangeOfString:@"#"];
//                tempID = [tempID substringFromIndex:range.location + 1];
//            }
//            [array addObject:dic[@"nickName"]];
//            [users addObject:@{dic[@"nickName"]:tempID}];
////            NSString *name = [[[Common sharedInstance].componentDelegate getDicWithId:tempID withType:0] objectForKey:Table_User_member_name];
////            [array addObject:name ? :dic[@"nickName"]?:tempID];
//        }
        
        for (id dic in inviteMsg.members) {
        if ([dic isKindOfClass:ECGroupMember.class]) {
            ECGroupMember *member = dic;
            [array addObject:member.memberId];
            [users addObject:@{member.display:member.memberId}];
        } else {
            NSString *tempID = dic[@"member"];
            if ([tempID containsString:@"#"]) {
                NSRange range = [tempID rangeOfString:@"#"];
                tempID = [tempID substringFromIndex:range.location + 1];
            }
            [array addObject:dic[@"nickName"]];
            [users addObject:@{dic[@"nickName"]:tempID}];
        }
        
            nickname = [array componentsJoinedByString:@","];
        }
    }
    
    //邀请人 姓名
    memberName = [[[Common sharedInstance].componentDelegate getDicWithId:memberID withType:0] objectForKey:Table_User_member_name];
    if ([memberID isEqualToString:[Common sharedInstance].getAccount]) {
        memberName = languageStringWithKey(@"你");
    }else {
        !memberName?:[users insertObject:@{memberName:memberID} atIndex:0];
    }
    NSMutableDictionary *userParas = [NSDictionary dictionaryWithObjectsAndKeys:@"GROUP_NOTICE",kRonxinMessageType,nil].mutableCopy;
    if (!memberName) {
        [[ECDevice sharedInstance] getOtherPersonInfoWith:memberID completion:^(ECError *error, ECPersonInfo *person) {
            NSString *memberName = person.nickName;
            if (memberName.length == 0 || !memberName) {
                return;
            }
            [users insertObject:@{memberName:memberID} atIndex:0];
            [userParas setObject:[users.yy_modelToJSONString base64EncodingString] forKey:@"groupNotice_rich_text"];
            NSString *userdataStr = [NSString stringWithFormat:@"UserData={%@}",[userParas coverString]];
            [self insertGroupMsgToDataBase:groupMsg memberName:memberName nickname:nickname userData:userdataStr];
        }];
    }else{
        [userParas setObject:[users.yy_modelToJSONString base64EncodingString] forKey:@"groupNotice_rich_text"];
        NSString *userdataStr = [NSString stringWithFormat:@"UserData={%@}",[userParas coverString]];
        [self insertGroupMsgToDataBase:groupMsg memberName:memberName nickname:nickname userData:userdataStr];
    }
}
///将消息入库
- (void)insertGroupMsgToDataBase:(ECGroupNoticeMessage *)groupMsg memberName:(NSString *)memberName nickname:(NSString *)nickname userData:(NSString *)userData{
    memberName = [memberName isEqualToString:languageStringWithKey(@"你")]?memberName:[NSString stringWithFormat:@"\"%@\"",memberName];
    nickname = [nickname isEqualToString:languageStringWithKey(@"你")]?nickname:[NSString stringWithFormat:@"\"%@\"",nickname];
    NSString *text = [NSString stringWithFormat:@"%@%@%@%@",memberName,languageStringWithKey(@"邀请"),nickname,languageStringWithKey(@"加入群聊")];
    
    //二维码加群 add by keven
    ECInviterMsg *message = (ECInviterMsg *)groupMsg;
    if ([message respondsToSelector:@selector(declared)] && [message.declared isEqualToString:@"fromQRCode"]) {
        text = [NSString stringWithFormat:@"%@%@",nickname,languageStringWithKey(@"通过扫描二维码加入群组")];
    }
    //end
    
//    NSDictionary *userParas = [NSDictionary dictionaryWithObjectsAndKeys:@"GROUP_NOTICE",kRonxinMessageType,kRONGXINANON_OFF,kRonxinANON_MODE, nil];
//    NSString *userdataStr = [NSString stringWithFormat:@"UserData={%@}",[userParas coverString]];
    //keven ADD注释：将groupMs构造成ECMessage存入数据库
    ECTextMessageBody *textBody = [[ECTextMessageBody alloc] initWithText:text];
    ECMessage *msg = [[ECMessage alloc] initWithReceiver:groupMsg.groupId body:textBody];
    msg.sessionId = groupMsg.groupId;
    msg.from = groupMsg.sender;
    msg.to = groupMsg.groupId;
    msg.isRead = YES;
    msg.userData = userData;
    msg.messageState = ECMessageState_SendSuccess;
    msg.timestamp = groupMsg.dateCreated;
    textBody.text = [[EmojiConvertor sharedInstance] convertEmojiSoftbankToUnicode:textBody.text];

    [[KitMsgData sharedInstance] addNewMessage:msg andSessionId:self.sessionId];
//    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:msg];
     [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChangedTheSessionId object:msg.sessionId];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_update_session_im_message_num object:nil userInfo:nil];
}

//群组成员修改了群昵称
- (void)groupMemberModfiyGroupMemName:(KitGroupMemberInfoData *)infoData sender:(NSString *)sender{
    
    NSString *memberName = [[Common sharedInstance] getOtherNameWithPhone:sender];
    NSString *showText = [NSString stringWithFormat:@"%@ %@",memberName?memberName:sender,languageStringWithKey(@"修改了群昵称")];
    NSMutableDictionary *userParas = [NSDictionary dictionaryWithObjectsAndKeys:@"GROUP_NOTICE",kRonxinMessageType,nil].mutableCopy;
    NSMutableArray *arr = [NSMutableArray array];
    if (!KCNSSTRING_ISEMPTY(memberName) && !KCNSSTRING_ISEMPTY(sender)) {
        [arr addObject:@{memberName:sender}];
    }
    [userParas setObject:[arr.yy_modelToJSONString base64EncodingString] forKey:@"groupNotice_rich_text"];
    NSString *userdataStr = [NSString stringWithFormat:@"UserData={%@}",[userParas coverString]];
    
    ECTextMessageBody *messageBody = [[ECTextMessageBody alloc] initWithText:showText];
    
    ECMessage *msg = [[ECMessage alloc] initWithReceiver:infoData.groupId body:messageBody];
    msg.sessionId = infoData.groupId;
    msg.from = sender;
    msg.to= infoData.groupId;
    msg.isRead = YES;
    msg.userData = userdataStr;
    msg.messageState = ECMessageState_SendSuccess;
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp = [date timeIntervalSince1970] * 1000;
    msg.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    messageBody.text = [[EmojiConvertor sharedInstance] convertEmojiSoftbankToUnicode:messageBody.text];
    [[KitMsgData sharedInstance] addNewMessage:msg andSessionId:self.sessionId];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:msg];
     [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChangedTheSessionId object:msg.sessionId];
}

//群信息修改
- (void)groupInfoChangeWith:(KitGroupInfoData *)groupData sender:(NSString *)sender type:(NSInteger)type{
    [KitGroupInfoData insertGroupInfoData:groupData];
    
    NSString *memberName = [[Common sharedInstance] getOtherNameWithPhone:sender];
    
    if (groupData){//群组的话 用群设置的昵称
        KitGroupMemberInfoData *infoData = [KitGroupMemberInfoData getGroupMemberInfoWithMemberId:sender withGroupId:groupData.groupId];
        if (!KCNSSTRING_ISEMPTY(infoData.memberName)) {
            memberName = infoData.memberName;
        }
    }
    
    NSMutableDictionary *userParas = [NSDictionary dictionaryWithObjectsAndKeys:@"GROUP_NOTICE",kRonxinMessageType,nil].mutableCopy;
    NSMutableArray *arr = [NSMutableArray array];
    if (!KCNSSTRING_ISEMPTY(memberName) && !KCNSSTRING_ISEMPTY(sender)) {
        [arr addObject:@{memberName:sender}];
    }
    [userParas setObject:[arr.yy_modelToJSONString base64EncodingString] forKey:@"groupNotice_rich_text"];
    NSString *userdataStr = [NSString stringWithFormat:@"UserData={%@}",[userParas coverString]];
    
    NSString *showText;
    if (type == 0) {
        showText = [NSString stringWithFormat:@"\"%@\"%@",memberName?memberName:sender,languageStringWithKey(@"修改了群名称")];
    }else if (type == 1){
        showText = [NSString stringWithFormat:@"\"%@\"%@",memberName?memberName:sender,languageStringWithKey(@"修改了群公告")];
    }else{
        showText = [NSString stringWithFormat:@"\"%@\"%@",memberName?memberName:sender,languageStringWithKey(@"修改了群资料")];
    }
    ECTextMessageBody *messageBody = [[ECTextMessageBody alloc] initWithText:showText];
    
    ECMessage *msg = [[ECMessage alloc] initWithReceiver:groupData.groupId body:messageBody];
    msg.sessionId = groupData.groupId;
    msg.from = sender;
    msg.to= groupData.groupId;
    msg.isRead = YES;
    msg.userData = userdataStr;
    msg.messageState = ECMessageState_SendSuccess;
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    msg.timestamp=[NSString stringWithFormat:@"%lld", (long long)tmp];
    messageBody.text = [[EmojiConvertor sharedInstance] convertEmojiSoftbankToUnicode:messageBody.text];
    [[KitMsgData sharedInstance] addNewMessage:msg andSessionId:self.sessionId];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:msg];
     [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChangedTheSessionId object:msg.sessionId];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_update_session_im_message_num object:nil userInfo:nil];
}
//有人退出入库
- (void)haveMemberExit:(ECQuitGroupMsg *)quitMsg withMemberName:(NSString *)memberName{
    [KitGroupMemberInfoData deleteGroupMemberPhoneInfoDataDB:quitMsg.member withGroupId:quitMsg.groupId];
    NSMutableDictionary *userParas = [NSDictionary dictionaryWithObjectsAndKeys:@"GROUP_NOTICE",kRonxinMessageType,nil].mutableCopy;
    NSMutableArray *arr = [NSMutableArray array];
    if (!KCNSSTRING_ISEMPTY(memberName) && !KCNSSTRING_ISEMPTY(quitMsg.member)) {
        [arr addObject:@{memberName:quitMsg.member}];
    }
    [userParas setObject:[arr.yy_modelToJSONString base64EncodingString] forKey:@"groupNotice_rich_text"];
    NSString *userdataStr=[NSString stringWithFormat:@"UserData={%@}",[userParas coverString]];
    ECTextMessageBody *messageBody = [[ECTextMessageBody alloc] initWithText:[NSString stringWithFormat:@"\"%@\"%@",memberName?memberName:quitMsg.member,languageStringWithKey(@"退出群聊")]];
    ECMessage *msg = [[ECMessage alloc] initWithReceiver:quitMsg.groupId body:messageBody];
    msg.sessionId = quitMsg.groupId;
    msg.from = [self getMyAccount];
    msg.to= quitMsg.groupId;
    msg.isRead = YES;
    msg.userData = userdataStr;
    msg.messageState = ECMessageState_SendSuccess;
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    msg.timestamp=[NSString stringWithFormat:@"%lld", (long long)tmp];
    messageBody.text = [[EmojiConvertor sharedInstance] convertEmojiSoftbankToUnicode:messageBody.text];
    [[KitMsgData sharedInstance] addNewMessage:msg andSessionId:self.sessionId];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:msg];
     [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChangedTheSessionId object:msg.sessionId];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_update_session_im_message_num object:nil userInfo:nil];
}

//有人被踢出
- (void)someMemberRemoved:(ECRemoveMemberMsg *)quitMsg withMemberName:(NSString *)memberName{
    [KitGroupMemberInfoData deleteGroupMemberPhoneInfoDataDB:quitMsg.member withGroupId:quitMsg.groupId];
    NSMutableDictionary* userParas = [NSDictionary dictionaryWithObjectsAndKeys:@"GROUP_NOTICE",kRonxinMessageType,nil].mutableCopy;
    if (![memberName isEqualToString:languageStringWithKey(@"你")]) {
        NSMutableArray *arr = [NSMutableArray array];
        if (!KCNSSTRING_ISEMPTY(memberName) && !KCNSSTRING_ISEMPTY(quitMsg.member)) {
            [arr addObject:@{memberName:quitMsg.member}];
        }
        [userParas setObject:[arr.yy_modelToJSONString base64EncodingString] forKey:@"groupNotice_rich_text"];
    }
    
    NSString *userdataStr=[NSString stringWithFormat:@"UserData={%@}",[userParas coverString]];
    ECTextMessageBody *messageBody = [[ECTextMessageBody alloc] initWithText:[NSString stringWithFormat:@"\"%@\"%@",memberName?memberName:quitMsg.member, quitMsg.isDiscuss ? languageStringWithKey(@"被管理员移出讨论组"): languageStringWithKey(@"被管理员移出群聊")]];
    ECMessage *msg = [[ECMessage alloc] initWithReceiver:quitMsg.groupId body:messageBody];
    msg.sessionId = quitMsg.groupId;
    msg.from = [self getMyAccount];
    msg.to= quitMsg.groupId;
    msg.isRead = YES;
    msg.userData = userdataStr;
    msg.messageState = ECMessageState_SendSuccess;
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    msg.timestamp=[NSString stringWithFormat:@"%lld", (long long)tmp];
    messageBody.text = [[EmojiConvertor sharedInstance] convertEmojiSoftbankToUnicode:messageBody.text];
    [[KitMsgData sharedInstance] addNewMessage:msg andSessionId:self.sessionId];

    
//    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:msg];
     [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChangedTheSessionId object:msg.sessionId];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_update_session_im_message_num object:nil userInfo:nil];
}
///add by李晓杰 查一遍群组成员
- (void)queryGroupMembers:(NSString *)groupId{
    [[ECDevice sharedInstance].messageManager queryGroupMembers:groupId completion:^(ECError *error, NSString *groupId, NSArray *members) {
        if (error.errorCode != ECErrorType_NoError || members.count == 0){
            return ;
        }
        [members sortedArrayUsingComparator:^(ECGroupMember *obj1, ECGroupMember *obj2){
            if(obj1.role < obj2.role){
                return (NSComparisonResult)NSOrderedAscending;
            }else {
                return (NSComparisonResult)NSOrderedDescending;
            }
        }];
        [KitGroupMemberInfoData deleteGroupAllMemberInfoDataDB:groupId];
        [KitGroupMemberInfoData insertGroupMemberArray:members withGroupId:groupId];
        // 这里主要是为了，IM插件时候，进入chatvc，读取到群成员个数为0，需要操作完数据库，发通知重新刷新一下，容信中不需要，因为有address模块，已经入库了
         [[NSNotificationCenter defaultCenter] postNotificationName:KNotice_InsertGroupMemberArray object:groupId];
    }];
}
#pragma mark - 判断是否为红包消息相关
- (NSDictionary *)redPacketDic:(ECMessage *)message{
    NSData *data = [message.userData dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length < 1) {
        return nil;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return dict;
}

- (NSMutableDictionary *)getCusDicWithUserData:(NSString *)userData{
    NSString* str = nil;
    NSMutableDictionary *im_modeDic = [NSMutableDictionary dictionary];
    
    NSRange ran = [userData rangeOfString:@"UserData="];
    if (ran.location == NSNotFound) {
        NSRange ran = [userData rangeOfString:[NSString stringWithFormat:@"%@,",kFileTransferMsgNotice_CustomType]];
        if (ran.location == NSNotFound) {
            str = userData;
        }else{
            NSInteger index = ran.location + ran.length;
            str = [userData substringFromIndex:index];
            str = [str base64DecodingString];
        }
        im_modeDic = [self getDicFromJsonStr:str];
    }else{
        NSInteger index = ran.location + ran.length;
        str = [userData substringFromIndex:index];
        im_modeDic =  [str coverDictionary];
    }
    return im_modeDic;
}
- (NSMutableDictionary *)getDicFromJsonStr:(NSString *)message
{
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length < 1) {
        return nil;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    return [NSMutableDictionary dictionaryWithDictionary:dict];
}
//收到个人助手消息处理
-(void)getPersonalAssistantWithMsg:(ECMessage *)message{
    ECMessage *msg = [[ECMessage alloc]init];
    msg.from = IMSystemLoginMsgFrom;
    msg.sessionId = IMSystemLoginSessionId;
    ECTextMessageBody *textBody = (ECTextMessageBody *)message.messageBody;
    NSString *text = textBody.text;
    ECTextMessageBody *messageBody = [[ECTextMessageBody alloc] initWithText:text];
//    message = [[ECMessage alloc]initWithReceiver:self.forwardAcount body:messageBody];
    msg.messageBody = messageBody;
    [[KitMsgData sharedInstance] addNewMessage:msg andSessionId:msg.from];
}


#pragma mark - 接收即时消息代理函数
/**
 @brief 接收即时消息代理函数
 @param message 接收的消息
 */
- (void)onReceiveMessage:(ECMessage *)message{
    DDLogInfo(@"before onReceiveMessage");
    NSLog(@"message.userData = %@",message.userData);
    NSDictionary *userData = [MessageTypeManager getCusDicWithUserData:message.userData];
    NSLog(@"userData = %@",userData);
    //多终端pc修改个人信息会发这个鬼东西
    if ([message.userData hasSuffix:@"ProfileChanged"]) {
        return;
    }

    if (message.messageBody.messageBodyType == MessageBodyType_Text) {

        /// eagle 如果是自己发送给自己的，就不入库了。因为发送时候已经入库了，但是如果是PC自己给自己发，就有问题。
        if ([message.from isEqualToString:message.to]) {
            NSLog(@"11");
            return;
        }

        //账号冻结
        if ([self onReceiveMessageOfAccountForzenedWithData:message]) {
            return;
        }
        //账号被删除
        if([self onReceiveMessageOfAccountDelWithData:message]){
            return;
        }
        
        //好友邀请消息
        if ([self onReceiveFriendMessage:message userData:userData]) {
            return;
        }
        ///未下载文件处理(文件转发)
        if (isUndownloadFileCanShare && message.isForwardMessage) {
            [self undownloadFileMessageHandle:message];
        }
        //修改密码的强制退出通知
        if (message.isModifyPasswordMessage) {
            [self onReceiveMessageOfModifyPasswordWithData:message];
            return;
        }
        
        //自己发送的阅后即焚
        if ([self onReceiveBurnMessage:message userData:userData]) {
            return;
        }
        
        if ([self textMsgHandle:message]) {
            return;
        }
        int res = 1;
        if ([userData hasValueForKey:SMSGTYPE]) {
          
            if ([userData[SMSGTYPE] isEqualToString: @"25"]) {
                // 好友验证同步消息的
                res = 0;
            }
        }
        
        if (res) {
            //keven注释：新消息插入数据库
            [[KitMsgData sharedInstance] addNewMessage:message andSessionId:self.sessionId];
        }
        
        if(message.sessionId){
            NSString *groupNotice = [NSString stringWithFormat:@"%@_%@_notice",[[Common sharedInstance] getAccount],message.sessionId];
            NSString *isNotice = [[NSUserDefaults standardUserDefaults] objectForKey:groupNotice];
            if([isNotice isEqualToString:@"1"] || [message.from isEqualToString:[[Common sharedInstance]getAccount]] || ([[AppModel sharedInstance].muteState isEqualToString:@"1"] && [AppModel sharedInstance].isPCLogin == YES)){
                //不通知消息提示音
            }else{
                if ([message.userData rangeOfString:@"vidyoRoomKey"].location == NSNotFound || message.userData.length <= 0) {
                    [self playRecMsgSound:message.sessionId];
                }
            }
        }else{
            [self playRecMsgSound:message.sessionId];
        }
        
        ///命令配置 相关
        [self aboutSetting:message];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_update_session_im_message_num object:nil userInfo:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChangedTheSessionId object:message.sessionId];
        DDLogInfo(@"after onReceiveMessage");
        return;
    }
    
    //文件消息加锚点
    if (message.messageBody.messageBodyType == MessageBodyType_File) {
        ECFileMessageBody *fileBody = (ECFileMessageBody *)message.messageBody;
        if (![fileBody.remotePath containsString:@"#iszip"]) {
//            fileBody.remotePath = [NSString stringWithFormat:@"%@#iszip=%d",fileBody.remotePath,fileBody.isCompress?1:0];
        }
    }
    
    
    ///大通讯录处理
    [self onReceiveBigAddress:message];
    // 先判断是不是PC登陆或者下线的消息
    if (message.isMoreLoginMessage) {
        BOOL isNewJson = [userData hasValueForKey:SMSGTYPE];
        NSString *online = isNewJson ? userData[@"online"]: [userData[kRonxinMessageType] isEqualToString:PC_online] ? @"1":@"0";
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_PCLogin object:@(online.integerValue)];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:nil];
        return;
    };
    // 判断是不是多终端对置顶消息的操作
    if (message.isTopMessage) {
        [self setTopListWithUserDataDic:userData];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:nil];
        return;
    }
    // 判断是不是多终端设置免打扰
    if (message.isSetMuteMessage) {
        [self setMsgMuteWithUserDataDic:userData];
        return;
    }
    //判断是否多终端设置新消息通知
    if (message.isNotiMuteMessage) {
        [self setMsgMuteWithUserDataDic:userData];
        return;
    }
    
    if ([message.from isEqualToString:@"0000000000"]) {
        return;
    }
    if (message.from.length == 0 || message.messageBody.messageBodyType == MessageBodyType_Call) {
        return;
    }
    if (message.messageBody.messageBodyType == MessageBodyType_UserState) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KNOTIFICATION_onUserState" object:message];
        return;
    }
    NSNumber *vidyoNumber = [[AppModel sharedInstance] runModuleFunc:@"Vidyo" :@"onReceiveMessageOfVidyoWithData:IsOffLine:" :@[message,[NSNumber numberWithBool:NO]]];
    if ([vidyoNumber boolValue]) {
        return;
    }

    
    //后台删除人员推送
    if (message.isDeleteAccountMessage) {
        [self handleDeleteAccountMessage:message];
        return;
    }
    //特别关注的同步消息
    if ([self onReceiveSpecialSynNoticeWithMessage:message]) {
        return;
    }
    //OA监控
    if([self onReceiveOAMessage:message]){
        DDLogInfo(@"OA监控");
    }
    //屏蔽自己发送的请假消息
    if ([self onReceiveMessageOfAskForLeaveWithData:message]) {
        return;
    }
    //好友邀请消息
    if ([self onReceiveFriendMessage:message userData:userData]) {
        return;
    }
    //第三方应用消息
    if([self onReceiveMyAppStoreMessage:message]) {
        return;
    }
    ///用户个人消息改变
    if(message.isProfileChangedMessage) {
        //更新数据库数据
        [[AppModel sharedInstance] runModuleFunc:@"RXUser":@"getVOIPUserInfoWithMobile":nil hasReturn:NO];
        return;
    }
    ///多终端同步 本地消息已读未读
    if (message.isHaveReadMessage) {
        NSString *sessionId = userData[@"sid"];
        [[KitMsgData sharedInstance] setUnreadMessageCountZeroWithSessionId:sessionId];
        return;
    }
    //自己发送的阅后即焚
    if ([self onReceiveBurnMessage:message userData:userData]) {
        return;
    }
    NSString *boardValue = [userData objectForKey:@"com.yuntongxun.rongxin.message_type"];
    if ([boardValue isEqualToString:@"GROUP_NOTICE"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KNOTIFICATION_onReceivedGroupNotice" object:message];
    }
    //白板控制消息
    if ([self onReceiveBoardNoticeWithMessage:message boardValue:boardValue userData:userData]) {
        return;
    }

    //视频切换语音消息 发送通知
    NSString *meetType;
    if ([userData hasValueForKey:kRonxinMessageType]) {
        meetType = [userData objectForKey:kRonxinMessageType];
    }
    if([meetType isEqualToString:kRONGXINVIDEOSWITCHVIOCE]){
        NSString *callId = message.from;
        [[NSNotificationCenter defaultCenter] postNotificationName:kRONGXINVIDEOSWITCHVIOCE object:ISSTRING_ISSTRING(callId)
         ];
        return;
    }
    ///日志相关
    if (message.messageBody.messageBodyType == MessageBodyType_Command) {
        [self aboutLog:userData];
    }
    ///命令配置 相关
    [self aboutSetting:message];
    //没有时间,按照本地时间时间全部转换成本地时间 先不处理 怕有风险
    if (message.timestamp) {
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval tmp = [date timeIntervalSince1970] * 1000;
        message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
    }
  
    
    ///图片处理 去掉sd以免图片显示不出来
    if ([message.messageBody isKindOfClass:[ECImageMessageBody class]]) {//图片
        ECImageMessageBody *imageBody = (ECImageMessageBody *)message.messageBody;
        if ([imageBody.remotePath hasSuffix:@"_sd"]) {
            imageBody.remotePath = [imageBody.remotePath substringToIndex:imageBody.remotePath.length - 3];
        }
    }
    
    

  
    /// eagle 如果是自己发送给自己的，就不入库了。因为发送时候已经入库了，但是如果是PC自己给自己发，就有问题。
    if ([message.from isEqualToString:message.to]) {
        NSLog(@"11");
        return;
    }
    
    //keven注释：新消息插入数据库
    [[KitMsgData sharedInstance] addNewMessage:message andSessionId:self.sessionId];
    if(message.sessionId){
        NSString *groupNotice = [NSString stringWithFormat:@"%@_%@_notice",[[Common sharedInstance] getAccount],message.sessionId];
        NSString *isNotice = [[NSUserDefaults standardUserDefaults] objectForKey:groupNotice];
        if([isNotice isEqualToString:@"1"] || [boardValue isEqualToString:StickyOnTopChanged] || [message.from isEqualToString:[[Common sharedInstance]getAccount]] || ([[AppModel sharedInstance].muteState isEqualToString:@"1"] && [AppModel sharedInstance].isPCLogin == YES)){
            //不通知消息提示音
        }else{
            if ([message.userData rangeOfString:@"vidyoRoomKey"].location == NSNotFound || message.userData.length <= 0) {
                [self playRecMsgSound:message.sessionId];   
            }
        }
    }else{
        [self playRecMsgSound:message.sessionId];
    }

    MessageBodyType bodyType = message.messageBody.messageBodyType;
    if(bodyType == MessageBodyType_Voice ||
       bodyType == MessageBodyType_Video ||
       bodyType == MessageBodyType_File ||
       bodyType == MessageBodyType_Image ||
       bodyType == MessageBodyType_Preview){
        ECFileMessageBody *body = (ECFileMessageBody *)message.messageBody;
        if (KCNSSTRING_ISEMPTY(body.displayName)) {
            body.displayName = body.remotePath.lastPathComponent;
        }
        if (message.messageBody.messageBodyType == MessageBodyType_Video) {
            ECVideoMessageBody *videoBody = (ECVideoMessageBody *)message.messageBody;
            if (videoBody.thumbnailRemotePath == nil) {
                videoBody.displayName = videoBody.remotePath.lastPathComponent;
                //提前下载消息
                [[AppModel sharedInstance] runModuleFunc:@"ChatMessageManager" :@"sharedInstance" :@[]];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"shoulDownloadMediaMessage" object:nil userInfo:@{@"mediaMessage": message}];
            }
        } else {
            //提前下载消息
            [[AppModel sharedInstance] runModuleFunc:@"ChatMessageManager" :@"sharedInstance" :@[]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"shoulDownloadMediaMessage" object:nil userInfo:@{@"mediaMessage": message}];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_update_session_im_message_num object:nil userInfo:nil];
    //keven Add注释：发出通知sessionController刷新列表
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:message];
    // 刷新单个session
    
     [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChangedTheSessionId object:message.sessionId];
    DDLogInfo(@"after onReceiveMessage");
}

#pragma mark 朋友圈推送  公众号消息推送
/**
 @brief 消息操作通知  朋友圈通知
 @param message 通知消息
 */
-(void)onReceiveServerUndefineMessage:(NSString*)jsonString {
    
    DDLogError(@"收到朋友圈推送！！！！！！！");
    
    // 收到推送 隐藏 收藏／复制 按钮
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hidenCollect" object:nil];
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"receivePush" object:nil];
    
    //解析jsonString
    NSData *messData =[jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDic =[NSJSONSerialization JSONObjectWithData:messData options:NSJSONReadingMutableContainers error:nil];
    
    //解析出来的content和domain二个字段是base64加密的
    if(jsonDic){
        
        if(![jsonDic hasValueForKey:@"msgDomain"]){
            return;
        }
        int messageType =[jsonDic intValueForKey:@"msgType"];
        
        if(messageType ==30){//同事圈、运动会
#pragma mark 暂时屏蔽 没有权限检查
            //没有朋友圈权限，屏蔽推送
            if (![[Common sharedInstance] checkUserAuth:FCAuth]) {
                return;
            }
            //
            //解密 domian  获取msgtype 类型 版本号version 标题subject
            NSString *content = [jsonDic objectForKey:@"msgDomain"];
            NSData *dominData =[[NSData alloc]initWithBase64EncodedString:content?content:@"" options:0];
            NSString *domainBase64 =[[NSString alloc]initWithData:dominData encoding:NSUTF8StringEncoding];
            NSDictionary *dominDic =[NSJSONSerialization JSONObjectWithData:[domainBase64 dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            //            NSString *version =[dominDic objectForKey:@"version"];
            int msgType = [dominDic intValueForKey:@"msgType"];
            
            
            if ([ISSTRING_ISSTRING([jsonDic objectForKey:@"msgSender"]) isEqualToString:[Common sharedInstance].getAccount]) {
                return;
            }
            
            if(msgType==0 || msgType==5 ||msgType==6){
                [[NSUserDefaults standardUserDefaults]setObject:KCreateSportMeetMessageFriendClass forKey:[NSString stringWithFormat:@"%@%@",KCreateSportMeetMessageFriendClass,[Common sharedInstance].getAccount]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_update_session_im_message_num object:nil userInfo:nil];
                
                //新增addyxp 记录红点的时间
                NSDate* recordDate = [NSDate dateWithTimeIntervalSinceNow:0];
                NSTimeInterval recordTmp =[recordDate timeIntervalSince1970]*1000;
                [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%f",recordTmp] forKey:[NSString stringWithFormat:@"%@%@",KReceiveSportMeetMessageFriendTime,[Common sharedInstance].getAccount]];
                
                
                return;
            }
            
            if (msgType==30||msgType==20||msgType==21||msgType==22||msgType==23){
                //20 :点赞 ，21:取消点赞 ，22：评论， 23：删除评论 ，30：删除朋友圈
                //用于区分通知类型
                [jsonDic setValue:[NSNumber numberWithInt:msgType] forKey:@"senderType"];
                
                //                [self runModuleFunc:@"FriendsCircle" :@"getNotification:":@[jsonDic]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kFirendCircleNotification object:nil userInfo:jsonDic];
                
                [self runModuleFunc:@"FriendsCircle" :@"getNotification" :@[jsonDic]];
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageFCChanged object:nil userInfo:jsonDic];
                //ydw modify
                //                [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_update_session_im_message_num object:nil userInfo:nil];
                
            }
        }else if (messageType==31){
            //公众号消息
            if (IsHengFengTarget ) {
                //没有公众号权限 屏蔽
                if(![[Common sharedInstance] checkUserAuth:PublicAuth])
                {
                    return;
                }
            }
            
            [self runModuleFunc:@"PublicService" :@"getNotificationWithPublicDic:":@[jsonDic]];
        }
    }
}
- (void)playRcgMsgSound:(NSTimer *)time{
    NSString *sessiond = time.userInfo;
    [self playRecMsgSound:sessiond];
}

- (void)playRecMsgSound:(NSString *)sessionId{
    //是否在会话里接收消息
    BOOL isChat = NO;
    if (self.sessionId.length > 0 &&
        sessionId.length > 0 &&
        [self.sessionId isEqualToString:sessionId]) {
        isChat = YES;
    }
    [self.coreModel playRecMsgSound:sessionId isChat:isChat];
}

/**
 @brief 离线消息数
 @param count 消息数
 */
-(void)onOfflineMessageCount:(NSUInteger)count{
    DDLogInfo(@"onOfflineMessageCount=%lu",(unsigned long)count);
    self.offlineCount = count;
    self.revOfflineCount = 0;
    
    
}

/**
 @brief 需要获取的消息数
 @return 消息数 -1:全部获取 0:不获取
 */
-(NSInteger)onGetOfflineMessage{
    NSInteger retCount = -1;
    if (self.offlineCount!=0)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_haveHistoryMessage object:nil];
        });
    }
    return retCount;
}

#pragma mark - 接收离线消息代理函数

/**
 @brief 接收离线消息代理函数
 @param msgArray 消息数组
 */
- (void)onReceiveOfflineMessageArray:(NSArray *)msgArray{
    DDLogInfo(@"eagle.接受离线消息 onReceiveOfflineMessageArray onReceiveOfflineMessage的数量 %lu",(unsigned long)msgArray.count);
    for (ECMessage *msg in msgArray) {
        [self onReceiveOfflineMessage:msg];
    }
    NSArray *newArr = [self.offLineMsgArray copy];
    [self.offLineMsgArray removeAllObjects];
    NSArray *sessionArr = [self.offSessionArray copy];
    [self.offSessionArray removeAllObjects];
    
    [[KitMsgData sharedInstance] addMessageArr:newArr];
    [[KitMsgData sharedInstance] updateSessionArr:sessionArr useTransaction:YES];
    
}
/**
 @brief 接收离线消息代理函数
 @param message 接收的消息
 */
- (void)onReceiveOfflineMessage:(ECMessage *)message{
    DDLogInfo(@"接收离线消息 onReceiveOfflineMessage");
    
    //多终端pc修改个人信息会发这个鬼东西
    if ([message.userData hasSuffix:@"ProfileChanged"]) {
        return;
    }
    if(self.revOfflineCount == 0){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kitOnReceiveOfflineCompletion" object:[NSNumber numberWithInteger:0]];
    }
    NSDictionary *userData = [MessageTypeManager getCusDicWithUserData:message.userData];
    if ([userData isKindOfClass:[NSArray class]]) {
        return;
    }
    
    //文件消息加锚点
    if (message.messageBody.messageBodyType == MessageBodyType_File) {
        ECFileMessageBody *fileBody = (ECFileMessageBody *)message.messageBody;
        if (![fileBody.remotePath containsString:@"#iszip"]) {
//            fileBody.remotePath = [NSString stringWithFormat:@"%@#iszip=%d",fileBody.remotePath,fileBody.isCompress?1:0];
        }
    }
    
    ///大通讯录处理
    [self onReceiveBigAddress:message];
    
    //设备安全pc登录. add by keven
    if ([self onReceiveDeviceSafeLoginForPC:message]) {
        return;
    }
    //end
    
    // 判断是不是多终端对置顶消息的操作
    if (message.isTopMessage) {
        [self setTopListWithUserDataDic:userData];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:nil];
        return;
    }
    // 判断是不是多终端设置免打扰
    if (message.isSetMuteMessage) {
        [self setMsgMuteWithUserDataDic:userData];
        return;
    }

    // 先判断是不是PC登陆或者下线的消息
    if (message.isMoreLoginMessage) {
        return;
    }
    if ([message.from isEqualToString:@"0000000000"]) {
        return;
    }
    NSNumber *vidyoNumber = [[AppModel sharedInstance] runModuleFunc:@"Vidyo" :@"onReceiveMessageOfVidyoWithData:IsOffLine:" :@[message,[NSNumber numberWithBool:YES]]];
    if ([vidyoNumber boolValue]) {
        return;
    }
    //修改密码的强制退出通知
    if (message.isModifyPasswordMessage) {
        [self onReceiveMessageOfModifyPasswordWithData:message];
        return;
    }
    //账号冻结
    if ([self onReceiveMessageOfAccountForzenedWithData:message]) {
        return;
    }
    
    //账号被删除
    if([self onReceiveMessageOfAccountDelWithData:message]){
        return;
    }

    //后台删除人员推送
    if (message.isDeleteAccountMessage) {
        [self handleDeleteAccountMessage:message];
        return;
    }
    
    //特别关注的同步消息
    if ([self onReceiveSpecialSynNoticeWithMessage:message]) {
        return;
    }
    //OA监控
    if([self onReceiveOAMessage:message]){
        DDLogInfo(@"OA监控");
    }
    //屏蔽自己发送的请假消息
    if ([self onReceiveMessageOfAskForLeaveWithData:message]) {
        return;
    }
    //好友邀请消息
    if([self onReceiveFriendMessage:message userData:userData]){
        return;
    }
    //第三方应用消息
    if([self onReceiveMyAppStoreMessage:message]){
        return;
    }
    ///用户个人消息改变
    if(message.isProfileChangedMessage) {
        //更新数据库数据
        [[AppModel sharedInstance] runModuleFunc:@"RXUser":@"getVOIPUserInfoWithMobile":nil hasReturn:NO];
        return;
    }
    ///消息已读消息
    if (message.isHaveReadMessage) {
        NSString *sessionId = userData[@"sid"];
        [[KitMsgData sharedInstance] setUnreadMessageCountZeroWithSessionId:sessionId];
        return;
    }
    //自己发送的阅后即焚
    if ([self onReceiveBurnMessage:message userData:userData]) {
        return;
    }

    NSString *boardValue = [userData objectForKey:@"com.yuntongxun.rongxin.message_type"];
    if ([boardValue isEqualToString:@"GROUP_NOTICE"]) {
        self.isGroupNotice = YES;
        return;
    }else{
        self.isGroupNotice = NO;
    }
    //白板控制消息
    if ([self onReceiveBoardNoticeWithMessage:message boardValue:boardValue userData:userData]) {
        return;
    }
    ///日志相关
    if (message.messageBody.messageBodyType == MessageBodyType_Command) {
        [self aboutLog:userData];
    }
    ///命令配置 相关
    [self aboutSetting:message];

    ///离线才实现的方法
    if (message.from.length == 0 || message.messageBody.messageBodyType == MessageBodyType_Call) {
        if (message.messageBody.messageBodyType == MessageBodyType_Call) {
            ECCallMessageBody *callBody = (ECCallMessageBody *)message.messageBody;
            NSString *text = @"";
            if (callBody.calltype == VIDEO) {
                message.userData = @"video";
                text = languageStringWithKey(@"视频通话 未接通");
            } else if (callBody.calltype == VOICE) {
                message.userData = @"voice";
                text = languageStringWithKey(@"语音通话 未接通");
            } else {
                DDLogError(@"未知离线呼叫，不添加到聊天记录：calltype=%d callText=%@",(int)callBody.calltype,callBody.callText);
                return;
            }
            ECTextMessageBody *body = [[ECTextMessageBody alloc] initWithText:text];
            message.messageBody = body;
            [self.offLineMsgArray addObject:message];
            
            ECSession *session = [[KitMsgData sharedInstance] addNewMessage2:message andSessionId:self.sessionId];
            [self.offSessionArray addObject:session];
//            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:message];
             [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChangedTheSessionId object:message.sessionId];
        }
        return;
    }
    if ([self textMsgHandle:message]) {
        return;
    }
    ///未下载文件处理
    if (isUndownloadFileCanShare && message.isForwardMessage) {
        [self undownloadFileMessageHandle:message];
    }
    ///图片处理 去掉sd以免图片显示不出来
    if ([message.messageBody isKindOfClass:[ECImageMessageBody class]]) {//图片
        ECImageMessageBody *imageBody = (ECImageMessageBody *)message.messageBody;
        if ([imageBody.remotePath hasSuffix:@"_sd"]) {
            imageBody.remotePath = [imageBody.remotePath substringToIndex:imageBody.remotePath.length - 3];
        }
    }
    ECSession *session = [[KitMsgData sharedInstance] addOfflineMessage:message andSessionId:self.sessionId];
    [self.offSessionArray addObject:session];
    [self.offLineMsgArray addObject:message];
    self.revOfflineCount++;
//    int k = 100;
//    if (self.revOfflineCount %  k == 0 ) {
//        DDLogInfo(@"离线消息刷新一次 revOfflineCount == %ld offlineCount = %ld k=%d",(long)self.revOfflineCount,(long)self.offlineCount,k);
////        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:message];
//         [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChangedTheSessionId object:message.sessionId];
//    }
    MessageBodyType bodyType = message.messageBody.messageBodyType;
    if( bodyType == MessageBodyType_Voice || bodyType == MessageBodyType_Video || bodyType == MessageBodyType_Image || bodyType== MessageBodyType_Preview){
        ECFileMessageBody *body = (ECFileMessageBody*)message.messageBody;
        body.displayName = body.remotePath.lastPathComponent;
        
        if (message.messageBody.messageBodyType == MessageBodyType_Video) {
            ECVideoMessageBody *videoBody = (ECVideoMessageBody *)message.messageBody;
            if (videoBody.thumbnailRemotePath == nil) {
                videoBody.displayName = videoBody.remotePath.lastPathComponent;
                //提前下载消息
                [[AppModel sharedInstance] runModuleFunc:@"ChatMessageManager" :@"sharedInstance" :@[]];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"shoulDownloadMediaMessage" object:nil userInfo:@{@"mediaMessage": message}];
            }
        } else {
            //提前下载消息
            [[AppModel sharedInstance] runModuleFunc:@"ChatMessageManager" :@"sharedInstance" :@[]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"shoulDownloadMediaMessage" object:nil userInfo:@{@"mediaMessage": message}];
        }
    }
}



- (void)onReceiveMessageNotify:(ECMessageNotifyMsg *)message {
    DDLogInfo(@"onReceiveMessageNotify:--%@",message);
    if (message.messageType == ECMessageNotifyType_DeleteMessage) {
        ECMessageDeleteNotifyMsg *msg = (ECMessageDeleteNotifyMsg*)message;
        
        //屏蔽同步消息
        if ([msg.sender isEqualToString:[Common sharedInstance].getAccount]) {
            return;
        }
        
        
        ECMessage * reMessage = [[KitMsgData sharedInstance] getMessagesWithMessageId:msg.messageId OfSession:msg.sender];
        if (reMessage.messageState == ECMessageState_Receive && reMessage.isRead == YES) {
            return;
        }
        
        
        //6875516A925A681D22CCF4CB9636C424|86
        //1496805533483|2416
        [[KitMsgData sharedInstance] deleteMessage:msg.messageId andSession:msg.sender];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_ReceiveMessageDelete object:nil userInfo:@{@"msgid":msg.messageId, @"sessionid":msg.sender}];
        
    } else if (message.messageType == ECMessageNotifyType_RevokeMessage) {
        ECMessageRevokeNotifyMsg *msg = (ECMessageRevokeNotifyMsg *)message;
        NSString *nickName;
        if ([msg.sender isEqualToString:[self getMyAccount]]) {
            nickName = languageStringWithKey(@"你");
        }else if ([msg.sessionId hasPrefix:@"g"]){//群组的话 用群设置的昵称
            KitGroupMemberInfoData *infoData = [KitGroupMemberInfoData getGroupMemberInfoWithMemberId:msg.sender withGroupId:msg.sessionId];
            if (!KCNSSTRING_ISEMPTY(infoData.memberName)) {
                nickName = infoData.memberName;
            }
        }else{
            nickName = [[Common sharedInstance] getOtherNameWithPhone:msg.sender];
        }
        RXRevokeMessageBody *revokeBody = [[RXRevokeMessageBody alloc] init];
        if ([nickName isEqualToString:languageStringWithKey(@"你")]) {
            revokeBody = [[RXRevokeMessageBody alloc] initWithText:[NSString stringWithFormat:@"%@%@",nickName.length>0?nickName:msg.sender,languageStringWithKey(@"撤回了一条消息")]];
        } else {
            revokeBody = [[RXRevokeMessageBody alloc] initWithText:[NSString stringWithFormat:@"\"%@\"%@",nickName.length>0?nickName:msg.sender,languageStringWithKey(@"撤回了一条消息")]];
        }
        ECMessage *message = [[ECMessage alloc] initWithReceiver:msg.sessionId body:revokeBody];
        message.timestamp = msg.dateCreated;
        if (!message.timestamp) {//之前是直接把当前时间直接赋值给了message.timestamp，会导致撤回消息提示展示成最新的
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
            message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];
        }
        message.messageState = ECMessageState_SendSuccess;
        message.from = msg.sender;
        ECMessage *oldMmessage = [[KitMsgData sharedInstance] getMessagesWithMessageId:msg.messageId OfSession:nil];
        if (oldMmessage) {
            message.messageId = msg.messageId;
            message.sessionId = oldMmessage.sessionId;
            msg.sessionId = oldMmessage.sessionId;
            [[KitMsgData sharedInstance]  updateSrcMessage:message.sessionId msgid:message.messageId withDstMessage:message];
        }else{
            /// eagle 本地没入库，如果c插入撤回，会导致自己对自己的撤回
//            [[KitMsgData sharedInstance] addNewMessage:message andSessionId:message.sessionId];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:message userInfo:@{@"message":message,@"msgid":msg.messageId, @"sessionid":msg.sessionId}];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationrevokeMessage" object:message userInfo:@{@"message":message,@"msgid":msg.messageId, @"sessionid":msg.sessionId}];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_update_session_im_message_num object:nil userInfo:nil];
    } else if (message.messageType == ECMessageNotifyType_MessageIsReaded) {
        ECMessageIsReadedNotifyMsg *isReadMsg = (ECMessageIsReadedNotifyMsg *)message;
        ECMessage *msg = [[KitMsgData sharedInstance] getMessageById:isReadMsg.messageId];
        if (!msg) {
            NSLog(@"--> onReceiveMessageNotify msgId %@",isReadMsg.messageId);
            [self.offLineMessageNotifyArray addObject:isReadMsg];
        }else {
        }
        [[KitMsgData sharedInstance] updateMessageReadStateByMessageId:isReadMsg.messageId isRead:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_IsReadMessage object:@{@"sessionid":isReadMsg.sessionId,@"messageId":isReadMsg.messageId}];
    }
}


- (NSDictionary *)getDic:(NSString *)str {
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length < 1) {
        return nil;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    return dict;
}





/**
 @brief 离线消息接收是否完成
 @param isCompletion YES:拉取完成 NO:拉取未完成(拉取消息失败)
 */
-(void)onReceiveOfflineCompletion:(BOOL)isCompletion {
    
    if(isCompletion)
    {
        if(self.revOfflineCount>0){
            [self performSelector:@selector(postRevOfflineCompletion) withObject:nil afterDelay:1];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kitOnReceiveOfflineCompletion" object:[NSNumber numberWithInteger:2]];
        NSArray *newArr = [self.offLineMsgArray copy];
        [self.offLineMsgArray removeAllObjects];
        NSArray *sessionArr = [self.offSessionArray copy];
        [self.offSessionArray removeAllObjects];
        [[KitMsgData sharedInstance] addMessageArr:newArr];
        [[KitMsgData sharedInstance] updateSessionArr:sessionArr useTransaction:YES];
        
        NSArray *isReadArr = [self.offLineMessageNotifyArray copy];
        [self.offLineMessageNotifyArray removeAllObjects];
        for (ECMessageIsReadedNotifyMsg *isReadMsg in isReadArr) {
            [[KitMsgData sharedInstance] updateMessageReadStateByMessageId:isReadMsg.messageId isRead:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_IsReadMessage object:@{@"sessionid":isReadMsg.sessionId,@"messageId":isReadMsg.messageId}];
        }
        
        //这里换了通知的顺序  应该是先入库再刷新  
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_update_session_im_message_num object:nil userInfo:nil];
        
    }else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kitOnReceiveOfflineCompletion" object:[NSNumber numberWithInteger:1]];
    }
}

-(void)postRevOfflineCompletion{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:nil];
    if (!self.isGroupNotice) {
        [self playRecMsgSound:nil];
    }
}


-(void)onCallEvents:(VoIPCall *)voipCall {
    
    if (voipCall.callStatus == ECallEnd) {
        [self cancleVoipPush:NO];
        [[Common sharedInstance] stopShakeSoundVibrate];
        [[AppModel sharedInstance] setOpenBackgroudTask:NO];
        //发送通知取消弹窗"是否先结束会议，再接听通话"
        [self voipEnd];
    }
    
    if ([voipCall.callID isEqualToString:self.appData.curVoipCall.callid]) {
        self.appData.curVoipCall.reason = (int)voipCall.reason;
        self.appData.curVoipCall.voipCallStatus = voipCall.callStatus;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"onCallEvents" object:voipCall];
    }
}

#pragma mark - 未读消息等设置相关

/**
 @brief 保持客户端TCP后台连接3分钟
 @discussion VoIP呼叫开始时打开，呼叫结束时关闭，保证APP在后台3分钟内收到呼叫状态回调
 @param isSandBox 是否打开
 */
- (void)setOpenBackgroudTask:(BOOL)isOpen {
    
    DDLogInfo(@"Set up the background TCP connection for 3 minutes %@",isOpen?@"is Open":@"no Open");
    [[ECDevice sharedInstance] setOpenBackgroudTask:isOpen];
}

/**
 @brief 设置角标数
 @param badgeNumber 角标数字
 */
-(void)setAppleBadgeNumber:(NSInteger)badgeNumber {
    [[ECDevice sharedInstance] setAppleBadgeNumber:badgeNumber completion:^(ECError *error) {
        DDLogInfo(@"applicationIconBadgeNumber end---- %ld",(long)error.errorCode);
    }];
}

/**
 @brief 获取应用未读信息数
 */
- (NSInteger)getAppleBadgeNumberCount {
    NSInteger count = [[KitMsgData sharedInstance] getUnreadMessageCountFromSession];
    return count;
}

#pragma mark - 换肤相关
/**
 @brief 根据用户的选择更换字体的大小
 @param size  大0 中1 小2
 @param isTheme  YES是主题文字 NO是系统文字
 */
- (UIFont *)themeFontWithSize:(NSInteger)size isTheme:(BOOL)isTheme {
    
    //第一次去获取plist里存储的尺寸 之后都从内存读取 方便使用插件开发
    if (self.themeFontSizeLarge == 0 && self.themeFontSizeMiddle == 0 && self.themeFontSizeSmall == 0) {
        NSString *themePath = [[NSBundle mainBundle] pathForResource:@"themeFont.plist" ofType:nil];
        NSDictionary *themeDict = [NSDictionary dictionaryWithContentsOfFile:themePath];
        self.themeFontSizeLarge = [themeDict[@"large"] floatValue];
        self.themeFontSizeMiddle = [themeDict[@"middle"] floatValue];
        self.themeFontSizeSmall = [themeDict[@"small"] floatValue];
    }
    
    //判断下用户有没有选择 主题文字 在设置里选择文字尺寸的时候 要设置 [AppModel sharedInstance].selectedThemeFontSize
    if (self.selectedThemeFontSize == 0) {
        CGFloat selectedThemeFontSize = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"selectedThemeFontSize%@",[Common sharedInstance].getAccount]] floatValue];
        //只判断一次 如果没有选择 赋值为-1
        self.selectedThemeFontSize = selectedThemeFontSize ==0 ?-1 :selectedThemeFontSize;
    }
    
    CGFloat themeFontSize= 0;
    switch (size) {
        case 0://大
            themeFontSize = isTheme ? (self.selectedThemeFontSize == -1 ?self.themeFontSizeLarge :self.selectedThemeFontSize) :self.themeFontSizeLarge;
            break;
        case 1://中 用plist里的差值和用户选择的尺寸去计算新的尺寸
            themeFontSize = isTheme ? (self.selectedThemeFontSize == -1 ?self.themeFontSizeMiddle :(self.selectedThemeFontSize - (self.themeFontSizeLarge - self.themeFontSizeMiddle))) :self.themeFontSizeMiddle;
            break;
        case 2://小 用plist里的差值和用户选择的尺寸去计算新的尺寸
            themeFontSize = isTheme ? (self.selectedThemeFontSize == -1 ?self.themeFontSizeSmall :(self.selectedThemeFontSize - (self.themeFontSizeLarge - self.themeFontSizeSmall))) :self.themeFontSizeSmall;
            break;
        default:
            themeFontSize = isTheme ? (self.selectedThemeFontSize == -1 ?self.themeFontSizeLarge :self.selectedThemeFontSize) :self.themeFontSizeLarge;
            break;
    }
    return [UIFont systemFontOfSize:themeFontSize];
}

/**
 @brief 根据用户的选择更换图片资源
 @param name  图片名字
 */
- (UIImage *)imageWithName:(NSString *)name {
//    NSLog(@"ThemeImage(@\"%@\");",name);
    if (KCNSSTRING_ISEMPTY(name)) {
        return nil;
    }
    //存其他bundle里的 直接用
    if ([name containsString:@".bundle"]) {
        return [UIImage imageNamed:name];
    }
    
    
    //偏好设置读取 用户选择的类型 没有就是默认
    //去对应的bundle里获取图片 没有就去默认的bundle下获取
    //现在图片还没有整理完全 如果默认的也获取不到 就直接imageNamed
    //要是服务端有图片传过来 提前下载到本地 图片名字存为plist
    NSString *themeType = [[NSUserDefaults standardUserDefaults] objectForKey:@"themeType"];
    if (!themeType) {
        themeType = @"default";
    }
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.bundle/%@",themeType,name]];
    if (!image) {
        image = [UIImage imageNamed:name];
    }
    return image;
}

- (UIColor *)themNavigationBarTitleColor:(NSString *)themeColor {
    //偏好设置读取 用户选择的类型 没有就是默认
    //    NSString *themeType = [[NSUserDefaults standardUserDefaults] objectForKey:@"Add_GetNavgationPageThem"];
    if (!themeColor) {
        //        themeType = @"otherNavigationTitleColor";
    }
    
    //根据用户选择的类型 去获取plist里存储的颜色值
    NSString *themePath = [[NSBundle mainBundle] pathForResource:@"themeColor.plist" ofType:nil];
    NSDictionary *themeDict = [NSDictionary dictionaryWithContentsOfFile:themePath];
    NSString *colorString = themeDict[themeColor];
    
    
    if ([colorString hasPrefix:@"#"]) {
        return [self colorWithHex:colorString];
    }
    else {
        NSArray *colorList = [colorString componentsSeparatedByString:@","];
        
        if ([colorList count] > 3) {
            CGFloat r = [[colorList objectAtIndex:0] floatValue];
            CGFloat g = [[colorList objectAtIndex:1] floatValue];
            CGFloat b = [[colorList objectAtIndex:2] floatValue];
            CGFloat a = [[colorList objectAtIndex:3] floatValue];
            
            if (r>1.0f) {
                r= r/255.0f;
            }
            
            if (g>1.0f) {
                g= g/255.0f;
            }
            
            if (b>1.0f) {
                b= b/255.0f;
            }
            
            return [UIColor colorWithRed:r
                                   green:g
                                    blue:b
                                   alpha:a];
        }
        else {
#ifdef DEBUG
            DDLogInfo(@"warning:【主题加载】颜色：颜色值格式错误，格式应该是#FFFFFF或者R,G,B,A 例如134,135,136,1.0");
#endif
            return nil;
        }
    }
}

/**
 @brief 根据用户的选择更换主题颜色
 *key对应的value的值格式：
 #RGB、#ARGB 、#RRGGBB 、#AARRGGBB 、R,G,B,A
 */
- (UIColor *)themeColor {
    
    //偏好设置读取 用户选择的类型 没有就是默认
    NSString *themeType = [[NSUserDefaults standardUserDefaults] objectForKey:@"themeType"];
    if (!themeType) {
        themeType = @"default";
    }
    //根据用户选择的类型 去获取plist里存储的颜色值
    NSString *themePath = [[NSBundle mainBundle] pathForResource:@"themeColor.plist" ofType:nil];
    NSDictionary *themeDict = [NSDictionary dictionaryWithContentsOfFile:themePath];
    NSString *colorString = themeDict[themeType];
    
    
    if ([colorString hasPrefix:@"#"]) {
        return [self colorWithHex:colorString];
    } else {
        NSArray *colorList = [colorString componentsSeparatedByString:@","];
        
        if ([colorList count] > 3) {
            CGFloat r = [[colorList objectAtIndex:0] floatValue];
            CGFloat g = [[colorList objectAtIndex:1] floatValue];
            CGFloat b = [[colorList objectAtIndex:2] floatValue];
            CGFloat a = [[colorList objectAtIndex:3] floatValue];
            
            if (r>1.0f) {
                r= r/255.0f;
            }
            
            if (g>1.0f) {
                g= g/255.0f;
            }
            
            if (b>1.0f) {
                b= b/255.0f;
            }
            
            return [UIColor colorWithRed:r
                                   green:g
                                    blue:b
                                   alpha:a];
        }
        else {
#ifdef DEBUG
            DDLogError(@"warning:【主题加载】颜色：颜色值格式错误，格式应该是#FFFFFF或者R,G,B,A 例如134,135,136,1.0");
#endif
            return nil;
        }
    }
}

- (UIColor *) colorWithHex: (NSString *) hexString {
    
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#"withString: @""] uppercaseString];
    
    CGFloat alpha, red, blue, green;
    
    switch ([colorString length]) {
            
        case 3: // #RGB
            
            alpha = 1.0f;
            
            red   = [self colorComponentFrom: colorString start: 0 length: 1];
            
            green = [self colorComponentFrom: colorString start: 1 length: 1];
            
            blue  = [self colorComponentFrom: colorString start: 2 length: 1];
            
            break;
            
        case 4: // #ARGB
            
            alpha = [self colorComponentFrom: colorString start: 0 length: 1];
            
            red   = [self colorComponentFrom: colorString start: 1 length: 1];
            
            green = [self colorComponentFrom: colorString start: 2 length: 1];
            
            blue  = [self colorComponentFrom: colorString start: 3 length: 1];
            
            break;
            
        case 6: // #RRGGBB
            
            alpha = 1.0f;
            
            red   = [self colorComponentFrom: colorString start: 0 length: 2];
            
            green = [self colorComponentFrom: colorString start: 2 length: 2];
            
            blue  = [self colorComponentFrom: colorString start: 4 length: 2];
            
            break;
            
        case 8: // #AARRGGBB
            
            alpha = [self colorComponentFrom: colorString start: 0 length: 2];
            
            red   = [self colorComponentFrom: colorString start: 2 length: 2];
            
            green = [self colorComponentFrom: colorString start: 4 length: 2];
            
            blue  = [self colorComponentFrom: colorString start: 6 length: 2];
            
            break;
            
        default:
            
            [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
            
            break;
            
    }
    
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
    
}

- (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    
    unsigned hexComponent;
    
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    
    return hexComponent / 255.0;
    
}
// 快速编译方法，无需调用
- (void)injected{
    NSLog(@"eagle.injected");
}

- (UIImage *)getThemeColorImage:(UIImage *)image withColor:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextClipToMask(context, rect, image.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}

- (UIImage *)drawDefaultHeadImageWithHeadSize:(CGSize)size andNameString:(NSString *)nameString andAccount:(NSString *)account {
    NSString *name;
    if (!nameString) {
        name = @"";
        if(account.length>0)
        {
            name = account;
        }
    }else{
        name = [NSString stringWithString:nameString];
    }
    // NSInteger x = [name hash] % colorArr.count;
    
    UILabel * nameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    nameLab.textAlignment = NSTextAlignmentCenter;
    if(name.length>1)
    {
        nameLab.text = [name substringFromIndex:name.length-2];
    }else{
        nameLab.text = name;
    }
    
    //    uLong crc = crc32(0L, Z_NULL, 0);
    //
    //    crc = crc32(crc, [nameLab.text dataUsingEncoding:NSUTF8StringEncoding].bytes, (uInt)[nameLab.text dataUsingEncoding:NSUTF8StringEncoding].length);
    NSArray * colorArr = @[@"#f6b565",@"#f07363",@"#af8b7c",@"#578bab",@"#369bec",@"#6072a5",@"#28c196",@"#56ccb5",@"#ecba41",@"#51bfe4"];
    // NSInteger x = crc % colorArr.count;
    NSInteger sum  = 0;
    if(account)
    {
        sum = [self getStringASCIISum:account] % colorArr.count;
    }
    nameLab.textColor = [UIColor whiteColor];
    nameLab.font = [UIFont systemFontOfSize:MIN(size.width, size.height)*1/3];
    nameLab.backgroundColor = [UIColor colorWithHexString:colorArr[sum]];
    nameLab.layer.masksToBounds = YES;
//    nameLab.layer.cornerRadius = nameLab.frame.size.width/2;// 圆形
    nameLab.layer.cornerRadius = 4;
    
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [nameLab.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(NSInteger)getStringASCIISum:(NSString *)accountSting
{
    const char *ch = [accountSting cStringUsingEncoding:NSASCIIStringEncoding];
    if (ch == NULL) return 0;
    NSInteger sum = 0 ;
//      printf("accountSting-");
    for (int i = 0; i < strlen(ch); i++) {
//        printf("%c", ch[i]);
        sum =sum+ch[i];
    }
    return sum;
}

- (NSInteger)GetStringCharSize:(NSString*)argString
{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(NSUTF16BigEndianStringEncoding);
    NSData *data = [argString dataUsingEncoding:enc];
    
    Byte *byte = (Byte *)[data bytes];
    
    NSInteger len  =  0 ;
    for (int i=0 ; i<[data length]; i++) {
        
        len = len + byte[i];
        DDLogInfo(@"byte = %d",byte[i]);
    }
    
    return data.length;
}

//屏蔽中英文字符
- (BOOL)isPureNumandCharacters:(NSString *)string
{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if(string.length > 0)
    {//包含中英文字符返回NO
        return NO;
    }
    return YES;
}

#pragma mark - 各模块代理回调
//0,根据account获取，1根据手机号获取
-(NSDictionary*)getDicWithId:(NSString*)Id withType:(int) type
{
    if (!Id) {
        return nil;
    }
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(getDicWithId:withType:)]) {
        return [self.appModelDelegate getDicWithId:Id withType:type];
    }
    NSDictionary* dict = [[AppModel sharedInstance] runModuleFunc:@"RXAddressBook" :@"getCompanyAddressWithId:withType:" :[NSArray arrayWithObjects:Id,[NSNumber numberWithInt:type], nil]];
    return dict;
}


-(NSString *)getLocalAddressNameWithPhoneNumber:(NSString *)phone {
    return [[AppModel sharedInstance] runModuleFunc:@"RXAddressBook" :@"getLocalAddressNameWithPhoneNumber:" :@[phone]];
}

-(NSString *)getDeptNameWithDeptID:(NSString *)deptID {
    if (!deptID.length) {
        return nil;
    }
    
    NSArray *array = [deptID componentsSeparatedByString:@","];
    if (array.count>0) {
        deptID = array.lastObject;
    }
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(getDeptNameWithDeptID:)]) {
        return [self.appModelDelegate getDeptNameWithDeptID:deptID];
    }
    return [[AppModel sharedInstance] runModuleFunc:@"RXAddressBook" :@"getCompanyDeptNameDataWithDeptID:" :@[deptID]];
}

-(NSDictionary*)onGetUserInfo{
    
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(onGetUserInfo)]) {
        return [self.appModelDelegate onGetUserInfo];
    }
    NSMutableDictionary* dict = nil;
    //    dict = [[[AppModel sharedInstance] runModuleFunc:@"RXUser" :@"userForAccount:" :[NSArray arrayWithObject: @"getUserAppModel"]] mutableCopy];
    dict = [[AppModel sharedInstance] runModuleFunc:@"RXUser" :@"userForAccount:" :[NSArray arrayWithObject: @"getUserAppModel"]] ;
    if (dict[@"RX_account_key"]) {
        [dict setObject:dict[@"RX_account_key"] forKey:Table_User_account];
    }
    if(dict[@"RX_oaAccount_key"])
    {
        [dict setObject:dict[@"RX_oaAccount_key"] forKey:Table_User_oaAccount];
    }
    if(dict[@"RX_loginTokenMd5_key"])
    {
        [dict setObject:dict[@"RX_loginTokenMd5_key"] forKey:Table_User_loginTokenMd5];
    }
    if (dict[@"RX_mobile_key"]) {
        [dict setObject:dict[@"RX_mobile_key"] forKey:Table_User_mobile];
    }
    if (dict[@"RX_user_head_url"]) {
        [dict setObject:dict[@"RX_user_head_url"] forKey:Table_User_avatar];
    }
    if (dict[@"username"]) {
        [dict setObject:dict[@"username"] forKey:Table_User_member_name];
    }
    if (dict[@"RX_StaffNo"]) {
        [dict setObject:dict[@"RX_StaffNo"] forKey:Table_User_staffNo];
    }
    if (dict[@"RX_appid_key"]) {
        [dict setObject:dict[@"RX_appid_key"] forKey:App_AppKey];
    }
    if (dict[@"RX_apptoken_key"]) {
        [dict setObject:dict[@"RX_apptoken_key"] forKey:App_Token];
    }
    if (dict[@"RX_companyid_key"]) {
        [dict setObject:dict[@"RX_companyid_key"] forKey:Table_User_company_id];
    }
    if (dict[@"RX_companyname_key"]) {
        [dict setObject:dict[@"RX_companyname_key"] forKey:Table_User_company_name];
    }
    if (dict[@"RX_clientpwd_key"]) {
        [dict setObject:dict[@"RX_clientpwd_key"] forKey:App_Clientpwd];
    }
    if (dict[@"RX_resthost_key"]) {
        [dict setObject:dict[@"RX_resthost_key"] forKey:App_Resthost];
    }
    if (dict[@"RX_OrgId"]) {
        [dict setObject:dict[@"RX_OrgId"] forKey:Table_User_OrgId];
    }
    if (dict[@"RX_lvs"]) {
        [dict setObject:dict[@"RX_lvs"] forKey:App_LvsArray];
    }
    if (dict[@"HX_vidyoRoomUrl"]) {
        [dict setObject:dict[@"HX_vidyoRoomUrl"] forKey:APP_VidyoRoomUrl];
    }
    if (dict[@"HX_vidyoRoomID"]) {
        [dict setObject:dict[@"HX_vidyoRoomID"] forKey:Vidyo_VidyoRoomID];
    }
    if (dict[@"HX_vidyoEntityID"]) {
        [dict setObject:dict[@"HX_vidyoEntityID"] forKey:Vidyo_VidyoEntityID];
    }
    if (dict[@"HX_vidyoFQDN"]) {
        [dict setObject:dict[@"HX_vidyoFQDN"] forKey:Vidyo_VidyoFQDN];
    }
    if (dict[@"HX_vidyoConfExten"]) {
        [dict setObject:dict[@"HX_vidyoConfExten"] forKey:Vidyo_VidyoConfExten];
    }
    if (dict[@"kHXClientAuthResp_confNum_regex"]) {
        [dict setObject:dict[@"kHXClientAuthResp_confNum_regex"] forKey:Vidyo_ConfNum_regex];
    }
    if (dict[@"kHXClientAuthResp_Coo_Url"]) {
        [dict setObject:dict[@"kHXClientAuthResp_Coo_Url"] forKey:App_boardUrl];
    }
    if (dict[@"kHXClientAuthResp_CooAppId"]) {
        [dict setObject:dict[@"kHXClientAuthResp_CooAppId"] forKey:APP_CooAppId];
    }
    if (dict[@"RX_user_authtag"]) {
        [dict setObject:dict[@"RX_user_authtag"] forKey:Table_User_access_control];
    }
    
    if(dict[@"KHXClientAuthResp_friendGroup_Url"])
    {
        [dict setObject:dict[@"KHXClientAuthResp_friendGroup_Url"] forKey:Table_User_FriendGroupUrl];
    }
    
    if (dict[@"RX_ConfRooms"]) {
        [dict setObject:dict[@"RX_ConfRooms"] forKey:Table_User_confRooms];
    }
    if (dict[@"RX_user_personLevel"]) {
           [dict setObject:dict[@"RX_user_personLevel"] forKey:@"RX_user_personLevel"];
    }
    return dict;
}


/**
 获取选择联系人页面
 */
-(UIViewController *)getChooseMembersVCWithExceptData:(NSDictionary *)exceptData WithType:(SelectObjectType)type{
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(getChooseMembersVCWithExceptData:WithType:)]) {
        return [self.appModelDelegate getChooseMembersVCWithExceptData:exceptData WithType:type];
    }
    else
    {
        UIViewController *chooseMembersVC = [[AppModel sharedInstance] runModuleFunc:@"RXAddressBook" :@"getChooseMembersVCWithExceptData:WithType:" :@[exceptData,[NSNumber numberWithInteger:type]]];
        if (chooseMembersVC) {
            return chooseMembersVC;
        }
        return nil;
    }
}
#if IsHaveYHCConference
-(UIViewController *)getChooseMembersVCWithExceptData:(YHCExceptData *)exceptData withType:(YHCSelectObjectType)type completion:(void(^)(NSArray *membersArr))completion{
    
    NSDictionary *dict =[NSDictionary dictionaryWithObjectsAndKeys:exceptData.confId,@"kitConferenceId",exceptData.exitMembers,@"members", nil];
    
    DDLogInfo(@"有会邀请联系人 exceptData =%@",exceptData);
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(getChooseMembersVCWithExceptData:withType:completion:)]) {
        UIViewController *vc = [self.appModelDelegate getChooseMembersVCWithExceptData:dict withType:type completion:nil];
        RXBaseNavgationController *nav = [[RXBaseNavgationController alloc]initWithRootViewController:vc];
//        if (self.YHCcompletion) {
//            completion(self.YHCcompletion);
//        }
        self.YHCcompletion = completion;
        return nav;
    }
    else
    {
        UIViewController *chooseMembersVC = [[AppModel sharedInstance] runModuleFunc:@"RXAddressBook" :@"getChooseMembersVCWithExceptData:WithType:" :@[dict,[NSNumber numberWithInteger:type]]];
        
        RXBaseNavgationController *nav = [[RXBaseNavgationController alloc]initWithRootViewController:chooseMembersVC];
        if (chooseMembersVC) {
            return nav;
        }
        return nil;
    }
}
#endif
/**
 获取联系人详情页面
 */
-(UIViewController *)getContactorInfosVCWithData:(id)data{
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(getContactorInfosVCWithData:)]) {
        return [self.appModelDelegate getContactorInfosVCWithData:data];
    }else if(data){
        UIViewController *contactorInfosVC = [[AppModel sharedInstance] runModuleFunc:@"RXAddressBook" :@"getContactorInfosVCWithData:" :@[data]];
        if (contactorInfosVC) {
            return contactorInfosVC;
        }
    }
    return nil;
}

/**
 ·@brief 会议插件点击成员代理方法
 @discussion 点击成员代理方法
 */
- (UIViewController *)onAvatarClickListener:(NSDictionary *)data {
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(onAvatarClickListener:)]) {
        return [self.appModelDelegate onAvatarClickListener:data];
    }
    return nil;
}

- (void)WXShareConferenceContent:(NSString *)strContent{
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(WXShareConferenceContent:)]) {
        [self.appModelDelegate WXShareConferenceContent:strContent];
    }
}

//获取联系人
//array的item为dict类型，至少需要包括name名字，phone电话
-(NSArray*)getContacts{
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(getContacts)]) {
        return [self.appModelDelegate getContacts];
    }
    else
    {
        NSMutableArray* companyAddressArray = [[AppModel sharedInstance] runModuleFunc:@"RXAddressBook" :@"getCompanyAddressArray" :nil];
        NSMutableArray* phoneAddressArray = [[AppModel sharedInstance] runModuleFunc:@"RXAddressBook" :@"getPhoneAddressArray" :nil];
        for (NSDictionary* dict in phoneAddressArray) {
            NSString* strPhone = [dict objectForKey:@"phone"];
            if (![self getDicWithId:strPhone withType:1]) {
                [companyAddressArray addObject:dict];
            }
        }
        return companyAddressArray;
    }
}

/**
 聊天界面"+"号功能列表定制
 */
- (void)getChatMoreArrayWithIsGroup:(BOOL)isGroup andMembers:(NSArray *)members completion:(void(^)(NSArray *myImagesArr,NSArray *myTextArr,NSArray *mySelectorArr))completion {
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(getChatMoreArrayWithIsGroup:andMembers:completion:)]) {
        [self.appModelDelegate getChatMoreArrayWithIsGroup:isGroup andMembers:members completion:completion];
    }
}

/**
 定制聊天界面长按消息item
 */
- (NSArray <NSString *> *)getMenuItems {
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(getMenuItems)]) {
        return [self.appModelDelegate getMenuItems];
    }
    return nil;
}

/**
 会话列表界面右上角"+"号功能列表定制
 */
- (void)getSessionMoreArrayWithCurrentVc:(UIViewController *)currentVC completion:(void(^)(NSArray *myImagesArr,NSArray *myTextArr,NSArray *mySelectorArr))completion {
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(getSessionMoreArrayWithCurrentVc:completion:)]) {
        [self.appModelDelegate getSessionMoreArrayWithCurrentVc:currentVC completion:completion];
    }
}


/**
 自定义会话列表导航栏按钮
 */
- (void)configSessionListNavigationItemsWithBlock:(void (^)(NSArray<UIBarButtonItem *> *, NSArray<UIBarButtonItem *> *))block {
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(configSessionListNavigationItemsWithBlock:)]) {
        [self.appModelDelegate configSessionListNavigationItemsWithBlock:block];
    }
}

/**
 聊天界面分享图文到微信
 */
- (void)shareDataWithTarget:(id)target Text:(NSString *)str Image:(UIImage *)img Url:(NSString *)url {
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(shareDataWithTarget:Text:Image:Url:)]) {
        [self.appModelDelegate shareDataWithTarget:target Text:str Image:img Url:url];
    }
}

- (void)finishedCallWithError:(NSError *)error WithType:(VoipCallType)type WithCallInformation:(NSDictionary *)information  UserData:(NSString *)userData{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onCloseBoardNotice object:nil];
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(finishedCallWithError:WithType:WithCallInformation:UserData:)]) {
        return [self.appModelDelegate finishedCallWithError:error WithType:type WithCallInformation:information UserData:userData];
    } else {
        if (error && error.code == 170486) {
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"当前正在通话中")];
        }else if (error && error.code == 111709) {
            [SVProgressHUD showErrorWithStatus:languageStringWithKey(@"超出房间人数上限")];
        }
        if (!information) {
            return;
        }
        if (information[@""]) {
            
        }
        NSString *CallInitiatorID = information[@"CallInitiatorID"];
        NSString *CallReceiverID = information[@"CallReceiverID"];
        NSString *Call_status = information[@"Call_status"]; //0  呼出电话 1 呼出未接听 2 呼入电话接听 3 呼入拒接
        NSNumber *startTime = information[@"startTime"];
        NSNumber *endTime = information[@"endTime"];
        NSString *CallMemberID = ([Call_status isEqualToString:@"0"] || [Call_status isEqualToString:@"1"])?CallReceiverID:CallInitiatorID;
        
        NSDictionary *CallMemberDict;
        
        NSString *account = @"";
        NSString *phone = @"";
        NSString *name = @"";
        if (type == VoipCallType_LandingCall ||
            type == VoipCallType_LandingReCall) {
            CallMemberDict = [[AppModel sharedInstance] getDicWithId:CallMemberID withType:1];
        }else{
            CallMemberDict = [[AppModel sharedInstance] getDicWithId:CallMemberID withType:0];
        }
        if (CallMemberDict == nil) {
            name = @"";
            phone = CallMemberID;
            account = @"";
        }else{
            name = [CallMemberDict objectForKey:Table_User_member_name];
            phone = [CallMemberDict objectForKey:Table_User_mobile];
            account = [CallMemberDict objectForKey:Table_User_account];
        }
        
        //电话记录入库
        KitDialingData *dialdata = [[KitDialingData alloc]init];
        dialdata.account = account;
        dialdata.mobile = phone;
        dialdata.nickname = name;
        dialdata.call_status = Call_status;
        dialdata.call_number = 1;
        dialdata.call_date =  [endTime doubleValue];
        if (type == VoipCallType_Voice) {
            dialdata.call_type = 0;
        }else if (type == VoipCallType_Video){
            dialdata.call_type = 1;
        }else if (type == VoipCallType_LandingCall){
            dialdata.call_type = 2;
        }else if (type == VoipCallType_LandingReCall){
            dialdata.call_type = 3;
        }else if (type == VoipCallType_VoiceMeeting){
            dialdata.call_type = 20;
        }else if (type == VoipCallType_VideoMeeting){
            dialdata.call_type = 21;
        }
        [KitDialingData updateDialingDataDB:dialdata];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"thechangeofcallrecords" object:nil];
        
        //电话详情记录入库
        KitDialingInfoData *infoData = [[KitDialingInfoData alloc]init];
        infoData.dialNickName = name;
        infoData.dialNickName = [CallMemberDict objectForKey:@"member_name"];
        if (type == VoipCallType_Voice) {
            infoData.dialType = languageStringWithKey(@"网络电话");
        }else if(type == VoipCallType_LandingCall){
            infoData.dialType = languageStringWithKey(@"直拨电话");
        }else if (type == VoipCallType_LandingReCall){
            infoData.dialType = languageStringWithKey(@"回拨电话");
        }else if (type == VoipCallType_Video){
            infoData.dialType = languageStringWithKey(@"视频通话");
        }else if (type == VoipCallType_VoiceMeeting){
            infoData.dialType = languageStringWithKey(@"音频会议");
        }else if (type == VoipCallType_VideoMeeting){
            infoData.dialType = languageStringWithKey(@"视频会议");
        }
        infoData.dialAccount = account;
        infoData.dialMobile = phone;
        infoData.dialState = Call_status;
        infoData.dialBeginTime = [endTime doubleValue];
        infoData.dialNickName = name;
        NSTimeInterval time = ([endTime doubleValue]-[startTime doubleValue]);
        int hhint = ((int)time)%(3600*24)/3600;
        int mmint = ((int)time)%(3600*24)%3600/60;
        int ssint = ((int)time)%(3600*24)%3600%60;
        NSString *hs = languageStringWithKey(@"小时");
        NSString *ms = languageStringWithKey(@"分");
        NSString *ss = languageStringWithKey(@"秒");
        
        if (hhint > 0) {
            infoData.dialTime =[NSString stringWithFormat:@"%02d%@%02d%@%0d%@",hhint,hs,mmint,ms,ssint,ss];
        } else {
            if(mmint > 0){
                infoData.dialTime =[NSString stringWithFormat:@"%02d%@%02d%@",mmint,ms,ssint,ss];
            }else if(ssint > 0) {
                infoData.dialTime =[NSString stringWithFormat:@"%02d%@",ssint,ss];
            }else{
                
            }
        }
        [KitDialingInfoData insertdialData:infoData];
    }
}

/**
 分享到朋友圈功能
 */
- (UIViewController *)sendFriendCircleWityDic:(NSDictionary *)dic {
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(sendFriendCircleWityDic:)]) {
        return [self.appModelDelegate sendFriendCircleWityDic:dic];
    }
    return nil;
}

- (UIViewController *)getWebViewControllerWithDic:(NSDictionary *)dic{
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(getWebViewControllerWithDic:)]) {
        return [self.appModelDelegate getWebViewControllerWithDic:dic];
    }
    return nil;
}

/**
 可实现回调，获取公众号历史消息列表，用于IM展示，点击恒信服务号入口可见
 */
- (UIViewController *)getHXPublicViewController{
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(getHXPublicViewController)]) {
        return [self.appModelDelegate getHXPublicViewController];
    }
    return nil;
}
/**
 IM搜索公众号
 */
- (NSMutableArray *)getHXPublicData:(NSString *)searchText{
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(getHXPublicData:)]) {
        return [self.appModelDelegate getHXPublicData:searchText];
    }
    return nil;
}

/**
 删除数据库缓存，用于更新IM列表
 */
- (void)deletePublicIMListWihtId:(NSString *)sessionID {
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(deletePublicIMListWihtId:)]) {
        [self.appModelDelegate deletePublicIMListWihtId:sessionID];
    }
}
/**
 文件助手点击链接
 */
- (UIViewController *)sendWebLinkViewControllerWithDic:(NSDictionary *)dic {
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(sendWebLinkViewControllerWithDic:)]) {
        return  [self.appModelDelegate sendWebLinkViewControllerWithDic:dic];
    }
    return nil;
}
/**
 可实现回调，获取收藏界面
 */
- (UIViewController *)getCollectionViewControllerWithData:(NSDictionary *)dic {
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(getCollectionViewControllerWithData:)]) {
        return [self.appModelDelegate getCollectionViewControllerWithData:dic];
    }
    return nil;
}
/**
 获取添加好友界面
 */
-(UIViewController *)getAddRXfriend:(NSDictionary *)data {
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(getAddRXfriend:)]) {
        return [self.appModelDelegate getAddRXfriend:data];
    }
    return nil;
}
/**
 @userData 红包的透传userData字段
 */
- (BOOL)isRedpacketWithData:(NSString *)userData {
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(isRedpacketWithData:)]) {
        return [self.appModelDelegate isRedpacketWithData:userData];
    }
    return NO;
}
- (BOOL)isTransferWithData:(NSString *)userData {
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(isTransferWithData:)]) {
        return [self.appModelDelegate isTransferWithData:userData];
    }
    return NO;
}
- (BOOL)isRedpacketOpenMessageWithData:(NSString *)userData {
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(isRedpacketOpenMessageWithData:)]) {
        return [self.appModelDelegate isRedpacketOpenMessageWithData:userData];
    }
    return NO;
}



-(void)createBoardWithParams:(NSDictionary *)params andPresentedVC:(id)vc {
    [[AppModel sharedInstance] runModuleFunc:@"Board" :@"createBoardWithParams:andPresentVC:" :@[params,vc]];
}

-(void)joinBoardWithParams:(NSDictionary *)params andPresentedVC:(id)vc {
    [[AppModel sharedInstance] runModuleFunc:@"Board" :@"joinRoomWithParams:andPresentVC:" :@[params,vc]];
}
/**
 @brief             白板发送IM消息
 @param roomID      房间ID
 @param psd         房间密码
 @param toUser      发送的对方
 @param keyValue    用来区分IM的类型
 */
-(void)sendBoardMessageWithInfo:(NSDictionary *)info
{
    [[AppModel sharedInstance] runModuleFunc:@"Board" :@"sendBoardMessageWithInfo:" :@[info]];
}

-(void)cleanBoardInfo {
    [[AppModel sharedInstance] runModuleFunc:@"Board" :@"setCurrentRoomNil" :@[]];
    [[AppModel sharedInstance] runModuleFunc:@"Board" :@"setSubmitDocNil" :@[]];
}

/**
 @brief 聊天界面点击红包
 @param groupMembers 群组信息
 @param controller 群组信息
 @param isGroup 是否是群组
 @param completeBlock （）
 */
- (void)redPacketTapWithArray:(NSArray *)groupMembers withPersonDic:(NSDictionary *)data withCountType:(NSInteger)type withController:(UIViewController *)controller isGroup:(BOOL)isGroup completeBlock:(void (^)(NSString *text,NSString *userData))completeBlock {
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(redPacketTapWithArray:withPersonDic:withCountType:withController:isGroup:completeBlock:)]) {
        [self.appModelDelegate redPacketTapWithArray:groupMembers withPersonDic:data withCountType:type withController:controller isGroup:isGroup completeBlock:completeBlock];
    }
}
- (void)reloadRedpacketCellWithData:(NSDictionary *)data withVC:(id)Vc withSessionId:(NSString *)sessionID {
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(reloadRedpacketCellWithData:withVC:withSessionId:)]) {
        [self.appModelDelegate reloadRedpacketCellWithData:data withVC:Vc withSessionId:sessionID];
    }
}
/**
 单聊转账
 */
- (void)transformMoneyWithPerson:(NSDictionary *)persondic withSessionId:(NSString *)sessionId withVC:(UIViewController *)controller  {
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(transformMoneyWithPerson:withSessionId:withVC:)]) {
        //        [self.appModelDelegate transformMoneyWithSeesionId:sessionid success:success];
        [self.appModelDelegate transformMoneyWithPerson:persondic withSessionId:sessionId withVC:controller];
    }
    
}

/**
 @brief 个人详情界面点击钱包界面
 */
- (UIViewController *)clickedMoneyController {
    if (self.appModelDelegate && [self.appModelDelegate respondsToSelector:@selector(clickedMoneyController)]) {
        return  [self.appModelDelegate clickedMoneyController];
    }
    return nil;
}
#pragma mark  checkIsHaveNewVersionI
/** 检查版本更新 外部调用请通过 runtime 形式：
 * [[AppModel sharedInstance]runModuleFunc:@"AppModel" :@"checkIsHaveNewVersionIsUpAount:" :@[@0] hasReturn:NO];
 * 是否需要account
 */
- (void)checkIsHaveNewVersionIsUpAount:(NSNumber *)isNeed
{
    //    if(!self.isRequestVersionSucceed)
    //    {
    BOOL isNeedAccount = [isNeed boolValue];
    if(self.isLoading)
    {
        return;
    }
    
    NSString *account = nil;
    if(isNeedAccount){
        account = [Common sharedInstance].getAccount;
    }else{
        account = @"";
    }
    
    self.isLoading =YES;
    
    [[RestApi sharedInstance] checkVersionWithMobile:account didFinishLoaded:^(NSDictionary *dict, NSString *path) {
        
        NSDictionary *headDic = [dict objectForKey:@"head"];
        NSInteger statusCode = [[headDic objectForKey:@"statusCode"] integerValue];
        if (statusCode == 000000) {
            
            NSDictionary *bodyDic = [dict objectForKey:@"body"];
            
            //请求成功过
            self.isRequestVersionSucceed =YES;
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:KNotification_NEWVERSION];
            
            //新的版本号
            NSString *newVersion =[bodyDic objectForKey:@"version"];
            [[NSUserDefaults standardUserDefaults]setObject:newVersion forKey:KNotification_NEWVERSIONUPDATE];
            
            //描述
            NSString *description =[bodyDic objectForKey:@"verdesc"];
            [[NSUserDefaults standardUserDefaults] setObject:description forKey:KNotifcation_UPDATEDESCRITION];
            
            //更新地址
            NSString *urlData;
            if (KCNSSTRING_ISEMPTY(APP_ID)) {
                urlData = [bodyDic objectForKey:@"url"];
            }else{
                urlData = [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@?mt=8",APP_ID];
            }
            
            
            //是否强制
            int levelTag = [[bodyDic objectForKey:@"tag"] intValue];
            
            [[NSUserDefaults standardUserDefaults]setInteger:levelTag forKey:KNotifcation_FORCEUPDATE];
            
            //更新地址
            [[NSUserDefaults standardUserDefaults]setObject:urlData forKey:KNotification_UPDATEAPPURL];
            
            if (levelTag==1)
            {
                //有新版本
                [[NSUserDefaults standardUserDefaults]setObject:@"newVersion" forKey:KNotification_NEWVERSION];
                [self promptAlertShowDescription:description withNerVersion:newVersion withIsUpdateString: languageStringWithKey(@"以后再说")];
                
            }else if (levelTag==2)
            {
                //有新版本
                [[NSUserDefaults standardUserDefaults]setObject:@"newVersion" forKey:KNotification_NEWVERSION];
                [self promptAlertShowDescription:description withNerVersion:newVersion withIsUpdateString:nil];
                
            }
        }
        self.isLoading =NO;
        
    } didFailLoaded:^(NSError *error, NSString *path) {
        self.isLoading =NO;
        
    }];
    
    //    }
}

-(void)promptAlertShowDescription:(NSString *)description withNerVersion:(NSString *)version withIsUpdateString:(NSString *)cancel
{
    //    UIAlertView *alertView =[[UIAlertView alloc]initWithTitle:@"有新版本更新" message:nil  delegate:self cancelButtonTitle:cancel otherButtonTitles:@"立即更新", nil];
    //    UILabel *textLabel = [[UILabel alloc] init];
    //    textLabel.font = ThemeFontMiddle;
    //    textLabel.numberOfLines =0;
    //    alertView.tag = VERSION_ALERTVIEW_TAG;
    //    textLabel.textAlignment =NSTextAlignmentLeft;
    //    textLabel.text = description;
    //    [alertView setValue:textLabel forKey:@"accessoryView"];
    //    [alertView show];
    
    // hanwei 2017.8.16
    AlertSheet *alertView2 = [[AlertSheet alloc] initWithNerVersion:version withDexcription:description withCancel:cancel withFromPage:0 withChickBolck:^{
        //更新按钮
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:KNotification_NEWVERSION];
        NSString *url =[[NSUserDefaults standardUserDefaults]objectForKey:KNotification_UPDATEAPPURL];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        exit(0);
    }];
    [alertView2 showInView:nil];
    
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != alertView.cancelButtonIndex && alertView.tag == VERSION_ALERTVIEW_TAG)
    {
        //更新按钮
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:KNotification_NEWVERSION];
        NSString *url =[[NSUserDefaults standardUserDefaults]objectForKey:KNotification_UPDATEAPPURL];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        exit(0);
    }
}

/**
 * 初始化消息列表
 * yuxp
 */
- (void)initSessionList
{
    self.appData.curSessionsDict = nil;
    [[KitMsgData sharedInstance] getMyCustomSession];
}



- (NSString *)sendGetLogFileMsg:(NSArray *)member{
    
    NSDictionary *bodyDic = @{@"cmd":@"rongxin://debuglog",@"customtype":@"601"};
    NSString *userdataStr=[NSString stringWithFormat:@"UserData={%@}",[bodyDic coverString]];
    
    ECCmdMessageBody * cmdBody = [[ECCmdMessageBody alloc] initWithText:languageStringWithKey(@"日志控制指令")];
    cmdBody.offlinePush = YES;
    cmdBody.isSyncMsg = YES;
    cmdBody.isHint =NO;
    cmdBody.isSave = NO;
    ECMessage *cmdMsg = [[ECMessage alloc] initWithReceiver:[[member objectAtIndex:0] objectForKey:@"caller"] body:cmdBody];
    cmdMsg.apsAlert = nil;
    cmdMsg.userData = userdataStr;
    cmdMsg.isRead = NO;
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
    cmdMsg.timestamp=[NSString stringWithFormat:@"%lld", (long long)tmp];
    [[ECDevice sharedInstance].messageManager sendMessage:cmdMsg progress:nil completion:^(ECError *error, ECMessage *amessage){
        if (error.errorCode == ECErrorType_NoError) {
            NSString *tep = [NSString stringWithFormat:@"%@----  rongxin://debuglog",languageStringWithKey(@"我发了一条取日志的指令")];
            ECTextMessageBody *messageBody = [[ECTextMessageBody alloc] initWithText:tep];
            amessage.messageBody = messageBody;
            [[KitMsgData sharedInstance] addNewMessage:amessage andSessionId:amessage.sessionId];
        }
    }];
    return nil;
}

/**
 * SVC会议通知
 */
- (void)onReceivedConferenceVoiceMemberNotification:(NSDictionary *)info{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_onReceiveVoiceMembersInConf object:info];
}

- (void) onReceivedConferenceVoiceMemberWithID:(NSString *)confId members:(NSArray *)members{
    /// eagle 有会
     [[NSNotificationCenter defaultCenter]postNotificationName:kNOTIFICATION_onReceiveVoiceMembersInConf object:@{@"confId":confId?:@"",@"members":members?:@[]}];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_onReceiveVoiceMembersInConf object:@{@"confId":confId,@"members":members}];
}
/// eagle 有会逻辑
-(void)onReceivedConferenceNotification2:(ECConferenceNotification*)info {
    int var = info.type;
    //    NSLog(@"8888888=====%d",var);
    if (!self.confStateDic) {
        self.confStateDic = [NSMutableDictionary dictionary];
    }
    NSMutableDictionary *myConfStateDic = self.confStateDic[self.account];
    if (!myConfStateDic) {
        myConfStateDic = [NSMutableDictionary dictionary];
    }
    if (var==ECConferenceNotificationType_Invite) {
        ECConferenceInviteNotification *inviteInfoMsg = (ECConferenceInviteNotification*)info;
        [myConfStateDic setValue:@(YES) forKey:inviteInfoMsg.conferenceId?:@""];
        [self.confStateDic setValue:myConfStateDic forKey:self.account];
        if (inviteInfoMsg.callImmediately == 0){
//            [NSObject yhc_runModule:@"YHCChat" func:@"onReceivedConfAlterationMsg:" parms:@[info]];
            [self runModuleFunc:@"YHCChat" :@"onReceivedConfAlterationMsg:" :@[info] hasReturn:NO];
        }else
            if (![inviteInfoMsg.appData isEqualToString:@"reservation invitation notice"]) {
                CGFloat time = [inviteInfoMsg.inviteTime doubleValue]/1000;
                NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
                //实例化一个NSDateFormatter对象
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                //设定时间格式,这里可以设置成自己需要的格式
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString * str1 = [dateFormatter stringFromDate: detaildate];
                NSDate *date = [NSDate date];
                NSDate *nextDay = [NSDate dateWithTimeInterval:-60*60*24 sinceDate:date];
                NSString *DateTime = [dateFormatter stringFromDate:nextDay];
                int current = [self compareDate:DateTime withDate:str1];
                if (current == -1) {
                    //一天前
                    return;
                }else{
                    WS(weakSelf)
                    [[ECDevice sharedInstance].conferenceManager getConference:inviteInfoMsg.conferenceId completion:^(ECError *error, ECConferenceInfo *conferenceInfo) {
                        if (error.errorCode == ECErrorType_NoError) {
                            NSMutableDictionary *myConfStateDic = weakSelf.confStateDic[weakSelf.account];
                            if (![myConfStateDic[conferenceInfo.conferenceId] boolValue]) {
                                return;
                            }
                            
                            inviteInfoMsg.appData = conferenceInfo.appData;
                            NSString *roomType = [NSString stringWithFormat:@"%d",conferenceInfo.confRoomType];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_ReloadConfCurrentList object:nil];
                                [[AppModel sharedInstance]runModuleFunc:@"YHCConference" :@"getInviteWithMsg:withRoomType:" :@[inviteInfoMsg,roomType] hasReturn:NO];
//                                [[AppModel sharedInstance] runModuleFunc:@"FusionMeeting" :@"getInviteWithMsg:":@[inviteInfoMsg] hasReturn:NO];
                                
                            });
                        }
                    }];
                }
            }else{
//                [NSObject yhc_runModule:@"YHCChat" func:@"onReceivedConfAlterationMsg:" parms:@[info]];
                 [[AppModel sharedInstance]runModuleFunc:@"YHCChat" :@"onReceivedConfAlterationMsg:" :@[info] hasReturn:NO];
            }
        
    } else if (var == ECConferenceNotificationType_Subscribe) {//预约
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_ReloadConfCurrentList object:nil];
        
    } else if (var == ECConferenceNotificationType_Recommend) {//用户推荐
//        [NSObject yhc_runModule:@"YHCAddressbook" func:@"onReceivedConferenceRecommendNotification:" parms:@[info]];
    } else if (var == ECConferenceNotificationType_AppSystem) {
//        [NSObject yhc_runModule:@"YHCAddressbook" func:@"onReceivedConferenceAppSysteNotification:" parms:@[info]];
    } else if (var == ECConferenceNotificationType_Update) {
        //接收会议变更消息
        ECConferenceUpdateNotification * updateMsg = (ECConferenceUpdateNotification *)info;
        if (!(updateMsg.state & 1)) {
            if (updateMsg.action == 55) {
//                [NSObject yhc_runModule:@"YHCChat" func:@"onReceivedConfAlterationMsg:" parms:@[info]];
                [[AppModel sharedInstance]runModuleFunc:@"YHCChat" :@"onReceivedConfAlterationMsg:" :@[info] hasReturn:NO];
            } else if (updateMsg.action == 54) {
//                [NSObject yhc_runModule:@"YHCChat" func:@"onReceivedConfAlterationMsg:" parms:@[info]];
                [[AppModel sharedInstance]runModuleFunc:@"YHCChat" :@"onReceivedConfAlterationMsg:" :@[info] hasReturn:NO];
            }
        }
    } else if (var == ECConferenceNotificationType_Near) {
        //会议即将开始
        ECConferenceNearNotification * nearMsg = (ECConferenceNearNotification *)info;
        //实例化一个NSDateFormatter对象
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //设定时间格式,这里可以设置成自己需要的格式
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = [NSDate date];
        NSString *DateTime = [dateFormatter stringFromDate:date];
        int current = [self compareDate:DateTime withDate:nearMsg.startTime];
        if (current == 1) {
            if ([nearMsg.creator.accountId isEqualToString:[[Common sharedInstance] getAccount]]) {
                RXCommonDialog * dialog = [RXCommonDialog presentModalDialogFromNibWidthDelegate:nil withPos:EContentPosMIDk withTapAtBackground:YES];
                [dialog showTitle:languageStringWithKey(@"提示") subTitle:@"您预约的会议三分钟以后即将开始，请提前安排好时间" ensureStr:languageStringWithKey(@"确定") cancalStr:nil selected:^(NSInteger index) {
                }];
            }
        }
    }else if (var == ECConferenceNotificationType_Delete) {
        ECConferenceDeleteNotification * delMsg = (ECConferenceDeleteNotification *)info;
        [myConfStateDic setValue:@(NO) forKey:delMsg.conferenceId?:@""];
        [self.confStateDic setValue:myConfStateDic forKey:self.account];
        if (delMsg.state & 1) {
        }else{
//            [NSObject yhc_runModule:@"YHCChat" func:@"onReceivedConfAlterationMsg:" parms:@[info]];
            [[AppModel sharedInstance]runModuleFunc:@"YHCChat" :@"onReceivedConfAlterationMsg:" :@[info] hasReturn:NO];
        }
    }else if (var == ECConferenceNotificationType_CancelInvite) {
        ECConferenceCancelInviteNotification * delMsg = (ECConferenceCancelInviteNotification *)info;
        [myConfStateDic setValue:@(NO) forKey:delMsg.conferenceId?:@""];
        [self.confStateDic setValue:myConfStateDic forKey:self.account];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_OnReceiveConferenceMsg object:info];
}
/// eagle 原来的插件走的方法
- (void)onReceivedConferenceNotification:(ECConferenceNotification*)info {
    int var = info.type;
    ECConferenceInviteNotification *inviteInfoMsg2 = (ECConferenceInviteNotification*)info;
    if (var==ECConferenceNotificationType_Invite) {
        
        // 判断是否在会议中，退出会议
        if ([AppModel sharedInstance].isInVoip && inviteInfoMsg2.callImmediately != 0) {
            if (self.closeConfFirst) {
                return;
            }
            __block typeof(self) weakSelf = self;
            UIAlertView *alertView = [UIAlertView showAlertView:@"会议通知" message:@"是否先结束通话，再加入会议" click:^{
                weakSelf.closeConfFirst = nil;
                [[NSNotificationCenter defaultCenter]postNotificationName:kNotification_CloseVoip object:nil];
                ECConferenceInviteNotification *inviteInfoMsg = (ECConferenceInviteNotification*)info;
                if (inviteInfoMsg.callImmediately == 0){
                    [[AppModel sharedInstance] runModuleFunc:@"YHCChat" :@"onReceivedConfAlterationMsg:":@[info] hasReturn:NO];
                }else
                    if (![inviteInfoMsg.appData isEqualToString:@"reservation invitation notice"]) {
                        CGFloat time = [inviteInfoMsg.inviteTime doubleValue]/1000;
                        NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
                        //实例化一个NSDateFormatter对象
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        //设定时间格式,这里可以设置成自己需要的格式
                        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                        NSString * str1 = [dateFormatter stringFromDate: detaildate];
                        NSDate *date = [NSDate date];
                        NSDate *nextDay = [NSDate dateWithTimeInterval:-60*60*24 sinceDate:date];
                        NSString *DateTime = [dateFormatter stringFromDate:nextDay];
                        int current = [weakSelf compareDate:DateTime withDate:str1];
                        if (current == -1) {
                            //一天前
                            return;
                        }else{
                            [[CoreModel sharedInstance] getConference:inviteInfoMsg.conferenceId completion:^(ECError *error, ECConferenceInfo *conferenceInfo) {
                                if (error.errorCode == ECErrorType_NoError) {
                                     inviteInfoMsg.appData = conferenceInfo.appData;
                                 NSString *roomType = [NSString stringWithFormat:@"%d",conferenceInfo.confRoomType];
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_ReloadConfCurrentList object:nil];
                                     [[AppModel sharedInstance]runModuleFunc:@"YHCConference" :@"getInviteWithMsg:withRoomType:" :@[inviteInfoMsg,roomType] hasReturn:NO];
                       
                                 
                                 });
                                }
                            }];
                        }
                    }else{
                        [[AppModel sharedInstance] runModuleFunc:@"YHCChat" :@"onReceivedConfAlterationMsg:":@[info] hasReturn:NO];
                    }
            } cancel:^{
                weakSelf.closeConfFirst = nil;
                return ;
            }];
            [alertView show];
            self.closeConfFirst = alertView;
            return;
        }
        ECConferenceInviteNotification *inviteInfoMsg = (ECConferenceInviteNotification*)info;
        if (inviteInfoMsg.callImmediately == 0){
            [[AppModel sharedInstance] runModuleFunc:@"YHCChat" :@"onReceivedConfAlterationMsg:":@[info] hasReturn:NO];
        }else
            if (![inviteInfoMsg.appData isEqualToString:@"reservation invitation notice"]) {
                CGFloat time = [inviteInfoMsg.inviteTime doubleValue]/1000;
                NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
                //实例化一个NSDateFormatter对象
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                //设定时间格式,这里可以设置成自己需要的格式
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSString * str1 = [dateFormatter stringFromDate: detaildate];
                NSDate *date = [NSDate date];
                NSDate *nextDay = [NSDate dateWithTimeInterval:-60*60*24 sinceDate:date];
                NSString *DateTime = [dateFormatter stringFromDate:nextDay];
                int current = [self compareDate:DateTime withDate:str1];
                if (current == -1) {
                    //一天前
                    return;
                }else{
                    [[CoreModel sharedInstance] getConference:inviteInfoMsg.conferenceId completion:^(ECError *error, ECConferenceInfo *conferenceInfo) {
                        if (error.errorCode == ECErrorType_NoError) {
                            inviteInfoMsg.appData = conferenceInfo.appData;
                             inviteInfoMsg.appData = conferenceInfo.appData;
                            NSString *roomType = [NSString stringWithFormat:@"%d",conferenceInfo.confRoomType];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_ReloadConfCurrentList object:nil];
                                [[AppModel sharedInstance]runModuleFunc:@"YHCConference" :@"getInviteWithMsg:withRoomType:" :@[inviteInfoMsg,roomType] hasReturn:NO];
//                                  [[AppModel sharedInstance] runModuleFunc:@"FusionMeeting" :@"getInviteWithMsg:":@[inviteInfoMsg] hasReturn:NO];
                                                            
                            });
                        }
                    }];
                }
            }else{
                [[AppModel sharedInstance] runModuleFunc:@"FusionMeeting" :@"onReceivedConfAlterationMsg:":@[info] hasReturn:NO];
            }
        
    } else if (var == ECConferenceNotificationType_Subscribe) {//预约
        [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_ReloadConfCurrentList object:nil];
    } else if (var == ECConferenceNotificationType_Update) {
        //接收会议变更消息
        ECConferenceUpdateNotification * updateMsg = (ECConferenceUpdateNotification *)info;
        if (updateMsg.action == 55) {
            [[AppModel sharedInstance] runModuleFunc:@"YHCChat" :@"onReceivedConfAlterationMsg:":@[info] hasReturn:NO];
        } else if (updateMsg.action == 54) {
            [[AppModel sharedInstance] runModuleFunc:@"YHCChat" :@"onReceivedConfAlterationMsg:":@[info] hasReturn:NO];
        }
    } else if (var == ECConferenceNotificationType_Near) {
        //会议即将开始
        ECConferenceNearNotification * nearMsg = (ECConferenceNearNotification *)info;
        //实例化一个NSDateFormatter对象
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //设定时间格式,这里可以设置成自己需要的格式
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = [NSDate date];
        NSString *DateTime = [dateFormatter stringFromDate:date];
        int current = [self compareDate:DateTime withDate:nearMsg.startTime];
        if (current == 1) {
            if ([nearMsg.creator.accountId isEqualToString:[Common sharedInstance].getAccount]) {
                [UIAlertView showAlertView:languageStringWithKey(@"提示") message:languageStringWithKey(@"您预约的会议三分钟以后即将开始，请提前安排好时间") click:^{
                    
                } okText:languageStringWithKey(@"确定")];
                
            }
        }
    }else if (var == ECConferenceNotificationType_Delete) {
        ECConferenceDeleteNotification * delMsg = (ECConferenceDeleteNotification *)info;
        if (delMsg.state) {
        }else{
            [[AppModel sharedInstance] runModuleFunc:@"YHCChat" :@"onReceivedConfAlterationMsg:":@[info] hasReturn:NO];
        }
    }else if (var == ECConferenceNotificationType_CancelInvite){
        // 先判断是其他端
        ECConferenceJoinNotification *joinInfo = (ECConferenceJoinNotification *)info;
        if(joinInfo.members.count>0){
            ECConferenceMemberInfo *memberInfo = joinInfo.members[0];
            if(memberInfo.account.deviceType != ECDeviceType_iPhone){
                NSLog(@"其他端已接听");
                //            [SVProgressHUD showErrorWithStatus:@"其他端已接听"];
                return;
                //                [[ECDevice sharedInstance].conferenceManager rejectInvitation:@"" cause:@"107781" ofConference:inviteInfoMsg2.conferenceId completion:^(ECError *error) {
                //                    if (error.errorCode == ECErrorType_NoError) {
                //
                //                    }
                //                    //                // 移除接听界面
                //                    [[NSNotificationCenter defaultCenter]postNotificationName:@"YHCConferenceAnswerViewControllerRemoveSelfFromWidow" object:nil];
                //                }];
            }else{
                // 移除接听界面
                [[NSNotificationCenter defaultCenter]postNotificationName:@"YHCConferenceAnswerViewControllerRemoveSelfFromWidow" object:nil];
            }
        }
        
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNOTIFICATION_OnReceiveConferenceMsg object:info];
}

- (void)onCallVideoRatioChanged:(NSString *)confId andAccount:(ECAccountInfo *)account andType:(int)type andWidth:(NSInteger)width andHeight:(NSInteger)height andVideoSource:(NSString *)videoSource {
    /// eagle 有会
    NSDictionary *dic = @{@"confId":confId?:@"",
                          @"account":account?:@"",
                          @"type":[NSNumber numberWithInt:type],
                          @"width":[NSNumber numberWithInteger:width],
                          @"height":[NSNumber numberWithInteger:height],
                          @"videoSource":videoSource?:@""};
    [[NSNotificationCenter defaultCenter]postNotificationName:kNOTIFICATION_onCallVideoRatioChanged object:dic];
}


- (int)compareDate:(NSString*)date01 withDate:(NSString*)date02{
    int ci;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    NSDate *dt1 = [df dateFromString:date01];
    NSDate *dt2 = [df dateFromString:date02];
    NSComparisonResult result = [dt1 compare:dt2];
    switch (result)
    {
            //date02比date01大
        case NSOrderedAscending: ci=1; break;
            //date02比date01小
        case NSOrderedDescending: ci=-1; break;
            //date02=date01
        case NSOrderedSame: ci=0; break;
        default: DDLogInfo(@"erorr dates %@, %@", dt2, dt1); break;
    }
    return ci;
}
/// eagle 有会
//没达到指定日期，返回-1，刚好是这一时间，返回0，否则返回1
- (int)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *oneDayStr = [dateFormatter stringFromDate:oneDay];
    NSString *anotherDayStr = [dateFormatter stringFromDate:anotherDay];
    NSDate *dateA = [dateFormatter dateFromString:oneDayStr];
    NSDate *dateB = [dateFormatter dateFromString:anotherDayStr];
    NSComparisonResult result = [dateA compare:dateB];
    if (result == NSOrderedDescending) {
        //NSLog(@"Date1  is in the future");
        return 1;
    }
    else if (result == NSOrderedAscending){
        //NSLog(@"Date1 is in the past");
        return -1;
    }
    //NSLog(@"Both dates are the same");
    return 0;
    
}

-(void)onReceiveMultiDeviceState:(NSArray*)multiDevices{
    NSArray *multiDArray =multiDevices;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkPCloginIn" object:nil];
    DDLogInfo(@"%@",multiDArray);
}
#pragma mark --多语言
- (void)switchOtherLangeuage:(NSInteger)type{
    switch (type) {
        case 0:
            [[LanguageTools sharedInstance] setNewLanguage:Chinese_Simple];
            break;
        case 1:
            [[LanguageTools sharedInstance] setNewLanguage:English_US];
            break;
        case 2:
            [[LanguageTools sharedInstance] setNewLanguage:Korean];
            
            break;
        case 3:
            [[LanguageTools sharedInstance] setNewLanguage:Chinese_Traditional];
            break;
        default:
            break;
    }
}
#pragma mark - 消息相关处理
// 收到多终端置顶的消息，然后进行沙盒处理
- (void)setTopListWithUserDataDic:(NSDictionary *)userDataDic{
    BOOL isNewJson = [userDataDic hasValueForKey:SMSGTYPE];
    NSString *account = isNewJson ? userDataDic[@"sid"] : userDataDic[@"account"];
    NSString *isTop = userDataDic[@"isTop"];

    if([isTop isEqualToString:@"true"] ||
       [isTop isEqualToString:@"1"]){
        // 置顶消息和置顶
        NSString *cur_top_key = [NSString stringWithFormat:@"%@_cur_top", account];
        [[NSUserDefaults standardUserDefaults] setObject:cur_top_key forKey:[NSString stringWithFormat:@"%@%@",SETUPTOP,account]];
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSString *str = [NSDate getTimeStrWithDate:date];
        [[NSUserDefaults standardUserDefaults]setObject:str forKey:[NSString stringWithFormat:@"%@%@",SETUPTOPNEWTIME,account]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else if([isTop isEqualToString:@"false"] ||
             [isTop isEqualToString:@"0"]){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOP,account]];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:[NSString stringWithFormat:@"%@%@",SETUPTOPNEWTIME,account]];
    }
}
// 收到多终端新消息通知的消息，然后进行沙盒处理
- (void)setMsgMuteWithUserDataDic:(NSDictionary *)userDataDic{
    BOOL isNewJson = [userDataDic hasValueForKey:SMSGTYPE];
    NSString *account = isNewJson ? userDataDic[@"sid"] : userDataDic[@"account"];
    NSString *isMute = userDataDic[@"isMute"];
//    mDic[@"isNotice"] = @(isNotice);
//    mDic[@"sessionId"] = sessionId;
//    mDic[@"type"]
    // 新消息通知
    NSString *notice_key = [NSString stringWithFormat:@"%@_%@_notice",[[Common sharedInstance] getAccount], account];
    if([isMute isEqualToString:@"true"] ||
       [isMute isEqualToString:@"1"]){
        [[KitMsgData sharedInstance]updateMessageNoticeid:account withNoticeStatus:1];
        NSUserDefaults *userGroupId = [NSUserDefaults standardUserDefaults];
        [userGroupId  setObject:@"1" forKey:notice_key];
        [[NSUserDefaults standardUserDefaults] synchronize];
         [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChangedTheSessionId object:account];
    }else if([isMute isEqualToString:@"false"] ||
             [isMute isEqualToString:@"0"]){
        [[KitMsgData sharedInstance]updateMessageNoticeid:account withNoticeStatus:0];
        NSUserDefaults *userGroupId = [NSUserDefaults standardUserDefaults];
        [userGroupId removeObjectForKey:notice_key];
        [[NSUserDefaults standardUserDefaults] synchronize];
         [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChangedTheSessionId object:account];
    }
}

///处理修改密码的强制退出通知
- (void)onReceiveMessageOfModifyPasswordWithData:(ECMessage *)message{
    NSString *keyStr = [NSString stringWithFormat:@"%@,",kUpdatePwdNotice_CustomType];
    NSString *userDataCove = [message.userData substringFromIndex:keyStr.length];
    
    message.userData = userDataCove;
    NSDictionary *userDataDic = [self ChangePass:message];
    NSDictionary *pwdMd5Dic = [userDataDic objectForKey:UpdatePwdPBSIM];
    NSString *syncDeviceName = [userDataDic objectForKey:@"syncDeviceName"];//设备类型
    //        NSInteger modifypasswd = [[pwdMd5Dic objectForKey:@"modifypasswd"] integerValue];//修改密码次数
    NSString *clientPwdMD5Str = [pwdMd5Dic objectForKey:@"clientPwdMD5"];
    NSString *locationClientPwdMD5Str = [[[Common sharedInstance] getAppClientpwd] MD5EncodingString];
    // 比较 ，忽略大小写
    BOOL result = [clientPwdMD5Str caseInsensitiveCompare:locationClientPwdMD5Str] == NSOrderedSame;
    if (!result &&
        [KitGlobalClass sharedInstance].isLogin
        /*&& modifypasswd > [[RXUser sharedInstance].modifypasswd integerValue]*/) {
        [KitGlobalClass sharedInstance].isLogin = NO;
        [KitGlobalClass sharedInstance].userName = nil;
        //防止直接杀死进程 用户信息还存在，下次进来依旧可以使用
        //用户退出时，清除推送时缓存的用户信息
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"%@%@",[[Common sharedInstance] getAccount],@"isLoginSetPersonInfo",nil]];
        [[AppModel sharedInstance] runModuleFunc:@"RXUser" :@"logout" :nil hasReturn:NO];
        [[AppModel sharedInstance] logout:nil];
        
        NSString *title;
        if ([syncDeviceName isEqualToString:BMSystem]) {
            title = languageStringWithKey(@"你在后台管理系统修改了密码，请重新登录");
        }else if ([syncDeviceName isEqualToString:kClientType_PC]){
            title = languageStringWithKey(@"你在PC上修改了密码，请重新登录");
        }else{
            title = languageStringWithKey(@"你在另一端修改了密码，请重新登录");
        }
        
        RXCommonDialog * dialog = [RXCommonDialog presentModalDialogFromNibWidthDelegate:nil withPos:EContentPosMIDk withTapAtBackground:YES];
        [dialog showTitle:languageStringWithKey(@"下线提示") subTitle:title ensureStr:languageStringWithKey(@"确定") cancalStr:nil selected:^(NSInteger index) {
            if (index == 1) {
                [[AppModel sharedInstance] logout:^(NSError *error) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"GOTOSWITCH" object:nil];
                }];
            }
        }];
    }
}
- (NSDictionary *)ChangePass:(ECMessage *)message{
    NSData *data = [message.userData dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length < 1) {
        return nil;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    DDLogInfo(@"dict = %@",dict);
    return dict;
}
///账号冻结 字段暂时不全，需要后台来改
- (BOOL)onReceiveMessageOfAccountForzenedWithData:(ECMessage *)message{
    //账号冻结消息判断
    if (!KCNSSTRING_ISEMPTY(message.userData) && [message.userData rangeOfString:KAccountFrozen_CustomType].location != NSNotFound) {
        
        if ([self.appModelDelegate  respondsToSelector:@selector(responseAccountFreezedKickedOff)]){
            [self.appModelDelegate responseAccountFreezedKickedOff];
        }
        return YES;
        //获取信息
        [[RestApi sharedInstance] getVOIPUserInfoWithMobile:[[Common sharedInstance] getAccount] type:@"2" didFinishLoaded:^(NSDictionary *dict, NSString *path) {
            NSInteger statusCode = [[[dict objectForKey:@"head"]objectForKey:@"statusCode"]integerValue];
            if (statusCode == 900005 || statusCode ) {
                //                NSArray *voipInfos = dict[@"body"][@"voipinfo"];
                //                NSDictionary *infoDict = voipInfos[0];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if ([self.appModelDelegate  respondsToSelector:@selector(responseAccountFreezedKickedOff)]){
                        [self.appModelDelegate responseAccountFreezedKickedOff];
                    }
                });
            }
        } didFailLoaded:^(NSError *error, NSString *path) {
            if (error.code == 900005) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if ([self.appModelDelegate  respondsToSelector:@selector(responseAccountFreezedKickedOff)]){
                        [self.appModelDelegate responseAccountFreezedKickedOff];
                    }
                });
            }
        }];
        return YES;
    }else if (!KCNSSTRING_ISEMPTY(message.userData) && [message.userData rangeOfString:KAccountleavejob_CustomType].location != NSNotFound) {
        //解析userData add yuxp 2017.11.2 人员离职
        NSMutableArray *arrayData = [[NSMutableArray alloc] initWithArray:[message.userData componentsSeparatedByString:@","]];
        [arrayData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *tempString = obj;
            if([tempString rangeOfString:@"customtype="].location!=NSNotFound){
                *stop = YES;
                [arrayData removeObject:obj];
            }
        }];
        NSString *dataStr = [arrayData componentsJoinedByString:@","];
        NSDictionary *im_jsonDic = [NSJSONSerialization JSONObjectWithData:[dataStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        NSString *account = im_jsonDic[@"account"];
        long long status = [im_jsonDic[@"userStatus"] longLongValue];
        if(account && account.length > 0){
            if([account isEqualToString:message.to]){
                //发给自己的 说明自己离职
                if ([self.appModelDelegate  respondsToSelector:@selector(responseAccountleaveJob)]){
                    [self.appModelDelegate responseAccountleaveJob];
                }
            }else{
                //更新当前删除用户的状态 @"3"
                [[AppModel sharedInstance] runModuleFunc:@"RXAddressBook" :@"updateAddressUserStatus:withAccount:" :@[[NSString stringWithFormat:@"%lld",status],account]];
                //删除好友列表 好友申请更新列表  清空邀请数 删除特别关注
                //[HXAddnewFriendList deleteOneFriendData:account];
                [HXMyFriendList deleteOneMyFriendData:account];
                //[HXInviteCountData updateInviteCount:0 withAccount:account];
                [HXAddnewFriendList updateFrienInviteStatus:account inviteFriendType:kExpiredVerification];
                [HXSpecialData deleteSpecialAccount:account];
                //更新通讯录缓存
                [[AppModel sharedInstance] runModuleFunc:@"RXAddressBook" :@"updateAddressCache:withAccount:" :@[[NSString stringWithFormat:@"%lld",status],account]];
                //发送通知 实时更新 更新邀请列表 好友列表 特别关注 IM消息列表 先不做
                [[NSNotificationCenter defaultCenter] postNotificationName:@"HXUserLeaveJobAtNow" object:account];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteFriendSend" object:nil];
            }
        }
        return YES;
    }
    return NO;
}
///后台强制删除用户
- (BOOL)onReceiveMessageOfAccountDelWithData:(ECMessage *)message{
    if(!KCNSSTRING_ISEMPTY(message.userData) && [message.userData rangeOfString:KAccountDel_CustomType].location != NSNotFound){
        //删除用户的操作和冻结相同
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([self.appModelDelegate  respondsToSelector:@selector(responseAccountDelete)]){
                [self.appModelDelegate responseAccountDelete];
            }
        });
        return YES;
    }else{
        return NO;
    }
}

///特别关注的同步消息
- (BOOL)onReceiveSpecialSynNoticeWithMessage:(ECMessage *)message{
    if(!KCNSSTRING_ISEMPTY(message.userData) &&
       [message.userData rangeOfString:kSpecialSynNotice_CustomType].location!= NSNotFound){
        NSString *keyStr = [NSString stringWithFormat:@"%@,",kSpecialSynNotice_CustomType];
        NSString *userDataCove = [message.userData substringFromIndex:keyStr.length];
        NSDictionary *userDataDic = [self getDic:userDataCove];
        if ([userDataDic[kVidyoSyncDeviceName] isEqualToString:kClientType_PC]) {
            NSInteger specialType = [userDataDic[@"type"] integerValue];
            NSArray *specialUserArr = userDataDic[@"attentionAccounts"];
            if (specialType == 0) {//添加特别关注
                [HXSpecialData insertSpecialAttentsInfo:specialUserArr];
            }else if (specialType == 1) {//取消特别关注
                [HXSpecialData deleteSpecialAttentsInfo:specialUserArr];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_SpecialSynNotice object:nil];
        }
        return YES;
    }
    return NO;
}
///OA监控
- (BOOL)onReceiveOAMessage:(ECMessage *)message{
    NSNumber *isCheckOANum = [self runModuleFunc:@"HXOAMessageManager" :@"obtainIsOAMessage:" :@[message]];
    BOOL isCheckOA = [isCheckOANum boolValue];
    if(!KCNSSTRING_ISEMPTY(message.userData) && isCheckOA){
        message.isRead = NO;//sdk
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_OAMessage_RECEIVE object:message];
        return  YES;
    }else{
        return NO;
    }
}
///屏蔽自己(服务端推送)发送的请假审批消息
- (BOOL)onReceiveMessageOfAskForLeaveWithData:(ECMessage *)message {
    NSDictionary *im_mode = [MessageTypeManager getCusDicWithUserData:message.userData];
    if([im_mode hasValueForKey:@"IM_Mode"] &&
       [[im_mode objectForKey:@"IM_Mode"] isEqualToString:@"APRV"] &&
       [message.from isEqualToString:[Common sharedInstance].getAccount]) {
        return YES;
    }
    return NO;
}
///邀请朋友消息
- (BOOL)onReceiveFriendMessage:(ECMessage *)message userData:(NSDictionary *)userData{
    if (!message.isAddFriendMessage) {
        return NO;
    }
    if ([userData hasValueForKey:SMSGTYPE]) {//好友验证消息
        NSString *account = userData[@"account"];
        //1.好友验证消息，列表显示为待添加状态 2.友验证通过消息，显示成消息状态
        NSString *status = userData[@"status"];
        NSString *msg = userData[@"msg"];

        HXAddnewFriendList *friendList = [[HXAddnewFriendList alloc] init];
        friendList.userAccount = account;
        friendList.describeMessage = msg;
        friendList.inviteStatus = kNeedToPassVerification;
        friendList.friendType = 1;
        friendList.userId = @"";
        if ([status isEqualToString:@"1"]) {
            BOOL isexist = [HXAddnewFriendList isExistLocationNewInvite:friendList.userAccount InviteFriendStatus:kNeedToPassVerification];
            if(isexist){//消息入库
                [HXAddnewFriendList insertImMessage:friendList];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"onReceiverFriendSend" object:friendList.userAccount];
                return YES;
            }else{
                //判断本地是否存在 存在则不做处理
                BOOL isExistFriend = [RXMyFriendList isMyFriend:friendList.userAccount];
                if(isExistFriend){
                    return YES;
                }
            }
            //消息入库
            [HXAddnewFriendList insertImMessage:friendList];
            //wwl 目前逻辑insertImMessage时会判断本地是否有这个人的邀请数据，邀请多次只会更新本地数据，一个人的邀请信息只会有一条，故存储消息数时存1即可
            [HXInviteCountData insertInviteCount:1 withAccount:friendList.userAccount];
            [[NSNotificationCenter defaultCenter]postNotificationName:KMyFriendInviteMessList_InviteId object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"onReceiverFriendSend" object:friendList.userAccount];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"onReceiverFriendSendNewVC" object:nil];// 刷新新的朋友界面
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addFriendTitleContactInfo" object:nil];//添加好友，个人中心页更新按钮名字
        }else if ([status isEqualToString:@"2"]){
            //内容里暂时没有设备字段
//            if(syncDeviceName &&
//               ![syncDeviceName isEqualToString:@"iPhone"] &&
//               [message.from isEqualToString:[Common sharedInstance].getOneAccount]){
//                if(message.messageBody.messageBodyType == MessageBodyType_Command){
//                    ECTextMessageBody *textBody = [[ECTextMessageBody alloc] initWithText:languageStringWithKey(@"你们已经是好友了, 现在可以开始聊天了")];
//                    message.messageBody = textBody;
//                }else{
//                    //兼容之前的好友请求
//                    ECTextMessageBody *textBody = (ECTextMessageBody *)message.messageBody;
//                    textBody.text = languageStringWithKey(@"你们已经是好友了, 现在可以开始聊天了");
//                    message.messageState = ECMessageState_SendSuccess;
//                }
//                NSDictionary *userParas = [NSDictionary dictionaryWithObjectsAndKeys:receiverFriendInvite,receiverFriendInvite, nil];
//                NSString *userdataStr = [NSString stringWithFormat:@"%@",[userParas coverString]];
//                message.userData = userdataStr;
//
//                [[KitMsgData sharedInstance] addNewMessage:message andSessionId:message.sessionId];
//                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:message];
//                //修改下  由于是PC的同步消息 好友ID改成message.to
//                friendList.userAccount = message.to;
//                [HXInviteCountData updateInviteCount:0 withAccount:friendList.userAccount];
//                //更新数据库
//                [HXAddnewFriendList updateFrienInviteStatus:friendList.userAccount inviteFriendType:kAddAsNewFriends];
//                //更新好友列表
//                RXMyFriendList *newfriendList = [[RXMyFriendList alloc] init];
//                newfriendList.account = friendList.userAccount;
//                [RXMyFriendList insertOneFriend:newfriendList];
//                //邀请数量的通知
//                [[NSNotificationCenter defaultCenter]postNotificationName:KMyFriendInviteMessList_InviteId object:nil];
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"onReceiverFriendSend" object:friendList.userAccount];
//                //添加好友，个人中心页更新按钮名字
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"addFriendTitleContactInfo" object:nil];
//                // 对方已接受
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"onReceiverFriendSendNewVC_DF_Accepted" object:friendList];
//            }else{
            
                return YES;
                //显示对方通过你的好友验证 直接入库 //兼容老版本
                NSString *inviteText = languageStringWithKey(@"我通过了你的好友验证请求,现在我们可以开始聊天了");
                if(message.messageBody.messageBodyType == MessageBodyType_Command){
//                    ECCmdMessageBody *ccmdMess = (ECCmdMessageBody *) message.messageBody;
//                    ccmdMess.text = inviteText;
                    ECTextMessageBody *textBody = [[ECTextMessageBody alloc] initWithText:inviteText];
                    message.messageBody = textBody;
                    message.sessionId = account;
                    if ([userData[@"device"] isEqualToString:@"PC"]) {
                        message.from = account;
                        message.sessionId = account;
                    }
                }
                [[KitMsgData sharedInstance] addNewMessage:message andSessionId:message.sessionId];
                //其他操作 当有邀请记录的时候 又去邀请别人
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    BOOL isexist = [HXAddnewFriendList isExistLocationNewInvite:friendList.userAccount InviteFriendStatus:kNeedToPassVerification];
                    if(isexist){
                        [HXAddnewFriendList updateFrienInviteStatus:friendList.userAccount inviteFriendType:kAddAsNewFriends];
                        NSInteger count = [HXInviteCountData getCurrentInviteCount];
                        count --;
                        count = count<=0?0:count;
                        [HXInviteCountData insertInviteCount:count withAccount:friendList.userAccount];
                        //邀请数量的通知
                        [[NSNotificationCenter defaultCenter] postNotificationName:KMyFriendInviteMessList_InviteId object:nil];
                    }
                });
//            }
            //添加好友成功回执
            RXMyFriendList *friendmodel = [[RXMyFriendList alloc] init];
            friendmodel.account = friendList.userAccount;
            [RXMyFriendList insertOneFriend:friendmodel];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:message];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_update_session_im_message_num object:message];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"onReceiverFriendSend" object:friendList.userAccount];
            //对方已接受
            [[NSNotificationCenter defaultCenter] postNotificationName:@"onReceiverFriendSendNewVC_DF_Accepted" object:friendList];
            //添加好友，个人中心页更新按钮名字
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addFriendTitleContactInfo" object:nil];
        }
    }else{
        NSDictionary *friendPBSIMDic = userData;
        NSDictionary *friendDic = [friendPBSIMDic objectForKey:@"friendPBSIM"];
        NSString *syncDeviceName = [friendPBSIMDic objectForKey:@"syncDeviceName"];
        if([friendDic hasValueForKey:@"addFriend"]){
            id addFriendDic = [friendDic objectForKey:@"addFriend"];
            if(![addFriendDic isKindOfClass:[NSDictionary class]]){
                return NO;
            }
            HXAddnewFriendList *friendList = [[HXAddnewFriendList alloc] init];
            friendList.userAccount = [addFriendDic objectForKey:@"friendAccount"];
            friendList.describeMessage = [addFriendDic objectForKey:@"msg"];
            friendList.inviteStatus = [addFriendDic intValueForKey:@"agreeStatus"];
            friendList.friendType = 1;
            friendList.userId = @"";
            switch (friendList.inviteStatus) {
                case kAddAsNewFriends:{
                    if(syncDeviceName &&
                       ![syncDeviceName isEqualToString:@"iPhone"] &&
                       [message.from isEqualToString:[Common sharedInstance].getAccount]){
                        if(message.messageBody.messageBodyType == MessageBodyType_Command){
//                            ECTextMessageBody *textBody = [[ECTextMessageBody alloc] initWithText:languageStringWithKey(@"你们已经是好友了, 现在可以开始聊天了")];
//                            message.messageBody = textBody;

                            NSString *inviteText = languageStringWithKey(@"我通过了你的好友验证请求,现在我们可以开始聊天了");
                            ECTextMessageBody *textBody = [[ECTextMessageBody alloc] initWithText:inviteText];
                            message.messageBody = textBody;//从数据库查询的时候把cmd消息过滤了
//                            return YES;
                        }else{
                            //兼容之前的好友请求
                            ECTextMessageBody *textBody = (ECTextMessageBody *)message.messageBody;
                            textBody.text = languageStringWithKey(@"你们已经是好友了, 现在可以开始聊天了");
                            message.messageState = ECMessageState_SendSuccess;
                        }
//                        NSDictionary *userParas = [NSDictionary dictionaryWithObjectsAndKeys:receiverFriendInvite,receiverFriendInvite, nil];
//                        NSString *userdataStr = [NSString stringWithFormat:@"%@",[userParas coverString]];
//                        message.userData = userdataStr;

                        [[KitMsgData sharedInstance] addNewMessage:message andSessionId:message.sessionId];
                        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:message];
                        //修改下  由于是PC的同步消息 好友ID改成message.to
                        friendList.userAccount = message.to;
                        NSInteger count = [HXInviteCountData getCurrentInviteCount];
                        count --;
                        count = count<=0?0:count;
                        [HXInviteCountData insertInviteCount:count withAccount:friendList.userAccount];
                        //更新数据库
                        [HXAddnewFriendList updateFrienInviteStatus:friendList.userAccount inviteFriendType:kAddAsNewFriends];
                        //更新好友列表
                        RXMyFriendList *newfriendList = [[RXMyFriendList alloc] init];
                        newfriendList.account = friendList.userAccount;
                        [RXMyFriendList insertOneFriend:newfriendList];
                        

                        
                        //邀请数量的通知
                        [[NSNotificationCenter defaultCenter] postNotificationName:KMyFriendInviteMessList_InviteId object:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"onReceiverFriendSend" object:friendList.userAccount];
                        //添加好友，个人中心页更新按钮名字
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"addFriendTitleContactInfo" object:nil];
                        // 对方已接受
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"onReceiverFriendSendNewVC_DF_Accepted" object:friendList];
                    }else{
                        //显示对方通过你的好友验证 直接入库 //兼容老版本
                        NSString *inviteText = languageStringWithKey(@"我通过了你的好友验证请求,现在我们可以开始聊天了");
                        if(message.messageBody.messageBodyType == MessageBodyType_Command){
                            ECCmdMessageBody *ccmdMess = (ECCmdMessageBody *) message.messageBody;
                            ccmdMess.text = inviteText;
                            ECTextMessageBody *textBody = [[ECTextMessageBody alloc] initWithText:inviteText];
                            message.messageBody = textBody;
                        }
                        [[KitMsgData sharedInstance] addNewMessage:message andSessionId:[AppModel sharedInstance].sessionId];
                        //其他操作 当有邀请记录的时候 又去邀请别人
                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                            BOOL isexist = [HXAddnewFriendList isExistLocationNewInvite:friendList.userAccount InviteFriendStatus:kNeedToPassVerification];
                            if(isexist){
                                [HXAddnewFriendList updateFrienInviteStatus:friendList.userAccount inviteFriendType:kAddAsNewFriends];
                            }
                        });
                    }
                    //添加好友成功回执
                    RXMyFriendList *friendmodel = [[RXMyFriendList alloc] init];
                    friendmodel.account = friendList.userAccount;
                    [RXMyFriendList insertOneFriend:friendmodel];
                    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:message];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_update_session_im_message_num object:message];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"onReceiverFriendSend" object:friendList.userAccount];
                    //对方已接受
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"onReceiverFriendSendNewVC_DF_Accepted" object:friendList];
                    //添加好友，个人中心页更新按钮名字
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"addFriendTitleContactInfo" object:nil];
                }
                    break;
                case kNeedToPassVerification:{
                    if (friendList.inviteStatus == 2 &&
                        [message.from isEqualToString:[[Common sharedInstance] getAccount]]) {
                        return YES;
                    }
                    //待验证
                    if(friendList){
                        BOOL isexist = [HXAddnewFriendList isExistLocationNewInvite:friendList.userAccount InviteFriendStatus:kNeedToPassVerification];
                        if(isexist){
                            //消息入库
                            [HXAddnewFriendList insertImMessage:friendList];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"onReceiverFriendSend" object:friendList.userAccount];
                            return YES;
                        }else{
                            //判断本地是否存在 存在则不做处理
                            BOOL isExistFriend =[RXMyFriendList isMyFriend:friendList.userAccount];
                            if(isExistFriend){
                                return YES;
                            }
                        }
                        //消息入库
                        [HXAddnewFriendList insertImMessage:friendList];
                        //wwl 目前逻辑insertImMessage时会判断本地是否有这个人的邀请数据，邀请多次只会更新本地数据，一个人的邀请信息只会有一条，故存储消息数时存1即可
                        [HXInviteCountData insertInviteCount:1 withAccount:friendList.userAccount];
                        [[NSNotificationCenter defaultCenter] postNotificationName:KMyFriendInviteMessList_InviteId object:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"onReceiverFriendSend" object:friendList.userAccount];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"onReceiverFriendSendNewVC" object:nil];// 刷新新的朋友界面
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"addFriendTitleContactInfo" object:nil];//添加好友，个人中心页更新按钮名字
                    }
                }
                    break;
                case kInviteFriendsDelete:{
                    //删除好友
                    if(friendList){
                        [RXMyFriendList deleteOneMyFriendData:friendList.userAccount];
                    }
                }
                    break;
                case kIMmessageSynchronize:{
                    //消息同步
                }
                    break;
                default:
                    break;
            }
        }else if ([friendDic hasValueForKey:@"delFriends"]){
            if(syncDeviceName &&
               [syncDeviceName isEqualToString:@"iPhone"] &&
               [message.from isEqualToString:[[Common sharedInstance] getAccount]]){
                return YES;
            }
            //消息同步
            if(syncDeviceName &&
               ![syncDeviceName isEqualToString:@"iPhone"] &&
               ![syncDeviceName isEqualToString:@"Android"] &&
               [message.from isEqualToString:[Common sharedInstance].getAccount]){
                //同步消息删除不能取userData里面的数据 这是发给另外一端的 取to值
                [RXMyFriendList deleteArrayFriend:@[message.to]];
                [HXAddnewFriendList deleteArrayFriendMessage:@[message.to]];
            }else{//对方删除
                NSDictionary *delFriendDic = [friendDic objectForKey:@"delFriends"];
                id delFriendData = [delFriendDic objectForKey:@"friendAccounts"];
                if([delFriendData isKindOfClass:[NSArray class]]){
                    NSArray *deleFriendArray = (NSArray *)delFriendData;
                    [RXMyFriendList deleteArrayFriend:deleFriendArray];
                    [HXAddnewFriendList deleteArrayFriendMessage:deleFriendArray];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteFriendSend" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"onReceiverFriendSendNewVC" object:nil];// 刷新新的朋友界面
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addFriendTitleContactInfo" object:nil];//删除好友，个人中心页更新按钮名字
        }
    }
    return YES;
}
///myAppStore 通知角标数据
- (BOOL)onReceiveMyAppStoreMessage:(ECMessage *)message{
    if (![message.userData hasPrefix:[NSString stringWithFormat:@"%@,",KMyAppStore_CustomType]]) {
        return NO;
    }
    NSRange ran = [message.userData rangeOfString:[NSString stringWithFormat:@"%@,",KMyAppStore_CustomType]];
    NSInteger index = ran.location + ran.length;
    NSString *appStr = [message.userData substringFromIndex:index];
    if(appStr){
        NSString *userDataCove = [appStr base64DecodingString];
        NSDictionary *appDic = [NSJSONSerialization JSONObjectWithData:[userDataCove dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        NSString *appId = appDic[@"appId"];
        if([[AppModel sharedInstance].sessionId isEqualToString:appId]) {
            return YES;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kitMyAppStoreUnreadUpdate" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kitWorkAppStoreUnreadUpdate" object:nil];
    }
    return YES;
}

///自己发送的阅后即焚
- (BOOL)onReceiveBurnMessage:(ECMessage *)message userData:(NSDictionary *)userData{
    if (message.isBurnWithMessage &&
        [message.from isEqualToString:[Common sharedInstance].getAccount]) {//自己发的阅后即焚
        return YES;
    }
    return NO;
}

///白板控制消息接收
- (BOOL)onReceiveBoardNoticeWithMessage:(ECMessage *)message boardValue:(NSString *)boardValue userData:(NSDictionary *)userData{
    if (message.isBoardMessage && [userData hasValueForKey:SMSGTYPE]) {//白板消息
        //0.显示白板邀请消息，可以点击加入 1.不显示消息直接弹出加入房间模式 2.隐藏白板房间模式
        NSString *wbssType = userData[@"wbssType"];
        if ([wbssType isEqualToString:@"0"]) {//open board PTP
            if (![message.from isEqualToString:[self getMyAccount]]){
                if (message.messageBody.messageBodyType == MessageBodyType_Command) {
                    ECCmdMessageBody *cmdBody = (ECCmdMessageBody *)message.messageBody;
                    message.messageBody = [[ECTextMessageBody alloc] initWithText:cmdBody.text];
                }
                return NO;
            }else {
                return YES;
            }
        }else if ([wbssType isEqualToString:@"1"]){//open board
            if (![message.from isEqualToString:[self getMyAccount]]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onPTPBoardNotice object:userData];
            }
            return YES;
        }else if ([wbssType isEqualToString:@"2"]){//close board
            if (![message.from isEqualToString:[self getMyAccount]]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onCloseBoardNotice object:userData];
                [[AppModel sharedInstance] runModuleFunc:@"Board" :@"closeB:" :@[[NSNumber numberWithBool:NO]]];

            }
            return YES;
        }else if ([wbssType isEqualToString:@"3"]){//open board VIDEO
            if (![message.from isEqualToString:[self getMyAccount]]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onVideoBoardNotice object:userData];
            }
            return YES;
        }
    }

    if([boardValue isEqualToString:@"WBSS_SHOWMSG"]) {
        //open board
        if (![message.from isEqualToString:[self getMyAccount]]){
            if (message.messageBody.messageBodyType == MessageBodyType_Command) {
                ECCmdMessageBody *cmdBody = (ECCmdMessageBody *)message.messageBody;
                message.messageBody = [[ECTextMessageBody alloc] initWithText:cmdBody.text];
            }
            return NO;
        }else {
            return YES;
        }
    }else if([boardValue isEqualToString:@"WBSS_SENDMSG"]) {
        //open board PTP
        if (![message.from isEqualToString:[self getMyAccount]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onPTPBoardNotice object:userData];
        }
        return YES;
    }else if([boardValue isEqualToString:@"WBSS_HIDE"]) {
        //close board
        if (![message.from isEqualToString:[self getMyAccount]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onCloseBoardNotice object:userData];
            [[AppModel sharedInstance] runModuleFunc:@"Board" :@"closeB:" :@[[NSNumber numberWithBool:NO]]];

        }
        return YES;
    }else if([boardValue isEqualToString:@"WBSS_VOICE"]) {
        //open board VIDEO
        if (![message.from isEqualToString:[self getMyAccount]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onVideoBoardNotice object:userData];
        }
        return YES;
    }
    return NO;
}
///文本消息处理 红包消息群非好友，呼叫失败被叫端不处理
- (BOOL)textMsgHandle:(ECMessage *)message{
    //文本消息
    if (message.messageBody.messageBodyType != MessageBodyType_Text) {
        return NO;
    }
    ECTextMessageBody *textmsg = (ECTextMessageBody *)message.messageBody;
    textmsg.text = [[EmojiConvertor sharedInstance] convertEmojiSoftbankToUnicode:textmsg.text];
    if (message.userData == nil || [message.userData isEqualToString:@""]) {
        return NO;
    }
    NSDictionary *dict = [self redPacketDic:message];
    
    if ([Common sharedInstance].componentDelegate && [[Common sharedInstance].componentDelegate respondsToSelector:@selector(isRedpacketWithData:)]) {
        BOOL isRedpacket = [[Common sharedInstance].componentDelegate isRedpacketWithData:message.userData];
        BOOL isTranser = [[Common sharedInstance].componentDelegate isTransferWithData:message.userData];
        //判断是不是红包消息
        if (!IsHengFengTarget && isRedpacket == YES && message.isGroup) {
            //不需要入库
            return YES;
        }
        if (isTranser == YES) {
            ECTextMessageBody *messageBody = (ECTextMessageBody *)message.messageBody;
            messageBody.text = languageStringWithKey(@"[转账]已收到对方转账");
        }
    }

    if (message.isVoipRecordsMessage && ![message.from isEqualToString:[[Common sharedInstance]getAccount]]) {//音视频消息,被叫方处理
        NSInteger status = [dict[@"status"] integerValue];
        switch (status) {
            case 106://呼叫失败 被叫端不处理
                return YES;
                break;
            case 105://呼叫超时
                textmsg.text = languageStringWithKey(@"未接通");
                break;
            case 104://对方无应答
                textmsg.text = languageStringWithKey(@"对方已取消");
                break;
            case 103://对方已拒绝
                textmsg.text = languageStringWithKey(@"已拒绝");
                break;
            case 102://对方忙线中
                textmsg.text = languageStringWithKey(@"忙线未接听");
                break;
            case 101://对方不在线
                textmsg.text = languageStringWithKey(@"未接通");
                break;
            case 100://已取消
                textmsg.text = languageStringWithKey(@"对方已取消");
                break;
            case 200://通话时长
                textmsg.text = [NSString stringWithFormat:@"%@  %@", languageStringWithKey(@"通话时长"), [NSDate calculateTime:dict[@"startTime"] endTime:dict[@"endTime"]]];
                break;
            default:
                break;
        }
    }
    return NO;
}
///未下载文件处理
- (void)undownloadFileMessageHandle:(ECMessage *)message{
    NSDictionary *userData = message.userDataToDictionary;
    BOOL isNewJson = [userData hasValueForKey:SMSGTYPE];

    if (isNewJson && [userData[SMSGTYPE] isEqualToString:@"4"]) {//H5端转发的图片
        ECImageMessageBody *imageMessageBody = [[ECImageMessageBody alloc] init];
        NSString *fileUrl = [userData objectForKey:@"fileUrl"];
        NSString *fileName = [userData objectForKey:@"fileName"];
        NSString *fileLength = [userData objectForKey:@"length"];
        NSString *originFileLength = userData[@"originFileLen"];

        imageMessageBody.displayName = fileName;
        imageMessageBody.remotePath = fileUrl;
        imageMessageBody.fileLength = [fileLength longLongValue];
        imageMessageBody.originFileLength = [originFileLength longLongValue];
        message.messageBody = imageMessageBody;
        return;
    }
    NSString *fileUrl = [userData objectForKey:@"fileUrl"];
    NSString *fileLength = [userData objectForKey:@"length"];
    NSString *originFileLength = isNewJson ? userData[@"originLen"]:userData[@"originFileLen"];
    NSString *fileName = [userData objectForKey:@"fileName"];

    ECFileMessageBody *fileMessageBody = [[ECFileMessageBody alloc] init];
    fileMessageBody.displayName = fileName;
    fileMessageBody.remotePath = fileUrl;
    fileMessageBody.fileLength = [fileLength longLongValue];
    fileMessageBody.originFileLength = [originFileLength longLongValue];
    fileMessageBody.mediaDownloadStatus = ECMediaUnDownload;
    message.messageBody = fileMessageBody;
}


///大通讯录相关
- (void)onReceiveBigAddress:(ECMessage *)message{
    if (!isLargeAddressBookModel) {
        return;
    }
    ///取message的userdata
    NSDictionary *dic = [MessageTypeManager getCusDicWithUserData:message.userData];
    
    //这里要处理
    if (![dic isKindOfClass:[NSDictionary class]]){return;};
    
    NSString *account = dic[Table_User_account];
    NSString *member_name = dic[Table_User_member_name];
    NSString *headImageUrl = dic[Table_User_avatar];
    NSString *md5 = dic[Table_User_urlmd5];
    if (account == nil || member_name == nil || headImageUrl == nil || md5 == nil) {
        return;
    }
    ///人员信息入库
    [[AppModel sharedInstance] runModuleFunc:@"KitCompanyAddress" :@"insertDataWhenBigAddress:" :@[dic] hasReturn:NO];
}


//收到pc设备安全登录消息 add by keven
- (BOOL)onReceiveDeviceSafeLoginForPC:(ECMessage *)message{
    if (!isOpenDeviceSafe) return NO;
    DDLogInfo(@"----收到onReceiveDeviceSafeLoginForPC");
    
    //弹出确认pc安全登录页
    if (message.messageBody.messageBodyType == MessageBodyType_Text) {
          ECTextMessageBody *messageBody = (ECTextMessageBody *)message.messageBody;
        NSString * msgContent = messageBody.text;
        DDLogInfo(@"---------msgContent:%@",msgContent);
        if (KCNSSTRING_ISEMPTY(msgContent) || ![msgContent containsString:@"confirmLogin"]) {
            return NO;
        }
        NSDictionary * jsonDic = [NSJSONSerialization JSONObjectWithData:[msgContent dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        if ([jsonDic[@"msg"] isEqualToString:@"confirmLogin"]) {
             UIViewController *VC = [[AppModel sharedInstance] runModuleFunc:@"UserCenter" :@"getConfirmLoginForPCWithData:" :@[jsonDic]];
            RXBaseNavgationController * nav = [[RXBaseNavgationController alloc]initWithRootViewController:VC];
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            [rootViewController presentViewController:nav animated:YES completion:nil];
        }
        return YES;
    }
    return NO;
}


/**
 后台删除人员推送处理

 @param message 消息
 */
- (void)handleDeleteAccountMessage:(ECMessage *)message {
    NSDictionary *userdata = [message userDataToDictionary];
    NSArray *deleteArray = userdata[@"list"];
    for (NSString *account in deleteArray) {
        if ([account isEqualToString:Common.sharedInstance.getAccount]) {//当前登录账号被删除
            if ([self.appModelDelegate  respondsToSelector:@selector(responseAccountFreezedKickedOff)]){
                [self.appModelDelegate responseAccountFreezedKickedOff];
            }
            return;
        }
        KitCompanyAddress *address = [KitCompanyAddress getCompanyAddressInfoDataWithAccount:account];
        if (address) {
            [KitCompanyAddress updateCompanyUserStatus:@"3" withAccount:account];
        }else {
            [[AppModel sharedInstance] runModuleFunc:@"Common" :@"getVOIPUserInfoWithAccount:" :@[account]];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BM_DeleteAccount_Notification" object:deleteArray];
}

#pragma mark - 日志相关
- (void)aboutLog:(NSDictionary *)userData{
    NSString *cmdType = nil;
    if ([userData hasValueForKey:@"customtype"]) {
        cmdType = [userData objectForKey:@"customtype"];
    }
    if ([cmdType isEqualToString:@"601"]) {
        NSString *strCmd = [userData objectForKey:@"cmd"];
        if ([strCmd hasPrefix:@"rongxin://debuglog"]) {
            if ([strCmd isEqualToString:@"rongxin://debuglog"]) {//取当天日志
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
                [self zipLogUpdate:dateStr];
            }else{
                if ([strCmd hasPrefix:@"rongxin://debuglog--"]){
                    //取指定日期的日志
                    NSArray *array = [strCmd componentsSeparatedByString:@"--"];
                    if (array[1] && [array[1] length]>0) {
                        [self zipLogUpdate:array[1]];
                    }else{
                        DDLogError(@"zipLogsUpload cmd err %@",strCmd);
                    }
                }
            }
        }
    } else if ([cmdType isEqualToString:@"602"]) {
        NSString *strLogLevel = [userData objectForKey:@"setLogLevel"];
        if ([strLogLevel length] > 0) {
            int logLevel = strLogLevel.intValue;
            switch (logLevel) {
                case 0:{
                    [DDDynamicLogLevel ddSetLogLevel:DDLogLevelOff];
                }
                    break;
                case 1:{
                    [DDDynamicLogLevel ddSetLogLevel:DDLogLevelError];
                }
                    break;
                case 2:{
                    [DDDynamicLogLevel ddSetLogLevel:DDLogLevelWarning];
                }
                    break;
                case 3:{
                    [DDDynamicLogLevel ddSetLogLevel:DDLogLevelInfo];
                }
                    break;
                case 4:{
                    [DDDynamicLogLevel ddSetLogLevel:DDLogLevelDebug];
                }
                    break;
                case 5:{
                    [DDDynamicLogLevel ddSetLogLevel:DDLogLevelVerbose];
                }
                    break;
                case 6:{
                    [DDDynamicLogLevel ddSetLogLevel:DDLogLevelAll];
                }
                    break;
                default:
                    break;
            }
        }
        NSString *strLog = [userData objectForKey:@"sdkLog"];
        if ([strLog length] > 0) {
            int sdkLevel = [strLog intValue];
            if(sdkLevel > 0){
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ecdevice.detail.sdk.log" object:[NSNumber numberWithInt:sdkLevel]];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ecdevice.detail.sdk.log" object:@0];
            }
        }
    }
}
- (void)zipLogUpdate:(NSString *)date{
    if (!date) {
        return;
    }
    @try {
        NSFileManager *myFileManager = [NSFileManager defaultManager];
        NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *zipPath = [NSString stringWithFormat:@"%@/logs.zip",cachesDirectory];
        [myFileManager removeItemAtPath:zipPath error:nil];

        NSMutableArray *filePaths = [[NSMutableArray alloc] init];
        NSString *password = nil;
        NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

        //遍历日志文件
        NSString *appLogFilePath = [documentDirectory stringByAppendingPathComponent:@"/Logs"];
        NSDirectoryEnumerator *myDirectoryEnumerator = [myFileManager enumeratorAtPath:appLogFilePath];
        NSString* tmpPath = nil;
        while((tmpPath = [myDirectoryEnumerator nextObject]) != nil) {
            DDLogError(@"%@",tmpPath);
            NSString* appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
            NSString* strLogNamePre1 = [NSString stringWithFormat:@"%@ %@",appName,date];
            NSString* strLogNamePre2 = [NSString stringWithFormat:@"%@/%@ %@",[self getMyAccount], appName,date];
            if ([tmpPath hasPrefix:strLogNamePre1] ||
                [tmpPath hasPrefix:strLogNamePre2]){
                NSString *file = [appLogFilePath stringByAppendingPathComponent:tmpPath];
                if ([myFileManager fileExistsAtPath:file]) {
                    [filePaths addObject:file];
                }
            }
        }
        //sdk日志
        NSString *sdkFileName = [NSString stringWithFormat:@"sdk_%@_v5.3.2r.log",date];
        NSString *sdkFilePath = [documentDirectory stringByAppendingPathComponent:sdkFileName];
        if ([myFileManager fileExistsAtPath:sdkFilePath])
            [filePaths addObject:sdkFilePath];
        BOOL success = [SSZipArchive createZipFileAtPath:zipPath withFilesAtPaths:filePaths withPassword:password.length > 0 ? password : nil];
        if (success) {
            NSData *date = [NSData dataWithContentsOfFile:zipPath];
            DDLogError(@"zipLogUpdate success");
            // 日志上传
            [HYTApiClient uploadPhoWithFileName:zipPath.lastPathComponent photo:nil withImageData:nil fileData:date fileType:@"zip" didFinishLoadedMK:^(NSDictionary *json, NSString *path) {
                //上传成功删除文件
                for (NSString* strFlie in filePaths) {
                    [myFileManager removeItemAtPath:strFlie error:nil];
                }
                DDLogError(@"upload logs finish");
            } didFailLoadedMK:^(NSError *error, NSString *path) {
                DDLogError(@"upload logs fail");
            }];
        }
    } @catch (NSException *exception) {

    } @finally {

    }
}



#pragma mark - 命令相关
- (void)aboutSetting:(ECMessage *)message{
    if(message.messageBody.messageBodyType != MessageBodyType_Text){
        return;
    }
    ECTextMessageBody *messageBody = (ECTextMessageBody *)message.messageBody;
    if ([messageBody.text isEqualToString:@"superDebugMode"]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"superDebugMode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        exit(0);
    }else if ([messageBody.text isEqualToString:@"superDebugModeOFF"]){
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"superDebugMode"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        exit(0);
    }else if ([messageBody.text isEqualToString:@"sendAppLogFilesNow"]){
        NSString* documentDirectory = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingFormat:@"/Caches"];
        NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
        [dateformat setDateFormat:@"yyyy-MM-dd"];
        NSString *fileName = [NSString stringWithFormat:@"LOG-%@.txt",[dateformat stringFromDate:[NSDate date]]];
        NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
        if ([[NSFileManager defaultManager]fileExistsAtPath:logFilePath]){
            ECFileMessageBody * fileMsgBody = [[ECFileMessageBody alloc] initWithFile:logFilePath displayName:[logFilePath lastPathComponent]];
            ECMessage *fileMsg = [[ECMessage alloc] initWithReceiver:message.from body:fileMsgBody];
            [[ECDevice sharedInstance].messageManager sendMessage:fileMsg progress:nil completion:^(ECError *error, ECMessage *message) {

            }];
        }
        fileName = [NSString stringWithFormat:@"config.data"];
        logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
        if ([[NSFileManager defaultManager]fileExistsAtPath:logFilePath]){
            ECFileMessageBody * fileMsgBody = [[ECFileMessageBody alloc] initWithFile:logFilePath displayName:[logFilePath lastPathComponent]];
            ECMessage* fileMsg = [[ECMessage alloc] initWithReceiver:message.from body:fileMsgBody];
            [[ECDevice sharedInstance].messageManager sendMessage:fileMsg progress:nil completion:^(ECError *error, ECMessage *message) {

            }];
        }
        return;
    }else if ([messageBody.text isEqualToString:@"sendSDKLogFilesNow"]){
        NSString* documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *fileName = @"sdk2016_v5.3.1r.log";
        NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];

        if ([[NSFileManager defaultManager] fileExistsAtPath:logFilePath]){
            ECFileMessageBody *fileMsgBody = [[ECFileMessageBody alloc] initWithFile:logFilePath displayName:[logFilePath lastPathComponent]];
            ECMessage* fileMsg = [[ECMessage alloc] initWithReceiver:message.from body:fileMsgBody];
            [[ECDevice sharedInstance].messageManager sendMessage:fileMsg progress:nil completion:^(ECError *error, ECMessage *message) {

            }];
        }else{
            NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
            [dateformat setDateFormat:@"yyyy-MM-dd"];
            fileName = [NSString stringWithFormat:@"sdk_%@_v5.4.14r.log",[dateformat stringFromDate:[NSDate date]]];
            logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:logFilePath]){
                ECFileMessageBody *fileMsgBody = [[ECFileMessageBody alloc] initWithFile:logFilePath displayName:[logFilePath lastPathComponent]];
                ECMessage* fileMsg = [[ECMessage alloc] initWithReceiver:message.from body:fileMsgBody];
                [[ECDevice sharedInstance].messageManager sendMessage:fileMsg progress:nil completion:^(ECError *error, ECMessage *message) {

                }];
            }
        }
        fileName = [NSString stringWithFormat:@"CCPSDKBundle.bundleServerAddr.xml"];
        logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:logFilePath]){
            ECFileMessageBody * fileMsgBody = [[ECFileMessageBody alloc] initWithFile:logFilePath displayName:[logFilePath lastPathComponent]];
            ECMessage* fileMsg = [[ECMessage alloc] initWithReceiver:message.from body:fileMsgBody];
            [[ECDevice sharedInstance].messageManager sendMessage:fileMsg progress:nil completion:^(ECError *error, ECMessage *message) {

            }];
        }
    }
}
//新增聊天室内容
- (void)onReceiveLiveChatRoomMessage:(ECMessage *)message {
    if (message.from.length==0) return;
    if (message.timestamp) {
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval tmp =[date timeIntervalSince1970]*1000;
        message.timestamp = [NSString stringWithFormat:@"%lld", (long long)tmp];}
    [[NSNotificationCenter defaultCenter] postNotificationName:
     @"kNOTIFICATION_onLiveChatRoomMesssageChanged" object:message];
}
    
        /**
         收到聊天室的通知消息
         @param msg 通知消息
         */
- (void)onReceiveLiveChatRoomNoticeMessage:(ECLiveChatRoomNoticeMessage *)msg{
    [[NSNotificationCenter defaultCenter] postNotificationName:
     @"KNOTIFICATION_onLiveChatRoomNotify"object:msg];
}
    //通过ECLiveChatRoomNoticeMessage 的type字段区分不不同的通知消息体类型
- (void)onReceiveFriendsPublishPresence:(NSArray<ECUserState *> *)friends{
    if (friends == nil ||friends.count == 0) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KNOTIFICATION_onReceiveFriendsPublishPresence" object:friends];
}
@end
