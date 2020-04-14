//
//  AppModel.h
//  AppModel
//
//  Created by wangming on 16/7/25.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppData.h"
#import "AppModelDelegate.h"
#import <PushKit/PushKit.h>
#import "LanguageTools.h"

//换肤相关的宏
#define ThemeImage(name)        [[AppModel sharedInstance] imageWithName:name]  //换图片
#define ThemeColor              [[AppModel sharedInstance] themeColor]          //换颜色
#define ThemeColorImage(image,color) [[AppModel sharedInstance] getThemeColorImage:(UIImage *)image withColor:(UIColor *)color]

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

#define ThemeDefaultHead(size,name,account) [[AppModel sharedInstance] drawDefaultHeadImageWithHeadSize:size andNameString:name andAccount:account]
#define languageStringWithKey(key) [[LanguageTools sharedInstance] getStringForKey:key] //切换语言

typedef void(^completion)(NSArray *obj);
@interface AppModel : NSObject<UIApplicationDelegate, PKPushRegistryDelegate>

@property (nonatomic,strong) AppData* appData;
@property (nonatomic,strong) id owner;
@property (nonatomic,assign) BOOL loginstate;
@property (nonatomic, copy) NSString *sessionId; //用于更新会话列表
@property (nonatomic ,assign) CGFloat theViewDown; //有电话等，屏幕下压20
@property (nonatomic ,assign) BOOL isInConf; //是否在会议中
@property (nonatomic, assign) BOOL isInVoip; // 是否在点对点通话中
@property (nonatomic ,assign) BOOL isHaveGetTopList; //是否获取了在置顶列表
@property (nonatomic, strong) NSMutableArray *interphoneArray; // 接收到的实时对讲消息集合

@property (nonatomic,weak) id<AppModelDelegate>appModelDelegate;

@property (nonatomic,assign) NSInteger invateConType;// 邀请加入会议的方式 0 为ECAccountType_AppNumber(应用账号) 1为落地电话ECAccountType_PhoneNumber  2为快速邀请(手动输入手机号)

//记录用户选择的字体大小
@property (nonatomic, assign) CGFloat selectedThemeFontSize;
@property (nonatomic, assign) CGFloat themeFontSizeLarge;
@property (nonatomic,strong) NSString *muteState;//静音状态，1 静音，2 没静音
@property (nonatomic ,assign) BOOL isPCLogin; //是否在pc或者MAC登陆
@property (strong,nonatomic) completion YHCcompletion;// 有会回调
//SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(AppModel);

+ (AppModel *)sharedInstance;


//加载serveradd配置  插件使用
- (void)initServerAddr;

/**
 登录 SDK

 @param loginInfo 登录时传递进来的用户信息   包含以下参数：
 @param @"account" 账号
 @param @"mobile" 手机号
 @param @"member_name" 姓名
 @param @"App_AppKey" appKey
 @param @"App_Token" appToken
 @param @"mode" 登录模式
 
 @{
     @"App_AppKey" : @"8a9aea976091926b0160925dxxxx",
     @"App_Token" : @"aafb5c1e3d1f40fd9c84fa655xxxx",
     @"account" : @"xxx",
     @"member_name" : @"XX",
     @"mobile" : @"130XXXX9358",
     @"mode" : @2
 }
 @param LoginCompletion 登录回调
 */
-(void)loginSDK:(NSDictionary*)loginInfo :(void(^)(NSError* error)) LoginCompletion;

// 结束会议之后开始VOIP通话
-(void)afterhasCloseConfAndAcceptVoipCall;

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
//收到个人助手消息处理
-(void)getPersonalAssistant;
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
 @brief 设置角标数
 @param badgeNumber 角标数字
 */
-(void)setAppleBadgeNumber:(NSInteger)badgeNumber;

/**
 @brief 获取应用未读信息数
 */
- (NSInteger)getAppleBadgeNumberCount;

/**
 @brief 是否置顶会话
 @param seesionId 会话id
 @param isTop 0 取消置顶 1 置顶
 */
-(void)setSession:(NSString*)seesionId IsTop:(BOOL)isTop completion:(void(^)(ECError *error, NSString *seesionId))completion;

#pragma mark - 换肤相关
/**
 @brief 根据用户的选择更换字体的大小
 @param size  大0 中1 小2
 @param isTheme  YES是主题文字 NO是系统文字
 */
- (UIFont *)themeFontWithSize:(NSInteger)size isTheme:(BOOL)isTheme;

/**
 @brief 根据用户的选择更换颜色
 @param themeColor  颜色
 */
- (UIColor *)themNavigationBarTitleColor:(NSString *)themeColor;

/**
 @brief 根据用户的选择更换图片资源
 @param name  图片名字
 */
- (UIImage *)imageWithName:(NSString *)name;

/**
 @brief 根据用户的选择更换主题颜色
 */
- (UIColor *)themeColor;

/**
 @brief 用户默认头像
 */
- (UIImage *)drawDefaultHeadImageWithHeadSize:(CGSize)size andNameString:(NSString *)name andNameString:(NSString *)account;



/**
 * 初始化消息列表
 * yuxp
 */
- (void)initSessionList;


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
 @brief 设置是否获取全部离线消息
 @param enable 是否全部
 */
- (void)setReceiveAllOfflineMsgEnabled:(BOOL)enable;

/**
 @brief 获取置顶会话列表
 @param completion 执行结果回调block（注：topContactLists为会话seesionId）
 */
- (void)getTopSessionLists:(void(^)(ECError *error, NSArray *topContactLists))completion;

/**
 @brief 获得媒体流冗余当前设置值。
 */
-(NSInteger)getAudioCodecRed;


/** zwh
 @brief pushkit 注册
 */
- (void)PushKitRegistry;

@end
